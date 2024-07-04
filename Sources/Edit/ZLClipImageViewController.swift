//
//  ZLClipImageViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/27.
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

extension ZLClipImageViewController {
    enum ClipPanEdge {
        case none
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
}

class ZLClipImageViewController: UIViewController {
    private static let bottomToolViewH: CGFloat = 90
    
    private static let clipRatioItemSize = CGSize(width: 60, height: 70)
    
    /// 取消裁剪时动画frame
    private var cancelClipAnimateFrame: CGRect = .zero
    
    private var viewDidAppearCount = 0
    
    private let originalImage: UIImage
    
    private let clipRatios: [ZLImageClipRatio]

    private var editImage: UIImage
    
    /// 初次进入界面时候，裁剪范围
    private var editRect: CGRect
    
    /// 初次进去界面时的动画占位view
    private lazy var animateImageView: UIImageView? = {
        guard let presentAnimateFrame, let presentAnimateImage else {
            return nil
        }
        
        let view = UIImageView(image: presentAnimateImage)
        view.frame = presentAnimateFrame
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var mainScrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        view.delegate = self
        return view
    }()
    
    private lazy var containerView = UIView()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = editImage
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var overlayView: ZLClipOverlayView = {
        let view = ZLClipOverlayView(frame: view.frame)
        view.isUserInteractionEnabled = false
        view.isCircle = selectedRatio.isCircle
        return view
    }()
    
    private lazy var gridPanGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(gridGesPanAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    private lazy var bottomToolView = UIView()
    
    private lazy var bottomShadowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.15).cgColor,
            UIColor.black.withAlphaComponent(0.35).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    
    private lazy var bottomToolLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.rgba(240, 240, 240)
        return view
    }()
    
