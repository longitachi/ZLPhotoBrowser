//
//  ZLEditVideoViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/30.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Photos
import AVFoundation

public class ZLEditVideoViewController: UIViewController {
    private static let frameImageSize = CGSize(width: CGFloat(round(50.0 * 2.0 / 3.0)), height: 50.0)
    
    private let avAsset: AVAsset
    
    private let animateDismiss: Bool
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
        btn.setTitleColor(.zl.bottomToolViewBtnNormalTitleColor, for: .normal)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(localLanguageTextValue(.editFinish), for: .normal)
        btn.setTitleColor(.zl.bottomToolViewBtnNormalTitleColor, for: .normal)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.backgroundColor = .zl.bottomToolViewBtnNormalBgColor
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    private var timer: Timer?
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspect
        return layer
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = ZLCollectionViewFlowLayout()
        layout.itemSize = ZLEditVideoViewController.frameImageSize
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        ZLEditVideoFrameImageCell.zl.register(view)
        return view
    }()
    
    private lazy var frameImageBorderView: ZLEditVideoFrameImageBorderView = {
        let view = ZLEditVideoFrameImageBorderView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var leftSideView: UIImageView = {
        let view = UIImageView(image: .zl.getImage("zl_ic_left"))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var rightSideView: UIImageView = {
        let view = UIImageView(image: .zl.getImage("zl_ic_right"))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var leftSidePan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(leftSidePanAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    private lazy var rightSidePan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(rightSidePanAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    private lazy var indicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        return view
    }()
    
    private var measureCount = 0
    
    private lazy var interval: TimeInterval = {
        let assetDuration = round(self.avAsset.duration.seconds)
        return min(assetDuration, TimeInterval(ZLPhotoConfiguration.default().maxEditVideoTime)) / 10
    }()
    
    private lazy var requestFrameImageQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    
    private lazy var avAssetRequestID = PHInvalidImageRequestID
    
    private lazy var videoRequestID = PHInvalidImageRequestID
    
    private var frameImageCache: [Int: UIImage] = [:]
    
    private var requestFailedFrameImageIndex: [Int] = []
    
    private var shouldLayout = true
    
    private lazy var generator: AVAssetImageGenerator = {
        let g = AVAssetImageGenerator(asset: self.avAsset)
        g.maximumSize = CGSize(width: ZLEditVideoViewController.frameImageSize.width * 3, height: ZLEditVideoViewController.frameImageSize.height * 3)
        g.appliesPreferredTrackTransform = true
        g.requestedTimeToleranceBefore = .zero
        g.requestedTimeToleranceAfter = .zero
        g.apertureMode = .productionAperture
        return g
    }()
    
    @objc public var editFinishBlock: ((URL?) -> Void)?
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        deviceIsiPhone() ? .portrait : .all
    }
    
    deinit {
        zl_debugPrint("ZLEditVideoViewController deinit")
        cleanTimer()
        requestFrameImageQueue.cancelAllOperations()
        if avAssetRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(avAssetRequestID)
        }
        if videoRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(videoRequestID)
        }
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    /// initialize
    /// - Parameters:
    ///   - avAsset: AVAsset对象，需要传入本地视频，网络视频不支持
    ///   - animateDismiss: 退出界面时是否显示dismiss动画
    @objc public init(avAsset: AVAsset, animateDismiss: Bool = false) {
        self.avAsset = avAsset
        self.animateDismiss = animateDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analysisAssetImages()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard shouldLayout else {
            return
        }
        shouldLayout = false
        
        zl_debugPrint("edit video layout subviews")
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        let btnH = ZLLayout.bottomToolBtnH
        let bottomBtnAndColSpacing: CGFloat = 20
        let playerLayerY = insets.top + 20
        let diffBottom = btnH + ZLEditVideoViewController.frameImageSize.height + bottomBtnAndColSpacing + insets.bottom + 30
        
        playerLayer.frame = CGRect(x: 15, y: insets.top + 20, width: view.bounds.width - 30, height: view.bounds.height - playerLayerY - diffBottom)
        
        let cancelBtnW = localLanguageTextValue(.cancel).zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: btnH)).width
        cancelBtn.frame = CGRect(x: 20, y: view.bounds.height - insets.bottom - btnH, width: cancelBtnW, height: btnH)
        let doneBtnW = (doneBtn.currentTitle ?? "")
            .zl.boundingRect(
                font: ZLLayout.bottomToolTitleFont,
                limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: btnH)
            ).width + 20
        doneBtn.frame = CGRect(x: view.bounds.width - doneBtnW - 20, y: view.bounds.height - insets.bottom - btnH, width: doneBtnW, height: btnH)
        
        collectionView.frame = CGRect(x: 0, y: doneBtn.frame.minY - bottomBtnAndColSpacing - ZLEditVideoViewController.frameImageSize.height, width: view.bounds.width, height: ZLEditVideoViewController.frameImageSize.height)
        
        let frameViewW = ZLEditVideoViewController.frameImageSize.width * 10
        frameImageBorderView.frame = CGRect(x: (view.bounds.width - frameViewW) / 2, y: collectionView.frame.minY, width: frameViewW, height: ZLEditVideoViewController.frameImageSize.height)
        // 左右拖动view
        let leftRightSideViewW = ZLEditVideoViewController.frameImageSize.width / 2
        leftSideView.frame = CGRect(x: frameImageBorderView.frame.minX, y: collectionView.frame.minY, width: leftRightSideViewW, height: ZLEditVideoViewController.frameImageSize.height)
        let rightSideViewX = view.bounds.width - frameImageBorderView.frame.minX - leftRightSideViewW
        rightSideView.frame = CGRect(x: rightSideViewX, y: collectionView.frame.minY, width: leftRightSideViewW, height: ZLEditVideoViewController.frameImageSize.height)
        
        frameImageBorderView.validRect = frameImageBorderView.convert(clipRect(), from: view)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.layer.addSublayer(playerLayer)
        view.addSubview(collectionView)
        view.addSubview(frameImageBorderView)
        view.addSubview(indicator)
        view.addSubview(leftSideView)
        view.addSubview(rightSideView)
        
        view.addGestureRecognizer(leftSidePan)
        view.addGestureRecognizer(rightSidePan)
        
        collectionView.panGestureRecognizer.require(toFail: leftSidePan)
        collectionView.panGestureRecognizer.require(toFail: rightSidePan)
        rightSidePan.require(toFail: leftSidePan)
        
        view.addSubview(cancelBtn)
        view.addSubview(doneBtn)
    }
    
    @objc private func cancelBtnClick() {
        dismiss(animated: animateDismiss, completion: nil)
    }
    
    @objc private func doneBtnClick() {
        cleanTimer()
        
        let d = CGFloat(interval) * clipRect().width / ZLEditVideoViewController.frameImageSize.width
        if ZLPhotoConfiguration.Second(round(d)) < ZLPhotoConfiguration.default().minSelectVideoDuration {
            let message = String(format: localLanguageTextValue(.shorterThanMinVideoDuration), ZLPhotoConfiguration.default().minSelectVideoDuration)
            showAlertView(message, self)
            return
        }
        if ZLPhotoConfiguration.Second(round(d)) > ZLPhotoConfiguration.default().maxSelectVideoDuration {
            let message = String(format: localLanguageTextValue(.longerThanMaxVideoDuration), ZLPhotoConfiguration.default().maxSelectVideoDuration)
            showAlertView(message, self)
            return
        }
        
        // Max deviation is 0.01
        if abs(d - round(CGFloat(avAsset.duration.seconds))) <= 0.01 {
            dismiss(animated: animateDismiss) {
                self.editFinishBlock?(nil)
            }
            return
        }
        
        let hud = ZLProgressHUD.show(toast: .processing)
        
        ZLVideoManager.exportEditVideo(for: avAsset, range: getTimeRange()) { [weak self] url, error in
            hud.hide()
            if let er = error {
                showAlertView(er.localizedDescription, self)
            } else if url != nil {
                self?.dismiss(animated: self?.animateDismiss ?? false) {
                    self?.editFinishBlock?(url)
                }
            }
        }
    }
    
    @objc private func leftSidePanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        
        if pan.state == .began {
            frameImageBorderView.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
            cleanTimer()
        } else if pan.state == .changed {
            let minX = frameImageBorderView.frame.minX
            let maxX = rightSideView.frame.minX - leftSideView.frame.width
            
            var frame = leftSideView.frame
            frame.origin.x = min(maxX, max(minX, point.x))
            leftSideView.frame = frame
            frameImageBorderView.validRect = frameImageBorderView.convert(clipRect(), from: view)
            
            playerLayer.player?.seek(to: getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
        } else if pan.state == .ended || pan.state == .cancelled {
            frameImageBorderView.layer.borderColor = UIColor.clear.cgColor
            startTimer()
        }
    }
    
    @objc private func rightSidePanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        
        if pan.state == .began {
            frameImageBorderView.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
            cleanTimer()
        } else if pan.state == .changed {
            let minX = leftSideView.frame.maxX
            let maxX = frameImageBorderView.frame.maxX - rightSideView.frame.width
            
            var frame = rightSideView.frame
            frame.origin.x = min(maxX, max(minX, point.x))
            rightSideView.frame = frame
            frameImageBorderView.validRect = frameImageBorderView.convert(clipRect(), from: view)
            
            playerLayer.player?.seek(to: getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
        } else if pan.state == .ended || pan.state == .cancelled {
            frameImageBorderView.layer.borderColor = UIColor.clear.cgColor
            startTimer()
        }
    }
    
    @objc private func appWillResignActive() {
        cleanTimer()
        indicator.layer.removeAllAnimations()
    }
    
    @objc private func appDidBecomeActive() {
        startTimer()
    }
    
    private func analysisAssetImages() {
        let duration = round(avAsset.duration.seconds)
        guard duration > 0 else {
            showFetchFailedAlert()
            return
        }
        let item = AVPlayerItem(asset: avAsset)
        let player = AVPlayer(playerItem: item)
        playerLayer.player = player
        
        measureCount = Int(duration / interval)
        collectionView.reloadData()
        startTimer()
        requestVideoMeasureFrameImage()
    }
    
    private func requestVideoMeasureFrameImage() {
        for i in 0..<measureCount {
            let mes = TimeInterval(i) * interval
            let time = CMTimeMakeWithSeconds(Float64(mes), preferredTimescale: avAsset.duration.timescale)
            
            let operation = ZLEditVideoFetchFrameImageOperation(generator: generator, time: time) { [weak self] image, _ in
                self?.frameImageCache[Int(i)] = image
                let cell = self?.collectionView.cellForItem(at: IndexPath(row: Int(i), section: 0)) as? ZLEditVideoFrameImageCell
                cell?.imageView.image = image
                if image == nil {
                    self?.requestFailedFrameImageIndex.append(i)
                }
            }
            requestFrameImageQueue.addOperation(operation)
        }
    }
    
    @objc private func playPartVideo() {
        playerLayer.player?.seek(to: getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
        if (playerLayer.player?.rate ?? 0) == 0 {
            playerLayer.player?.play()
        }
    }
    
    private func startTimer() {
        cleanTimer()
        let duration = interval * TimeInterval(clipRect().width / ZLEditVideoViewController.frameImageSize.width)
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: ZLWeakProxy(target: self), selector: #selector(playPartVideo), userInfo: nil, repeats: true)
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
        
        indicator.isHidden = false
        
        let indicatorW: CGFloat = 2
        let indicatorH = leftSideView.zl.height
        let indicatorY = leftSideView.zl.top
        var indicatorFromX = leftSideView.zl.left
        var indicatorToX = rightSideView.zl.right - indicatorW
        
        if isRTL() {
            swap(&indicatorFromX, &indicatorToX)
        }
        
        let fromFrame = CGRect(x: indicatorFromX, y: indicatorY, width: indicatorW, height: indicatorH)
        indicator.frame = fromFrame
        
        var toFrame = fromFrame
        toFrame.origin.x = indicatorToX
        
        indicator.layer.removeAllAnimations()
        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveLinear, .repeat], animations: {
            self.indicator.frame = toFrame
        }, completion: nil)
    }
    
    private func cleanTimer() {
        timer?.invalidate()
        timer = nil
        indicator.layer.removeAllAnimations()
        indicator.isHidden = true
        playerLayer.player?.pause()
    }
    
    private func getStartTime() -> CMTime {
        var oneFrameDuration = interval
        if measureCount > 10 {
            // 如果measureCount > 10，计算出框选区域外，每一帧图片占的时长
            oneFrameDuration = (avAsset.duration.seconds - Double(ZLPhotoConfiguration.default().maxEditVideoTime)) / Double(measureCount - 10)
        }
        
        let offsetX = collectionView.contentOffset.x
        let previousSecond = offsetX / ZLEditVideoViewController.frameImageSize.width * oneFrameDuration
        
        // 框选区域内起始时长
        let innerRect = frameImageBorderView.convert(clipRect(), from: view)
        let innerPreviousSecond: TimeInterval
        if isRTL() {
            innerPreviousSecond = (frameImageBorderView.zl.width - innerRect.maxX) / ZLEditVideoViewController.frameImageSize.width * interval
        } else {
            innerPreviousSecond = innerRect.minX / ZLEditVideoViewController.frameImageSize.width * interval
        }
        
        let totalDuration = max(0, previousSecond + round(innerPreviousSecond))
        
        return CMTimeMakeWithSeconds(Float64(totalDuration), preferredTimescale: avAsset.duration.timescale)
    }
    
    private func getTimeRange() -> CMTimeRange {
        let start = getStartTime()
        let d = CGFloat(interval) * clipRect().width / ZLEditVideoViewController.frameImageSize.width
        let duration = CMTimeMakeWithSeconds(Float64(round(d)), preferredTimescale: avAsset.duration.timescale)
        return CMTimeRangeMake(start: start, duration: duration)
    }
    
    private func clipRect() -> CGRect {
        var frame = CGRect.zero
        frame.origin.x = leftSideView.frame.minX
        frame.origin.y = leftSideView.frame.minY
        frame.size.width = rightSideView.frame.maxX - frame.minX
        frame.size.height = leftSideView.frame.height
        return frame
    }
    
    private func showFetchFailedAlert() {
        let action = ZLCustomAlertAction(title: localLanguageTextValue(.ok), style: .default) { [weak self] _ in
            self?.dismiss(animated: false)
        }
        showAlertController(title: nil, message: localLanguageTextValue(.iCloudVideoLoadFaild), style: .alert, actions: [action], sender: self)
    }
}

