//
//  ZLImageStickerView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/11/20.
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

protocol ZLStickerViewDelegate: NSObject {
    
    // Called when scale or rotate or move.
    func stickerBeginOperation(_ sticker: UIView)
    
    // Called during scale or rotate or move.
    func stickerOnOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer)
    
    // Called after scale or rotate or move.
    func stickerEndOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer)
    
    // Called when tap sticker.
    func stickerDidTap(_ sticker: UIView)
    
}


protocol ZLStickerViewAdditional: NSObject {
    
    var gesIsEnabled: Bool { get set }
    
    func resetState()
    
    func moveToAshbin()
    
    func addScale(_ scale: CGFloat)
    
}


class ZLImageStickerView: UIView, ZLStickerViewAdditional {

    static let edgeInset: CGFloat = 20
    
    static let borderWidth = 1 / UIScreen.main.scale
    
    weak var delegate: ZLStickerViewDelegate?
    
    var firstLayout = true
    
    var gesIsEnabled = true
    
    let originScale: CGFloat
    
    let originAngle: CGFloat
    
    var originFrame: CGRect
    
    var originTransform: CGAffineTransform = .identity
    
    let image: UIImage
    
    var pinchGes: UIPinchGestureRecognizer!
    
    var tapGes: UITapGestureRecognizer!
    
    var panGes: UIPanGestureRecognizer!
    
    var timer: Timer?
    
    var imageView: UIImageView!
    
    var totalTranslationPoint: CGPoint = .zero
    
    var gesTranslationPoint: CGPoint = .zero
    
    var gesRotation: CGFloat = 0
    
    var gesScale: CGFloat = 1
    
    var onOperation = false
    
    // Conver all states to model.
    var state: ZLImageStickerState {
        return ZLImageStickerState(image: self.image, originScale: self.originScale, originAngle: self.originAngle, originFrame: self.originFrame, gesScale: self.gesScale, gesRotation: self.gesRotation, totalTranslationPoint: self.totalTranslationPoint)
    }
    
    deinit {
        zl_debugPrint("ZLImageStickerView deinit")
        self.cleanTimer()
    }
    
    convenience init(from state: ZLImageStickerState) {
        self.init(image: state.image, originScale: state.originScale, originAngle: state.originAngle, originFrame: state.originFrame, gesScale: state.gesScale, gesRotation: state.gesRotation, totalTranslationPoint: state.totalTranslationPoint, showBorder: false)
    }
    