    private lazy var cancelBtn: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setImage(.zl.getImage("zl_close"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.enlargeInset = 20
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var revertBtn: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(localLanguageTextValue(.revert), for: .normal)
        btn.enlargeInset = 20
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.addTarget(self, action: #selector(revertBtnClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var doneBtn: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setImage(.zl.getImage("zl_right"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.enlargeInset = 20
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var rotateBtn: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setImage(.zl.getImage("zl_rotateimage"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.enlargeInset = 20
        btn.addTarget(self, action: #selector(rotateBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var clipRatioColView: UICollectionView = {
        let layout = ZLCollectionViewFlowLayout()
        layout.itemSize = ZLClipImageViewController.clipRatioItemSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.alpha = 0
        view.showsHorizontalScrollIndicator = false
        ZLImageClipRatioCell.zl.register(view)
        return view
    }()
    
    private var shouldLayout = true
    
    private var panEdge: ZLClipImageViewController.ClipPanEdge = .none
    
    private var beginPanPoint: CGPoint = .zero
    
    private var clipBoxFrame: CGRect = .zero
    
    private var clipOriginFrame: CGRect = .zero
    
    private var isAnimate = false
    
    private var angle: CGFloat = 0
    
    private var selectedRatio: ZLImageClipRatio {
        didSet {
            overlayView.isCircle = selectedRatio.isCircle
        }
    }
    
    private var thumbnailImage: UIImage?
    
    private lazy var maxClipFrame = calculateMaxClipFrame()
    
    private var minClipSize = CGSize(width: 45, height: 45)
    
    private var resetTimer: Timer?
    
    private var showRatioColView: Bool { clipRatios.count > 1 }
    
    var animate = true
    /// 用作进入裁剪界面首次动画frame
    var presentAnimateFrame: CGRect?
    /// 用作进入裁剪界面首次动画和取消裁剪时动画的image
    var presentAnimateImage: UIImage?
    
    var dismissAnimateFromRect: CGRect = .zero
    
    var dismissAnimateImage: UIImage?
    
    /// 传回旋转角度，图片编辑区域的rect
    var clipDoneBlock: ((CGFloat, CGRect, ZLImageClipRatio) -> Void)?
    
    var cancelClipBlock: (() -> Void)?
    
    override var prefersStatusBarHidden: Bool { true }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    /// 延缓屏幕上下方通知栏弹出，避免手势冲突
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { [.top, .bottom] }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        deviceIsiPhone() ? .portrait : .all
    }
    
    deinit {
        zl_debugPrint("ZLClipImageViewController deinit")
        cleanTimer()
    }
    
    init(image: UIImage, status: ZLClipStatus) {
        originalImage = image
        let configuration = ZLPhotoConfiguration.default().editImageConfiguration
        clipRatios = configuration.clipRatios
        editRect = status.editRect
        angle = status.angle
        let angle = ((Int(angle) % 360) - 360) % 360
        if angle == -90 {
            editImage = image.zl.rotate(orientation: .left)
        } else if angle == -180 {
            editImage = image.zl.rotate(orientation: .down)
        } else if angle == -270 {
            editImage = image.zl.rotate(orientation: .right)
        } else {
            editImage = image
        }
        var firstEnter = false
        if let ratio = status.ratio {
            selectedRatio = ratio
        } else {
            firstEnter = true
            selectedRatio = ZLPhotoConfiguration.default().editImageConfiguration.clipRatios.first!
        }
        super.init(nibName: nil, bundle: nil)
        if firstEnter {
            calculateClipRect()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        generateThumbnailImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearCount += 1
        if presentingViewController is ZLEditImageViewController {
            transitioningDelegate = self
        }
        
        guard viewDidAppearCount == 1 else {
            return
        }
        
        if let animateImageView {
            cancelClipAnimateFrame = clipBoxFrame
            UIView.animate(withDuration: 0.25) {
                animateImageView.frame = self.clipBoxFrame
                self.bottomToolView.alpha = 1
                self.rotateBtn.alpha = 1
                self.clipRatioColView.alpha = self.showRatioColView ? 1 : 0
            } completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.mainScrollView.alpha = 1
                    self.overlayView.alpha = 1
                } completion: { _ in
                    animateImageView.removeFromSuperview()
                }
            }
        } else {
            bottomToolView.alpha = 1
            rotateBtn.alpha = 1
            mainScrollView.alpha = 1
            overlayView.alpha = 1
            clipRatioColView.alpha = clipRatios.count <= 1 ? 0 : 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard shouldLayout else { return }
        shouldLayout = false
        
        mainScrollView.frame = view.bounds
        
        layoutInitialImage(animate: true)
        
        bottomToolView.frame = CGRect(x: 0, y: view.bounds.height - ZLClipImageViewController.bottomToolViewH, width: view.bounds.width, height: ZLClipImageViewController.bottomToolViewH)
        bottomShadowLayer.frame = bottomToolView.bounds
        
        bottomToolLineView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 1 / UIScreen.main.scale)
        let toolBtnH: CGFloat = 25
        let toolBtnY = (ZLClipImageViewController.bottomToolViewH - toolBtnH) / 2 - 10
        cancelBtn.frame = CGRect(x: 30, y: toolBtnY, width: toolBtnH, height: toolBtnH)
        let revertBtnW = localLanguageTextValue(.revert).zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: toolBtnH)).width + 20
        revertBtn.frame = CGRect(x: (view.bounds.width - revertBtnW) / 2, y: toolBtnY, width: revertBtnW, height: toolBtnH)
        doneBtn.frame = CGRect(x: view.bounds.width - 30 - toolBtnH, y: toolBtnY, width: toolBtnH, height: toolBtnH)
        
        let ratioColViewY = bottomToolView.frame.minY - ZLClipImageViewController.clipRatioItemSize.height - 5
        rotateBtn.frame = CGRect(x: 30, y: ratioColViewY + (ZLClipImageViewController.clipRatioItemSize.height - 25) / 2, width: 25, height: 25)
        let ratioColViewX = rotateBtn.frame.maxX + 15
        clipRatioColView.frame = CGRect(x: ratioColViewX, y: ratioColViewY, width: view.bounds.width - ratioColViewX, height: 70)
        
        if showRatioColView, let index = clipRatios.firstIndex(where: { $0 == self.selectedRatio }) {
            clipRatioColView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        shouldLayout = true
        maxClipFrame = calculateMaxClipFrame()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(containerView)
        containerView.addSubview(imageView)
        view.addSubview(overlayView)
        
        view.addSubview(bottomToolView)
        bottomToolView.layer.addSublayer(bottomShadowLayer)
        bottomToolView.addSubview(bottomToolLineView)
        bottomToolView.addSubview(cancelBtn)
        bottomToolView.addSubview(revertBtn)
        bottomToolView.addSubview(doneBtn)
        
        view.addSubview(rotateBtn)
        view.addSubview(clipRatioColView)
        
        if let animateImageView {
            view.addSubview(animateImageView)
        }
        
        view.addGestureRecognizer(gridPanGes)
        mainScrollView.panGestureRecognizer.require(toFail: gridPanGes)
        
        mainScrollView.alpha = 0
        overlayView.alpha = 0
        bottomToolView.alpha = 0
        rotateBtn.alpha = 0
    }
    
    private func generateThumbnailImage() {
        let size: CGSize
        let ratio = (editImage.size.width / editImage.size.height)
        let fixLength: CGFloat = 100
        if ratio >= 1 {
            size = CGSize(width: fixLength * ratio, height: fixLength)
        } else {
            size = CGSize(width: fixLength, height: fixLength / ratio)
        }
        thumbnailImage = editImage.zl.resize_vI(size)
    }
    
    /// 计算最大裁剪范围
    private func calculateMaxClipFrame() -> CGRect {
        var insets = deviceSafeAreaInsets()
        insets.top += 20
        var rect = CGRect.zero
        rect.origin.x = 15
        rect.origin.y = insets.top
        rect.size.width = UIScreen.main.bounds.width - 15 * 2
        rect.size.height = UIScreen.main.bounds.height - insets.top - ZLClipImageViewController.bottomToolViewH - ZLClipImageViewController.clipRatioItemSize.height - 25
        return rect
    }
    
    private func calculateClipRect() {
        if selectedRatio.whRatio == 0 {
            editRect = CGRect(origin: .zero, size: editImage.size)
        } else {
            let imageSize = editImage.size
            let imageWHRatio = imageSize.width / imageSize.height
            
            var w: CGFloat = 0, h: CGFloat = 0
            if selectedRatio.whRatio >= imageWHRatio {
                w = imageSize.width
                h = w / selectedRatio.whRatio
            } else {
                h = imageSize.height
                w = h * selectedRatio.whRatio
            }
            
            editRect = CGRect(x: (imageSize.width - w) / 2, y: (imageSize.height - h) / 2, width: w, height: h)
        }
    }
    
    private func layoutInitialImage(animate: Bool) {
        mainScrollView.minimumZoomScale = 1
        mainScrollView.maximumZoomScale = 1
        mainScrollView.zoomScale = 1
        
        let editSize = editRect.size
        mainScrollView.contentSize = editSize
        let maxClipRect = maxClipFrame
        
        containerView.frame = CGRect(origin: .zero, size: editImage.size)
        imageView.frame = containerView.bounds
        
        // editRect比例，计算editRect所占frame
        let editScale = min(maxClipRect.width / editSize.width, maxClipRect.height / editSize.height)
        let scaledSize = CGSize(width: floor(editSize.width * editScale), height: floor(editSize.height * editScale))
        
        // 计算当前裁剪rect区域
        var frame = CGRect.zero
        frame.size = scaledSize
        frame.origin.x = maxClipRect.minX + floor((maxClipRect.width - frame.width) / 2)
        frame.origin.y = maxClipRect.minY + floor((maxClipRect.height - frame.height) / 2)
        
        // 按照edit image进行计算缩放比例
        let originalScale = max(frame.width / editImage.size.width, frame.height / editImage.size.height)
        
        // 将 edit rect 相对 originalScale 进行缩放，缩放到图片未放大时候的clip rect
        let scaleEditSize = CGSize(width: editRect.width * originalScale, height: editRect.height * originalScale)
        // 计算缩放后的clip rect相对maxClipRect的比例
        let clipRectZoomScale = min(maxClipRect.width / scaleEditSize.width, maxClipRect.height / scaleEditSize.height)
        
        mainScrollView.minimumZoomScale = originalScale
        mainScrollView.maximumZoomScale = 10
        // 设置当前zoom scale
        let zoomScale = clipRectZoomScale * originalScale
        mainScrollView.zoomScale = zoomScale
        mainScrollView.contentSize = CGSize(width: editImage.size.width * zoomScale, height: editImage.size.height * zoomScale)
        
        changeClipBoxFrame(newFrame: frame, animate: animate, updateInset: animate)
        
        if (frame.size.width < scaledSize.width - CGFloat.ulpOfOne) || (frame.size.height < scaledSize.height - CGFloat.ulpOfOne) {
            var offset = CGPoint.zero
            offset.x = -floor((mainScrollView.frame.width - scaledSize.width) / 2)
            offset.y = -floor((mainScrollView.frame.height - scaledSize.height) / 2)
            mainScrollView.contentOffset = offset
        }
        
        // edit rect 相对 image size 的 偏移量
        let diffX = editRect.origin.x / editImage.size.width * mainScrollView.contentSize.width
        let diffY = editRect.origin.y / editImage.size.height * mainScrollView.contentSize.height
        mainScrollView.contentOffset = CGPoint(x: -mainScrollView.contentInset.left + diffX, y: -mainScrollView.contentInset.top + diffY)
    }
    
    private func changeClipBoxFrame(newFrame: CGRect, animate: Bool, updateInset: Bool, endEditing: Bool = false) {
        guard clipBoxFrame != newFrame else {
            // 可能是拖拽图片和缩放图片，编辑区域未改变，这里也要调用下endUpdate
            if endEditing {
                overlayView.endUpdate()
            }
            return
        }
        if newFrame.width < CGFloat.ulpOfOne || newFrame.height < CGFloat.ulpOfOne {
            return
        }
        var frame = newFrame
        let originX = ceil(maxClipFrame.minX)
        let diffX = frame.minX - originX
        frame.origin.x = max(frame.minX, originX)
//        frame.origin.x = floor(max(frame.minX, originX))
        if diffX < -CGFloat.ulpOfOne {
            frame.size.width += diffX
        }
        let originY = ceil(maxClipFrame.minY)
        let diffY = frame.minY - originY
        frame.origin.y = max(frame.minY, originY)
//        frame.origin.y = floor(max(frame.minY, originY))
        if diffY < -CGFloat.ulpOfOne {
            frame.size.height += diffY
        }
        let maxW = maxClipFrame.width + maxClipFrame.minX - frame.minX
        frame.size.width = max(minClipSize.width, min(frame.width, maxW))
//        frame.size.width = floor(max(self.minClipSize.width, min(frame.width, maxW)))
        
        let maxH = maxClipFrame.height + maxClipFrame.minY - frame.minY
        frame.size.height = max(minClipSize.height, min(frame.height, maxH))
//        frame.size.height = floor(max(self.minClipSize.height, min(frame.height, maxH)))
        
        clipBoxFrame = frame
        overlayView.updateLayers(frame, animate: animate, endEditing: endEditing)
        
        if updateInset {
            updateMainScrollViewContentInsetAndScale()
        }
    }
    
    private func updateMainScrollViewContentInsetAndScale() {
        let frame = clipBoxFrame
        
        mainScrollView.contentInset = UIEdgeInsets(top: frame.minY, left: frame.minX, bottom: mainScrollView.frame.maxY - frame.maxY, right: mainScrollView.frame.maxX - frame.maxX)
        
        let scale = max(frame.height / editImage.size.height, frame.width / editImage.size.width)
        mainScrollView.minimumZoomScale = scale
        
//        var size = self.mainScrollView.contentSize
//        size.width = floor(size.width)
//        size.height = floor(size.height)
//        self.mainScrollView.contentSize = size
        
        mainScrollView.zoomScale = mainScrollView.zoomScale
    }
    
    @objc private func cancelBtnClick() {
        dismissAnimateFromRect = cancelClipAnimateFrame
        dismissAnimateImage = presentAnimateImage
        cancelClipBlock?()
        dismiss(animated: animate, completion: nil)
    }
    
    @objc private func revertBtnClick() {
        guard !isAnimate else { return }
        
        configFakeAnimateImageView()
        let revertAngle: CGFloat
        // 如果角度最终效果是顺时针旋转了90度，还原时候就逆时针旋转，否则就顺时针旋转
        if (Int(angle) + 360) % 360 == 90 {
            revertAngle = CGFloat(-90).zl.toPi
        } else {
            revertAngle = -angle.zl.toPi
        }
        
        let transform = CGAffineTransform(rotationAngle: revertAngle)
        
        angle = 0
        editImage = originalImage
        calculateClipRect()
        imageView.image = editImage
        layoutInitialImage(animate: true)
        
        let toFrame = view.convert(containerView.frame, from: mainScrollView)
        animateFakeImageView {
            self.fakeAnimateImageView.transform = transform
            self.fakeAnimateImageView.frame = toFrame
        }
        
        generateThumbnailImage()
        clipRatioColView.reloadData()
    }
    
    @objc private func doneBtnClick() {
        let image = clipImage()
        dismissAnimateFromRect = clipBoxFrame
        dismissAnimateImage = image.clipImage
        if presentingViewController is ZLCustomCamera {
            dismiss(animated: animate) {
                self.clipDoneBlock?(self.angle, image.editRect, self.selectedRatio)
            }
        } else {
            clipDoneBlock?(angle, image.editRect, selectedRatio)
            dismiss(animated: animate, completion: nil)
        }
    }
    
    @objc private func rotateBtnClick() {
        guard !isAnimate else { return }
        
        angle -= 90
        if angle == -360 {
            angle = 0
        }
        
        configFakeAnimateImageView()
        
        if selectedRatio.whRatio == 0 || selectedRatio.whRatio == 1 {
            // 自由比例和1:1比例，进行edit rect转换
            
            // 将edit rect转换为相对edit image的rect
            let rect = convertClipRectToEditImageRect()
            // 旋转图片
            editImage = editImage.zl.rotate(orientation: .left)
            // 将rect进行旋转，转换到相对于旋转后的edit image的rect
            editRect = CGRect(x: rect.minY, y: editImage.size.height - rect.minX - rect.width, width: rect.height, height: rect.width)
            // 向右旋转可用下面这行代码
//            editRect = CGRect(x: editImage.size.width - rect.maxY, y: rect.minX, width: rect.height, height: rect.width)
        } else {
            // 旋转图片
            editImage = editImage.zl.rotate(orientation: .left)
            calculateClipRect()
        }
        
        imageView.image = editImage
        layoutInitialImage(animate: true)
        
        let toFrame = view.convert(containerView.frame, from: mainScrollView)
        let transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        animateFakeImageView {
            self.fakeAnimateImageView.transform = transform
            self.fakeAnimateImageView.frame = toFrame
        }
        
        generateThumbnailImage()
        clipRatioColView.reloadData()
    }
    
    /// 图片旋转、还原、切换比例时，用来动画的view
    private lazy var fakeAnimateImageView: UIImageView = {
        let animateImageView = UIImageView()
        animateImageView.contentMode = .scaleAspectFit
        animateImageView.clipsToBounds = true
        return animateImageView
    }()
    
    private func configFakeAnimateImageView() {
        fakeAnimateImageView.transform = .identity
        fakeAnimateImageView.image = editImage
        let originFrame = view.convert(containerView.frame, from: mainScrollView)
        fakeAnimateImageView.frame = originFrame
        view.insertSubview(fakeAnimateImageView, belowSubview: overlayView)
    }
    
    private func animateFakeImageView(animations: @escaping (() -> Void), completion: (() -> Void)? = nil) {
        containerView.alpha = 0
        isAnimate = true
        UIView.animate(withDuration: 0.25) {
            animations()
        } completion: { _ in
            self.containerView.alpha = 1
            self.isAnimate = false
            self.fakeAnimateImageView.removeFromSuperview()
            completion?()
        }
    }
    
    @objc private func gridGesPanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        if pan.state == .began {
            startEditing()
            beginPanPoint = point
            clipOriginFrame = clipBoxFrame
            panEdge = calculatePanEdge(at: point)
        } else if pan.state == .changed {
            guard panEdge != .none else {
                return
            }
            
            updateClipBoxFrame(point: point)
        } else if pan.state == .cancelled || pan.state == .ended {
            panEdge = .none
            startTimer()
        }
    }
    
    private func calculatePanEdge(at point: CGPoint) -> ZLClipImageViewController.ClipPanEdge {
        let frame = clipBoxFrame.insetBy(dx: -30, dy: -30)
        
        let cornerSize = CGSize(width: 60, height: 60)
        let topLeftRect = CGRect(origin: frame.origin, size: cornerSize)
        if topLeftRect.contains(point) {
            return .topLeft
        }
        
        let topRightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.minY), size: cornerSize)
        if topRightRect.contains(point) {
            return .topRight
        }
        
