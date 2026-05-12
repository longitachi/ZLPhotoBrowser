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

public class ZLEditVideoModel: NSObject {
    let start: TimeInterval
    let end: TimeInterval
    let preDuration: TimeInterval
    let url: URL
    let coverImage: UIImage?
    
    init(start: TimeInterval, end: TimeInterval, preDuration: TimeInterval, url: URL, coverImage: UIImage?) {
        self.start = start
        self.end = end
        self.preDuration = preDuration
        self.url = url
        self.coverImage = coverImage
    }
}

public class ZLEditVideoViewController: UIViewController {
    private enum Layout {
        static let frameImageSize = CGSize(width: CGFloat(round(50.0 * 2.0 / 3.0)), height: 50.0)
        static let leftRightSideViewW: CGFloat = 8
    }
    
    private let avAsset: AVAsset
    
    private let assetDataSize: ZLPhotoConfiguration.KBUnit?
    
    private let editModel: ZLEditVideoModel?
    
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
        btn.setTitleColor(.zl.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
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
        layout.itemSize = Layout.frameImageSize
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
    
    private lazy var overlayView = ZLEditVideoOverlayView()
    
    private lazy var frameImageBorderView: ZLEditVideoFrameImageBorderView = {
        let view = ZLEditVideoFrameImageBorderView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var leftSideView: UIImageView = {
        let view = UIImageView(image: .zl.getImage("zl_edit_video_pan_icon"))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var rightSideView: UIImageView = {
        let view = UIImageView(image: .zl.getImage("zl_edit_video_pan_icon"))
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
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .zl.font(ofSize: 12)
        return label
    }()
    
    private lazy var measureCount: Int = {
        Int(avAsset.duration.seconds / interval)
    }()
    
    private var maxEditDuration: TimeInterval {
        let assetDuration = avAsset.duration.seconds
        return min(assetDuration, TimeInterval(ZLPhotoConfiguration.default().maxEditVideoTime))
    }
    
    private lazy var interval: TimeInterval = {
        TimeInterval(maxEditDuration) / 10
    }()
    
    private lazy var avAssetRequestID = PHInvalidImageRequestID
    
    private lazy var videoRequestID = PHInvalidImageRequestID
    
    private var frameImageCache: [Int: UIImage] = [:]
    
    private var requestFailedFrameImageIndex: Set<Int> = Set()
    
    private var shouldLayout = true
    
    private lazy var generator: AVAssetImageGenerator = {
        let g = AVAssetImageGenerator(asset: self.avAsset)
        g.maximumSize = CGSize(width: Layout.frameImageSize.width * 3, height: Layout.frameImageSize.height * 3)
        g.appliesPreferredTrackTransform = true
        g.requestedTimeToleranceBefore = .zero
        g.requestedTimeToleranceAfter = .zero
        g.apertureMode = .productionAperture
        return g
    }()
    
    private lazy var coverImageGenerator: AVAssetImageGenerator = {
        let g = AVAssetImageGenerator(asset: self.avAsset)
        g.appliesPreferredTrackTransform = true
        g.requestedTimeToleranceBefore = .zero
        g.requestedTimeToleranceAfter = .zero
        g.apertureMode = .productionAperture
        return g
    }()
    
    public var editFinishBlock: ((ZLEditVideoModel?) -> Void)?
    
    public var cancelEditBlock: (() -> Void)?
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        deviceIsiPhone() ? .portrait : .all
    }
    
    deinit {
        zl_debugPrint("ZLEditVideoViewController deinit")
        cleanTimer()
        generator.cancelAllCGImageGeneration()
        coverImageGenerator.cancelAllCGImageGeneration()
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
    ///   - assetDataSize: 视频对象原大小
    ///   - editModel: 视频上次编辑结果对象
    ///   - animateDismiss: 退出界面时是否显示dismiss动画
    public init(
        avAsset: AVAsset,
        assetDataSize: ZLPhotoConfiguration.KBUnit? = nil,
        editModel: ZLEditVideoModel? = nil,
        animateDismiss: Bool = false
    ) {
        self.avAsset = avAsset
        self.assetDataSize = assetDataSize
        self.editModel = editModel
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
        let diffBottom = btnH + Layout.frameImageSize.height + bottomBtnAndColSpacing + insets.bottom + 30
        
        playerLayer.frame = CGRect(x: 15, y: insets.top + 20, width: view.bounds.width - 30, height: view.bounds.height - playerLayerY - diffBottom)
        
        let cancelBtnW = localLanguageTextValue(.cancel).zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: btnH)).width
        cancelBtn.frame = CGRect(x: 20, y: view.bounds.height - insets.bottom - btnH, width: cancelBtnW, height: btnH)
        let doneBtnW = (doneBtn.currentTitle ?? "")
            .zl.boundingRect(
                font: ZLLayout.bottomToolTitleFont,
                limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: btnH)
            ).width + 20
        doneBtn.frame = CGRect(x: view.bounds.width - doneBtnW - 20, y: view.bounds.height - insets.bottom - btnH, width: doneBtnW, height: btnH)
        
        collectionView.frame = CGRect(x: 0, y: doneBtn.frame.minY - bottomBtnAndColSpacing - Layout.frameImageSize.height, width: view.bounds.width, height: Layout.frameImageSize.height)
        overlayView.frame = collectionView.frame
        
        let frameViewW = Layout.frameImageSize.width * 10
        frameImageBorderView.frame = CGRect(x: (view.bounds.width - frameViewW) / 2, y: collectionView.frame.minY, width: frameViewW, height: Layout.frameImageSize.height)
        
        var innerStartX: CGFloat = 0
        var durationW: CGFloat = frameImageBorderView.zl.width
        if let editModel {
            let preTime = editModel.preDuration
            var oneFrameDuration = interval
            if measureCount > 10 {
                oneFrameDuration = (avAsset.duration.seconds - Double(ZLPhotoConfiguration.default().maxEditVideoTime)) / Double(measureCount - 10)
            }
            
            let offsetX = preTime / oneFrameDuration * Layout.frameImageSize.width
            collectionView.contentOffset = CGPoint(x: offsetX, y: 0)
            
            let innerStartTime = editModel.start - editModel.preDuration
            innerStartX = innerStartTime / interval * Layout.frameImageSize.width
            
            let durationTime = editModel.end - editModel.start
            durationW = durationTime / interval * Layout.frameImageSize.width
        }
        
        if isRTL() {
            // 左右拖动view
            rightSideView.frame = CGRect(
                x: frameImageBorderView.zl.right - Layout.leftRightSideViewW / 2 - innerStartX,
                y: collectionView.zl.top,
                width: Layout.leftRightSideViewW,
                height: Layout.frameImageSize.height
            )
            leftSideView.frame = CGRect(
                x: max(rightSideView.zl.left - durationW, frameImageBorderView.zl.left - Layout.leftRightSideViewW / 2),
                y: collectionView.zl.top,
                width: Layout.leftRightSideViewW,
                height: Layout.frameImageSize.height
            )
        } else {
            // 左右拖动view
            leftSideView.frame = CGRect(
                x: frameImageBorderView.zl.left - Layout.leftRightSideViewW / 2 + innerStartX,
                y: collectionView.zl.top,
                width: Layout.leftRightSideViewW,
                height: Layout.frameImageSize.height
            )
            rightSideView.frame = CGRect(
                x: min(leftSideView.zl.left + durationW, frameImageBorderView.zl.right - Layout.leftRightSideViewW / 2),
                y: collectionView.zl.top,
                width: Layout.leftRightSideViewW,
                height: Layout.frameImageSize.height
            )
        }
        
        frameImageBorderView.validRect = frameImageBorderView.convert(clipRect(), from: view)
        durationLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        updateSubviewStatus()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.layer.addSublayer(playerLayer)
        view.addSubview(collectionView)
        view.addSubview(overlayView)
        view.addSubview(frameImageBorderView)
        view.addSubview(indicator)
        view.addSubview(leftSideView)
        view.addSubview(rightSideView)
        view.addSubview(durationLabel)
        
        view.addGestureRecognizer(leftSidePan)
        view.addGestureRecognizer(rightSidePan)
        
        collectionView.panGestureRecognizer.require(toFail: leftSidePan)
        collectionView.panGestureRecognizer.require(toFail: rightSidePan)
        rightSidePan.require(toFail: leftSidePan)
        
        view.addSubview(cancelBtn)
        view.addSubview(doneBtn)
    }
    
