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

public class ZLEditImageViewController: UIViewController {

    let originalImage: UIImage
    
    let tools: EditImageTool
    
    var editImage: UIImage
    
    var cancelBtn: UIButton!
    
    var scrollView: UIScrollView!
    
    var containerView: UIView!
    
    // 显示图片
    var imageView: UIImageView!
    
    // 显示涂鸦
    var drawingImageView: UIImageView!
    
    // 上方渐变阴影层
    var topShadowView: UIView!
    
    var topShadowLayer: CAGradientLayer!
     
    // 下方渐变阴影层
    var bottomShadowView: UIView!
    
    var bottomShadowLayer: CAGradientLayer!
    
    var drawBtn: UIButton!
    
    var clipBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var revokeBtn: UIButton!
    
    // 选择涂鸦颜色
    var drawColorCollectionView: UICollectionView!
    
    let drawColors: [UIColor]
    
    var currentDrawColor = ZLPhotoConfiguration.default().editImageDefaultDrawColor
    
    var drawPaths: [ZLDrawPath] = []
    
    var drawLineWidth: CGFloat = 5
    
    var isScrolling = false
    
    var shouldLayout = true
    
    public var editFinishBlock: ( (UIImage) -> Void )?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        debugPrint("ZLEditImageViewController deinit")
    }
    
    public init(image: UIImage, tools: ZLEditImageViewController.EditImageTool = ZLPhotoConfiguration.default().editImageTools) {
        self.originalImage = image
        self.editImage = image
        self.tools = tools
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
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard self.shouldLayout else {
            return
        }
        self.shouldLayout = false
        debugPrint("edit image layout subviews")
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
        let toolBtnSpacing: CGFloat = 30
        if self.tools.contains(.draw) {
            self.drawBtn.frame = CGRect(origin: CGPoint(x: toolBtnX, y: toolBtnY), size: toolBtnSize)
            toolBtnX += toolBtnSize.width + toolBtnSpacing
        }
        if self.tools.contains(.clip) {
            self.clipBtn.frame = CGRect(origin: CGPoint(x: toolBtnX, y: toolBtnY), size: toolBtnSize)
            toolBtnX += toolBtnSize.width + toolBtnSpacing
        }
        
        let doneBtnH = ZLLayout.bottomToolBtnH
        let doneBtnW = localLanguageTextValue(.editFinish).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: doneBtnH)).width + 20
        // y 多减的 8 是为了和工具条居中 (50 - doneBtnH) / 2 = 8
        self.doneBtn.frame = CGRect(x: self.view.frame.width-15-doneBtnW, y: toolBtnY, width: doneBtnW, height: doneBtnH)
    }
    
    func resetContainerViewFrame() {
        self.scrollView.zoomScale = 1
        self.imageView.image = self.editImage
        
        let imageSize = self.editImage.size
        let scrollViewSize = self.scrollView.frame
        let ratio = min(scrollViewSize.width / imageSize.width, scrollViewSize.height / imageSize.height)
        let w = ratio * imageSize.width * self.scrollView.zoomScale
        let h = ratio * imageSize.height * self.scrollView.zoomScale
        self.containerView.frame = CGRect(x: max(0, (scrollViewSize.width-w)/2), y: max(0, (scrollViewSize.height-h)/2), width: w, height: h)
        
        self.imageView.frame = self.containerView.bounds
        self.drawingImageView.frame = self.containerView.bounds
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
        self.scrollView.addSubview(self.containerView)
        
        self.imageView = UIImageView(image: self.originalImage)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.imageView.backgroundColor = .black
        self.containerView.addSubview(self.imageView)
        
        self.drawingImageView = UIImageView()
        self.drawingImageView.contentMode = .center
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
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drawAction(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        self.scrollView.panGestureRecognizer.require(toFail: pan)
    }
    
    @objc func cancelBtnClick() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func drawBtnClick() {
        self.drawBtn.isSelected = !self.drawBtn.isSelected
        self.drawColorCollectionView.isHidden = !self.drawBtn.isSelected
        self.revokeBtn.isHidden = !self.drawBtn.isSelected
    }
    
    @objc func clipBtnClick() {
        func animateWhenClipSuc(_ from: CGRect, _ image: UIImage) {
            let animateImageView = UIImageView(image: image)
            animateImageView.contentMode = .scaleAspectFit
            animateImageView.clipsToBounds = true
            animateImageView.frame = from
            self.view.insertSubview(animateImageView, aboveSubview: self.scrollView)
            let to = self.view.convert(self.containerView.frame, from: self.scrollView)
            self.scrollView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                animateImageView.frame = to
            }) { (_) in
                self.scrollView.alpha = 1
                animateImageView.removeFromSuperview()
            }
        }
        
        let vc = ZLClipImageViewController(image: self.buildImage())
        let rect = self.view.convert(self.containerView.frame, from: self.scrollView)
        vc.animateOriginFrame = rect
        vc.modalPresentationStyle = .fullScreen
        
        vc.clipDoneBlock = { [weak self] (image, frame) in
            self?.drawPaths.removeAll()
            self?.revokeBtn.isEnabled = false
            self?.editImage = image
            self?.drawingImageView.image = nil
            self?.resetContainerViewFrame()
            animateWhenClipSuc(frame, image)
        }
        
        vc.cancelClipBlock = { [weak self] (image, frame) in
            self?.resetContainerViewFrame()
            if let _ = image {
                animateWhenClipSuc(frame, image!)
            }
        }
        
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func doneBtnClick() {
        let image = self.buildImage()
        self.dismiss(animated: false) {
            self.editFinishBlock?(image)
        }
    }
    
    @objc func revokeBtnClick() {
        guard !self.drawPaths.isEmpty else {
            return
        }
        self.drawPaths.removeLast()
        self.revokeBtn.isEnabled = self.drawPaths.count > 0
        self.drawLine()
    }
    
    @objc func drawAction(_ pan: UIPanGestureRecognizer) {
        guard self.drawBtn.isSelected else {
            return
        }
        let point = pan.location(in: self.drawingImageView)
        if pan.state == .began {
            self.setToolView(show: false)
            let diff = (self.scrollView.zoomScale - 1)
            let path = ZLDrawPath(pathColor: self.currentDrawColor, pathWidth: self.drawLineWidth - diff, startPoint: point)
            self.drawPaths.append(path)
        } else if pan.state == .changed {
            let path = self.drawPaths.last
            path?.addLine(to: point)
            self.drawLine()
        } else if pan.state == .cancelled || pan.state == .ended {
            self.setToolView(show: true)
            self.revokeBtn.isEnabled = self.drawPaths.count > 0
        }
    }
    
    func setToolView(show: Bool) {
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
        let size = self.drawingImageView.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
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
    
    func buildImage() -> UIImage {
        let imageSize = self.editImage.size
        let scrollViewSize = self.scrollView.frame
        let ratio = min(scrollViewSize.width / imageSize.width, scrollViewSize.height / imageSize.height)
        // 先把drawing image view 大小缩放到编辑图片对应的比例
        let drawingImageSize = CGSize(width: self.drawingImageView.frame.width / ratio, height: self.drawingImageView.frame.height / ratio)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.editImage.size.width, height: self.editImage.size.height), false, self.editImage.scale)
        self.editImage.draw(at: .zero)
        let x = (editImage.size.width - drawingImageSize.width) / 2
        let y = (editImage.size.height - drawingImageSize.height) / 2
        
        self.drawingImageView.image?.draw(in: CGRect(origin: CGPoint(x: x, y: y), size: drawingImageSize))
        
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return self.editImage
        }
        let image = UIImage(cgImage: cgi, scale: self.editImage.scale, orientation: .up)
        return image
    }

}


extension ZLEditImageViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.drawBtn.isSelected && !self.isScrolling
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
class ZLDrawPath {
    
    let pathColor: UIColor
    
    let path: UIBezierPath
    
    let shapeLayer: CAShapeLayer
    
    init(pathColor: UIColor, pathWidth: CGFloat, startPoint: CGPoint) {
        self.pathColor = pathColor
        self.path = UIBezierPath()
        self.path.lineWidth = pathWidth
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.path.move(to: startPoint)
        
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.lineCap = .round
        self.shapeLayer.lineJoin = .round
        self.shapeLayer.lineWidth = pathWidth
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = pathColor.cgColor
        self.shapeLayer.path = self.path.cgPath
    }
    
    func addLine(to point: CGPoint) {
        self.path.addLine(to: point)
        self.shapeLayer.path = self.path.cgPath
    }
    
    func drawPath() {
        self.pathColor.set()
        self.path.stroke()
    }
    
}