        let bottomLeftRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY - cornerSize.height), size: cornerSize)
        if bottomLeftRect.contains(point) {
            return .bottomLeft
        }
        
        let bottomRightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.maxY - cornerSize.height), size: cornerSize)
        if bottomRightRect.contains(point) {
            return .bottomRight
        }
        
        let topRect = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: cornerSize.height))
        if topRect.contains(point) {
            return .top
        }
        
        let bottomRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY - cornerSize.height), size: CGSize(width: frame.width, height: cornerSize.height))
        if bottomRect.contains(point) {
            return .bottom
        }
        
        let leftRect = CGRect(origin: frame.origin, size: CGSize(width: cornerSize.width, height: frame.height))
        if leftRect.contains(point) {
            return .left
        }
        
        let rightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.minY), size: CGSize(width: cornerSize.width, height: frame.height))
        if rightRect.contains(point) {
            return .right
        }
        
        return .none
    }
    
    private func updateClipBoxFrame(point: CGPoint) {
        var frame = clipBoxFrame
        let originFrame = clipOriginFrame
        
        var newPoint = point
        newPoint.x = max(maxClipFrame.minX, newPoint.x)
        newPoint.y = max(maxClipFrame.minY, newPoint.y)
        
        let diffX = ceil(newPoint.x - beginPanPoint.x)
        let diffY = ceil(newPoint.y - beginPanPoint.y)
        let ratio = selectedRatio.whRatio
        
        switch panEdge {
        case .left:
            frame.origin.x = originFrame.minX + diffX
            frame.size.width = originFrame.width - diffX
            if ratio != 0 {
                frame.size.height = originFrame.height - diffX / ratio
            }
        case .right:
            frame.size.width = originFrame.width + diffX
            if ratio != 0 {
                frame.size.height = originFrame.height + diffX / ratio
            }
        case .top:
            frame.origin.y = originFrame.minY + diffY
            frame.size.height = originFrame.height - diffY
            if ratio != 0 {
                frame.size.width = originFrame.width - diffY * ratio
            }
        case .bottom:
            frame.size.height = originFrame.height + diffY
            if ratio != 0 {
                frame.size.width = originFrame.width + diffY * ratio
            }
        case .topLeft:
            if ratio != 0 {
//                if abs(diffX / ratio) >= abs(diffY) {
                frame.origin.x = originFrame.minX + diffX
                frame.size.width = originFrame.width - diffX
                frame.origin.y = originFrame.minY + diffX / ratio
                frame.size.height = originFrame.height - diffX / ratio
//                } else {
//                    frame.origin.y = originFrame.minY + diffY
//                    frame.size.height = originFrame.height - diffY
//                    frame.origin.x = originFrame.minX + diffY * ratio
//                    frame.size.width = originFrame.width - diffY * ratio
//                }
            } else {
                frame.origin.x = originFrame.minX + diffX
                frame.size.width = originFrame.width - diffX
                frame.origin.y = originFrame.minY + diffY
                frame.size.height = originFrame.height - diffY
            }
        case .topRight:
            if ratio != 0 {
//                if abs(diffX / ratio) >= abs(diffY) {
                frame.size.width = originFrame.width + diffX
                frame.origin.y = originFrame.minY - diffX / ratio
                frame.size.height = originFrame.height + diffX / ratio
//                } else {
//                    frame.origin.y = originFrame.minY + diffY
//                    frame.size.height = originFrame.height - diffY
//                    frame.size.width = originFrame.width - diffY * ratio
//                }
            } else {
                frame.size.width = originFrame.width + diffX
                frame.origin.y = originFrame.minY + diffY
                frame.size.height = originFrame.height - diffY
            }
        case .bottomLeft:
            if ratio != 0 {
//                if abs(diffX / ratio) >= abs(diffY) {
                frame.origin.x = originFrame.minX + diffX
                frame.size.width = originFrame.width - diffX
                frame.size.height = originFrame.height - diffX / ratio
//                } else {
//                    frame.origin.x = originFrame.minX - diffY * ratio
//                    frame.size.width = originFrame.width + diffY * ratio
//                    frame.size.height = originFrame.height + diffY
//                }
            } else {
                frame.origin.x = originFrame.minX + diffX
                frame.size.width = originFrame.width - diffX
                frame.size.height = originFrame.height + diffY
            }
        case .bottomRight:
            if ratio != 0 {
//                if abs(diffX / ratio) >= abs(diffY) {
                frame.size.width = originFrame.width + diffX
                frame.size.height = originFrame.height + diffX / ratio
//                } else {
//                    frame.size.width += diffY * ratio
//                    frame.size.height += diffY
//                }
            } else {
                frame.size.width = originFrame.width + diffX
                frame.size.height = originFrame.height + diffY
            }
        default:
            break
        }
        
        let minSize: CGSize
        let maxSize: CGSize
        let maxClipFrame: CGRect
        if ratio != 0 {
            if ratio >= 1 {
                minSize = CGSize(width: minClipSize.height * ratio, height: minClipSize.height)
            } else {
                minSize = CGSize(width: minClipSize.width, height: minClipSize.width / ratio)
            }
            if ratio > self.maxClipFrame.width / self.maxClipFrame.height {
                maxSize = CGSize(width: self.maxClipFrame.width, height: self.maxClipFrame.width / ratio)
            } else {
                maxSize = CGSize(width: self.maxClipFrame.height * ratio, height: self.maxClipFrame.height)
            }
            maxClipFrame = CGRect(origin: CGPoint(x: self.maxClipFrame.minX + (self.maxClipFrame.width - maxSize.width) / 2, y: self.maxClipFrame.minY + (self.maxClipFrame.height - maxSize.height) / 2), size: maxSize)
        } else {
            minSize = minClipSize
            maxSize = self.maxClipFrame.size
            maxClipFrame = self.maxClipFrame
        }
        
        frame.size.width = min(maxSize.width, max(minSize.width, frame.size.width))
        frame.size.height = min(maxSize.height, max(minSize.height, frame.size.height))
        
        frame.origin.x = min(maxClipFrame.maxX - minSize.width, max(frame.origin.x, maxClipFrame.minX))
        frame.origin.y = min(maxClipFrame.maxY - minSize.height, max(frame.origin.y, maxClipFrame.minY))
        
        if panEdge == .topLeft || panEdge == .bottomLeft || panEdge == .left, frame.size.width <= minSize.width + CGFloat.ulpOfOne {
            frame.origin.x = originFrame.maxX - minSize.width
        }
        if panEdge == .topLeft || panEdge == .topRight || panEdge == .top, frame.size.height <= minSize.height + CGFloat.ulpOfOne {
            frame.origin.y = originFrame.maxY - minSize.height
        }
        
        changeClipBoxFrame(newFrame: frame, animate: false, updateInset: true)
    }
    
    private func startEditing() {
        cleanTimer()
        
        overlayView.beginUpdate()
        if rotateBtn.alpha != 0 {
            rotateBtn.layer.removeAllAnimations()
            clipRatioColView.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2) {
                self.rotateBtn.alpha = 0
                self.clipRatioColView.alpha = 0
            }
        }
    }
    
    @objc private func endEditing() {
        moveClipContentToCenter()
    }
    
    private func startTimer() {
        cleanTimer()
        
        resetTimer = Timer.scheduledTimer(timeInterval: 0.8, target: ZLWeakProxy(target: self), selector: #selector(endEditing), userInfo: nil, repeats: false)
        RunLoop.current.add(resetTimer!, forMode: .common)
    }
    
    private func cleanTimer() {
        resetTimer?.invalidate()
        resetTimer = nil
    }
    
    private func moveClipContentToCenter() {
        let maxClipRect = maxClipFrame
        var clipRect = clipBoxFrame
        
        if clipRect.width < CGFloat.ulpOfOne || clipRect.height < CGFloat.ulpOfOne {
            return
        }
        
        let scale = min(maxClipRect.width / clipRect.width, maxClipRect.height / clipRect.height)
        
        let focusPoint = CGPoint(x: clipRect.midX, y: clipRect.midY)
        let midPoint = CGPoint(x: maxClipRect.midX, y: maxClipRect.midY)
        
        clipRect.size.width = ceil(clipRect.width * scale)
        clipRect.size.height = ceil(clipRect.height * scale)
        clipRect.origin.x = maxClipRect.minX + ceil((maxClipRect.width - clipRect.width) / 2)
        clipRect.origin.y = maxClipRect.minY + ceil((maxClipRect.height - clipRect.height) / 2)
        
        var contentTargetPoint = CGPoint.zero
        contentTargetPoint.x = (focusPoint.x + mainScrollView.contentOffset.x) * scale
        contentTargetPoint.y = (focusPoint.y + mainScrollView.contentOffset.y) * scale
        
        var offset = CGPoint(x: contentTargetPoint.x - midPoint.x, y: contentTargetPoint.y - midPoint.y)
        offset.x = max(-clipRect.minX, offset.x)
        offset.y = max(-clipRect.minY, offset.y)
        
        changeClipBoxFrame(newFrame: clipRect, animate: true, updateInset: false, endEditing: true)
        UIView.animate(withDuration: 0.25) {
            if scale < 1 - CGFloat.ulpOfOne || scale > 1 + CGFloat.ulpOfOne {
                self.mainScrollView.zoomScale *= scale
                self.mainScrollView.zoomScale = min(self.mainScrollView.maximumZoomScale, self.mainScrollView.zoomScale)
            }

            if self.mainScrollView.zoomScale < self.mainScrollView.maximumZoomScale - CGFloat.ulpOfOne {
                offset.x = min(self.mainScrollView.contentSize.width - clipRect.maxX, offset.x)
                offset.y = min(self.mainScrollView.contentSize.height - clipRect.maxY, offset.y)
                self.mainScrollView.contentOffset = offset
            }
            
            self.updateMainScrollViewContentInsetAndScale()
            self.rotateBtn.alpha = 1
            self.clipRatioColView.alpha = self.showRatioColView ? 1 : 0
        }
    }
    
    private func clipImage() -> (clipImage: UIImage, editRect: CGRect) {
        let frame = convertClipRectToEditImageRect()
        let clipImage = editImage.zl.clipImage(angle: 0, editRect: frame, isCircle: selectedRatio.isCircle)
        return (clipImage, frame)
    }
    
    private func convertClipRectToEditImageRect() -> CGRect {
        let imageSize = editImage.size
        let contentSize = mainScrollView.contentSize
        let offset = mainScrollView.contentOffset
        let insets = mainScrollView.contentInset
        
        var frame = CGRect.zero
        frame.origin.x = floor((offset.x + insets.left) * (imageSize.width / contentSize.width))
        frame.origin.x = max(0, frame.origin.x)
        
        frame.origin.y = floor((offset.y + insets.top) * (imageSize.height / contentSize.height))
        frame.origin.y = max(0, frame.origin.y)
        
        frame.size.width = ceil(clipBoxFrame.width * (imageSize.width / contentSize.width))
        frame.size.width = min(imageSize.width, frame.width)
        
        frame.size.height = ceil(clipBoxFrame.height * (imageSize.height / contentSize.height))
        frame.size.height = min(imageSize.height, frame.height)
        
        return frame
    }
}

