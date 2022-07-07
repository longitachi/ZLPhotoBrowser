//
//  ZLPhotoPreviewCell.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/21.
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
import PhotosUI

class ZLPreviewBaseCell: UICollectionViewCell {
    
    var singleTapBlock: (() -> Void)?
    
    var currentImage: UIImage? {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(previewVCScroll), name: ZLPhotoPreviewController.previewVCScrollNotification, object: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func previewVCScroll() {}
    
    func resetSubViewStatusWhenCellEndDisplay() {}
    
    func resizeImageView(imageView: UIImageView, asset: PHAsset) {
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        var frame: CGRect = .zero
        
        let viewW = bounds.width
        let viewH = bounds.height
        
        var width = viewW
        
        // video和livephoto没必要处理长图和宽图
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let height = viewH
            frame.size.height = height
            
            let imageWHRatio = size.width / size.height
            let viewWHRatio = viewW / viewH
            
            if imageWHRatio > viewWHRatio {
                frame.size.width = floor(height * imageWHRatio)
                if frame.size.width > viewW {
                    frame.size.width = viewW
                    frame.size.height = viewW / imageWHRatio
                }
            } else {
                width = floor(height * imageWHRatio)
                if width < 1 || width.isNaN {
                    width = viewW
                }
                frame.size.width = width
            }
        } else {
            frame.size.width = width
            
            let imageHWRatio = size.height / size.width
            let viewHWRatio = viewH / viewW
            
            if imageHWRatio > viewHWRatio {
                frame.size.height = floor(width * imageHWRatio)
            } else {
                var height = floor(width * imageHWRatio)
                if height < 1 || height.isNaN {
                    height = viewH
                }
                frame.size.height = height
            }
        }
        
        imageView.frame = frame
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            if frame.height < viewH {
                imageView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            } else {
                imageView.frame = CGRect(origin: CGPoint(x: (viewW - frame.width) / 2, y: 0), size: frame.size)
            }
        } else {
            if frame.width < viewW || frame.height < viewH {
                imageView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            }
        }
    }
    
    func animateImageFrame(convertTo view: UIView) -> CGRect {
        return .zero
    }
    
}

// MARK: local image preview cell

class ZLLocalImagePreviewCell: ZLPreviewBaseCell {
    
    override var currentImage: UIImage? {
        return preview.image
    }
    
    lazy var preview: ZLPreviewView = {
        let view = ZLPreviewView()
        view.singleTapBlock = { [weak self] in
            self?.singleTapBlock?()
        }
        return view
    }()
    
    var image: UIImage? {
        didSet {
            preview.image = image
            preview.resetSubViewSize()
        }
    }
    
    var longPressBlock: (() -> Void)?
    
    deinit {
        zl_debugPrint("ZLLocalImagePreviewCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        preview.frame = bounds
    }
    
    private func setupUI() {
        contentView.addSubview(preview)
        
        let longGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        longGes.minimumPressDuration = 0.5
        addGestureRecognizer(longGes)
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        preview.scrollView.zoomScale = 1
    }
    
    @objc func longPressAction(_ ges: UILongPressGestureRecognizer) {
        guard currentImage != nil else {
            return
        }
        
        if ges.state == .began {
            longPressBlock?()
        }
    }
    
}

// MARK: net image preview cell

class ZLNetImagePreviewCell: ZLLocalImagePreviewCell {
    
    private lazy var progressView: ZLProgressView = {
        let view = ZLProgressView()
        view.isHidden = true
        return view
    }()
    
