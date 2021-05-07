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
    
    public let selectRatio: ZLImageClipRatio?
    
    public let selectFilter: ZLFilter?
    
    public let textStickers: [(state: ZLTextStickerState, index: Int)]?
    
    public let imageStickers: [(state: ZLImageStickerState, index: Int)]?
    
    init(drawPaths: [ZLDrawPath], mosaicPaths: [ZLMosaicPath], editRect: CGRect?, angle: CGFloat, selectRatio: ZLImageClipRatio?, selectFilter: ZLFilter, textStickers: [(state: ZLTextStickerState, index: Int)]?, imageStickers: [(state: ZLImageStickerState, index: Int)]?) {
        self.drawPaths = drawPaths
        self.mosaicPaths = mosaicPaths
        self.editRect = editRect
        self.angle = angle
        self.selectRatio = selectRatio
        self.selectFilter = selectFilter
        self.textStickers = textStickers
        self.imageStickers = imageStickers
        super.init()
    }
    
}

public class ZLEditImageViewController: UIViewController {

    static let filterColViewH: CGFloat = 80
    
    static let maxDrawLineImageWidth: CGFloat = 600
    
    static let ashbinNormalBgColor = zlRGB(40, 40, 40).withAlphaComponent(0.8)
    
    var animate = false
    
    var originalImage: UIImage
    
    // 第一次进入界面时，布局后frame，裁剪dimiss动画使用
    var originalFrame: CGRect = .zero
    
    // 图片可编辑rect
    var editRect: CGRect
    
    let tools: [ZLEditImageViewController.EditImageTool]
    
    var selectRatio: ZLImageClipRatio?
    
    var editImage: UIImage
    
    var cancelBtn: UIButton!
    
    var scrollView: UIScrollView!
    
    var containerView: UIView!
    
    // Show image.
    var imageView: UIImageView!
    
    // Show draw lines.
    var drawingImageView: UIImageView!
    
    // Show text and image stickers.
    var stickersContainer: UIView!
    
    // 处理好的马赛克图片
    var mosaicImage: UIImage?
    
    // 显示马赛克图片的layer
    var mosaicImageLayer: CALayer?
    
    // 显示马赛克图片的layer的mask
    var mosaicImageLayerMaskLayer: CAShapeLayer?
    
    // 上方渐变阴影层
    var topShadowView: UIView!
    
    var topShadowLayer: CAGradientLayer!
     
    // 下方渐变阴影层
    var bottomShadowView: UIView!
    
    var bottomShadowLayer: CAGradientLayer!
    
    var doneBtn: UIButton!
    
    var revokeBtn: UIButton!
    
    var selectedTool: ZLEditImageViewController.EditImageTool?
    
    var editToolCollectionView: UICollectionView!
    
    var drawColorCollectionView: UICollectionView!
    
    var filterCollectionView: UICollectionView!
    
    var ashbinView: UIView!
    
    var ashbinImgView: UIImageView!
    
    let drawColors: [UIColor]
    
    var currentDrawColor = ZLPhotoConfiguration.default().editImageDefaultDrawColor
    
    var drawPaths: [ZLDrawPath]
    
    var drawLineWidth: CGFloat = 5
    
    var mosaicPaths: [ZLMosaicPath]
    
    var mosaicLineWidth: CGFloat = 25
    
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
    
    var panGes: UIPanGestureRecognizer!
    
    var imageSize: CGSize {
        if self.angle == -90 || self.angle == -270 {
            return CGSize(width: self.originalImage.size.height, height: self.originalImage.size.width)
        }
        return self.originalImage.size
    }
    
