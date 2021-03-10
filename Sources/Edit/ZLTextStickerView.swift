//
//  ZLTextStickerView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/10/30.
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

protocol ZLTextStickerViewDelegate: ZLStickerViewDelegate {
    
    func sticker(_ textSticker: ZLTextStickerView, editText text: String)
    
}

class ZLTextStickerView: UIView, ZLStickerViewAdditional {

    static let edgeInset: CGFloat = 20
    
    static let fontSize: CGFloat = 30
    
    static let borderWidth = 1 / UIScreen.main.scale
    
    weak var delegate: ZLTextStickerViewDelegate?
    
    var firstLayout = true
    
    var gesIsEnabled = true
    
    let originScale: CGFloat
    
    let originAngle: CGFloat
    
    var originFrame: CGRect
    
    var originTransform: CGAffineTransform = .identity
    
    var text: String {
        didSet {
            self.label.text = text
        }
    }
    
    var textColor: UIColor {
        didSet {
            label.textColor = textColor
        }
    }
    
    // TODO: add text background color
    var bgColor: UIColor {
        didSet {
            label.backgroundColor = bgColor
        }
    }
    
    var borderView: UIView!
    
    var label: UILabel!
    
    var pinchGes: UIPinchGestureRecognizer!
    
    var tapGes: UITapGestureRecognizer!
    
    var panGes: UIPanGestureRecognizer!
    
    var timer: Timer?
    
    var totalTranslationPoint: CGPoint = .zero
    
    var gesTranslationPoint: CGPoint = .zero
    
    var gesRotation: CGFloat = 0
    
    var gesScale: CGFloat = 1
    
    var onOperation = false
    
    // Conver all states to model.
    var state: ZLTextStickerState {
        return ZLTextStickerState(text: self.text, textColor: self.textColor, bgColor: self.bgColor, originScale: self.originScale, originAngle: self.originAngle, originFrame: self.originFrame, gesScale: self.gesScale, gesRotation: self.gesRotation, totalTranslationPoint: self.totalTranslationPoint)
    }
    
    deinit {
        zl_debugPrint("ZLTextStickerView deinit")
        self.cleanTimer()
    }
    
    convenience init(from state: ZLTextStickerState) {
        self.init(text: state.text, textColor: state.textColor, bgColor: state.bgColor, originScale: state.originScale, originAngle: state.originAngle, originFrame: state.originFrame, gesScale: state.gesScale, gesRotation: state.gesRotation, totalTranslationPoint: state.totalTranslationPoint, showBorder: false)
    }
    
    init(text: String, textColor: UIColor, bgColor: UIColor, originScale: CGFloat, originAngle: CGFloat, originFrame: CGRect, gesScale: CGFloat = 1, gesRotation: CGFloat = 0, totalTranslationPoint: CGPoint = .zero, showBorder: Bool = true) {
        self.originScale = originScale
        self.text = text
        self.textColor = textColor
        self.bgColor = bgColor
        self.originAngle = originAngle
        self.originFrame = originFrame
        
        super.init(frame: .zero)
        
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        
        self.borderView = UIView()
        self.borderView.layer.borderWidth = ZLTextStickerView.borderWidth
        self.hideBorder()
        if showBorder {
            self.startTimer()
        }
        self.addSubview(self.borderView)
        
        self.label = UILabel()
        self.label.text = text
        self.label.font = UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        self.label.textColor = textColor
        self.label.backgroundColor = bgColor
        self.label.numberOfLines = 0
        self.label.lineBreakMode = .byCharWrapping
        self.borderView.addSubview(self.label)
        
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
        self.borderView.frame = self.bounds.insetBy(dx: ZLTextStickerView.edgeInset, dy: ZLTextStickerView.edgeInset)
        self.label.frame = self.borderView.bounds.insetBy(dx: ZLTextStickerView.edgeInset, dy: ZLTextStickerView.edgeInset)
    }
    
    @objc func tapAction(_ ges: UITapGestureRecognizer) {
        guard self.gesIsEnabled else { return }
        
        if let t = self.timer, t.isValid {
            self.delegate?.sticker(self, editText: self.text)
        } else {
            self.superview?.bringSubviewToFront(self)
            self.delegate?.stickerDidTap(self)
            self.startTimer()
        }
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
            self.borderView.layer.borderColor = UIColor.white.cgColor
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
        self.borderView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func startTimer() {
        self.cleanTimer()
        self.borderView.layer.borderColor = UIColor.white.cgColor
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: ZLWeakProxy(target: self), selector: #selector(hideBorder), userInfo: nil, repeats: false)
        RunLoop.current.add(self.timer!, forMode: .common)
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
    
    func changeSize(to newSize: CGSize) {
        // Revert zoom scale.
        self.transform = self.transform.scaledBy(x: 1/self.originScale, y: 1/self.originScale)
        // Revert ges scale.
        self.transform = self.transform.scaledBy(x: 1/self.gesScale, y: 1/self.gesScale)
        // Revert ges rotation.
        self.transform = self.transform.rotated(by: -self.gesRotation)
        self.transform = self.transform.rotated(by: -self.originAngle.toPi)
        
        // Recalculate current frame.
        let center = CGPoint(x: self.frame.midX, y: self.frame.midY)
        var frame = self.frame
        frame.origin.x = center.x - newSize.width / 2
        frame.origin.y = center.y - newSize.height / 2
        frame.size = newSize
        self.frame = frame
        
        let oc = CGPoint(x: self.originFrame.midX, y: self.originFrame.midY)
        var of = self.originFrame
        of.origin.x = oc.x - newSize.width / 2
        of.origin.y = oc.y - newSize.height / 2
        of.size = newSize
        self.originFrame = of
        
        self.borderView.frame = self.bounds.insetBy(dx: ZLTextStickerView.edgeInset, dy: ZLTextStickerView.edgeInset)
        self.label.frame = self.borderView.bounds.insetBy(dx: ZLTextStickerView.edgeInset, dy: ZLTextStickerView.edgeInset)
        
        // Readd zoom scale.
        self.transform = self.transform.scaledBy(x: self.originScale, y: self.originScale)
        // Readd ges scale.
        self.transform = self.transform.scaledBy(x: self.gesScale, y: self.gesScale)
        // Readd ges rotation.
        self.transform = self.transform.rotated(by: self.gesRotation)
        self.transform = self.transform.rotated(by: self.originAngle.toPi)
    }
    
    class func calculateSize(text: String, width: CGFloat) -> CGSize {
        let diff = ZLTextStickerView.edgeInset * 2
        let size = text.boundingRect(font: UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize), limitSize: CGSize(width: width - diff, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: size.width + diff * 2, height: size.height + diff * 2)
    }
    
}


extension ZLTextStickerView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


public class ZLTextStickerState: NSObject {
    
    let text: String
    let textColor: UIColor
    let bgColor: UIColor
    let originScale: CGFloat
    let originAngle: CGFloat
    let originFrame: CGRect
    let gesScale: CGFloat
    let gesRotation: CGFloat
    let totalTranslationPoint: CGPoint
    
    init(text: String, textColor: UIColor, bgColor: UIColor, originScale: CGFloat, originAngle: CGFloat, originFrame: CGRect, gesScale: CGFloat, gesRotation: CGFloat, totalTranslationPoint: CGPoint) {
        self.text = text
        self.textColor = textColor
        self.bgColor = bgColor
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        super.init()
    }
    
}
