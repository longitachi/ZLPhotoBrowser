//
//  ZLEditImageViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/26.
//
//  Copyright (c) 2020 Long Zhang <longitachi@163.com>
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
    
    init(drawPaths: [ZLDrawPath], mosaicPaths: [ZLMosaicPath], editRect: CGRect?, angle: CGFloat) {
        self.drawPaths = drawPaths
        self.mosaicPaths = mosaicPaths
        self.editRect = editRect
        self.angle = angle
        super.init()
    }
    
}

public class ZLEditImageViewController: UIViewController {

    var originalImage: UIImage
    
    // 第一次进入界面时，布局后frame，裁剪dimiss动画使用
    var originalFrame: CGRect = .zero
    
    // 图片可编辑rect
    var editRect: CGRect
    
    let tools: EditImageTool
    
    var editImage: UIImage
    
    var cancelBtn: UIButton!
    
    var scrollView: UIScrollView!
    
    var containerView: UIView!
    
    // 显示图片
    var imageView: UIImageView!
    
    // 显示涂鸦
    var drawingImageView: UIImageView!
    
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
    
    var drawBtn: UIButton!
    
    var clipBtn: UIButton!
    
    var mosaicBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var revokeBtn: UIButton!
    
    // 选择涂鸦颜色
    var drawColorCollectionView: UICollectionView!
    
    let drawColors: [UIColor]
    
    var currentDrawColor = ZLPhotoConfiguration.default().editImageDefaultDrawColor
    
    var drawPaths: [ZLDrawPath] = []
    
    var drawLineWidth: CGFloat = 5
    
    var mosaicPaths: [ZLMosaicPath] = []
    
    var mosaicLineWidth: CGFloat = 25
    
    var isScrolling = false
    
    var shouldLayout = true
    
    var angle: CGFloat = 0
    
    var imageSize: CGSize {
        if self.angle == -90 || self.angle == -270 {
            return CGSize(width: self.originalImage.size.height, height: self.originalImage.size.width)
        }
        return self.originalImage.size
    }
    
