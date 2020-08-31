//
//  ZLEditVideoViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/30.
//

import UIKit
import Photos

public class ZLEditVideoViewController: UIViewController {

    static let frameImageSize = CGSize(width: 50.0 * 2.0 / 3.0, height: 50.0)
    
    let asset: PHAsset
    
    var avAsset: AVAsset?
    
    var cancelBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var timer: Timer?
    
    var playerLayer: AVPlayerLayer!
    
    var collectionView: UICollectionView!
    
    var frameImageBorderView: ZLEditVideoFrameImageBorderView!
    
    var leftSideView: UIImageView!
    
    var rightSideView: UIImageView!
    
    var leftSidePan: UIPanGestureRecognizer!
    
    var rightSidePan: UIPanGestureRecognizer!
    
    var indicator: UIView!
    
    var measureCount = 0
    
    let interval: TimeInterval = TimeInterval(ZLPhotoConfiguration.default().maxEditVideoTime) / 10
    
    var requestFrameImageQueue: OperationQueue!
    
    var avAssetRequestID = PHInvalidImageRequestID
    
    var videoRequestID = PHInvalidImageRequestID
    
    var frameImageCache: [IndexPath: UIImage] = [:]
    
    var shouldLayout = true
    
    lazy var generator: AVAssetImageGenerator? = {
        if let avAsset = self.avAsset {
            let g = AVAssetImageGenerator(asset: avAsset)
            g.maximumSize = CGSize(width: ZLEditVideoViewController.frameImageSize.width * 2, height: ZLEditVideoViewController.frameImageSize.height * 2)
            g.appliesPreferredTrackTransform = true
            g.requestedTimeToleranceBefore = .zero
            g.requestedTimeToleranceAfter = .zero
            g.apertureMode = .productionAperture
            return g
        }
        return nil
    }()
    
