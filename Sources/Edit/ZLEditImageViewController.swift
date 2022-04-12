//
//  ZLEditImageViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/26.
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

public class ZLEditImageModel: NSObject {
    
    public let drawPaths: [ZLDrawPath]
    
    public let mosaicPaths: [ZLMosaicPath]
    
    public let editRect: CGRect?
    
    public let angle: CGFloat
    
    public let brightness: Float
    
    public let contrast: Float
    
    public let saturation: Float
    
    public let selectRatio: ZLImageClipRatio?
    
    public let selectFilter: ZLFilter?
    
    public let textStickers: [(state: ZLTextStickerState, index: Int)]?
    
    public let imageStickers: [(state: ZLImageStickerState, index: Int)]?
    
    public init(
        drawPaths: [ZLDrawPath],
        mosaicPaths: [ZLMosaicPath],
        editRect: CGRect?,
        angle: CGFloat,
        brightness: Float,
        contrast: Float,
        saturation: Float,
        selectRatio: ZLImageClipRatio?,
        selectFilter: ZLFilter,
        textStickers: [(state: ZLTextStickerState, index: Int)]?,
        imageStickers: [(state: ZLImageStickerState, index: Int)]?
    ) {
        self.drawPaths = drawPaths
        self.mosaicPaths = mosaicPaths
        self.editRect = editRect
        self.angle = angle
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.selectRatio = selectRatio
        self.selectFilter = selectFilter
        self.textStickers = textStickers
        self.imageStickers = imageStickers
        super.init()
    }
    
}

open class ZLEditImageViewController: UIViewController {
    
    static let maxDrawLineImageWidth: CGFloat = 600
    
    @objc public var drawColViewH: CGFloat = 50
    
    @objc public var filterColViewH: CGFloat = 80
    
    @objc public var adjustColViewH: CGFloat = 60
    
    @objc public var ashbinNormalBgColor = zlRGB(40, 40, 40).withAlphaComponent(0.8)
    
    @objc public lazy var cancelBtn = UIButton(type: .custom)
    
    @objc public lazy var mainScrollView = UIScrollView()
    
    // 上方渐变阴影层
    @objc public lazy var topShadowView = UIView()
    
    @objc public lazy var topShadowLayer = CAGradientLayer()
     
    // 下方渐变阴影层
    @objc public var bottomShadowView = UIView()
    
    @objc public var bottomShadowLayer = CAGradientLayer()
    
    @objc public var doneBtn = UIButton(type: .custom)
    
    @objc public var revokeBtn = UIButton(type: .custom)
    
    @objc public lazy var ashbinView = UIView()
    
    @objc public lazy var ashbinImgView = UIImageView(image: getImage("zl_ashbin"), highlightedImage: getImage("zl_ashbin_open"))
    
    @objc public var drawLineWidth: CGFloat = 5
    
    @objc public var mosaicLineWidth: CGFloat = 25
    
    var animate = false
    
    var originalImage: UIImage
    
    // 第一次进入界面时，布局后frame，裁剪dimiss动画使用
    var originalFrame: CGRect = .zero
    
    // 图片可编辑rect
    var editRect: CGRect
    
    let tools: [ZLEditImageConfiguration.EditTool]
    
    let adjustTools: [ZLEditImageConfiguration.AdjustTool]
    
    var selectRatio: ZLImageClipRatio?
    
    var editImage: UIImage
    
    var editImageWithoutAdjust: UIImage
    
    var editImageAdjustRef: UIImage?
    
    lazy var containerView = UIView()
    
    // Show image.
    lazy var imageView = UIImageView(image: originalImage)
    
    // Show draw lines.
    lazy var drawingImageView = UIImageView()
    
    // Show text and image stickers.
    lazy var stickersContainer = UIView()
    
    // 处理好的马赛克图片
    var mosaicImage: UIImage?
    
    // 显示马赛克图片的layer
    var mosaicImageLayer: CALayer?
    
    // 显示马赛克图片的layer的mask
    var mosaicImageLayerMaskLayer: CAShapeLayer?
    
    var selectedTool: ZLEditImageConfiguration.EditTool?
    
    var selectedAdjustTool: ZLEditImageConfiguration.AdjustTool?
    
    var editToolCollectionView: UICollectionView!
    
    var drawColorCollectionView: UICollectionView?
    
    var filterCollectionView: UICollectionView?
    
    var adjustCollectionView: UICollectionView?
    
    var adjustSlider: ZLAdjustSlider?
    
    let drawColors: [UIColor]
    
    var currentDrawColor = ZLPhotoConfiguration.default().editImageConfiguration.defaultDrawColor
    
    var drawPaths: [ZLDrawPath]
    
    var mosaicPaths: [ZLMosaicPath]
    
    // collectionview 中的添加滤镜的小图
    var thumbnailFilterImages: [UIImage] = []
    
    // 选择滤镜后对原图添加滤镜后的图片
    var filterImages: [String: UIImage] = [:]
    
    var currentFilter: ZLFilter
    
    var stickers: [UIView] = []
    
    var isScrolling = false
    
    var shouldLayout = true
    
    var imageStickerContainerIsHidden = true
    
    var angle: CGFloat
    
    var brightness: Float
    
    var contrast: Float
    
    var saturation: Float
    
    var panGes: UIPanGestureRecognizer!
    
    var imageSize: CGSize {
        if self.angle == -90 || self.angle == -270 {
            return CGSize(width: self.originalImage.size.height, height: self.originalImage.size.width)
        }
        return self.originalImage.size
    }
    
    @objc public var editFinishBlock: ((UIImage, ZLEditImageModel?) -> Void)?
    