    var progress: CGFloat = 0 {
        didSet {
            progressView.progress = progress
            progressView.isHidden = progress >= 1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(progressView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bringSubviewToFront(progressView)
        progressView.frame = CGRect(x: bounds.width / 2 - 20, y: bounds.height / 2 - 20, width: 40, height: 40)
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        progressView.isHidden = true
        preview.scrollView.zoomScale = 1
    }
    
}

// MARK: static image preview cell

class ZLPhotoPreviewCell: ZLPreviewBaseCell {
    
    override var currentImage: UIImage? {
        return preview.image
    }
    
    private lazy var preview: ZLPreviewView = {
        let view = ZLPreviewView()
        view.singleTapBlock = { [weak self] in
            self?.singleTapBlock?()
        }
        return view
    }()
    
    var model: ZLPhotoModel! {
        didSet {
            preview.model = model
        }
    }
    
    deinit {
        zl_debugPrint("ZLPhotoPreviewCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        preview.frame = bounds
    }
    
    private func setupUI() {
        contentView.addSubview(preview)
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        preview.scrollView.zoomScale = 1
    }
    
    override func animateImageFrame(convertTo view: UIView) -> CGRect {
        let rect = preview.scrollView.convert(preview.containerView.frame, to: self)
        return convert(rect, to: view)
    }
    
}

// MARK: gif preview cell

class ZLGifPreviewCell: ZLPreviewBaseCell {
    
    override var currentImage: UIImage? {
        return preview.image
    }
    
    private lazy var preview: ZLPreviewView = {
        let view = ZLPreviewView()
        view.singleTapBlock = { [weak self] in
            self?.singleTapBlock?()
        }
        return view
    }()
    
    var model: ZLPhotoModel! {
        didSet {
            preview.model = model
        }
    }
    
    deinit {
        zl_debugPrint("ZLGifPreviewCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        preview.frame = bounds
    }
    
    private func setupUI() {
        contentView.addSubview(preview)
    }
    
    override func previewVCScroll() {
        preview.pauseGif()
    }
    
    func resumeGif() {
        preview.resumeGif()
    }
    
    func pauseGif() {
        preview.pauseGif()
    }
    
    /// gif图加载会导致主线程卡顿一下，所以放在willdisplay时候加载
    func loadGifWhenCellDisplaying() {
        preview.loadGifData()
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        preview.scrollView.zoomScale = 1
    }
    
    override func animateImageFrame(convertTo view: UIView) -> CGRect {
        let rect = preview.scrollView.convert(preview.containerView.frame, to: self)
        return convert(rect, to: view)
    }
    
}

// MARK: live photo preview cell

class ZLLivePhotoPreviewCell: ZLPreviewBaseCell {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var imageRequestID = PHInvalidImageRequestID
    
    private var livePhotoRequestID = PHInvalidImageRequestID
    
    private var onFetchingLivePhoto = false
    
    private var fetchLivePhotoDone = false
    
    var model: ZLPhotoModel! {
        didSet {
            loadNormalImage()
        }
    }
    
    lazy var livePhotoView: PHLivePhotoView = {
        let view = PHLivePhotoView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override var currentImage: UIImage? {
        return imageView.image
    }
    
    deinit {
        zl_debugPrint("ZLLivePhotoPewviewCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        livePhotoView.frame = bounds
        resizeImageView(imageView: imageView, asset: model.asset)
    }
    
    override func previewVCScroll() {
        livePhotoView.stopPlayback()
    }
    
    override func animateImageFrame(convertTo view: UIView) -> CGRect {
        return convert(imageView.frame, to: view)
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        PHImageManager.default().cancelImageRequest(livePhotoRequestID)
    }
    
    private func setupUI() {
        contentView.addSubview(livePhotoView)
        contentView.addSubview(imageView)
    }
    
    private func loadNormalImage() {
        if imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        if livePhotoRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(livePhotoRequestID)
        }
        onFetchingLivePhoto = false
        imageView.isHidden = false
        
        // livephoto 加载个较小的预览图即可
        var size = model.previewSize
        size.width /= 4
        size.height /= 4
        
        resizeImageView(imageView: imageView, asset: model.asset)
        imageRequestID = ZLPhotoManager.fetchImage(for: model.asset, size: size, completion: { [weak self] image, _ in
            self?.imageView.image = image
        })
    }
    
    private func startPlayLivePhoto() {
        imageView.isHidden = true
        livePhotoView.startPlayback(with: .full)
    }
    
    func loadLivePhotoData() {
        guard !onFetchingLivePhoto else {
            if fetchLivePhotoDone {
                startPlayLivePhoto()
            }
            return
        }
        onFetchingLivePhoto = true
        fetchLivePhotoDone = false
        
        livePhotoRequestID = ZLPhotoManager.fetchLivePhoto(for: model.asset, completion: { livePhoto, _, isDegraded in
            if !isDegraded {
                self.fetchLivePhotoDone = true
                self.livePhotoView.livePhoto = livePhoto
                self.startPlayLivePhoto()
            }
        })
    }
    
}

// MARK: video preview cell

class ZLVideoPreviewCell: ZLPreviewBaseCell {
    
    override var currentImage: UIImage? {
        return imageView.image
    }
    
    private var player: AVPlayer?
    
    private var playerLayer: AVPlayerLayer?
    
    private lazy var progressView = ZLProgressView()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var playBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.zl.getImage("zl_playVideo"), for: .normal)
        btn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var syncErrorLabel: UILabel = {
        let attStr = NSMutableAttributedString()
        let attach = NSTextAttachment()
        attach.image = .zl.getImage("zl_videoLoadFailed")
        attach.bounds = CGRect(x: 0, y: -10, width: 30, height: 30)
        attStr.append(NSAttributedString(attachment: attach))
        let errorText = NSAttributedString(
            string: localLanguageTextValue(.iCloudVideoLoadFaild),
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.zl.font(ofSize: 12)
            ]
        )
        attStr.append(errorText)
        
        let label = UILabel()
        label.attributedText = attStr
        return label
    }()
    
    private var imageRequestID = PHInvalidImageRequestID
    
    private var videoRequestID = PHInvalidImageRequestID
    
    private var onFetchingVideo = false
    
    private var fetchVideoDone = false
    
    var isPlaying: Bool {
        if player != nil, player?.rate != 0 {
            return true
        }
        return false
    }
    
    var model: ZLPhotoModel! {
        didSet {
            configureCell()
        }
    }
    
    deinit {
        zl_debugPrint("ZLVideoPreviewCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
        resizeImageView(imageView: imageView, asset: model.asset)
        let insets = deviceSafeAreaInsets()
        playBtn.frame = CGRect(x: 0, y: insets.top, width: bounds.width, height: bounds.height - insets.top - insets.bottom)
        syncErrorLabel.frame = CGRect(x: 10, y: insets.top + 60, width: bounds.width - 20, height: 35)
        progressView.frame = CGRect(x: bounds.width / 2 - 30, y: bounds.height / 2 - 30, width: 60, height: 60)
    }
    
    override func previewVCScroll() {
        if player != nil, player?.rate != 0 {
            pausePlayer(seekToZero: false)
        }
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        imageView.isHidden = false
        player?.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
    }
    
    override func animateImageFrame(convertTo view: UIView) -> CGRect {
        return convert(imageView.frame, to: view)
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(syncErrorLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(playBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func configureCell() {
        imageView.image = nil
        imageView.isHidden = false
        syncErrorLabel.isHidden = true
        playBtn.isEnabled = false
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        if imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        if videoRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(videoRequestID)
        }
        
        // 视频预览图尺寸
        var size = model.previewSize
        size.width /= 2
        size.height /= 2
        
        resizeImageView(imageView: imageView, asset: model.asset)
        imageRequestID = ZLPhotoManager.fetchImage(for: model.asset, size: size, completion: { image, _ in
            self.imageView.image = image
        })
        
        videoRequestID = ZLPhotoManager.fetchVideo(for: model.asset, progress: { [weak self] progress, _, _, _ in
            self?.progressView.progress = progress
            zl_debugPrint("video progress \(progress)")
            if progress >= 1 {
                zl_debugPrint("video load finished")
                self?.progressView.isHidden = true
            } else {
                self?.progressView.isHidden = false
            }
        }, completion: { [weak self] item, info, isDegraded in
            let error = info?[PHImageErrorKey] as? Error
            let isFetchError = ZLPhotoManager.isFetchImageError(error)
            if isFetchError {
                self?.syncErrorLabel.isHidden = false
                self?.playBtn.setImage(nil, for: .normal)
            }
            if !isDegraded, item != nil {
                self?.fetchVideoDone = true
                self?.configurePlayerLayer(item!)
            }
        })
    }
    
    private func configurePlayerLayer(_ item: AVPlayerItem) {
        playBtn.setImage(.zl.getImage("zl_playVideo"), for: .normal)
        playBtn.isEnabled = true
        
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        layer.insertSublayer(playerLayer!, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playFinish), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    @objc private func playBtnClick() {
        let currentTime = player?.currentItem?.currentTime()
        let duration = player?.currentItem?.duration
        if player?.rate == 0 {
            if currentTime?.value == duration?.value {
                player?.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
            }
            imageView.isHidden = true
            player?.play()
            playBtn.setImage(nil, for: .normal)
            singleTapBlock?()
        } else {
            pausePlayer(seekToZero: false)
        }
    }
    
    @objc private func playFinish() {
        pausePlayer(seekToZero: true)
    }
    
    @objc private func appWillResignActive() {
        if player != nil, player?.rate != 0 {
            pausePlayer(seekToZero: false)
        }
    }
    
    private func pausePlayer(seekToZero: Bool) {
        player?.pause()
        if seekToZero {
            player?.seek(to: .zero)
        }
        playBtn.setImage(.zl.getImage("zl_playVideo"), for: .normal)
        singleTapBlock?()
    }
    
    func pauseWhileTransition() {
        player?.pause()
        playBtn.setImage(.zl.getImage("zl_playVideo"), for: .normal)
    }
    
}

// MARK: net video preview cell

class ZLNetVideoPreviewCell: ZLPreviewBaseCell {
    
    private var player: AVPlayer?
    
    private var playerLayer: AVPlayerLayer?
    
    private lazy var playBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.zl.getImage("zl_playVideo"), for: .normal)
        btn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        return btn
    }()
    
    var isPlaying: Bool {
        if player != nil, player?.rate != 0 {
            return true
        }
        return false
    }
    
    deinit {
        zl_debugPrint("v deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        let insets = deviceSafeAreaInsets()
        playBtn.frame = CGRect(x: 0, y: insets.top, width: bounds.width, height: bounds.height - insets.top - insets.bottom)
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        player?.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
    }
    
    private func setupUI() {
        contentView.addSubview(playBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc private func playBtnClick() {
        let currentTime = player?.currentItem?.currentTime()
        let duration = player?.currentItem?.duration
        if player?.rate == 0 {
            if currentTime?.value == duration?.value {
                player?.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
            }
            player?.play()
            playBtn.setImage(nil, for: .normal)
            singleTapBlock?()
        } else {
            pausePlayer(seekToZero: false)
        }
    }
    
    @objc private func playFinish() {
        pausePlayer(seekToZero: true)
    }
    
    @objc private func appWillResignActive() {
        if player != nil, player?.rate != 0 {
            pausePlayer(seekToZero: false)
        }
    }
    
    override func previewVCScroll() {
        if player != nil, player?.rate != 0 {
            pausePlayer(seekToZero: false)
        }
    }
    
    private func pausePlayer(seekToZero: Bool) {
        player?.pause()
        if seekToZero {
            player?.seek(to: .zero)
        }
        playBtn.setImage(.zl.getImage("zl_playVideo"), for: .normal)
        singleTapBlock?()
    }
    
    func configureCell(videoUrl: URL, httpHeader: [String: Any]?) {
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        var options: [String: Any] = [:]
        options["AVURLAssetHTTPHeaderFieldsKey"] = httpHeader
        let asset = AVURLAsset(url: videoUrl, options: options)
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        layer.insertSublayer(playerLayer!, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playFinish), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
}

// MARK: class ZLPreviewView

class ZLPreviewView: UIView {
    
    private static let defaultMaxZoomScale: CGFloat = 3
    
    private lazy var progressView = ZLProgressView()
    
    private var imageRequestID = PHInvalidImageRequestID
    
    private var gifImageRequestID = PHInvalidImageRequestID
    
    private var imageIdentifier = ""
    
    private var onFetchingGif = false
    
    private var fetchGifDone = false
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.maximumZoomScale = ZLPreviewView.defaultMaxZoomScale
        view.minimumZoomScale = 1
        view.isMultipleTouchEnabled = true
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delaysContentTouches = false
        return view
    }()
    
    lazy var containerView = UIView()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var singleTapBlock: (() -> Void)?
    
    var doubleTapBlock: (() -> Void)?
    
    var model: ZLPhotoModel! {
        didSet {
            self.configureView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        progressView.frame = CGRect(x: bounds.width / 2 - 20, y: bounds.height / 2 - 20, width: 40, height: 40)
        scrollView.zoomScale = 1
        resetSubViewSize()
    }
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(imageView)
        addSubview(progressView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    @objc private func singleTapAction(_ tap: UITapGestureRecognizer) {
        singleTapBlock?()
    }
    
    @objc private func doubleTapAction(_ tap: UITapGestureRecognizer) {
        let scale: CGFloat = scrollView.zoomScale != scrollView.maximumZoomScale ? scrollView.maximumZoomScale : 1
        let tapPoint = tap.location(in: self)
        var rect = CGRect.zero
        rect.size.width = scrollView.frame.width / scale
        rect.size.height = scrollView.frame.height / scale
        rect.origin.x = tapPoint.x - (rect.size.width / 2)
        rect.origin.y = tapPoint.y - (rect.size.height / 2)
        scrollView.zoom(to: rect, animated: true)
    }
    
    private func configureView() {
        if imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        if gifImageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(gifImageRequestID)
        }
        
        scrollView.zoomScale = 1
        imageIdentifier = model.ident
        
        if ZLPhotoConfiguration.default().allowSelectGif, model.type == .gif {
            loadGifFirstFrame()
        } else {
            loadPhoto()
        }
    }
    
    private func requestPhotoSize(gif: Bool) -> CGSize {
        // gif 情况下优先加载一个小的缩略图
        var size = model.previewSize
        if gif {
            size.width /= 2
            size.height /= 2
        }
        return size
    }
    
    private func loadPhoto() {
        if let editImage = model.editImage {
            imageView.image = editImage
            resetSubViewSize()
        } else {
            imageRequestID = ZLPhotoManager.fetchImage(for: model.asset, size: requestPhotoSize(gif: false), progress: { [weak self] progress, _, _, _ in
                self?.progressView.progress = progress
                if progress >= 1 {
                    self?.progressView.isHidden = true
                } else {
                    self?.progressView.isHidden = false
                }
            }, completion: { [weak self] image, isDegraded in
                guard self?.imageIdentifier == self?.model.ident else {
                    return
                }
                self?.imageView.image = image
                self?.resetSubViewSize()
                if !isDegraded {
                    self?.progressView.isHidden = true
                    self?.imageRequestID = PHInvalidImageRequestID
                }
            })
        }
    }
    
    private func loadGifFirstFrame() {
        onFetchingGif = false
        fetchGifDone = false
        
        imageRequestID = ZLPhotoManager.fetchImage(for: model.asset, size: requestPhotoSize(gif: true), completion: { [weak self] image, _ in
            guard self?.imageIdentifier == self?.model.ident else {
                return
            }
            if self?.fetchGifDone == false {
                self?.imageView.image = image
                self?.resetSubViewSize()
            }
        })
    }
    
    func loadGifData() {
        guard !onFetchingGif else {
            if fetchGifDone {
                resumeGif()
            }
            return
        }
        onFetchingGif = true
        fetchGifDone = false
        imageView.layer.speed = 1
        imageView.layer.timeOffset = 0
        imageView.layer.beginTime = 0
        gifImageRequestID = ZLPhotoManager.fetchOriginalImageData(for: model.asset, progress: { [weak self] progress, _, _, _ in
            self?.progressView.progress = progress
            if progress >= 1 {
                self?.progressView.isHidden = true
            } else {
                self?.progressView.isHidden = false
            }
        }, completion: { [weak self] data, _, isDegraded in
            guard self?.imageIdentifier == self?.model.ident else {
                return
            }
            if !isDegraded {
                self?.fetchGifDone = true
                self?.imageView.image = UIImage.zl.animateGifImage(data: data)
                self?.resetSubViewSize()
            }
        })
    }
    
    func resetSubViewSize() {
        let size: CGSize
        if let model = model {
            if let ei = model.editImage {
                size = ei.size
            } else {
                size = CGSize(width: model.asset.pixelWidth, height: model.asset.pixelHeight)
            }
        } else {
            size = imageView.image?.size ?? bounds.size
        }
        
        var frame: CGRect = .zero
        
        let viewW = bounds.width
        let viewH = bounds.height
        
        var width = viewW
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let height = viewH
            frame.size.height = height
            
            let imageWHRatio = size.width / size.height
            let viewWHRatio = viewW / viewH
            
            if imageWHRatio > viewWHRatio {
                frame.size.width = floor(height * imageWHRatio)
                if frame.size.width > viewW {
                    // 宽图
                    frame.size.width = viewW
                    frame.size.height = viewW / imageWHRatio
                }
            } else {
                width = floor(height * imageWHRatio)
                if width < 1 || width.isNaN {
                    width = viewW
                }
                frame.size.width = width
            }
        } else {
            frame.size.width = width
            
            let imageHWRatio = size.height / size.width
            let viewHWRatio = viewH / viewW
            
            if imageHWRatio > viewHWRatio {
                // 长图
                frame.size.width = min(size.width, viewW)
                frame.size.height = floor(frame.size.width * imageHWRatio)
            } else {
                var height = floor(frame.size.width * imageHWRatio)
                if height < 1 || height.isNaN {
                    height = viewH
                }
                frame.size.height = height
            }
        }
        
        // 优化 scroll view zoom scale
        if frame.width < frame.height {
            scrollView.maximumZoomScale = max(ZLPreviewView.defaultMaxZoomScale, viewW / frame.width)
        } else {
            scrollView.maximumZoomScale = max(ZLPreviewView.defaultMaxZoomScale, viewH / frame.height)
        }
        
        containerView.frame = frame
        
        var contenSize: CGSize = .zero
        if UIApplication.shared.statusBarOrientation.isLandscape {
            contenSize = CGSize(width: width, height: max(viewH, frame.height))
            if frame.height < viewH {
                containerView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            } else {
                containerView.frame = CGRect(origin: CGPoint(x: (viewW - frame.width) / 2, y: 0), size: frame.size)
            }
        } else {
            contenSize = frame.size
            if frame.height < viewH {
                containerView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            } else {
                containerView.frame = CGRect(origin: CGPoint(x: (viewW - frame.width) / 2, y: 0), size: frame.size)
            }
        }
        
        ZLMainAsync(after: 0.01) {
            self.scrollView.contentSize = contenSize
            self.imageView.frame = self.containerView.bounds
            self.scrollView.contentOffset = .zero
        }
    }
    
    func resumeGif() {
        guard let m = model else { return }
        guard ZLPhotoConfiguration.default().allowSelectGif, m.type == .gif else { return }
        guard imageView.layer.speed != 1 else { return }
        
        let pauseTime = imageView.layer.timeOffset
        imageView.layer.speed = 1
        imageView.layer.timeOffset = 0
        imageView.layer.beginTime = 0
        let timeSincePause = imageView.layer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        imageView.layer.beginTime = timeSincePause
    }
    
    func pauseGif() {
        guard let m = model else { return }
        guard ZLPhotoConfiguration.default().allowSelectGif, m.type == .gif else { return }
        guard imageView.layer.speed != 0 else { return }
        
        let pauseTime = imageView.layer.convertTime(CACurrentMediaTime(), from: nil)
        imageView.layer.speed = 0
        imageView.layer.timeOffset = pauseTime
    }
    
}

extension ZLPreviewView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        containerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resumeGif()
    }
    
}