    public var editFinishBlock: ( (PHAsset) -> Void )?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        debugPrint("ZLEditVideoViewController deinit")
        self.cleanTimer()
        if self.avAssetRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.avAssetRequestID)
        }
        if self.videoRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.videoRequestID)
        }
    }
    
    public init(asset: PHAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        self.requestFrameImageQueue = OperationQueue()
        self.requestFrameImageQueue.maxConcurrentOperationCount = 5
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.analysisAssetImages()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard self.shouldLayout else {
            return
        }
        self.shouldLayout = false
        
        debugPrint("edit video layout subviews")
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        let btnH = ZLThumbnailViewController.Layout.bottomToolBtnH
        let bottomBtnAndColSpacing: CGFloat = 20
        let playerLayerY = insets.top + 20
        let diffBottom = btnH + ZLEditVideoViewController.frameImageSize.height + bottomBtnAndColSpacing + insets.bottom + 30
        
        self.playerLayer.frame = CGRect(x: 15, y: insets.top + 20, width: self.view.bounds.width - 30, height: self.view.bounds.height - playerLayerY - diffBottom)
        
        let cancelBtnW = localLanguageTextValue(.previewCancel).boundingRect(font: ZLThumbnailViewController.Layout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: btnH)).width
        self.cancelBtn.frame = CGRect(x: 20, y: self.view.bounds.height - insets.bottom - btnH, width: cancelBtnW, height: btnH)
        let doneBtnW = localLanguageTextValue(.done).boundingRect(font: ZLThumbnailViewController.Layout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: btnH)).width + 20
        self.doneBtn.frame = CGRect(x: self.view.bounds.width-doneBtnW-20, y: self.view.bounds.height - insets.bottom - btnH, width: doneBtnW, height: btnH)
        
        self.collectionView.frame = CGRect(x: 0, y: self.doneBtn.frame.minY - bottomBtnAndColSpacing - ZLEditVideoViewController.frameImageSize.height, width: self.view.bounds.width, height: ZLEditVideoViewController.frameImageSize.height)
        
        let frameViewW = ZLEditVideoViewController.frameImageSize.width * 10
        self.frameImageBorderView.frame = CGRect(x: (self.view.bounds.width - frameViewW)/2, y: self.collectionView.frame.minY, width: frameViewW, height: ZLEditVideoViewController.frameImageSize.height)
        // 左右拖动view
        let leftRightSideViewW = ZLEditVideoViewController.frameImageSize.width/2
        self.leftSideView.frame = CGRect(x: self.frameImageBorderView.frame.minX, y: self.collectionView.frame.minY, width: leftRightSideViewW, height: ZLEditVideoViewController.frameImageSize.height)
        let rightSideViewX = self.view.bounds.width - self.frameImageBorderView.frame.minX - leftRightSideViewW
        self.rightSideView.frame = CGRect(x: rightSideViewX, y: self.collectionView.frame.minY, width: leftRightSideViewW, height: ZLEditVideoViewController.frameImageSize.height)
        
        self.frameImageBorderView.validRect = self.frameImageBorderView.convert(self.clipRect(), from: self.view)
    }
    
    func setupUI() {
        self.view.backgroundColor = .black
        
        self.playerLayer = AVPlayerLayer()
        self.playerLayer.videoGravity = .resizeAspect
        self.view.layer.addSublayer(self.playerLayer)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = ZLEditVideoViewController.frameImageSize
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.collectionView)
        
        ZLEditVideoFrameImageCell.zl_register(self.collectionView)
        
        self.frameImageBorderView = ZLEditVideoFrameImageBorderView()
        self.frameImageBorderView.isUserInteractionEnabled = false
        self.view.addSubview(self.frameImageBorderView)
        
        self.indicator = UIView()
        self.indicator.backgroundColor = .white
        self.view.addSubview(self.indicator)
        
        self.leftSideView = UIImageView(image: getImage("zl_ic_left"))
        self.leftSideView.isUserInteractionEnabled = true
        self.view.addSubview(self.leftSideView)
        
        self.leftSidePan = UIPanGestureRecognizer(target: self, action: #selector(leftSidePanAction(_:)))
        self.leftSidePan.delegate = self
        self.leftSideView.addGestureRecognizer(self.leftSidePan)
        
        self.rightSideView = UIImageView(image: getImage("zl_ic_right"))
        self.rightSideView.isUserInteractionEnabled = true
        self.view.addSubview(self.rightSideView)
        
        self.rightSidePan = UIPanGestureRecognizer(target: self, action: #selector(rightSidePanAction(_:)))
        self.rightSidePan.delegate = self
        self.rightSideView.addGestureRecognizer(self.rightSidePan)
        
        self.rightSidePan.require(toFail: self.leftSidePan)
        
        self.cancelBtn = UIButton(type: .custom)
        self.cancelBtn.setTitle(localLanguageTextValue(.previewCancel), for: .normal)
        self.cancelBtn.setTitleColor(.bottomToolViewBtnNormalTitleColor, for: .normal)
        self.cancelBtn.titleLabel?.font = ZLThumbnailViewController.Layout.bottomToolTitleFont
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        self.view.addSubview(self.cancelBtn)
        
        self.doneBtn = UIButton(type: .custom)
        self.doneBtn.setTitle(localLanguageTextValue(.done), for: .normal)
        self.doneBtn.setTitleColor(.bottomToolViewBtnNormalTitleColor, for: .normal)
        self.doneBtn.titleLabel?.font = ZLThumbnailViewController.Layout.bottomToolTitleFont
        self.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        self.doneBtn.backgroundColor = .bottomToolViewBtnNormalBgColor
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.layer.cornerRadius = 5
        self.view.addSubview(self.doneBtn)
    }
    
    @objc func cancelBtnClick() {
        self.cleanTimer()
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func doneBtnClick() {
        guard let avAsset = self.avAsset else {
            return
        }
        let d = CGFloat(self.interval) * self.clipRect().width / ZLEditVideoViewController.frameImageSize.width
        if Second(round(d)) < ZLPhotoConfiguration.default().minSelectVideoDuration {
            let message = String(format: localLanguageTextValue(.shorterThanMaxVideoDuration), ZLPhotoConfiguration.default().minSelectVideoDuration)
            showAlertView(message, self)
            return
        }
        if Second(round(d)) > ZLPhotoConfiguration.default().maxSelectVideoDuration {
            let message = String(format: localLanguageTextValue(.longerThanMaxVideoDuration), ZLPhotoConfiguration.default().maxSelectVideoDuration)
            showAlertView(message, self)
            return
        }
        let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
        hud.show()
        
        ZLPhotoManager.exportEditVideo(for: avAsset, range: self.getTimeRange()) { [weak self] (url, error) in
            hud.hide()
            if let er = error {
                showAlertView(er.localizedDescription, self)
            } else if url != nil {
                ZLPhotoManager.saveVideoToAblum(url: url!) { [weak self] (suc, asset) in
                    if suc, asset != nil {
                        self?.dismiss(animated: false, completion: {
                            self?.editFinishBlock?(asset!)
                        })
                    } else {
                        showAlertView(localLanguageTextValue(.saveVideoError), self)
                    }
                }
            }
        }
    }
    
    @objc func leftSidePanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: self.view)
        
        if pan.state == .began {
            self.frameImageBorderView.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
            self.cleanTimer()
        } else if pan.state == .changed {
            let minX = self.frameImageBorderView.frame.minX
            let maxX = self.rightSideView.frame.minX
            
            var frame = self.leftSideView.frame
            frame.origin.x = min(maxX, max(minX, point.x))
            self.leftSideView.frame = frame
            self.frameImageBorderView.validRect = self.frameImageBorderView.convert(self.clipRect(), from: self.view)
            
            self.playerLayer.player?.seek(to: self.getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
        } else if pan.state == .ended || pan.state == .cancelled {
            self.frameImageBorderView.layer.borderColor = UIColor.clear.cgColor
            self.startTimer()
        }
    }
    
    @objc func rightSidePanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: self.view)
        
        if pan.state == .began {
            self.frameImageBorderView.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
            self.cleanTimer()
        } else if pan.state == .changed {
            let minX = self.leftSideView.frame.maxX
            let maxX = self.frameImageBorderView.frame.maxX - self.rightSideView.frame.width
            
            var frame = self.rightSideView.frame
            frame.origin.x = min(maxX, max(minX, point.x))
            self.rightSideView.frame = frame
            self.frameImageBorderView.validRect = self.frameImageBorderView.convert(self.clipRect(), from: self.view)
            
            self.playerLayer.player?.seek(to: self.getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
        } else if pan.state == .ended || pan.state == .cancelled {
            self.frameImageBorderView.layer.borderColor = UIColor.clear.cgColor
            self.startTimer()
        }
    }
    
    func analysisAssetImages() {
        let duration = round(self.asset.duration)
        self.measureCount = Int(duration / self.interval)
        
        let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
        hud.show()
        
        self.videoRequestID = ZLPhotoManager.fetchVideo(for: self.asset, completion: { [weak self] (item, info, _) in
            hud.hide()
            if let item = item {
                let player = AVPlayer(playerItem: item)
                self?.playerLayer.player = player
                self?.startTimer()
            } else {
                self?.showFetchFailedAlert()
            }
        })
        
        self.avAssetRequestID = ZLPhotoManager.fetchAVAsset(forVideo: self.asset) { [weak self] (avAsset, info) in
            if let avAsset = avAsset {
                self?.avAsset = avAsset
                self?.collectionView.reloadData()
            } else {
                self?.showFetchFailedAlert()
            }
        }
    }
    
    func startTimer() {
        self.cleanTimer()
        let duration = self.interval * TimeInterval(self.clipRect().width / ZLEditVideoViewController.frameImageSize.width)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { (_) in
            if (self.playerLayer.player?.rate ?? 0) == 0 {
                self.playerLayer.player?.play()
            }
            self.playerLayer.player?.seek(to: self.getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
        })
        
        self.timer?.fire()
        RunLoop.main.add(self.timer!, forMode: .common)
        
        self.indicator.isHidden = false
        self.indicator.frame = CGRect(x: self.leftSideView.frame.minX, y: self.leftSideView.frame.minY, width: 2, height: self.leftSideView.frame.height)
        self.indicator.layer.removeAllAnimations()
        
        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveLinear, .repeat], animations: {
            self.indicator.frame = CGRect(x: self.rightSideView.frame.maxX-2, y: self.rightSideView.frame.minY, width: 2, height: self.rightSideView.frame.height)
        }, completion: nil)
    }
    
    func cleanTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.indicator.layer.removeAllAnimations()
        self.indicator.isHidden = true
        self.playerLayer.player?.pause()
    }
    
    func getStartTime() -> CMTime {
        var rect = self.collectionView.convert(self.clipRect(), from: self.view)
        rect.origin.x -= self.frameImageBorderView.frame.minX
        let timescale = self.playerLayer.player?.currentTime().timescale ?? 1000
        let second = max(0, CGFloat(self.interval) * rect.minX / ZLEditVideoViewController.frameImageSize.width)
        return CMTimeMakeWithSeconds(Float64(second), preferredTimescale: timescale)
    }
    
    func getTimeRange() -> CMTimeRange {
        let start = self.getStartTime()
        let d = CGFloat(self.interval) * self.clipRect().width / ZLEditVideoViewController.frameImageSize.width
        let duration = CMTimeMakeWithSeconds(Float64(d), preferredTimescale: self.playerLayer.player?.currentTime().timescale ?? 1000)
        return CMTimeRangeMake(start: start, duration: duration)
    }
    
    func clipRect() -> CGRect {
        var frame = CGRect.zero
        frame.origin.x = self.leftSideView.frame.minX
        frame.origin.y = self.leftSideView.frame.minY
        frame.size.width = self.rightSideView.frame.maxX - frame.minX
        frame.size.height = self.leftSideView.frame.height
        return frame
    }
    
    func showFetchFailedAlert() {
        let alert = UIAlertController(title: nil, message: localLanguageTextValue(.timeout), preferredStyle: .alert)
        let action = UIAlertAction(title: localLanguageTextValue(.ok), style: .default) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
        alert.addAction(action)
        self.showDetailViewController(alert, sender: nil)
    }
    
}