    @objc public var cancelEditBlock: (() -> Void)?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        zl_debugPrint("ZLEditImageViewController deinit")
    }
    
    @objc public class func showEditImageVC(parentVC: UIViewController?, animate: Bool = false, image: UIImage, editModel: ZLEditImageModel? = nil, cancel: (() -> Void)? = nil, completion: ((UIImage, ZLEditImageModel?) -> Void)?) {
        let tools = ZLPhotoConfiguration.default().editImageConfiguration.tools
        if ZLPhotoConfiguration.default().showClipDirectlyIfOnlyHasClipTool, tools.count == 1, tools.contains(.clip) {
            let vc = ZLClipImageViewController(image: image, editRect: editModel?.editRect, angle: editModel?.angle ?? 0, selectRatio: editModel?.selectRatio)
            vc.clipDoneBlock = { (angle, editRect, ratio) in
                let m = ZLEditImageModel(drawPaths: [], mosaicPaths: [], editRect: editRect, angle: angle, brightness: 0, contrast: 0, saturation: 0, selectRatio: ratio, selectFilter: .normal, textStickers: nil, imageStickers: nil)
                completion?(image.clipImage(angle: angle, editRect: editRect, isCircle: ratio.isCircle) ?? image, m)
            }
            vc.cancelClipBlock = cancel
            vc.animate = animate
            vc.modalPresentationStyle = .fullScreen
            parentVC?.present(vc, animated: animate, completion: nil)
        } else {
            let vc = ZLEditImageViewController(image: image, editModel: editModel)
            vc.editFinishBlock = { (ei, editImageModel) in
                completion?(ei, editImageModel)
            }
            vc.cancelEditBlock = cancel
            vc.animate = animate
            vc.modalPresentationStyle = .fullScreen
            parentVC?.present(vc, animated: animate, completion: nil)
        }
    }
    
    @objc public init(image: UIImage, editModel: ZLEditImageModel? = nil) {
        let editConfig = ZLPhotoConfiguration.default().editImageConfiguration
        
        originalImage = image.fixOrientation()
        editImage = originalImage
        editImageWithoutAdjust = originalImage
        editRect = editModel?.editRect ?? CGRect(origin: .zero, size: image.size)
        drawColors = editConfig.drawColors
        currentFilter = editModel?.selectFilter ?? .normal
        drawPaths = editModel?.drawPaths ?? []
        mosaicPaths = editModel?.mosaicPaths ?? []
        angle = editModel?.angle ?? 0
        brightness = editModel?.brightness ?? 0
        contrast = editModel?.contrast ?? 0
        saturation = editModel?.saturation ?? 0
        selectRatio = editModel?.selectRatio
        
        var ts = editConfig.tools
        if ts.contains(.imageSticker), editConfig.imageStickerContainerView == nil {
            ts.removeAll { $0 == .imageSticker }
        }
        tools = ts
        adjustTools = editConfig.adjustTools
        selectedAdjustTool = editConfig.adjustTools.first
        
        super.init(nibName: nil, bundle: nil)
        
        if !drawColors.contains(currentDrawColor) {
            currentDrawColor = drawColors.first!
        }
        
        let teStic = editModel?.textStickers ?? []
        let imStic = editModel?.imageStickers ?? []
        
        var stickers: [UIView?] = Array(repeating: nil, count: teStic.count + imStic.count)
        teStic.forEach { (cache) in
            let v = ZLTextStickerView(from: cache.state)
            stickers[cache.index] = v
        }
        imStic.forEach { (cache) in
            let v = ZLImageStickerView(from: cache.state)
            stickers[cache.index] = v
        }
        
        self.stickers = stickers.compactMap { $0 }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.rotationImageView()
        if self.tools.contains(.filter) {
            self.generateFilterImages()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard self.shouldLayout else {
            return
        }
        self.shouldLayout = false
        zl_debugPrint("edit image layout subviews")
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        insets.top = max(20, insets.top)
        
        self.mainScrollView.frame = self.view.bounds
        self.resetContainerViewFrame()
        
        self.topShadowView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150)
        self.topShadowLayer.frame = self.topShadowView.bounds
        self.cancelBtn.frame = CGRect(x: 30, y: insets.top+10, width: 28, height: 28)
        
        self.bottomShadowView.frame = CGRect(x: 0, y: self.view.frame.height - 140 - insets.bottom, width: self.view.frame.width, height: 140 + insets.bottom)
        self.bottomShadowLayer.frame = self.bottomShadowView.bounds
        
        self.drawColorCollectionView?.frame = CGRect(x: 20, y: 20, width: view.frame.width - 80, height: drawColViewH)
        self.revokeBtn.frame = CGRect(x: self.view.frame.width - 15 - 35, y: 30, width: 35, height: 30)
        
        self.adjustCollectionView?.frame = CGRect(x: 20, y: 10, width: view.frame.width - 40, height: adjustColViewH)
        self.adjustSlider?.frame = CGRect(x: view.frame.width - 60, y: view.frame.height / 2 - 100, width: 60, height: 200)
        
        self.filterCollectionView?.frame = CGRect(x: 20, y: 0, width: view.frame.width - 40, height: filterColViewH)
        
        let toolY: CGFloat = 85
        
        let doneBtnH = ZLLayout.bottomToolBtnH
        let doneBtnW = localLanguageTextValue(.editFinish).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: doneBtnH)).width + 20
        self.doneBtn.frame = CGRect(x: self.view.frame.width-20-doneBtnW, y: toolY-2, width: doneBtnW, height: doneBtnH)
        
        self.editToolCollectionView.frame = CGRect(x: 20, y: toolY, width: self.view.bounds.width - 20 - 20 - doneBtnW - 20, height: 30)
        
        if !self.drawPaths.isEmpty {
            self.drawLine()
        }
        if !self.mosaicPaths.isEmpty {
            self.generateNewMosaicImage()
        }
        
        if let index = self.drawColors.firstIndex(where: { $0 == self.currentDrawColor}) {
            self.drawColorCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    func generateFilterImages() {
        let size: CGSize
        let ratio = (self.originalImage.size.width / self.originalImage.size.height)
        let fixLength: CGFloat = 200
        if ratio >= 1 {
            size = CGSize(width: fixLength * ratio, height: fixLength)
        } else {
            size = CGSize(width: fixLength, height: fixLength / ratio)
        }
        let thumbnailImage = self.originalImage.resize_vI(size) ?? self.originalImage
        
        DispatchQueue.global().async {
            let filters = ZLPhotoConfiguration.default().editImageConfiguration.filters
            self.thumbnailFilterImages = filters.map { $0.applier?(thumbnailImage) ?? thumbnailImage }
            
            ZLMainAsync {
                self.filterCollectionView?.reloadData()
                self.filterCollectionView?.performBatchUpdates {
                    
                } completion: { (_) in
                    if let index = filters.firstIndex(where: { $0 == self.currentFilter }) {
                        self.filterCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
                    }
                }
            }
        }
    }
    
    func resetContainerViewFrame() {
        self.mainScrollView.setZoomScale(1, animated: true)
        self.imageView.image = self.editImage
        
        let editSize = self.editRect.size
        let scrollViewSize = self.mainScrollView.frame.size
        let ratio = min(scrollViewSize.width / editSize.width, scrollViewSize.height / editSize.height)
        let w = ratio * editSize.width * self.mainScrollView.zoomScale
        let h = ratio * editSize.height * self.mainScrollView.zoomScale
        self.containerView.frame = CGRect(x: max(0, (scrollViewSize.width-w)/2), y: max(0, (scrollViewSize.height-h)/2), width: w, height: h)
        if self.selectRatio?.isCircle == true {
            let mask = CAShapeLayer()
            let path = UIBezierPath(arcCenter: CGPoint(x: w / 2, y: h / 2), radius: w / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            mask.path = path.cgPath
            self.containerView.layer.mask = mask
        } else {
            self.containerView.layer.mask = nil
        }
        let scaleImageOrigin = CGPoint(x: -self.editRect.origin.x*ratio, y: -self.editRect.origin.y*ratio)
        let scaleImageSize = CGSize(width: self.imageSize.width * ratio, height: self.imageSize.height * ratio)
        self.imageView.frame = CGRect(origin: scaleImageOrigin, size: scaleImageSize)
        self.mosaicImageLayer?.frame = self.imageView.bounds
        self.mosaicImageLayerMaskLayer?.frame = self.imageView.bounds
        self.drawingImageView.frame = self.imageView.frame
        self.stickersContainer.frame = self.imageView.frame
        
        // 针对于长图的优化
        if (self.editRect.height / self.editRect.width) > (self.view.frame.height / self.view.frame.width * 1.1) {
            let widthScale = self.view.frame.width / w
            self.mainScrollView.maximumZoomScale = widthScale
            self.mainScrollView.zoomScale = widthScale
            self.mainScrollView.contentOffset = .zero
        } else if self.editRect.width / self.editRect.height > 1 {
            self.mainScrollView.maximumZoomScale = max(3, self.view.frame.height / h)
        }
        
        self.originalFrame = self.view.convert(self.containerView.frame, from: self.mainScrollView)
        self.isScrolling = false
    }
    
    func setupUI() {
        self.view.backgroundColor = .black
        
        self.mainScrollView.backgroundColor = .black
        self.mainScrollView.minimumZoomScale = 1
        self.mainScrollView.maximumZoomScale = 3
        self.mainScrollView.delegate = self
        self.view.addSubview(self.mainScrollView)
        
        self.containerView.clipsToBounds = true
        self.mainScrollView.addSubview(self.containerView)
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.imageView.backgroundColor = .black
        self.containerView.addSubview(self.imageView)
        
        self.drawingImageView.contentMode = .scaleAspectFit
        self.drawingImageView.isUserInteractionEnabled = true
        self.containerView.addSubview(self.drawingImageView)
        
        self.containerView.addSubview(self.stickersContainer)
        
        let color1 = UIColor.black.withAlphaComponent(0.35).cgColor
        let color2 = UIColor.black.withAlphaComponent(0).cgColor
        
        self.view.addSubview(self.topShadowView)
        
        self.topShadowLayer.colors = [color1, color2]
        self.topShadowLayer.locations = [0, 1]
        self.topShadowView.layer.addSublayer(self.topShadowLayer)
        
        self.cancelBtn.setImage(getImage("zl_retake"), for: .normal)
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        self.cancelBtn.adjustsImageWhenHighlighted = false
        self.cancelBtn.zl_enlargeValidTouchArea(inset: 30)
        self.topShadowView.addSubview(self.cancelBtn)
        
        self.view.addSubview(self.bottomShadowView)
        
        self.bottomShadowLayer.colors = [color2, color1]
        self.bottomShadowLayer.locations = [0, 1]
        self.bottomShadowView.layer.addSublayer(self.bottomShadowLayer)
        
        let editToolLayout = UICollectionViewFlowLayout()
        editToolLayout.itemSize = CGSize(width: 30, height: 30)
        editToolLayout.minimumLineSpacing = 20
        editToolLayout.minimumInteritemSpacing = 20
        editToolLayout.scrollDirection = .horizontal
        self.editToolCollectionView = UICollectionView(frame: .zero, collectionViewLayout: editToolLayout)
        self.editToolCollectionView.backgroundColor = .clear
        self.editToolCollectionView.delegate = self
        self.editToolCollectionView.dataSource = self
        self.editToolCollectionView.showsHorizontalScrollIndicator = false
        self.bottomShadowView.addSubview(self.editToolCollectionView)
        
        ZLEditToolCell.zl_register(self.editToolCollectionView)
        
        self.doneBtn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        self.doneBtn.backgroundColor = .bottomToolViewBtnNormalBgColor
        self.doneBtn.setTitle(localLanguageTextValue(.editFinish), for: .normal)
        self.doneBtn.setTitleColor(.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        self.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        self.bottomShadowView.addSubview(self.doneBtn)
        
        if tools.contains(.draw) {
            let drawColorLayout = UICollectionViewFlowLayout()
            let drawColorItemWidth: CGFloat = 30
            drawColorLayout.itemSize = CGSize(width: drawColorItemWidth, height: drawColorItemWidth)
            drawColorLayout.minimumLineSpacing = 15
            drawColorLayout.minimumInteritemSpacing = 15
            drawColorLayout.scrollDirection = .horizontal
            let drawColorTopBottomInset = (drawColViewH - drawColorItemWidth) / 2
            drawColorLayout.sectionInset = UIEdgeInsets(top: drawColorTopBottomInset, left: 0, bottom: drawColorTopBottomInset, right: 0)
            
            let drawCV = UICollectionView(frame: .zero, collectionViewLayout: drawColorLayout)
            drawCV.backgroundColor = .clear
            drawCV.delegate = self
            drawCV.dataSource = self
            drawCV.isHidden = true
            drawCV.showsHorizontalScrollIndicator = false
            bottomShadowView.addSubview(drawCV)
            
            ZLDrawColorCell.zl_register(drawCV)
            drawColorCollectionView = drawCV
        }
        
        if tools.contains(.filter) {
            if let applier = currentFilter.applier {
                let image = applier(originalImage)
                editImage = image
                editImageWithoutAdjust = image
                filterImages[currentFilter.name] = image
            }
            
            let filterLayout = UICollectionViewFlowLayout()
            filterLayout.itemSize = CGSize(width: filterColViewH - 20, height: filterColViewH)
            filterLayout.minimumLineSpacing = 15
            filterLayout.minimumInteritemSpacing = 15
            filterLayout.scrollDirection = .horizontal
            
            let filterCV = UICollectionView(frame: .zero, collectionViewLayout: filterLayout)
            filterCV.backgroundColor = .clear
            filterCV.delegate = self
            filterCV.dataSource = self
            filterCV.isHidden = true
            filterCV.showsHorizontalScrollIndicator = false
            bottomShadowView.addSubview(filterCV)
            
            ZLFilterImageCell.zl_register(filterCV)
            filterCollectionView = filterCV
        }
        
        if tools.contains(.adjust) {
            editImage = editImage.adjust(brightness: brightness, contrast: contrast, saturation: saturation) ?? editImage
            
            let adjustLayout = UICollectionViewFlowLayout()
            adjustLayout.itemSize = CGSize(width: adjustColViewH, height: adjustColViewH)
            adjustLayout.minimumLineSpacing = 10
            adjustLayout.minimumInteritemSpacing = 10
            adjustLayout.scrollDirection = .horizontal
            
            let adjustCV = UICollectionView(frame: .zero, collectionViewLayout: adjustLayout)
            adjustCV.backgroundColor = .clear
            adjustCV.delegate = self
            adjustCV.dataSource = self
            adjustCV.isHidden = true
            adjustCV.showsHorizontalScrollIndicator = false
            bottomShadowView.addSubview(adjustCV)
            
            ZLAdjustToolCell.zl_register(adjustCV)
            adjustCollectionView = adjustCV
            
            adjustSlider = ZLAdjustSlider()
            if let selectedAdjustTool = selectedAdjustTool {
                changeAdjustTool(selectedAdjustTool)
            }
            adjustSlider?.beginAdjust = {
            }
            adjustSlider?.valueChanged = { [weak self] value in
                self?.adjustValueChanged(value)
            }
            adjustSlider?.endAdjust = { [weak self] in
                self?.endAdjust()
            }
            adjustSlider?.isHidden = true
            view.addSubview(adjustSlider!)
        }
        
        self.revokeBtn.setImage(getImage("zl_revoke_disable"), for: .disabled)
        self.revokeBtn.setImage(getImage("zl_revoke"), for: .normal)
        self.revokeBtn.adjustsImageWhenHighlighted = false
        self.revokeBtn.isEnabled = false
        self.revokeBtn.isHidden = true
        self.revokeBtn.addTarget(self, action: #selector(revokeBtnClick), for: .touchUpInside)
        self.bottomShadowView.addSubview(self.revokeBtn)
        
        let ashbinSize = CGSize(width: 160, height: 80)
        self.ashbinView.frame = CGRect(
            x: (self.view.frame.width - ashbinSize.width) / 2,
            y: self.view.frame.height - ashbinSize.height - 40,
            width: ashbinSize.width,
            height: ashbinSize.height
        )
        self.ashbinView.backgroundColor = ashbinNormalBgColor
        self.ashbinView.layer.cornerRadius = 15
        self.ashbinView.layer.masksToBounds = true
        self.ashbinView.isHidden = true
        self.view.addSubview(self.ashbinView)
        
        self.ashbinImgView.frame = CGRect(x: (ashbinSize.width-25)/2, y: 15, width: 25, height: 25)
        self.ashbinView.addSubview(self.ashbinImgView)
        
        let asbinTipLabel = UILabel(frame: CGRect(x: 0, y: ashbinSize.height-34, width: ashbinSize.width, height: 34))
        asbinTipLabel.font = getFont(12)
        asbinTipLabel.textAlignment = .center
        asbinTipLabel.textColor = .white
        asbinTipLabel.text = localLanguageTextValue(.textStickerRemoveTips)
        asbinTipLabel.numberOfLines = 2
        asbinTipLabel.lineBreakMode = .byCharWrapping
        self.ashbinView.addSubview(asbinTipLabel)
        
        if self.tools.contains(.mosaic) {
            mosaicImage = editImage.mosaicImage()
            
            self.mosaicImageLayer = CALayer()
            self.mosaicImageLayer?.contents = self.mosaicImage?.cgImage
            self.imageView.layer.addSublayer(self.mosaicImageLayer!)
            
            self.mosaicImageLayerMaskLayer = CAShapeLayer()
            self.mosaicImageLayerMaskLayer?.strokeColor = UIColor.blue.cgColor
            self.mosaicImageLayerMaskLayer?.fillColor = nil
            self.mosaicImageLayerMaskLayer?.lineCap = .round
            self.mosaicImageLayerMaskLayer?.lineJoin = .round
            self.imageView.layer.addSublayer(self.mosaicImageLayerMaskLayer!)
            
            self.mosaicImageLayer?.mask = self.mosaicImageLayerMaskLayer
        }
        
        if self.tools.contains(.imageSticker) {
            let imageStickerView = ZLPhotoConfiguration.default().editImageConfiguration.imageStickerContainerView
            imageStickerView?.hideBlock = { [weak self] in
                self?.setToolView(show: true)
                self?.imageStickerContainerIsHidden = true
            }
            
            imageStickerView?.selectImageBlock = { [weak self] (image) in
                self?.addImageStickerView(image)
            }
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGes.delegate = self
        self.view.addGestureRecognizer(tapGes)
        
        self.panGes = UIPanGestureRecognizer(target: self, action: #selector(drawAction(_:)))
        self.panGes.maximumNumberOfTouches = 1
        self.panGes.delegate = self
        self.view.addGestureRecognizer(self.panGes)
        self.mainScrollView.panGestureRecognizer.require(toFail: self.panGes)
        
        self.stickers.forEach { (view) in
            self.stickersContainer.addSubview(view)
            if let tv = view as? ZLTextStickerView {
                tv.frame = tv.originFrame
                self.configTextSticker(tv)
            } else if let iv = view as? ZLImageStickerView {
                iv.frame = iv.originFrame
                self.configImageSticker(iv)
            }
        }
    }
    
    func rotationImageView() {
        let transform = CGAffineTransform(rotationAngle: angle.toPi)
        imageView.transform = transform
        drawingImageView.transform = transform
        stickersContainer.transform = transform
    }
    
    @objc func cancelBtnClick() {
        dismiss(animated: animate) {
            self.cancelEditBlock?()
        }
    }
    
    func drawBtnClick() {
        let isSelected = selectedTool != .draw
        if isSelected {
            selectedTool = .draw
        } else {
            selectedTool = nil
        }
        drawColorCollectionView?.isHidden = !isSelected
        revokeBtn.isHidden = !isSelected
        revokeBtn.isEnabled = drawPaths.count > 0
        filterCollectionView?.isHidden = true
        adjustCollectionView?.isHidden = true
        adjustSlider?.isHidden = true
    }
    
    func clipBtnClick() {
        let currentEditImage = buildImage()
        let vc = ZLClipImageViewController(image: currentEditImage, editRect: editRect, angle: angle, selectRatio: selectRatio)
        let rect = mainScrollView.convert(containerView.frame, to: view)
        vc.presentAnimateFrame = rect
        vc.presentAnimateImage = currentEditImage.clipImage(angle: angle, editRect: editRect, isCircle: selectRatio?.isCircle ?? false)
        vc.modalPresentationStyle = .fullScreen
        
        vc.clipDoneBlock = { [weak self] (angle, editFrame, selectRatio) in
            guard let `self` = self else { return }
            let oldAngle = self.angle
            let oldContainerSize = self.stickersContainer.frame.size
            if self.angle != angle {
                self.angle = angle
                self.rotationImageView()
            }
            self.editRect = editFrame
            self.selectRatio = selectRatio
            self.resetContainerViewFrame()
            self.reCalculateStickersFrame(oldContainerSize, oldAngle, angle)
        }
        
        vc.cancelClipBlock = { [weak self] () in
            self?.resetContainerViewFrame()
        }
        
        present(vc, animated: false) {
            self.mainScrollView.alpha = 0
            self.topShadowView.alpha = 0
            self.bottomShadowView.alpha = 0
            self.adjustSlider?.alpha = 0
        }
    }
    
    func imageStickerBtnClick() {
        ZLPhotoConfiguration.default().editImageConfiguration.imageStickerContainerView?.show(in: view)
        setToolView(show: false)
        imageStickerContainerIsHidden = false
    }
    
    func textStickerBtnClick() {
        showInputTextVC { [weak self] (text, textColor, bgColor) in
            self?.addTextStickersView(text, textColor: textColor, bgColor: bgColor)
        }
    }
    
    func mosaicBtnClick() {
        let isSelected = selectedTool != .mosaic
        if isSelected {
            selectedTool = .mosaic
        } else {
            selectedTool = nil
        }
        
        drawColorCollectionView?.isHidden = true
        filterCollectionView?.isHidden = true
        adjustCollectionView?.isHidden = true
        adjustSlider?.isHidden = true
        revokeBtn.isHidden = !isSelected
        revokeBtn.isEnabled = mosaicPaths.count > 0
    }
    
    func filterBtnClick() {
        let isSelected = selectedTool != .filter
        if isSelected {
            selectedTool = .filter
        } else {
            selectedTool = nil
        }
        
        drawColorCollectionView?.isHidden = true
        revokeBtn.isHidden = true
        filterCollectionView?.isHidden = !isSelected
        adjustCollectionView?.isHidden = true
        adjustSlider?.isHidden = true
    }
    
    func adjustBtnClick() {
        let isSelected = selectedTool != .adjust
        if isSelected {
            selectedTool = .adjust
        } else {
            selectedTool = nil
        }
        
        drawColorCollectionView?.isHidden = true
        revokeBtn.isHidden = true
        filterCollectionView?.isHidden = true
        adjustCollectionView?.isHidden = !isSelected
        adjustSlider?.isHidden = !isSelected
        
        generateAdjustImageRef()
    }
    
    func changeAdjustTool(_ tool: ZLEditImageConfiguration.AdjustTool) {
        selectedAdjustTool = tool
        
        switch tool {
        case .brightness:
            adjustSlider?.value = brightness
        case .contrast:
            adjustSlider?.value = contrast
        case .saturation:
            adjustSlider?.value = saturation
        }
        
        generateAdjustImageRef()
    }
    
    @objc func doneBtnClick() {
        var textStickers: [(ZLTextStickerState, Int)] = []
        var imageStickers: [(ZLImageStickerState, Int)] = []
        for (index, view) in stickersContainer.subviews.enumerated() {
            if let ts = view as? ZLTextStickerView, let _ = ts.label.text {
                textStickers.append((ts.state, index))
            } else if let ts = view as? ZLImageStickerView {
                imageStickers.append((ts.state, index))
            }
        }
        
        var hasEdit = true
        if drawPaths.isEmpty, editRect.size == imageSize, angle == 0, mosaicPaths.isEmpty, imageStickers.isEmpty, textStickers.isEmpty, currentFilter.applier == nil, brightness == 0, contrast == 0, saturation == 0 {
            hasEdit = false
        }
        
        var resImage = originalImage
        var editModel: ZLEditImageModel? = nil
        if hasEdit {
            resImage = buildImage()
            resImage = resImage.clipImage(angle: angle, editRect: editRect, isCircle: selectRatio?.isCircle ?? false) ?? resImage
            editModel = ZLEditImageModel(drawPaths: drawPaths, mosaicPaths: mosaicPaths, editRect: editRect, angle: angle, brightness: brightness, contrast: contrast, saturation: saturation, selectRatio: selectRatio, selectFilter: currentFilter, textStickers: textStickers, imageStickers: imageStickers)
        }
        
        dismiss(animated: animate) {
            self.editFinishBlock?(resImage, editModel)
        }
    }
    
    @objc func revokeBtnClick() {
        if self.selectedTool == .draw {
            guard !self.drawPaths.isEmpty else {
                return
            }
            self.drawPaths.removeLast()
            self.revokeBtn.isEnabled = self.drawPaths.count > 0
            self.drawLine()
        } else if self.selectedTool == .mosaic {
            guard !self.mosaicPaths.isEmpty else {
                return
            }
            self.mosaicPaths.removeLast()
            self.revokeBtn.isEnabled = self.mosaicPaths.count > 0
            self.generateNewMosaicImage()
        }
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if self.bottomShadowView.alpha == 1 {
            self.setToolView(show: false)
        } else {
            self.setToolView(show: true)
        }
    }
    
    @objc func drawAction(_ pan: UIPanGestureRecognizer) {
        if self.selectedTool == .draw {
            let point = pan.location(in: self.drawingImageView)
            if pan.state == .began {
                self.setToolView(show: false)
                
                let originalRatio = min(self.mainScrollView.frame.width / self.originalImage.size.width, self.mainScrollView.frame.height / self.originalImage.size.height)
                let ratio = min(self.mainScrollView.frame.width / self.editRect.width, self.mainScrollView.frame.height / self.editRect.height)
                let scale = ratio / originalRatio
                // 缩放到最初的size
                var size = self.drawingImageView.frame.size
                size.width /= scale
                size.height /= scale
                if self.angle == -90 || self.angle == -270 {
                    swap(&size.width, &size.height)
                }
                
                var toImageScale = ZLEditImageViewController.maxDrawLineImageWidth / size.width
                if self.editImage.size.width / self.editImage.size.height > 1 {
                    toImageScale = ZLEditImageViewController.maxDrawLineImageWidth / size.height
                }
                
                let path = ZLDrawPath(pathColor: self.currentDrawColor, pathWidth: self.drawLineWidth / self.mainScrollView.zoomScale, ratio: ratio / originalRatio / toImageScale, startPoint: point)
                self.drawPaths.append(path)
            } else if pan.state == .changed {
                let path = self.drawPaths.last
                path?.addLine(to: point)
                self.drawLine()
            } else if pan.state == .cancelled || pan.state == .ended {
                self.setToolView(show: true)
                self.revokeBtn.isEnabled = self.drawPaths.count > 0
            }
        } else if self.selectedTool == .mosaic {
            let point = pan.location(in: self.imageView)
            if pan.state == .began {
                self.setToolView(show: false)
                
                var actualSize = self.editRect.size
                if self.angle == -90 || self.angle == -270 {
                    swap(&actualSize.width, &actualSize.height)
                }
                let ratio = min(self.mainScrollView.frame.width / self.editRect.width, self.mainScrollView.frame.height / self.editRect.height)
                
                let pathW = self.mosaicLineWidth / self.mainScrollView.zoomScale
                let path = ZLMosaicPath(pathWidth: pathW, ratio: ratio, startPoint: point)
                
                self.mosaicImageLayerMaskLayer?.lineWidth = pathW
                self.mosaicImageLayerMaskLayer?.path = path.path.cgPath
                self.mosaicPaths.append(path)
            } else if pan.state == .changed {
                let path = self.mosaicPaths.last
                path?.addLine(to: point)
                self.mosaicImageLayerMaskLayer?.path = path?.path.cgPath
            } else if pan.state == .cancelled || pan.state == .ended {
                self.setToolView(show: true)
                self.revokeBtn.isEnabled = self.mosaicPaths.count > 0
                self.generateNewMosaicImage()
            }
        }
    }
    
    // 生成一个没有调整参数前的图片
    func generateAdjustImageRef() {
        editImageAdjustRef = generateNewMosaicImage(inputImage: editImageWithoutAdjust, inputMosaicImage: editImageWithoutAdjust.mosaicImage())
    }
    
    func adjustValueChanged(_ value: Float) {
        guard let selectedAdjustTool = selectedAdjustTool, let editImageAdjustRef = editImageAdjustRef else {
            return
        }
        var resultImage: UIImage? = nil
        
        switch selectedAdjustTool {
        case .brightness:
            if brightness == value {
                return
            }
            brightness = value
            resultImage = editImageAdjustRef.adjust(brightness: value, contrast: contrast, saturation: saturation)
        case .contrast:
            if contrast == value {
                return
            }
            contrast = value
            resultImage = editImageAdjustRef.adjust(brightness: brightness, contrast: value, saturation: saturation)
        case .saturation:
            if saturation == value {
                return
            }
            saturation = value
            resultImage = editImageAdjustRef.adjust(brightness: brightness, contrast: contrast, saturation: value)
        }
        
        guard let resultImage = resultImage else {
            return
        }
        editImage = resultImage
        imageView.image = editImage
    }
    
    func endAdjust() {
        if tools.contains(.mosaic) {
            generateNewMosaicImageLayer()
            
            if !mosaicPaths.isEmpty {
                generateNewMosaicImage()
            }
        }
    }
    
    func setToolView(show: Bool) {
        topShadowView.layer.removeAllAnimations()
        bottomShadowView.layer.removeAllAnimations()
        adjustSlider?.layer.removeAllAnimations()
        if show {
            UIView.animate(withDuration: 0.25) {
                self.topShadowView.alpha = 1
                self.bottomShadowView.alpha = 1
                self.adjustSlider?.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.topShadowView.alpha = 0
                self.bottomShadowView.alpha = 0
                self.adjustSlider?.alpha = 0
            }
        }
    }
    
    func showInputTextVC(_ text: String? = nil, textColor: UIColor? = nil, bgColor: UIColor? = nil, completion: @escaping ( (String, UIColor, UIColor) -> Void )) {
        // Calculate image displayed frame on the screen.
        var r = self.mainScrollView.convert(self.view.frame, to: self.containerView)
        r.origin.x += self.mainScrollView.contentOffset.x / self.mainScrollView.zoomScale
        r.origin.y += self.mainScrollView.contentOffset.y / self.mainScrollView.zoomScale
        let scale = self.imageSize.width / self.imageView.frame.width
        r.origin.x *= scale
        r.origin.y *= scale
        r.size.width *= scale
        r.size.height *= scale
        let isCircle = self.selectRatio?.isCircle ?? false
        let bgImage = self.buildImage().clipImage(angle: self.angle, editRect: self.editRect, isCircle: isCircle)?.clipImage(angle: 0, editRect: r, isCircle: isCircle)
        let vc = ZLInputTextViewController(image: bgImage, text: text, textColor: textColor, bgColor: bgColor)
        
        vc.endInput = { (text, textColor, bgColor) in
            completion(text, textColor, bgColor)
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.showDetailViewController(vc, sender: nil)
    }
    
    func getStickerOriginFrame(_ size: CGSize) -> CGRect {
        let scale = self.mainScrollView.zoomScale
        // Calculate the display rect of container view.
        let x = (self.mainScrollView.contentOffset.x - self.containerView.frame.minX) / scale
        let y = (self.mainScrollView.contentOffset.y - self.containerView.frame.minY) / scale
        let w = view.frame.width / scale
        let h = view.frame.height / scale
        // Convert to text stickers container view.
        let r = self.containerView.convert(CGRect(x: x, y: y, width: w, height: h), to: self.stickersContainer)
        let originFrame = CGRect(x: r.minX + (r.width - size.width) / 2, y: r.minY + (r.height - size.height) / 2, width: size.width, height: size.height)
        return originFrame
    }
    
    /// Add image sticker
    func addImageStickerView(_ image: UIImage) {
        let scale = self.mainScrollView.zoomScale
        let size = ZLImageStickerView.calculateSize(image: image, width: self.view.frame.width)
        let originFrame = self.getStickerOriginFrame(size)
        
        let imageSticker = ZLImageStickerView(image: image, originScale: 1 / scale, originAngle: -self.angle, originFrame: originFrame)
        self.stickersContainer.addSubview(imageSticker)
        imageSticker.frame = originFrame
        self.view.layoutIfNeeded()
        
        self.configImageSticker(imageSticker)
    }
    
    /// Add text sticker
    func addTextStickersView(_ text: String, textColor: UIColor, bgColor: UIColor) {
        guard !text.isEmpty else { return }
        let scale = self.mainScrollView.zoomScale
        let size = ZLTextStickerView.calculateSize(text: text, width: self.view.frame.width)
        let originFrame = self.getStickerOriginFrame(size)
        
        let textSticker = ZLTextStickerView(text: text, textColor: textColor, bgColor: bgColor, originScale: 1 / scale, originAngle: -self.angle, originFrame: originFrame)
        self.stickersContainer.addSubview(textSticker)
        textSticker.frame = originFrame
        
        self.configTextSticker(textSticker)
    }
    
    func configTextSticker(_ textSticker: ZLTextStickerView) {
        textSticker.delegate = self
        self.mainScrollView.pinchGestureRecognizer?.require(toFail: textSticker.pinchGes)
        self.mainScrollView.panGestureRecognizer.require(toFail: textSticker.panGes)
        self.panGes.require(toFail: textSticker.panGes)
    }
    
    func configImageSticker(_ imageSticker: ZLImageStickerView) {
        imageSticker.delegate = self
        self.mainScrollView.pinchGestureRecognizer?.require(toFail: imageSticker.pinchGes)
        self.mainScrollView.panGestureRecognizer.require(toFail: imageSticker.panGes)
        self.panGes.require(toFail: imageSticker.panGes)
    }
    
    func reCalculateStickersFrame(_ oldSize: CGSize, _ oldAngle: CGFloat, _ newAngle: CGFloat) {
        let currSize = self.stickersContainer.frame.size
        let scale: CGFloat
        if Int(newAngle - oldAngle) % 180 == 0 {
            scale = currSize.width / oldSize.width
        } else {
            scale = currSize.height / oldSize.width
        }
        
        self.stickersContainer.subviews.forEach { (view) in
            (view as? ZLStickerViewAdditional)?.addScale(scale)
        }
    }
    
    func drawLine() {
        let originalRatio = min(self.mainScrollView.frame.width / self.originalImage.size.width, self.mainScrollView.frame.height / self.originalImage.size.height)
        let ratio = min(self.mainScrollView.frame.width / self.editRect.width, self.mainScrollView.frame.height / self.editRect.height)
        let scale = ratio / originalRatio
        // 缩放到最初的size
        var size = self.drawingImageView.frame.size
        size.width /= scale
        size.height /= scale
        if self.angle == -90 || self.angle == -270 {
            swap(&size.width, &size.height)
        }
        var toImageScale = ZLEditImageViewController.maxDrawLineImageWidth / size.width
        if self.editImage.size.width / self.editImage.size.height > 1 {
            toImageScale = ZLEditImageViewController.maxDrawLineImageWidth / size.height
        }
        size.width *= toImageScale
        size.height *= toImageScale
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.editImage.scale)
        let context = UIGraphicsGetCurrentContext()
        // 去掉锯齿
        context?.setAllowsAntialiasing(true)
        context?.setShouldAntialias(true)
        for path in self.drawPaths {
            path.drawPath()
        }
        self.drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func generateNewMosaicImageLayer() {
        mosaicImage = editImage.mosaicImage()
        
        mosaicImageLayer?.removeFromSuperlayer()
        
        mosaicImageLayer = CALayer()
        mosaicImageLayer?.frame = imageView.bounds
        mosaicImageLayer?.contents = mosaicImage?.cgImage
        imageView.layer.insertSublayer(mosaicImageLayer!, below: mosaicImageLayerMaskLayer)
        
        mosaicImageLayer?.mask = mosaicImageLayerMaskLayer
    }
    
    /// 传入inputImage 和 inputMosaicImage则代表仅想要获取新生成的mosaic图片
    @discardableResult
    func generateNewMosaicImage(inputImage: UIImage? = nil, inputMosaicImage: UIImage? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
        if inputImage != nil {
            inputImage?.draw(at: .zero)
        } else {
            var drawImage: UIImage? = nil
            if tools.contains(.filter), let image = filterImages[currentFilter.name] {
                drawImage = image
            } else {
                drawImage = originalImage
            }
            drawImage = drawImage?.adjust(brightness: brightness, contrast: contrast, saturation: saturation)
            drawImage?.draw(at: .zero)
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        mosaicPaths.forEach { (path) in
            context?.move(to: path.startPoint)
            path.linePoints.forEach { (point) in
                context?.addLine(to: point)
            }
            context?.setLineWidth(path.path.lineWidth / path.ratio)
            context?.setLineCap(.round)
            context?.setLineJoin(.round)
            context?.setBlendMode(.clear)
            context?.strokePath()
        }
        
        var midImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let midCgImage = midImage?.cgImage else {
            return nil
        }
        
        midImage = UIImage(cgImage: midCgImage, scale: editImage.scale, orientation: .up)
        
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
        (inputMosaicImage ?? mosaicImage)?.draw(at: .zero)
        midImage?.draw(at: .zero)
        
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return nil
        }
        let image = UIImage(cgImage: cgi, scale: editImage.scale, orientation: .up)
        
        if inputImage != nil {
            return image
        }
        editImage = image
        imageView.image = image
        mosaicImageLayerMaskLayer?.path = nil
        
        return image
    }
    
    func buildImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(editImage.size, false, editImage.scale)
        editImage.draw(at: .zero)
        
        drawingImageView.image?.draw(in: CGRect(origin: .zero, size: originalImage.size))
        
        if !stickersContainer.subviews.isEmpty, let context = UIGraphicsGetCurrentContext() {
            let scale = imageSize.width / stickersContainer.frame.width
            stickersContainer.subviews.forEach { (view) in
                (view as? ZLStickerViewAdditional)?.resetState()
            }
            context.concatenate(CGAffineTransform(scaleX: scale, y: scale))
            stickersContainer.layer.render(in: context)
            context.concatenate(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        }
        
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return editImage
        }
        return UIImage(cgImage: cgi, scale: editImage.scale, orientation: .up)
    }
    
    func finishClipDismissAnimate() {
        self.mainScrollView.alpha = 1
        UIView.animate(withDuration: 0.1) {
            self.topShadowView.alpha = 1
            self.bottomShadowView.alpha = 1
            self.adjustSlider?.alpha = 1
        }
    }

}

extension ZLEditImageViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard self.imageStickerContainerIsHidden else {
            return false
        }
        if gestureRecognizer is UITapGestureRecognizer {
            if self.bottomShadowView.alpha == 1 {
                let p = gestureRecognizer.location(in: self.view)
                return !self.bottomShadowView.frame.contains(p)
            } else {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            guard let st = self.selectedTool else {
                return false
            }
            return (st == .draw || st == .mosaic) && !self.isScrolling
        }
        
        return true
    }
    
}

// MARK: scroll view delegate
extension ZLEditImageViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        self.containerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.isScrolling = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.mainScrollView else {
            return
        }
        self.isScrolling = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == self.mainScrollView else {
            return
        }
        self.isScrolling = decelerate
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.mainScrollView else {
            return
        }
        self.isScrolling = false
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView == self.mainScrollView else {
            return
        }
        self.isScrolling = false
    }
    
}

extension ZLEditImageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == editToolCollectionView {
            return tools.count
        } else if collectionView == drawColorCollectionView {
            return drawColors.count
        } else if collectionView == filterCollectionView {
            return thumbnailFilterImages.count
        } else {
            return adjustTools.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == editToolCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLEditToolCell.zl_identifier(), for: indexPath) as! ZLEditToolCell
            
            let toolType = tools[indexPath.row]
            cell.icon.isHighlighted = false
            cell.toolType = toolType
            cell.icon.isHighlighted = toolType == selectedTool
            
            return cell
        } else if collectionView == drawColorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.zl_identifier(), for: indexPath) as! ZLDrawColorCell
            
            let c = drawColors[indexPath.row]
            cell.color = c
            if c == currentDrawColor {
                cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
            } else {
                cell.bgWhiteView.layer.transform = CATransform3DIdentity
            }
            
            return cell
        } else if collectionView == filterCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLFilterImageCell.zl_identifier(), for: indexPath) as! ZLFilterImageCell
            
            let image = thumbnailFilterImages[indexPath.row]
            let filter = ZLPhotoConfiguration.default().editImageConfiguration.filters[indexPath.row]
            
            cell.nameLabel.text = filter.name
            cell.imageView.image = image
            
            if currentFilter === filter {
                cell.nameLabel.textColor = .white
            } else {
                cell.nameLabel.textColor = zlRGB(160, 160, 160)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLAdjustToolCell.zl_identifier(), for: indexPath) as! ZLAdjustToolCell
            
            let tool = adjustTools[indexPath.row]
            
            cell.imageView.isHighlighted = false
            cell.adjustTool = tool
            let isSelected = tool == selectedAdjustTool
            cell.imageView.isHighlighted = isSelected
            
            if isSelected {
                cell.nameLabel.textColor = .white
            } else {
                cell.nameLabel.textColor = zlRGB(160, 160, 160)
            }
            
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == editToolCollectionView {
            let toolType = tools[indexPath.row]
            switch toolType {
            case .draw:
                drawBtnClick()
            case .clip:
                clipBtnClick()
            case .imageSticker:
                imageStickerBtnClick()
            case .textSticker:
                textStickerBtnClick()
            case .mosaic:
                mosaicBtnClick()
            case .filter:
                filterBtnClick()
            case .adjust:
                adjustBtnClick()
            }
        } else if collectionView == drawColorCollectionView {
            currentDrawColor = drawColors[indexPath.row]
        } else if collectionView == filterCollectionView {
            currentFilter = ZLPhotoConfiguration.default().editImageConfiguration.filters[indexPath.row]
            if let image = filterImages[currentFilter.name] {
                editImage = image.adjust(brightness: brightness, contrast: contrast, saturation: saturation) ?? image
                editImageWithoutAdjust = image
            } else {
                let image = currentFilter.applier?(originalImage) ?? originalImage
                editImage = image.adjust(brightness: brightness, contrast: contrast, saturation: saturation) ?? image
                editImageWithoutAdjust = image
                filterImages[currentFilter.name] = image
            }
            if tools.contains(.mosaic) {
                generateNewMosaicImageLayer()
                
                if mosaicPaths.isEmpty {
                    imageView.image = editImage
                } else {
                    generateNewMosaicImage()
                }
            } else {
                imageView.image = editImage
            }
        } else {
            let tool = adjustTools[indexPath.row]
            if tool != selectedAdjustTool {
                changeAdjustTool(tool)
            }
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
    
}