    init(image: UIImage, originScale: CGFloat, originAngle: CGFloat, originFrame: CGRect, gesScale: CGFloat = 1, gesRotation: CGFloat = 0, totalTranslationPoint: CGPoint = .zero, showBorder: Bool = true) {
        self.image = image
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        
        super.init(frame: .zero)
        
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        
        self.layer.borderWidth = ZLTextStickerView.borderWidth
        self.hideBorder()
        if showBorder {
            self.startTimer()
        }
        
        self.imageView = UIImageView(image: image)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
        
        self.tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.addGestureRecognizer(self.tapGes)
        
        self.pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        self.pinchGes.delegate = self
        self.addGestureRecognizer(self.pinchGes)
        
        let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))
        rotationGes.delegate = self
        self.addGestureRecognizer(rotationGes)
        
        self.panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        self.panGes.delegate = self
        self.addGestureRecognizer(self.panGes)
        
        self.tapGes.require(toFail: self.panGes)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard self.firstLayout else {
            return
        }
        
        // Rotate must be first when first layout.
        self.transform = self.transform.rotated(by: self.originAngle.toPi)
        
        if self.totalTranslationPoint != .zero {
            if self.originAngle == 90 {
                self.transform = self.transform.translatedBy(x: self.totalTranslationPoint.y, y: -self.totalTranslationPoint.x)
            } else if self.originAngle == 180 {
                self.transform = self.transform.translatedBy(x: -self.totalTranslationPoint.x, y: -self.totalTranslationPoint.y)
            } else if self.originAngle == 270 {
                self.transform = self.transform.translatedBy(x: -self.totalTranslationPoint.y, y: self.totalTranslationPoint.x)
            } else {
                self.transform = self.transform.translatedBy(x: self.totalTranslationPoint.x, y: self.totalTranslationPoint.y)
            }
        }
        
        self.transform = self.transform.scaledBy(x: self.originScale, y: self.originScale)
        
        self.originTransform = self.transform
        
        if self.gesScale != 1 {
            self.transform = self.transform.scaledBy(x: self.gesScale, y: self.gesScale)
        }
        if self.gesRotation != 0 {
            self.transform = self.transform.rotated(by: self.gesRotation)
        }
        
        self.firstLayout = false
        self.imageView.frame = self.bounds.insetBy(dx: ZLImageStickerView.edgeInset, dy: ZLImageStickerView.edgeInset)
    }
    
    @objc func tapAction(_ ges: UITapGestureRecognizer) {
        guard self.gesIsEnabled else { return }
        
        self.superview?.bringSubviewToFront(self)
        self.delegate?.stickerDidTap(self)
        self.startTimer()
    }
    
    @objc func pinchAction(_ ges: UIPinchGestureRecognizer) {
        guard self.gesIsEnabled else { return }
        
        self.gesScale *= ges.scale
        ges.scale = 1
        
        if ges.state == .began {
            self.setOperation(true)
        } else if ges.state == .changed {
            self.updateTransform()
        } else if (ges.state == .ended || ges.state == .cancelled){
            self.setOperation(false)
        }
    }
    
    @objc func rotationAction(_ ges: UIRotationGestureRecognizer) {
        guard self.gesIsEnabled else { return }
        
        self.gesRotation += ges.rotation
        ges.rotation = 0
        
        if ges.state == .began {
            self.setOperation(true)
        } else if ges.state == .changed {
            self.updateTransform()
        } else if (ges.state == .ended || ges.state == .cancelled){
            self.setOperation(false)
        }
    }
    
    @objc func panAction(_ ges: UIPanGestureRecognizer) {
        guard self.gesIsEnabled else { return }
        
        let point = ges.translation(in: self.superview)
        self.gesTranslationPoint = CGPoint(x: point.x / self.originScale, y: point.y / self.originScale)
        
        if ges.state == .began {
            self.setOperation(true)
        } else if ges.state == .changed {
            self.updateTransform()
        } else if (ges.state == .ended || ges.state == .cancelled) {
            self.totalTranslationPoint.x += point.x
            self.totalTranslationPoint.y += point.y
            self.setOperation(false)
            if self.originAngle == 90 {
                self.originTransform = self.originTransform.translatedBy(x: self.gesTranslationPoint.y, y: -self.gesTranslationPoint.x)
            } else if self.originAngle == 180 {
                self.originTransform = self.originTransform.translatedBy(x: -self.gesTranslationPoint.x, y: -self.gesTranslationPoint.y)
            } else if self.originAngle == 270 {
                self.originTransform = self.originTransform.translatedBy(x: -self.gesTranslationPoint.y, y: self.gesTranslationPoint.x)
            } else {
                self.originTransform = self.originTransform.translatedBy(x: self.gesTranslationPoint.x, y: self.gesTranslationPoint.y)
            }
            self.gesTranslationPoint = .zero
        }
    }
    
    func setOperation(_ isOn: Bool) {
        if isOn, !self.onOperation {
            self.onOperation = true
            self.cleanTimer()
            self.layer.borderColor = UIColor.white.cgColor
            self.superview?.bringSubviewToFront(self)
            self.delegate?.stickerBeginOperation(self)
        } else if !isOn, self.onOperation {
            self.onOperation = false
            self.startTimer()
            self.delegate?.stickerEndOperation(self, panGes: self.panGes)
        }
    }
    
    func updateTransform() {
        var transform = self.originTransform
        
        if self.originAngle == 90 {
            transform = transform.translatedBy(x: self.gesTranslationPoint.y, y: -self.gesTranslationPoint.x)
        } else if self.originAngle == 180 {
            transform = transform.translatedBy(x: -self.gesTranslationPoint.x, y: -self.gesTranslationPoint.y)
        } else if self.originAngle == 270 {
            transform = transform.translatedBy(x: -self.gesTranslationPoint.y, y: self.gesTranslationPoint.x)
        } else {
            transform = transform.translatedBy(x: self.gesTranslationPoint.x, y: self.gesTranslationPoint.y)
        }
        // Scale must after translate.
        transform = transform.scaledBy(x: self.gesScale, y: self.gesScale)
        // Rotate must after scale.
        transform = transform.rotated(by: self.gesRotation)
        self.transform = transform
        
        self.delegate?.stickerOnOperation(self, panGes: self.panGes)
    }
    
    @objc func hideBorder() {
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func startTimer() {
        self.cleanTimer()
        self.layer.borderColor = UIColor.white.cgColor
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: ZLWeakProxy(target: self), selector: #selector(hideBorder), userInfo: nil, repeats: false)
        RunLoop.current.add(self.timer!, forMode: .default)
    }
    
    func cleanTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func resetState() {
        self.onOperation = false
        self.cleanTimer()
        self.hideBorder()
    }
    
    func moveToAshbin() {
        self.cleanTimer()
        self.removeFromSuperview()
    }
    
    func addScale(_ scale: CGFloat) {
        // Revert zoom scale.
        self.transform = self.transform.scaledBy(x: 1/self.originScale, y: 1/self.originScale)
        // Revert ges scale.
        self.transform = self.transform.scaledBy(x: 1/self.gesScale, y: 1/self.gesScale)
        // Revert ges rotation.
        self.transform = self.transform.rotated(by: -self.gesRotation)
        
        var origin = self.frame.origin
        origin.x *= scale
        origin.y *= scale
        
        let newSize = CGSize(width: self.frame.width * scale, height: self.frame.height * scale)
        let newOrigin = CGPoint(x: self.frame.minX + (self.frame.width - newSize.width)/2, y: self.frame.minY + (self.frame.height - newSize.height)/2)
        let diffX: CGFloat = (origin.x - newOrigin.x)
        let diffY: CGFloat = (origin.y - newOrigin.y)
        
        if self.originAngle == 90 {
            self.transform = self.transform.translatedBy(x: diffY, y: -diffX)
            self.originTransform = self.originTransform.translatedBy(x: diffY / self.originScale, y: -diffX / self.originScale)
        } else if self.originAngle == 180 {
            self.transform = self.transform.translatedBy(x: -diffX, y: -diffY)
            self.originTransform = self.originTransform.translatedBy(x: -diffX / self.originScale, y: -diffY / self.originScale)
        } else if self.originAngle == 270 {
            self.transform = self.transform.translatedBy(x: -diffY, y: diffX)
            self.originTransform = self.originTransform.translatedBy(x: -diffY / self.originScale, y: diffX / self.originScale)
        } else {
            self.transform = self.transform.translatedBy(x: diffX, y: diffY)
            self.originTransform = self.originTransform.translatedBy(x: diffX / self.originScale, y: diffY / self.originScale)
        }
        self.totalTranslationPoint.x += diffX
        self.totalTranslationPoint.y += diffY
        
        self.transform = self.transform.scaledBy(x: scale, y: scale)
        
        // Readd zoom scale.
        self.transform = self.transform.scaledBy(x: self.originScale, y: self.originScale)
        // Readd ges scale.
        self.transform = self.transform.scaledBy(x: self.gesScale, y: self.gesScale)
        // Readd ges rotation.
        self.transform = self.transform.rotated(by: self.gesRotation)
        
        self.gesScale *= scale
    }
    
    class func calculateSize(image: UIImage, width: CGFloat) -> CGSize {
        let maxSide = width / 2
        let minSide: CGFloat = 100
        let whRatio = image.size.width / image.size.height
        var size: CGSize = .zero
        if whRatio >= 1 {
            let w = min(maxSide, max(minSide, image.size.width))
            let h = w / whRatio
            size = CGSize(width: w, height: h)
        } else {
            let h = min(maxSide, max(minSide, image.size.width))
            let w = h * whRatio
            size = CGSize(width: w, height: h)
        }
        size.width += ZLImageStickerView.edgeInset * 2
        size.height += ZLImageStickerView.edgeInset * 2
        return size
    }
    
}


extension ZLImageStickerView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


public class ZLImageStickerState: NSObject {
    
    let image: UIImage
    let originScale: CGFloat
    let originAngle: CGFloat
    let originFrame: CGRect
    let gesScale: CGFloat
    let gesRotation: CGFloat
    let totalTranslationPoint: CGPoint
    
    init(image: UIImage, originScale: CGFloat, originAngle: CGFloat, originFrame: CGRect, gesScale: CGFloat, gesRotation: CGFloat, totalTranslationPoint: CGPoint) {
        self.image = image
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        super.init()
    }
    
}