extension ZLEditVideoViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.leftSidePan {
            let point = gestureRecognizer.location(in: self.view)
            let frame = self.leftSideView.frame
            let outerFrame = frame.insetBy(dx: -20, dy: -20)
            return outerFrame.contains(point)
        } else if gestureRecognizer == self.rightSidePan {
            let point = gestureRecognizer.location(in: self.view)
            let frame = self.rightSideView.frame
            let outerFrame = frame.insetBy(dx: -20, dy: -20)
            return outerFrame.contains(point)
        }
        return true
    }
    
}


extension ZLEditVideoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.cleanTimer()
        self.playerLayer.player?.seek(to: self.getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.startTimer()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let w = ZLEditVideoViewController.frameImageSize.width * 10
        let leftRight = (collectionView.frame.width - w) / 2
        return UIEdgeInsets(top: 0, left: leftRight, bottom: 0, right: leftRight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.measureCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLEditVideoFrameImageCell.zl_identifier(), for: indexPath) as! ZLEditVideoFrameImageCell
        
        cell.imageView.image = self.frameImageCache[indexPath]
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let avAsset = self.avAsset, let g = self.generator else {
            return
        }
        guard self.frameImageCache[indexPath] == nil else {
            return
        }
        let cell = cell as! ZLEditVideoFrameImageCell
        cell.operation?.cancel()
        
        let i = Int32(TimeInterval(indexPath.row) * self.interval)
        let time = CMTimeMake(value: Int64((i * avAsset.duration.timescale)), timescale: avAsset.duration.timescale)
        let operation = ZLEditVideoFetchFrameImageOperation(generator: g, time: time) { [weak self, weak cell] (image) in
            self?.frameImageCache[indexPath] = image
            cell?.imageView.image = image
            cell?.operation = nil
        }
        self.requestFrameImageQueue.addOperation(operation)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! ZLEditVideoFrameImageCell
        cell.operation?.cancel()
        cell.operation = nil
    }
    
}