extension ZLEditImageViewController: ZLTextStickerViewDelegate {
    
    func stickerBeginOperation(_ sticker: UIView) {
        self.setToolView(show: false)
        self.ashbinView.layer.removeAllAnimations()
        self.ashbinView.isHidden = false
        var frame = self.ashbinView.frame
        let diff = self.view.frame.height - frame.minY
        frame.origin.y += diff
        self.ashbinView.frame = frame
        frame.origin.y -= diff
        UIView.animate(withDuration: 0.25) {
            self.ashbinView.frame = frame
        }
        
        self.stickersContainer.subviews.forEach { (view) in
            if view !== sticker {
                (view as? ZLStickerViewAdditional)?.resetState()
                (view as? ZLStickerViewAdditional)?.gesIsEnabled = false
            }
        }
    }
    
    func stickerOnOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer) {
        let point = panGes.location(in: self.view)
        if self.ashbinView.frame.contains(point) {
            self.ashbinView.backgroundColor = zlRGB(241, 79, 79).withAlphaComponent(0.98)
            self.ashbinImgView.isHighlighted = true
            if sticker.alpha == 1 {
                sticker.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.25) {
                    sticker.alpha = 0.5
                }
            }
        } else {
            self.ashbinView.backgroundColor = ashbinNormalBgColor
            self.ashbinImgView.isHighlighted = false
            if sticker.alpha != 1 {
                sticker.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.25) {
                    sticker.alpha = 1
                }
            }
        }
    }
    
    func stickerEndOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer) {
        self.setToolView(show: true)
        self.ashbinView.layer.removeAllAnimations()
        self.ashbinView.isHidden = true
        
        let point = panGes.location(in: self.view)
        if self.ashbinView.frame.contains(point) {
            (sticker as? ZLStickerViewAdditional)?.moveToAshbin()
        }
        
        self.stickersContainer.subviews.forEach { (view) in
            (view as? ZLStickerViewAdditional)?.gesIsEnabled = true
        }
    }
    
    func stickerDidTap(_ sticker: UIView) {
        self.stickersContainer.subviews.forEach { (view) in
            if view !== sticker {
                (view as? ZLStickerViewAdditional)?.resetState()
            }
        }
    }
    
    func sticker(_ textSticker: ZLTextStickerView, editText text: String) {
        self.showInputTextVC(text, textColor: textSticker.textColor, bgColor: textSticker.bgColor) { [weak self] (text, textColor, bgColor) in
            guard let `self` = self else { return }
            if text.isEmpty {
                textSticker.moveToAshbin()
            } else {
                textSticker.startTimer()
                guard textSticker.text != text || textSticker.textColor != textColor || textSticker.bgColor != bgColor else {
                    return
                }
                textSticker.text = text
                textSticker.textColor = textColor
                textSticker.bgColor = bgColor
                let newSize = ZLTextStickerView.calculateSize(text: text, width: self.view.frame.width)
                textSticker.changeSize(to: newSize)
            }
        }
    }
    
}