    @objc private func cancelBtnClick() {
        dismiss(animated: animateDismiss) {
            self.cancelEditBlock?()
        }
    }
    
    @objc private func doneBtnClick() {
        func callback(editModel: ZLEditVideoModel?) {
            // 内部自己调用，先回调在退出
            if let nav = presentingViewController as? ZLImageNavController,
               nav.topViewController is ZLPhotoPreviewController {
                editFinishBlock?(editModel)
                dismiss(animated: animateDismiss)
            } else {
                dismiss(animated: animateDismiss) {
                    self.editFinishBlock?(editModel)
                }
            }
        }
        
        let config = ZLPhotoConfiguration.default()
        
        let d = CGFloat(interval) * clipRect().width / Layout.frameImageSize.width
        if !videoDurationIsValid(ZLPhotoConfiguration.Second(round(d)), sender: self) {
            return
        }
        
        // Max deviation is 0.01
        if abs(d - avAsset.duration.seconds) <= 0.01 {
            if let assetDataSize, !videoSizeIsValid(assetDataSize, sender: self) {
                return
            }
            
            callback(editModel: nil)
            return
        }
        
        if let editModel,
           abs(editModel.start - getStartTime().seconds) <= 0.01,
           abs(editModel.end - getEndTime().seconds) <= 0.01 {
            callback(editModel: editModel)
            return
        }
        
        let hud = ZLProgressHUD.show(toast: .processing)
        ZLVideoManager.exportEditVideo(for: avAsset, range: getTimeRange()) { [weak self] url, error in
            hud.hide()
            guard let `self` = self else { return }
            
            if let error {
                showAlertView(error.localizedDescription, self)
            } else if let url {
                if config.shouldCheckVideoDataSize {
                    let size = ZLCommonTools.getLocalFileSize(for: url)
                    if !videoSizeIsValid(size, sender: self) {
                        return
                    }
                }
                
                
                self.coverImageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: self.getStartTime())]) { _, cgImage, _, result, _ in
                    var coverImage: UIImage?
                    if result == .succeeded, let cg = cgImage {
                        coverImage = UIImage(cgImage: cg)
                    }
                    
                    ZLMainAsync {
                        let editModel = ZLEditVideoModel(
                            start: self.getStartTime().seconds,
                            end: self.getEndTime().seconds,
                            preDuration: self.getPreTime().seconds,
                            url: url,
                            coverImage: coverImage
                        )
                        
                        callback(editModel: editModel)
                    }
                }
            }
        }
    }
    
    /// 视频最短只能裁剪1s，这里获取左右两个icon间距为多少时时间为1s
    private func minDistance() -> CGFloat {
        let maxW = frameImageBorderView.zl.width
        return maxW / maxEditDuration
    }
    
    @objc private func leftSidePanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        
        if pan.state == .began {
            frameImageBorderView.layer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor
            cleanTimer()
        } else if pan.state == .changed {
            let minX = frameImageBorderView.zl.left - Layout.leftRightSideViewW / 2
            let maxX = rightSideView.zl.left - minDistance()
            
            var frame = leftSideView.frame
            frame.origin.x = min(maxX, max(minX, point.x))
            leftSideView.frame = frame
            frameImageBorderView.validRect = frameImageBorderView.convert(clipRect(), from: view)
            updateSubviewStatus()
            
            if isRTL() {
                playerLayer.player?.seek(to: getEndTime(), toleranceBefore: .zero, toleranceAfter: .zero)
            } else {
                playerLayer.player?.seek(to: getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
            }
        } else if pan.state == .ended || pan.state == .cancelled {
            frameImageBorderView.layer.borderColor = UIColor.clear.cgColor
            startTimer()
        }
    }
    
    @objc private func rightSidePanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        
        if pan.state == .began {
            frameImageBorderView.layer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor
            cleanTimer()
        } else if pan.state == .changed {
            let minX = leftSideView.zl.left + minDistance()
            let maxX = frameImageBorderView.frame.maxX - Layout.leftRightSideViewW / 2
            
            var frame = rightSideView.frame
            frame.origin.x = min(maxX, max(minX, point.x))
            rightSideView.frame = frame
            frameImageBorderView.validRect = frameImageBorderView.convert(clipRect(), from: view)
            updateSubviewStatus()
            
            if isRTL() {
                playerLayer.player?.seek(to: getStartTime(), toleranceBefore: .zero, toleranceAfter: .zero)
            } else {
                playerLayer.player?.seek(to: getEndTime(), toleranceBefore: .zero, toleranceAfter: .zero)
            }
        } else if pan.state == .ended || pan.state == .cancelled {
            frameImageBorderView.layer.borderColor = UIColor.clear.cgColor
            startTimer()
        }
    }
    
    private func updateSubviewStatus() {
        durationLabel.center = CGPoint(x: rightSideView.zl.centerX, y: rightSideView.zl.top - durationLabel.zl.height / 2)
        let d = CGFloat(interval) * clipRect().width / Layout.frameImageSize.width
        durationLabel.text = ZLCommonTools.formatVideoDuration(round(d))
        
        let rect = CGRect(
            x: leftSideView.zl.centerX,
            y: leftSideView.zl.top,
            width: rightSideView.zl.centerX - leftSideView.zl.centerX,
            height: frameImageBorderView.zl.height
        )
        overlayView.updateMaskLayer(view.convert(rect, to: overlayView))
    }
    
    @objc private func appWillResignActive() {
        cleanTimer()
        indicator.layer.removeAllAnimations()
    }
    
    @objc private func appDidBecomeActive() {
        startTimer()
    }
    
    private func analysisAssetImages() {
        guard measureCount > 0 else {
            showFetchFailedAlert()
            return
        }
        let item = AVPlayerItem(asset: avAsset)
        let player = AVPlayer(playerItem: item)
        playerLayer.player = player
        
        collectionView.reloadData()
        startTimer()
        
        let times = (0..<measureCount).map {
            cmtimeFor(second: TimeInterval($0) * interval)
        }
        requestVideoMeasureFrameImage(times: times)
    }
    
    private func cmtimeFor(second: TimeInterval) -> CMTime {
        return CMTimeMakeWithSeconds(Float64(second), preferredTimescale: avAsset.duration.timescale)
    }
    
    private func requestVideoMeasureFrameImage(times: [CMTime]) {
        if #available(iOS 16.0, *) {
            Task {
                let stream = generator.images(for: times)
                
                for await result in stream {
                    switch result {
                    case let .success(requestedTime, cgImage, _):
                        let image = UIImage(cgImage: cgImage)
                        let seconds = CMTimeGetSeconds(requestedTime)
                        let index = Int(round(seconds / interval))
                        
                        await MainActor.run {
                            requestFailedFrameImageIndex.remove(index)
                            frameImageCache[index] = image
                            if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ZLEditVideoFrameImageCell {
                                cell.imageView.image = image
                            }
                        }
                    case let .failure(requestedTime, _):
                        let seconds = CMTimeGetSeconds(requestedTime)
                        let index = Int(round(seconds / self.interval))
                        requestFailedFrameImageIndex.insert(index)
                    }
                }
            }
        } else {
            let times = times.map { NSValue(time: $0) }
            
            generator.generateCGImagesAsynchronously(forTimes: times) { [weak self] requestedTime, cgImage, actualTime, result, error in
                guard let `self` = self else { return }
                
                var image: UIImage?
                if result == .succeeded, let cgImage {
                    image = UIImage(cgImage: cgImage)
                }
                
                let seconds = CMTimeGetSeconds(requestedTime)
                let index = Int(round(seconds / self.interval))
                
                DispatchQueue.main.async {
                    if let image {
                        self.requestFailedFrameImageIndex.remove(index)
                        self.frameImageCache[index] = image
                        // 仅更新当前可见的 cell，避免复用问题
                        let indexPath = IndexPath(row: index, section: 0)
                        if let cell = self.collectionView.cellForItem(at: indexPath) as? ZLEditVideoFrameImageCell {
                            cell.imageView.image = image
                        }
                    } else {
                        self.requestFailedFrameImageIndex.insert(index)
                    }
                }
            }
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
        let duration = interval * TimeInterval(clipRect().width / Layout.frameImageSize.width)
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: ZLWeakProxy(target: self), selector: #selector(playPartVideo), userInfo: nil, repeats: true)
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
        
        indicator.isHidden = false
        
        let indicatorW: CGFloat = 2
        let indicatorH = leftSideView.zl.height
        let indicatorY = leftSideView.zl.top
        var indicatorFromX = leftSideView.zl.centerX
        var indicatorToX = rightSideView.zl.centerX - indicatorW
        
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
    
    /// 获取框选外区域总时长
    private func getPreTime() -> CMTime {
        var oneFrameDuration = interval
        if measureCount > 10 {
            // 如果measureCount > 10，计算出框选区域外，每一帧图片占的时长
            // 比如视频16.5s，那么此时measureCount为16，为了保证框选区域内十帧是10s，所以框选区域外的每一帧图片要均摊多出来的0.5s
            oneFrameDuration = (avAsset.duration.seconds - Double(ZLPhotoConfiguration.default().maxEditVideoTime)) / Double(measureCount - 10)
        }
        
        let offsetX = collectionView.contentOffset.x
        let previousSeconds = offsetX / Layout.frameImageSize.width * oneFrameDuration
        return cmtimeFor(second: previousSeconds)
    }
    
    private func getStartTime() -> CMTime {
        let previousTime = getPreTime()
        
        // 框选区域内起始时长
        let innerRect = frameImageBorderView.convert(clipRect(), from: view)
        let innerPreviousSecond: TimeInterval
        if isRTL() {
            innerPreviousSecond = (frameImageBorderView.zl.width - innerRect.maxX) / Layout.frameImageSize.width * interval
        } else {
            innerPreviousSecond = innerRect.minX / Layout.frameImageSize.width * interval
        }
        
        let innerTime = cmtimeFor(second: max(innerPreviousSecond, 0))
        return previousTime + innerTime
    }
    
    private func getEndTime() -> CMTime {
        let start = getStartTime()
        let d = CGFloat(interval) * clipRect().width / Layout.frameImageSize.width
        let duration = cmtimeFor(second: d)
        return start + duration
    }
    
    private func getTimeRange() -> CMTimeRange {
        let start = getStartTime()
        let d = CGFloat(interval) * clipRect().width / Layout.frameImageSize.width
        let duration = cmtimeFor(second: d)
        return CMTimeRangeMake(start: start, duration: duration)
    }
    
    private func clipRect() -> CGRect {
        var frame = CGRect.zero
        frame.origin.x = leftSideView.zl.centerX
        frame.origin.y = leftSideView.zl.top
        frame.size.width = rightSideView.zl.centerX - leftSideView.zl.centerX
        frame.size.height = leftSideView.zl.height
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
            let leftFrame = leftSideView.frame
            let rightFrame = rightSideView.frame
            let distance = rightFrame.minX - leftFrame.maxX
            let outerFrame = leftFrame.inset(by: UIEdgeInsets(top: -20, left: -40, bottom: -20, right: -min(20, distance)))
            return outerFrame.contains(point)
        } else if gestureRecognizer == rightSidePan {
            let point = gestureRecognizer.location(in: view)
            let leftFrame = leftSideView.frame
            let rightFrame = rightSideView.frame
            let distance = rightFrame.minX - leftFrame.maxX
            let outerFrame = rightFrame.inset(by: UIEdgeInsets(top: -20, left: -min(20, distance), bottom: -20, right: -40))
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
        let w = Layout.frameImageSize.width * 10
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
            let time = cmtimeFor(second: mes)
            requestVideoMeasureFrameImage(times: [time])
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