class ZLEditVideoFrameImageBorderView: UIView {
    
    var validRect: CGRect = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = .clear
        self.isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(4)
        
        context?.move(to: CGPoint(x: self.validRect.minX, y: 0))
        context?.addLine(to: CGPoint(x: self.validRect.minX+self.validRect.width, y: 0))
        
        context?.move(to: CGPoint(x: self.validRect.minX, y: rect.height))
        context?.addLine(to: CGPoint(x: self.validRect.minX+self.validRect.width, y: rect.height))
        
        context?.strokePath()
    }
    
}


private var operationKey = "edgeKey"
class ZLEditVideoFrameImageCell: UICollectionViewCell {
    
    var operation: Operation? {
        get {
            if let temp = objc_getAssociatedObject(self, &operationKey) as? Operation  {
                return temp
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &operationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
    }
    
}


class ZLEditVideoFetchFrameImageOperation: Operation {

    let generator: AVAssetImageGenerator
    
    let time: CMTime
    
    let completion: ( (UIImage?) -> Void )
    
    var pri_isExecuting = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return self.pri_isExecuting
    }
    
    var pri_isFinished = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return self.pri_isFinished
    }
    
    init(generator: AVAssetImageGenerator, time: CMTime, completion: @escaping ( (UIImage?) -> Void )) {
        self.generator = generator
        self.time = time
        self.completion = completion
        super.init()
    }
    
    override func start() {
        
        self.pri_isExecuting = true
        do {
            let cgImage = try self.generator.copyCGImage(at: self.time, actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.completion(image)
            }
            self.fetchFinish()
        } catch {
            DispatchQueue.main.async {
                self.completion(nil)
            }
            self.fetchFinish()
        }
    }
    
    func fetchFinish() {
        self.pri_isExecuting = false
        self.pri_isFinished = true
    }
    
    override func cancel() {
        self.fetchFinish()
    }
    
}