// MARK: 涂鸦path
public class ZLDrawPath: NSObject {
    
    let pathColor: UIColor
    
    let path: UIBezierPath
    
    let ratio: CGFloat
    
    let shapeLayer: CAShapeLayer
    
    init(pathColor: UIColor, pathWidth: CGFloat, ratio: CGFloat, startPoint: CGPoint) {
        self.pathColor = pathColor
        self.path = UIBezierPath()
        self.path.lineWidth = pathWidth / ratio
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.path.move(to: CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio))
        
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.lineCap = .round
        self.shapeLayer.lineJoin = .round
        self.shapeLayer.lineWidth = pathWidth / ratio
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = pathColor.cgColor
        self.shapeLayer.path = self.path.cgPath
        
        self.ratio = ratio
        
        super.init()
    }
    
    func addLine(to point: CGPoint) {
        self.path.addLine(to: CGPoint(x: point.x / self.ratio, y: point.y / self.ratio))
        self.shapeLayer.path = self.path.cgPath
    }
    
    func drawPath() {
        self.pathColor.set()
        self.path.stroke()
    }
    
}

// MARK: 马赛克path
public class ZLMosaicPath: NSObject {
    
    let path: UIBezierPath
    
    let ratio: CGFloat
    
    let startPoint: CGPoint
    
    var linePoints: [CGPoint] = []
    
    init(pathWidth: CGFloat, ratio: CGFloat, startPoint: CGPoint) {
        self.path = UIBezierPath()
        self.path.lineWidth = pathWidth
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.path.move(to: startPoint)
        
        self.ratio = ratio
        self.startPoint = CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio)
        
        super.init()
    }
    
    func addLine(to point: CGPoint) {
        self.path.addLine(to: point)
        self.linePoints.append(CGPoint(x: point.x / self.ratio, y: point.y / self.ratio))
    }
    
}