extension ZLEditVideoViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == leftSidePan {
            let point = gestureRecognizer.location(in: view)
            let frame = leftSideView.frame
            let outerFrame = frame.inset(by: UIEdgeInsets(top: -20, left: -40, bottom: -20, right: -20))
            return outerFrame.contains(point)
        } else if gestureRecognizer == rightSidePan {
            let point = gestureRecognizer.location(in: view)
            let frame = rightSideView.frame
            let outerFrame = frame.inset(by: UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -40))
            return outerFrame.contains(point)
        }
        return true
    }
}

extension ZLEditVideoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cleanTimer()
        playerLayer.player?.seek(to: getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startTimer()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let w = ZLEditVideoViewController.frameImageSize.width * 10
        let leftRight = (collectionView.frame.width - w) / 2
        return UIEdgeInsets(top: 0, left: leftRight, bottom: 0, right: leftRight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return measureCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLEditVideoFrameImageCell.zl.identifier, for: indexPath) as! ZLEditVideoFrameImageCell
        
        if let image = frameImageCache[indexPath.row] {
            cell.imageView.image = image
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if requestFailedFrameImageIndex.contains(indexPath.row) {
            let mes = TimeInterval(indexPath.row) * interval
            let time = CMTimeMakeWithSeconds(Float64(mes), preferredTimescale: avAsset.duration.timescale)
            
            let operation = ZLEditVideoFetchFrameImageOperation(generator: generator, time: time) { [weak self] image, _ in
                self?.frameImageCache[indexPath.row] = image
                let cell = self?.collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? ZLEditVideoFrameImageCell
                cell?.imageView.image = image
                if image != nil {
                    self?.requestFailedFrameImageIndex.removeAll { $0 == indexPath.row }
                }
            }
            requestFrameImageQueue.addOperation(operation)
        }
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
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = .clear
        isOpaque = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(4)
        
        context?.move(to: CGPoint(x: validRect.minX, y: 0))
        context?.addLine(to: CGPoint(x: validRect.minX + validRect.width, y: 0))
        
        context?.move(to: CGPoint(x: validRect.minX, y: rect.height))
        context?.addLine(to: CGPoint(x: validRect.minX + validRect.width, y: rect.height))
        
        context?.strokePath()
    }
}

class ZLEditVideoFrameImageCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}

class ZLEditVideoFetchFrameImageOperation: Operation {
    private let generator: AVAssetImageGenerator
    
    private let time: CMTime
    
    let completion: (UIImage?, CMTime) -> Void
    
    var pri_isExecuting = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return pri_isExecuting
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
        return pri_isFinished
    }
    
    var pri_isCancelled = false {
        willSet {
            self.willChangeValue(forKey: "isCancelled")
        }
        didSet {
            self.didChangeValue(forKey: "isCancelled")
        }
    }

    override var isCancelled: Bool {
        return pri_isCancelled
    }
    
    init(generator: AVAssetImageGenerator, time: CMTime, completion: @escaping ((UIImage?, CMTime) -> Void)) {
        self.generator = generator
        self.time = time
        self.completion = completion
        super.init()
    }
    
    override func start() {
        if isCancelled {
            fetchFinish()
            return
        }
        pri_isExecuting = true
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, result, _ in
            if result == .succeeded, let cg = cgImage {
                let image = UIImage(cgImage: cg)
                ZLMainAsync {
                    self.completion(image, self.time)
                }
                self.fetchFinish()
            } else {
                self.fetchFinish()
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        pri_isCancelled = true
    }
    
    private func fetchFinish() {
        pri_isExecuting = false
        pri_isFinished = true
    }
}