extension ZLClipImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == gridPanGes else {
            return true
        }
        
        let point = gestureRecognizer.location(in: view)
        let innerFrame = clipBoxFrame.insetBy(dx: 22, dy: 22)
        let outerFrame = clipBoxFrame.insetBy(dx: -22, dy: -22)
        
        if innerFrame.contains(point) || !outerFrame.contains(point) {
            return false
        }
        return true
    }
}

extension ZLClipImageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clipRatios.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLImageClipRatioCell.zl.identifier, for: indexPath) as! ZLImageClipRatioCell
        
        let ratio = clipRatios[indexPath.row]
        cell.configureCell(image: thumbnailImage ?? editImage, ratio: ratio)
        
        if ratio == selectedRatio {
            cell.titleLabel.textColor = .zl.imageEditorToolTitleTintColor
        } else {
            cell.titleLabel.textColor = .zl.imageEditorToolTitleNormalColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ratio = clipRatios[indexPath.row]
        guard ratio != selectedRatio, !isAnimate else {
            return
        }
        
        selectedRatio = ratio
        clipRatioColView.reloadData()
        clipRatioColView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        calculateClipRect()
        
        configFakeAnimateImageView()
        layoutInitialImage(animate: true)
        
        let toFrame = view.convert(containerView.frame, from: mainScrollView)
        animateFakeImageView {
            self.fakeAnimateImageView.frame = toFrame
        }
    }
}