    @objc public var editFinishBlock: ( (UIImage, ZLEditImageModel?) -> Void )?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        zl_debugPrint("ZLEditImageViewController deinit")
    }
    
    @objc public class func showEditImageVC(parentVC: UIViewController?, animate: Bool = false, image: UIImage, editModel: ZLEditImageModel? = nil, completion: ( (UIImage, ZLEditImageModel?) -> Void )? ) {
        let tools = ZLPhotoConfiguration.default().editImageTools
        if ZLPhotoConfiguration.default().showClipDirectlyIfOnlyHasClipTool, tools.count == 1, tools.contains(.clip) {
            let vc = ZLClipImageViewController(image: image, editRect: editModel?.editRect, angle: editModel?.angle ?? 0, selectRatio: editModel?.selectRatio)
            vc.clipDoneBlock = { (angle, editRect, ratio) in
                let m = ZLEditImageModel(drawPaths: [], mosaicPaths: [], editRect: editRect, angle: angle, selectRatio: ratio, selectFilter: .normal, textStickers: nil, imageStickers: nil)
                completion?(image.clipImage(angle, editRect) ?? image, m)
            }
            vc.animate = animate
            vc.modalPresentationStyle = .fullScreen
            parentVC?.present(vc, animated: animate, completion: nil)
        } else {
            let vc = ZLEditImageViewController(image: image, editModel: editModel)
            vc.editFinishBlock = {  (ei, editImageModel) in
                completion?(ei, editImageModel)
            }
            vc.animate = animate
            vc.modalPresentationStyle = .fullScreen
            parentVC?.present(vc, animated: animate, completion: nil)
        }
    }
    
    @objc public init(image: UIImage, editModel: ZLEditImageModel? = nil) {
        self.originalImage = image
        self.editImage = image
        self.editRect = editModel?.editRect ?? CGRect(origin: .zero, size: image.size)
        self.drawColors = ZLPhotoConfiguration.default().editImageDrawColors
        self.currentFilter = editModel?.selectFilter ?? .normal
        self.drawPaths = editModel?.drawPaths ?? []
        self.mosaicPaths = editModel?.mosaicPaths ?? []
        self.angle = editModel?.angle ?? 0
        self.selectRatio = editModel?.selectRatio
        
        var ts = ZLPhotoConfiguration.default().editImageTools
        if ts.contains(.imageSticker), ZLPhotoConfiguration.default().imageStickerContainerView == nil {
            ts.removeAll { $0 == .imageSticker }
        }
        self.tools = ts
        
        super.init(nibName: nil, bundle: nil)
        
        if !self.drawColors.contains(self.currentDrawColor) {
            self.currentDrawColor = self.drawColors.first!
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.rotationImageView()
        if self.tools.contains(.filter) {
            self.generateFilterImages()
        }
    }
    
    public override func viewDidLayoutSubviews() {
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
        
        self.scrollView.frame = self.view.bounds
        self.resetContainerViewFrame()
        
        self.topShadowView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150)
        self.topShadowLayer.frame = self.topShadowView.bounds
        self.cancelBtn.frame = CGRect(x: 30, y: insets.top+10, width: 28, height: 28)
        
        self.bottomShadowView.frame = CGRect(x: 0, y: self.view.frame.height-140-insets.bottom, width: self.view.frame.width, height: 140+insets.bottom)
        self.bottomShadowLayer.frame = self.bottomShadowView.bounds
        
        self.drawColorCollectionView.frame = CGRect(x: 20, y: 20, width: self.view.frame.width - 80, height: 50)
        self.revokeBtn.frame = CGRect(x: self.view.frame.width - 15 - 35, y: 30, width: 35, height: 30)
        
        self.filterCollectionView.frame = CGRect(x: 20, y: 0, width: self.view.frame.width-40, height: ZLEditImageViewController.filterColViewH)
        
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
            self.drawColorCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
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
            self.thumbnailFilterImages = ZLPhotoConfiguration.default().filters.map { $0.applier?(thumbnailImage) ?? thumbnailImage }
            
            DispatchQueue.main.async {
                self.filterCollectionView.reloadData()
                self.filterCollectionView.performBatchUpdates {
                    
                } completion: { (_) in
                    if let index = ZLPhotoConfiguration.default().filters.firstIndex(where: { $0 == self.currentFilter }) {
                        self.filterCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
                    }
                }

            }
        }
    }
    
    func resetContainerViewFrame() {
        self.scrollView.setZoomScale(1, animated: true)
        self.imageView.image = self.editImage
        
        let editSize = self.editRect.size
        let scrollViewSize = self.scrollView.frame.size
        let ratio = min(scrollViewSize.width / editSize.width, scrollViewSize.height / editSize.height)
        let w = ratio * editSize.width * self.scrollView.zoomScale
        let h = ratio * editSize.height * self.scrollView.zoomScale
        self.containerView.frame = CGRect(x: max(0, (scrollViewSize.width-w)/2), y: max(0, (scrollViewSize.height-h)/2), width: w, height: h)
        
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
            self.scrollView.maximumZoomScale = widthScale
            self.scrollView.zoomScale = widthScale
            self.scrollView.contentOffset = .zero
        } else if self.editRect.width / self.editRect.height > 1 {
            self.scrollView.maximumZoomScale = max(3, self.view.frame.height / h)
        }
        
        self.originalFrame = self.view.convert(self.containerView.frame, from: self.scrollView)
        self.isScrolling = false
    }
    
    func setupUI() {
        self.view.backgroundColor = .black
        
        self.scrollView = UIScrollView()
        self.scrollView.backgroundColor = .black
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 3
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        
        self.containerView = UIView()
        self.containerView.clipsToBounds = true
        self.scrollView.addSubview(self.containerView)
        
        self.imageView = UIImageView(image: self.originalImage)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.imageView.backgroundColor = .black
        self.containerView.addSubview(self.imageView)
        
        self.drawingImageView = UIImageView()
        self.drawingImageView.contentMode = .scaleAspectFit
        self.drawingImageView.isUserInteractionEnabled = true
        self.containerView.addSubview(self.drawingImageView)
        
        self.stickersContainer = UIView()
        self.containerView.addSubview(self.stickersContainer)
        
        let color1 = UIColor.black.withAlphaComponent(0.35).cgColor
        let color2 = UIColor.black.withAlphaComponent(0).cgColor
        self.topShadowView = UIView()
        self.view.addSubview(self.topShadowView)
        
        self.topShadowLayer = CAGradientLayer()
        self.topShadowLayer.colors = [color1, color2]
        self.topShadowLayer.locations = [0, 1]
        self.topShadowView.layer.addSublayer(self.topShadowLayer)
        
        self.cancelBtn = UIButton(type: .custom)
        self.cancelBtn.setImage(getImage("zl_retake"), for: .normal)
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        self.cancelBtn.adjustsImageWhenHighlighted = false
        self.cancelBtn.zl_enlargeValidTouchArea(inset: 30)
        self.topShadowView.addSubview(self.cancelBtn)
        
        self.bottomShadowView = UIView()
        self.view.addSubview(self.bottomShadowView)
        
        self.bottomShadowLayer = CAGradientLayer()
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
        
        self.doneBtn = UIButton(type: .custom)
        self.doneBtn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        self.doneBtn.backgroundColor = .bottomToolViewBtnNormalBgColor
        self.doneBtn.setTitle(localLanguageTextValue(.editFinish), for: .normal)
        self.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        self.bottomShadowView.addSubview(self.doneBtn)
        
        let drawColorLayout = UICollectionViewFlowLayout()
        drawColorLayout.itemSize = CGSize(width: 30, height: 30)
        drawColorLayout.minimumLineSpacing = 15
        drawColorLayout.minimumInteritemSpacing = 15
        drawColorLayout.scrollDirection = .horizontal
        drawColorLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.drawColorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: drawColorLayout)
        self.drawColorCollectionView.backgroundColor = .clear
        self.drawColorCollectionView.delegate = self
        self.drawColorCollectionView.dataSource = self
        self.drawColorCollectionView.isHidden = true
        self.drawColorCollectionView.showsHorizontalScrollIndicator = false
        self.bottomShadowView.addSubview(self.drawColorCollectionView)
        
        ZLDrawColorCell.zl_register(self.drawColorCollectionView)
        
        let filterLayout = UICollectionViewFlowLayout()
        filterLayout.itemSize = CGSize(width: ZLEditImageViewController.filterColViewH-20, height: ZLEditImageViewController.filterColViewH)
        filterLayout.minimumLineSpacing = 15
        filterLayout.minimumInteritemSpacing = 15
        filterLayout.scrollDirection = .horizontal
        self.filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: filterLayout)
        self.filterCollectionView.backgroundColor = .clear
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        self.filterCollectionView.isHidden = true
        self.filterCollectionView.showsHorizontalScrollIndicator = false
        self.bottomShadowView.addSubview(self.filterCollectionView)
        
        ZLFilterImageCell.zl_register(self.filterCollectionView)
        
        self.revokeBtn = UIButton(type: .custom)
        self.revokeBtn.setImage(getImage("zl_revoke_disable"), for: .disabled)
        self.revokeBtn.setImage(getImage("zl_revoke"), for: .normal)
        self.revokeBtn.adjustsImageWhenHighlighted = false
        self.revokeBtn.isEnabled = false
        self.revokeBtn.isHidden = true
        self.revokeBtn.addTarget(self, action: #selector(revokeBtnClick), for: .touchUpInside)
        self.bottomShadowView.addSubview(self.revokeBtn)
        
        let ashbinSize = CGSize(width: 160, height: 80)
        self.ashbinView = UIView(frame: CGRect(x: (self.view.frame.width-ashbinSize.width)/2, y: self.view.frame.height-ashbinSize.height-40, width: ashbinSize.width, height: ashbinSize.height))
        self.ashbinView.backgroundColor = ZLEditImageViewController.ashbinNormalBgColor
        self.ashbinView.layer.cornerRadius = 15
        self.ashbinView.layer.masksToBounds = true
        self.ashbinView.isHidden = true
        self.view.addSubview(self.ashbinView)
        
        self.ashbinImgView = UIImageView(image: getImage("zl_ashbin"), highlightedImage: getImage("zl_ashbin_open"))
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
            // 之前选择过滤镜
            if let applier = self.currentFilter.applier {
                let image = applier(self.originalImage)
                self.editImage = image
                self.filterImages[self.currentFilter.name] = image
                
                self.mosaicImage = self.editImage.mosaicImage()
            } else {
                self.mosaicImage = self.originalImage.mosaicImage()
            }
            
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
            ZLPhotoConfiguration.default().imageStickerContainerView?.hideBlock = { [weak self] in
                self?.setToolView(show: true)
                self?.imageStickerContainerIsHidden = true
            }
            
            ZLPhotoConfiguration.default().imageStickerContainerView?.selectImageBlock = { [weak self] (image) in
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
        self.scrollView.panGestureRecognizer.require(toFail: self.panGes)
        
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
        let transform = CGAffineTransform(rotationAngle: self.angle.toPi)
        self.imageView.transform = transform
        self.drawingImageView.transform = transform
        self.stickersContainer.transform = transform
    }
    
    @objc func cancelBtnClick() {
        self.dismiss(animated: self.animate, completion: nil)
    }
    
    func drawBtnClick() {
        let isSelected = self.selectedTool != .draw
        if isSelected {
            self.selectedTool = .draw
        } else {
            self.selectedTool = nil
        }
        self.drawColorCollectionView.isHidden = !isSelected
        self.revokeBtn.isHidden = !isSelected
        self.revokeBtn.isEnabled = self.drawPaths.count > 0
        self.filterCollectionView.isHidden = true
    }
    
    func clipBtnClick() {
        let currentEditImage = self.buildImage()
        let vc = ZLClipImageViewController(image: currentEditImage, editRect: self.editRect, angle: self.angle, selectRatio: self.selectRatio)
        let rect = self.scrollView.convert(self.containerView.frame, to: self.view)
        vc.presentAnimateFrame = rect
        vc.presentAnimateImage = currentEditImage.clipImage(self.angle, self.editRect)
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
        
        self.present(vc, animated: false) {
            self.scrollView.alpha = 0
            self.topShadowView.alpha = 0
            self.bottomShadowView.alpha = 0
        }
    }
    
    func imageStickerBtnClick() {
        ZLPhotoConfiguration.default().imageStickerContainerView?.show(in: self.view)
        self.setToolView(show: false)
        self.imageStickerContainerIsHidden = false
    }
    
    func textStickerBtnClick() {
        self.showInputTextVC { [weak self] (text, textColor, bgColor) in
            self?.addTextStickersView(text, textColor: textColor, bgColor: bgColor)
        }
    }
    
    func mosaicBtnClick() {
        let isSelected = self.selectedTool != .mosaic
        if isSelected {
            self.selectedTool = .mosaic
        } else {
            self.selectedTool = nil
        }
        
        self.drawColorCollectionView.isHidden = true
        self.filterCollectionView.isHidden = true
        self.revokeBtn.isHidden = !isSelected
        self.revokeBtn.isEnabled = self.mosaicPaths.count > 0
    }
    
    func filterBtnClick() {
        let isSelected = self.selectedTool != .filter
        if isSelected {
            self.selectedTool = .filter
        } else {
            self.selectedTool = nil
        }
        
        self.drawColorCollectionView.isHidden = true
        self.revokeBtn.isHidden = true
        self.filterCollectionView.isHidden = !isSelected
    }
    
    @objc func doneBtnClick() {
        var textStickers: [(ZLTextStickerState, Int)] = []
        var imageStickers: [(ZLImageStickerState, Int)] = []
        for (index, view) in self.stickersContainer.subviews.enumerated() {
            if let ts = view as? ZLTextStickerView, let _ = ts.label.text {
                textStickers.append((ts.state, index))
            } else if let ts = view as? ZLImageStickerView {
                imageStickers.append((ts.state, index))
            }
        }
        
        var hasEdit = true
        if self.drawPaths.isEmpty, self.editRect.size == self.imageSize, self.angle == 0, self.mosaicPaths.isEmpty, imageStickers.isEmpty, textStickers.isEmpty, self.currentFilter.applier == nil {
            hasEdit = false
        }
        
        var resImage = self.originalImage
        var editModel: ZLEditImageModel? = nil
        if hasEdit {
            resImage = self.buildImage()
            resImage = resImage.clipImage(self.angle, self.editRect) ?? resImage
            editModel = ZLEditImageModel(drawPaths: self.drawPaths, mosaicPaths: self.mosaicPaths, editRect: self.editRect, angle: self.angle, selectRatio: self.selectRatio, selectFilter: self.currentFilter, textStickers: textStickers, imageStickers: imageStickers)
        }
        self.editFinishBlock?(resImage, editModel)
        
        self.dismiss(animated: self.animate, completion: nil)
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
                
                let originalRatio = min(self.scrollView.frame.width / self.originalImage.size.width, self.scrollView.frame.height / self.originalImage.size.height)
                let ratio = min(self.scrollView.frame.width / self.editRect.width, self.scrollView.frame.height / self.editRect.height)
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
                
                let path = ZLDrawPath(pathColor: self.currentDrawColor, pathWidth: self.drawLineWidth / self.scrollView.zoomScale, ratio: ratio / originalRatio / toImageScale, startPoint: point)
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
                let ratio = min(self.scrollView.frame.width / self.editRect.width, self.scrollView.frame.height / self.editRect.height)
                
                let pathW = self.mosaicLineWidth / self.scrollView.zoomScale
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
    
    func setToolView(show: Bool) {
        self.topShadowView.layer.removeAllAnimations()
        self.bottomShadowView.layer.removeAllAnimations()
        if show {
            UIView.animate(withDuration: 0.25) {
                self.topShadowView.alpha = 1
                self.bottomShadowView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.topShadowView.alpha = 0
                self.bottomShadowView.alpha = 0
            }
        }
    }
    
    func showInputTextVC(_ text: String? = nil, textColor: UIColor? = nil, bgColor: UIColor? = nil, completion: @escaping ( (String, UIColor, UIColor) -> Void )) {
        // Calculate image displayed frame on the screen.
        var r = self.scrollView.convert(self.view.frame, to: self.containerView)
        r.origin.x += self.scrollView.contentOffset.x / self.scrollView.zoomScale
        r.origin.y += self.scrollView.contentOffset.y / self.scrollView.zoomScale
        let scale = self.imageSize.width / self.imageView.frame.width
        r.origin.x *= scale
        r.origin.y *= scale
        r.size.width *= scale
        r.size.height *= scale
        let bgImage = self.buildImage().clipImage(self.angle, self.editRect)?.clipImage(0, r)
        let vc = ZLInputTextViewController(image: bgImage, text: text, textColor: textColor, bgColor: bgColor)
        
        vc.endInput = { (text, textColor, bgColor) in
            completion(text, textColor, bgColor)
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.showDetailViewController(vc, sender: nil)
    }
    
    func getStickerOriginFrame(_ size: CGSize) -> CGRect {
        let scale = self.scrollView.zoomScale
        // Calculate the display rect of container view.
        let x = (self.scrollView.contentOffset.x - self.containerView.frame.minX) / scale
        let y = (self.scrollView.contentOffset.y - self.containerView.frame.minY) / scale
        let w = view.frame.width / scale
        let h = view.frame.height / scale
        // Convert to text stickers container view.
        let r = self.containerView.convert(CGRect(x: x, y: y, width: w, height: h), to: self.stickersContainer)
        let originFrame = CGRect(x: r.minX + (r.width - size.width) / 2, y: r.minY + (r.height - size.height) / 2, width: size.width, height: size.height)
        return originFrame
    }
    
    /// Add image sticker
    func addImageStickerView(_ image: UIImage) {
        let scale = self.scrollView.zoomScale
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
        let scale = self.scrollView.zoomScale
        let size = ZLTextStickerView.calculateSize(text: text, width: self.view.frame.width)
        let originFrame = self.getStickerOriginFrame(size)
        
        let textSticker = ZLTextStickerView(text: text, textColor: textColor, bgColor: bgColor, originScale: 1 / scale, originAngle: -self.angle, originFrame: originFrame)
        self.stickersContainer.addSubview(textSticker)
        textSticker.frame = originFrame
        
        self.configTextSticker(textSticker)
    }
    
    func configTextSticker(_ textSticker: ZLTextStickerView) {
        textSticker.delegate = self
        self.scrollView.pinchGestureRecognizer?.require(toFail: textSticker.pinchGes)
        self.scrollView.panGestureRecognizer.require(toFail: textSticker.panGes)
        self.panGes.require(toFail: textSticker.panGes)
    }
    
    func configImageSticker(_ imageSticker: ZLImageStickerView) {
        imageSticker.delegate = self
        self.scrollView.pinchGestureRecognizer?.require(toFail: imageSticker.pinchGes)
        self.scrollView.panGestureRecognizer.require(toFail: imageSticker.panGes)
        self.panGes.require(toFail: imageSticker.panGes)
    }
    
    func reCalculateStickersFrame(_ oldSize: CGSize, _ oldAngle: CGFloat, _ newAngle: CGFloat) {
        let currSize = self.stickersContainer.frame.size
        let scale: CGFloat
        if Int(newAngle - oldAngle) % 180 == 0{
            scale = currSize.width / oldSize.width
        } else {
            scale = currSize.height / oldSize.width
        }
        
        self.stickersContainer.subviews.forEach { (view) in
            (view as? ZLStickerViewAdditional)?.addScale(scale)
        }
    }
    
    func drawLine() {
        let originalRatio = min(self.scrollView.frame.width / self.originalImage.size.width, self.scrollView.frame.height / self.originalImage.size.height)
        let ratio = min(self.scrollView.frame.width / self.editRect.width, self.scrollView.frame.height / self.editRect.height)
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
    
    func generateNewMosaicImage() {
        UIGraphicsBeginImageContextWithOptions(self.originalImage.size, false, self.originalImage.scale)
        if self.tools.contains(.filter), let image = self.filterImages[self.currentFilter.name] {
            image.draw(at: .zero)
        } else {
            self.originalImage.draw(at: .zero)
        }
        let context = UIGraphicsGetCurrentContext()
        
        self.mosaicPaths.forEach { (path) in
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
            return
        }
        
        midImage = UIImage(cgImage: midCgImage, scale: self.editImage.scale, orientation: .up)
        
        UIGraphicsBeginImageContextWithOptions(self.originalImage.size, false, self.originalImage.scale)
        self.mosaicImage?.draw(at: .zero)
        midImage?.draw(at: .zero)
        
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return
        }
        let image = UIImage(cgImage: cgi, scale: self.editImage.scale, orientation: .up)
        
        self.editImage = image
        self.imageView.image = self.editImage
        
        self.mosaicImageLayerMaskLayer?.path = nil
    }
    
    func buildImage() -> UIImage {
        let imageSize = self.originalImage.size
        
        UIGraphicsBeginImageContextWithOptions(self.editImage.size, false, self.editImage.scale)
        self.editImage.draw(at: .zero)
        
        self.drawingImageView.image?.draw(in: CGRect(origin: .zero, size: imageSize))
        
        if !self.stickersContainer.subviews.isEmpty, let context = UIGraphicsGetCurrentContext() {
            let scale = self.imageSize.width / self.stickersContainer.frame.width
            self.stickersContainer.subviews.forEach { (view) in
                (view as? ZLStickerViewAdditional)?.resetState()
            }
            context.concatenate(CGAffineTransform(scaleX: scale, y: scale))
            self.stickersContainer.layer.render(in: context)
            context.concatenate(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        }
        
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return self.editImage
        }
        return UIImage(cgImage: cgi, scale: self.editImage.scale, orientation: .up)
    }
    
    func finishClipDismissAnimate() {
        self.scrollView.alpha = 1
        UIView.animate(withDuration: 0.1) {
            self.topShadowView.alpha = 1
            self.bottomShadowView.alpha = 1
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
        guard scrollView == self.scrollView else {
            return
        }
        self.isScrolling = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == self.scrollView else {
            return
        }
        self.isScrolling = decelerate
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else {
            return
        }
        self.isScrolling = false
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else {
            return
        }
        self.isScrolling = false
    }
    
}


extension ZLEditImageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.editToolCollectionView {
            return self.tools.count
        } else if collectionView == self.drawColorCollectionView {
            return self.drawColors.count
        } else {
            return self.thumbnailFilterImages.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.editToolCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLEditToolCell.zl_identifier(), for: indexPath) as! ZLEditToolCell
            
            let toolType = self.tools[indexPath.row]
            cell.icon.isHighlighted = false
            cell.toolType = toolType
            cell.icon.isHighlighted = toolType == self.selectedTool
            
            return cell
        } else if collectionView == self.drawColorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.zl_identifier(), for: indexPath) as! ZLDrawColorCell
            
            let c = self.drawColors[indexPath.row]
            cell.color = c
            if c == self.currentDrawColor {
                cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
            } else {
                cell.bgWhiteView.layer.transform = CATransform3DIdentity
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLFilterImageCell.zl_identifier(), for: indexPath) as! ZLFilterImageCell
            
            let image = self.thumbnailFilterImages[indexPath.row]
            let filter = ZLPhotoConfiguration.default().filters[indexPath.row]
            
            cell.nameLabel.text = filter.name
            cell.imageView.image = image
            
            if self.currentFilter === filter {
                cell.nameLabel.textColor = .white
            } else {
                cell.nameLabel.textColor = zlRGB(160, 160, 160)
            }
            
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.editToolCollectionView {
            let toolType = self.tools[indexPath.row]
            switch toolType {
            case .draw:
                self.drawBtnClick()
            case .clip:
                self.clipBtnClick()
            case .imageSticker:
                self.imageStickerBtnClick()
            case .textSticker:
                self.textStickerBtnClick()
            case .mosaic:
                self.mosaicBtnClick()
            case .filter:
                self.filterBtnClick()
            }
        } else if collectionView == self.drawColorCollectionView {
            self.currentDrawColor = self.drawColors[indexPath.row]
        } else {
            self.currentFilter = ZLPhotoConfiguration.default().filters[indexPath.row]
            if let image = self.filterImages[self.currentFilter.name] {
                self.editImage = image
            } else {
                let image = self.currentFilter.applier?(self.originalImage) ?? self.originalImage
                self.editImage = image
                self.filterImages[self.currentFilter.name] = image
            }
            if self.tools.contains(.mosaic) {
                self.mosaicImage = self.editImage.mosaicImage()
                
                self.mosaicImageLayer?.removeFromSuperlayer()
                
                self.mosaicImageLayer = CALayer()
                self.mosaicImageLayer?.frame = self.imageView.bounds
                self.mosaicImageLayer?.contents = self.mosaicImage?.cgImage
                self.imageView.layer.insertSublayer(self.mosaicImageLayer!, below: self.mosaicImageLayerMaskLayer)
                
                self.mosaicImageLayer?.mask = self.mosaicImageLayerMaskLayer
                
                if self.mosaicPaths.isEmpty {
                    self.imageView.image = self.editImage
                } else {
                    self.generateNewMosaicImage()
                }
            } else {
                self.imageView.image = self.editImage
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
            self.ashbinView.backgroundColor = ZLEditImageViewController.ashbinNormalBgColor
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


extension ZLEditImageViewController {
    
    @objc public enum EditImageTool: Int {
        case draw
        case clip
        case imageSticker
        case textSticker
        case mosaic
        case filter
    }
    
}


// MARK: 裁剪比例

public class ZLImageClipRatio: NSObject {
    
    let title: String
    
    let whRatio: CGFloat
    
    @objc public init(title: String, whRatio: CGFloat) {
        self.title = title
        self.whRatio = whRatio
    }
    
}


func ==(lhs: ZLImageClipRatio, rhs: ZLImageClipRatio) -> Bool {
    return lhs.whRatio == rhs.whRatio
}


extension ZLImageClipRatio {
    
    @objc public static let custom = ZLImageClipRatio(title: "custom", whRatio: 0)
    
    @objc public static let wh1x1 = ZLImageClipRatio(title: "1 : 1", whRatio: 1)
    
    @objc public static let wh3x4 = ZLImageClipRatio(title: "3 : 4", whRatio: 3.0/4.0)
    
    @objc public static let wh4x3 = ZLImageClipRatio(title: "4 : 3", whRatio: 4.0/3.0)
    
    @objc public static let wh2x3 = ZLImageClipRatio(title: "2 : 3", whRatio: 2.0/3.0)
    
    @objc public static let wh3x2 = ZLImageClipRatio(title: "3 : 2", whRatio: 3.0/2.0)
    
    @objc public static let wh9x16 = ZLImageClipRatio(title: "9 : 16", whRatio: 9.0/16.0)
    
    @objc public static let wh16x9 = ZLImageClipRatio(title: "16 : 9", whRatio: 16.0/9.0)
    
}


// MARK: Edit tool cell
class ZLEditToolCell: UICollectionViewCell {
    
    var toolType: ZLEditImageViewController.EditImageTool? {
        didSet {
            switch toolType {
            case .draw?:
                self.icon.image = getImage("zl_drawLine")
                self.icon.highlightedImage = getImage("zl_drawLine_selected")
            case .clip?:
                self.icon.image = getImage("zl_clip")
                self.icon.highlightedImage = getImage("zl_clip")
            case .imageSticker?:
                self.icon.image = getImage("zl_imageSticker")
                self.icon.highlightedImage = getImage("zl_imageSticker")
            case .textSticker?:
                self.icon.image = getImage("zl_textSticker")
                self.icon.highlightedImage = getImage("zl_textSticker")
            case .mosaic?:
                self.icon.image = getImage("zl_mosaic")
                self.icon.highlightedImage = getImage("zl_mosaic_selected")
            case .filter?:
                self.icon.image = getImage("zl_filter")
                self.icon.highlightedImage = getImage("zl_filter_selected")
            default:
                break
            }
        }
    }
    
    var icon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.icon = UIImageView(frame: self.contentView.bounds)
        self.contentView.addSubview(self.icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: draw color cell

class ZLDrawColorCell: UICollectionViewCell {
    
    var bgWhiteView: UIView!
    
    var colorView: UIView!
    
    var color: UIColor! {
        didSet {
            self.colorView.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.bgWhiteView = UIView()
        self.bgWhiteView.backgroundColor = .white
        self.bgWhiteView.layer.cornerRadius = 10
        self.bgWhiteView.layer.masksToBounds = true
        self.bgWhiteView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.bgWhiteView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        self.contentView.addSubview(self.bgWhiteView)
        
        self.colorView = UIView()
        self.colorView.layer.cornerRadius = 8
        self.colorView.layer.masksToBounds = true
        self.colorView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        self.colorView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        self.contentView.addSubview(self.colorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: filter cell
class ZLFilterImageCell: UICollectionViewCell {
    
    var nameLabel: UILabel!
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.nameLabel = UILabel(frame: CGRect(x: 0, y: self.bounds.height-20, width: self.bounds.width, height: 20))
        self.nameLabel.font = getFont(12)
        self.nameLabel.textColor = .white
        self.nameLabel.textAlignment = .center
        self.nameLabel.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.nameLabel.layer.shadowOffset = .zero
        self.nameLabel.layer.shadowOpacity = 1
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.minimumScaleFactor = 0.5
        self.contentView.addSubview(self.nameLabel)
        
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width))
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