    @objc public var editFinishBlock: ( (UIImage, ZLEditImageModel) -> Void )?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        zl_debugPrint("ZLEditImageViewController deinit")
    }
    
    @objc convenience init(image: UIImage) {
        self.init(image: image, tools: [.draw, .clip, .mosaic])
    }
    
    public init(image: UIImage, editModel: ZLEditImageModel? = nil, tools: ZLEditImageViewController.EditImageTool = ZLPhotoConfiguration.default().editImageTools) {
        self.originalImage = image
        self.editImage = image
        self.drawPaths = editModel?.drawPaths ?? []
        self.mosaicPaths = editModel?.mosaicPaths ?? []
        self.editRect = editModel?.editRect ?? CGRect(origin: .zero, size: image.size)
        self.angle = editModel?.angle ?? 0
        self.tools = tools.rawValue == 0 ? [.draw, .clip, .mosaic] : tools
        if ZLPhotoConfiguration.default().editImageDrawColors.isEmpty {
            self.drawColors = [.white, .black, zlRGB(241, 79, 79), zlRGB(243, 170, 78), zlRGB(80, 169, 56), zlRGB(30, 183, 243), zlRGB(139, 105, 234)]
        } else {
            self.drawColors = ZLPhotoConfiguration.default().editImageDrawColors
        }
        super.init(nibName: nil, bundle: nil)
        
        if !self.drawColors.contains(self.currentDrawColor) {
            self.currentDrawColor = self.drawColors.first!
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.rotationImageView()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard self.shouldLayout else {
            return
        }
        self.shouldLayout = false
        zl_debugPrint("edit image layout subviews")
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        self.scrollView.frame = self.view.bounds
        self.resetContainerViewFrame()
        
        self.topShadowView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150)
        self.topShadowLayer.frame = self.topShadowView.bounds
        self.cancelBtn.frame = CGRect(x: 30, y: insets.top+10, width: 28, height: 28)
        
        self.bottomShadowView.frame = CGRect(x: 0, y: self.view.frame.height-150-insets.bottom, width: self.view.frame.width, height: 150+insets.bottom)
        self.bottomShadowLayer.frame = self.bottomShadowView.bounds
        
        self.drawColorCollectionView.frame = CGRect(x: 30, y: 20, width: self.view.frame.width - 90, height: 50)
        self.revokeBtn.frame = CGRect(x: self.view.frame.width - 15 - 35, y: 30, width: 35, height: 30)
        
        var toolBtnX: CGFloat = 30
        let toolBtnY: CGFloat = 85
        let toolBtnSize = CGSize(width: 30, height: 30)
        let toolBtnSpacing: CGFloat = 25
        if self.tools.contains(.draw) {
            self.drawBtn.frame = CGRect(origin: CGPoint(x: toolBtnX, y: toolBtnY), size: toolBtnSize)
            toolBtnX += toolBtnSize.width + toolBtnSpacing
        }
        if self.tools.contains(.clip) {
            self.clipBtn.frame = CGRect(origin: CGPoint(x: toolBtnX, y: toolBtnY), size: toolBtnSize)
            toolBtnX += toolBtnSize.width + toolBtnSpacing
        }
        if self.tools.contains(.mosaic) {
            self.mosaicBtn.frame = CGRect(origin: CGPoint(x: toolBtnX, y: toolBtnY), size: toolBtnSize)
            toolBtnX += toolBtnSize.width + toolBtnSpacing
        }
        
        let doneBtnH = ZLLayout.bottomToolBtnH
        let doneBtnW = localLanguageTextValue(.editFinish).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: doneBtnH)).width + 20
        // y 多减的 8 是为了和工具条居中 (50 - doneBtnH) / 2 = 8
        self.doneBtn.frame = CGRect(x: self.view.frame.width-15-doneBtnW, y: toolBtnY, width: doneBtnW, height: doneBtnH)
        
        if !self.drawPaths.isEmpty {
            self.drawLine()
        }
        if !self.mosaicPaths.isEmpty {
            self.generateNewMosaicImage()
        }
    }
    
    func resetContainerViewFrame() {
        self.scrollView.setZoomScale(1, animated: true)
        self.imageView.image = self.editImage
        
        let editSize = self.editRect.size
        let scrollViewSize = self.scrollView.frame
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
        
        self.drawBtn = UIButton(type: .custom)
        self.drawBtn.setImage(getImage("zl_drawLine"), for: .normal)
        self.drawBtn.setImage(getImage("zl_drawLine_selected"), for: .selected)
        self.drawBtn.adjustsImageWhenHighlighted = false
        self.drawBtn.addTarget(self, action: #selector(drawBtnClick), for: .touchUpInside)
        self.bottomShadowView.addSubview(self.drawBtn)
        
        self.clipBtn = UIButton(type: .custom)
        self.clipBtn.setImage(getImage("zl_clip"), for: .normal)
        self.clipBtn.adjustsImageWhenHighlighted = false
        self.clipBtn.addTarget(self, action: #selector(clipBtnClick), for: .touchUpInside)
        self.bottomShadowView.addSubview(self.clipBtn)
        
        self.mosaicBtn = UIButton(type: .custom)
        self.mosaicBtn.setImage(getImage("zl_mosaic"), for: .normal)
        self.mosaicBtn.setImage(getImage("zl_mosaic_selected"), for: .selected)
        self.mosaicBtn.adjustsImageWhenHighlighted = false
        self.mosaicBtn.addTarget(self, action: #selector(mosaicBtnClick), for: .touchUpInside)
        self.bottomShadowView.addSubview(self.mosaicBtn)
        
        self.doneBtn = UIButton(type: .custom)
        self.doneBtn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        self.doneBtn.backgroundColor = .bottomToolViewBtnNormalBgColor
        self.doneBtn.setTitle(localLanguageTextValue(.editFinish), for: .normal)
        self.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        self.bottomShadowView.addSubview(self.doneBtn)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.drawColorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.drawColorCollectionView.backgroundColor = .clear
        self.drawColorCollectionView.delegate = self
        self.drawColorCollectionView.dataSource = self
        self.drawColorCollectionView.isHidden = true
        self.bottomShadowView.addSubview(self.drawColorCollectionView)
        
        ZLDrawColorCell.zl_register(self.drawColorCollectionView)
        
        self.revokeBtn = UIButton(type: .custom)
        self.revokeBtn.setImage(getImage("zl_revoke_disable"), for: .disabled)
        self.revokeBtn.setImage(getImage("zl_revoke"), for: .normal)
        self.revokeBtn.adjustsImageWhenHighlighted = false
        self.revokeBtn.isEnabled = false
        self.revokeBtn.isHidden = true
        self.revokeBtn.addTarget(self, action: #selector(revokeBtnClick), for: .touchUpInside)
        self.bottomShadowView.addSubview(self.revokeBtn)
        
        if self.tools.contains(.mosaic) {
            self.mosaicImage = self.originalImage.mosaicImage()
            
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drawAction(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        self.scrollView.panGestureRecognizer.require(toFail: pan)
    }
    
    func rotationImageView() {
        var transform = CGAffineTransform.identity
        if self.angle == -90 {
            transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        } else if self.angle == -180 {
            transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        } else if self.angle == -270 {
            transform = CGAffineTransform(rotationAngle: -CGFloat.pi*3/2)
        }
        self.imageView.transform = transform
        self.drawingImageView.transform = transform
    }
    
    @objc func cancelBtnClick() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func drawBtnClick() {
        self.drawBtn.isSelected = !self.drawBtn.isSelected
        self.drawColorCollectionView.isHidden = !self.drawBtn.isSelected
        self.revokeBtn.isHidden = !self.drawBtn.isSelected
        self.revokeBtn.isEnabled = self.drawPaths.count > 0
        self.mosaicBtn.isSelected = false
    }
    
    @objc func clipBtnClick() {
        let currentEditImage = self.buildImage()
        let vc = ZLClipImageViewController(image: currentEditImage, editRect: self.editRect, angle: self.angle)
        let rect = self.scrollView.convert(self.containerView.frame, to: self.view)
        vc.presentAnimateFrame = rect
        vc.presentAnimateImage = self.clipImage(currentEditImage)
        vc.modalPresentationStyle = .fullScreen
        
        vc.clipDoneBlock = { [weak self] (angle, editFrame) in
            guard let `self` = self else { return }
            if self.angle != angle {
                self.angle = angle
                self.rotationImageView()
            }
            self.editRect = editFrame
            self.resetContainerViewFrame()
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
    
    @objc func mosaicBtnClick() {
        self.drawBtn.isSelected = false
        self.drawColorCollectionView.isHidden = true
        self.mosaicBtn.isSelected = !self.mosaicBtn.isSelected
        self.revokeBtn.isHidden = !self.mosaicBtn.isSelected
        self.revokeBtn.isEnabled = self.mosaicPaths.count > 0
    }
    
    @objc func doneBtnClick() {
        var image = self.buildImage()
        image = self.clipImage(image) ?? image
        self.editFinishBlock?(image, ZLEditImageModel(drawPaths: self.drawPaths, mosaicPaths: self.mosaicPaths, editRect: self.editRect, angle: self.angle))
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func revokeBtnClick() {
        if self.drawBtn.isSelected {
            guard !self.drawPaths.isEmpty else {
                return
            }
            self.drawPaths.removeLast()
            self.revokeBtn.isEnabled = self.drawPaths.count > 0
            self.drawLine()
        } else if self.mosaicBtn.isSelected {
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
        if self.drawBtn.isSelected {
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
                var toImageScale = ZLMaxImageWidth / size.width
                if self.editImage.size.width / self.editImage.size.height > 1 {
                    toImageScale = ZLMaxImageWidth / size.height
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
        } else if self.mosaicBtn.isSelected {
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
        var toImageScale = ZLMaxImageWidth / size.width
        if self.editImage.size.width / self.editImage.size.height > 1 {
            toImageScale = ZLMaxImageWidth / size.height
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
        self.originalImage.draw(at: .zero)
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
        
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return self.editImage
        }
        return UIImage(cgImage: cgi, scale: self.editImage.scale, orientation: .up)
    }
    
    func clipImage(_ image: UIImage) -> UIImage? {
        var newImage = image
        if self.angle == -90 {
            newImage = image.rotate(orientation: .left)
        } else if self.angle == -180 {
            newImage = image.rotate(orientation: .down)
        } else if self.angle == -270 {
            newImage = image.rotate(orientation: .right)
        }
        guard self.editRect.size != newImage.size else {
            return newImage
        }
        let origin = CGPoint(x: -self.editRect.minX, y: -self.editRect.minY)
        UIGraphicsBeginImageContextWithOptions(self.editRect.size, false, newImage.scale)
        newImage.draw(at: origin)
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return temp
        }
        let clipImage = UIImage(cgImage: cgi, scale: newImage.scale, orientation: .up)
        return clipImage
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
        if gestureRecognizer is UITapGestureRecognizer {
            if self.bottomShadowView.alpha == 1 {
                let p = gestureRecognizer.location(in: self.view)
                return !self.bottomShadowView.frame.contains(p)
            } else {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            return (self.drawBtn.isSelected || self.mosaicBtn.isSelected) && !self.isScrolling
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
        self.isScrolling = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isScrolling = decelerate
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isScrolling = false
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.isScrolling = false
    }
    
}


extension ZLEditImageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.drawColors.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.zl_identifier(), for: indexPath) as! ZLDrawColorCell
        
        let c = self.drawColors[indexPath.row]
        cell.color = c
        if c == self.currentDrawColor {
            cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        } else {
            cell.bgWhiteView.layer.transform = CATransform3DIdentity
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentDrawColor = self.drawColors[indexPath.row]
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
    
}



extension ZLEditImageViewController {
    
    public struct EditImageTool: OptionSet {
        
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let draw = EditImageTool(rawValue: 1 << 0)
        
        public static let clip = EditImageTool(rawValue: 1 << 1)
        
        public static let mosaic = EditImageTool(rawValue: 1 << 2)
        
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
    
    /// 初始化 mosaic path
    /// - Parameters:
    ///   - pathWidth: 线宽
    ///   - startPoint: path 起始点
    ///   - actualStartPoint: startPoint 相对于图片的真实起始点
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