extension ZLClipImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        startEditing()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard scrollView == mainScrollView else {
            return
        }
        if !scrollView.isDragging {
            startTimer()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == mainScrollView else {
            return
        }
        startEditing()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == mainScrollView else {
            return
        }
        startTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == mainScrollView else {
            return
        }
        if !decelerate {
            startTimer()
        }
    }
}

extension ZLClipImageViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZLClipImageDismissAnimatedTransition()
    }
}

// MARK: 裁剪比例cell

class ZLImageClipRatioCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 8, y: 5, width: bounds.width - 16, height: bounds.width - 16))
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: bounds.height - 15, width: bounds.width, height: 12))
        label.font = .zl.font(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 1
        return label
    }()
    
    var image: UIImage?
    
    var ratio: ZLImageClipRatio!
    
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
        guard let ratio = ratio, let image = image else {
            return
        }
        
        let center = imageView.center
        var w: CGFloat = 0, h: CGFloat = 0
        
        let imageMaxW = bounds.width - 10
        if ratio.whRatio == 0 {
            let maxSide = max(image.size.width, image.size.height)
            w = imageMaxW * image.size.width / maxSide
            h = imageMaxW * image.size.height / maxSide
        } else {
            if ratio.whRatio >= 1 {
                w = imageMaxW
                h = w / ratio.whRatio
            } else {
                h = imageMaxW
                w = h * ratio.whRatio
            }
        }
        if ratio.isCircle {
            imageView.layer.cornerRadius = w / 2
        } else {
            imageView.layer.cornerRadius = 3
        }
        imageView.frame = CGRect(x: center.x - w / 2, y: center.y - h / 2, width: w, height: h)
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }
    
    func configureCell(image: UIImage, ratio: ZLImageClipRatio) {
        imageView.image = image
        titleLabel.text = ratio.title
        self.image = image
        self.ratio = ratio
        
        setNeedsLayout()
    }
}
