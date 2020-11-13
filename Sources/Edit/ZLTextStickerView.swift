//
//  ZLTextStickerView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/10/30.
//

import UIKit

class ZLTextStickerView: UIView {

    static let edgeInset: CGFloat = 20
    
    static let fontSize: CGFloat = 30
    
    static let borderWidth = 1 / UIScreen.main.scale
    
    var firstLayout = true
    
    let zoomScale: CGFloat
    
    let originAngle: CGFloat
    
    var originFrame: CGRect
    
    var text: String
    
    var textColor: UIColor {
        didSet {
            label.textColor = textColor
        }
    }
    
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
    
    var isSelected = false
    
    var timer: Timer?
    
    var totalTranslationPoint: CGPoint = .zero
    
    var gesTranslationPoint: CGPoint = .zero
    
    var gesRotation: CGFloat = 0
    
    var gesScale: CGFloat = 1
    
    var originTransform: CGAffineTransform = .identity
    
    var editText: ( (String) -> Void )?
    
    // Call when scale or rotate or move.
    var beginOperation: ( () -> Void )?
    
    // Call when end scale or rotate or move.
    var endOperation: ( () -> Void )?
    
    var onOperation = false
    
    // Conver all states to model.
    var state: ZLTextStickerState {
        return ZLTextStickerState(text: self.text, textColor: self.textColor, bgColor: self.bgColor, zoomScale: self.zoomScale, originAngle: self.originAngle, originFrame: self.originFrame, gesScale: self.gesScale, gesRotation: self.gesRotation, totalTranslationPoint: self.totalTranslationPoint)
    }
    
    deinit {
        self.cleanTimer()
    }
    
    convenience init(from state: ZLTextStickerState) {
        self.init(text: state.text, textColor: state.textColor, bgColor: state.bgColor, zoomScale: state.zoomScale, originAngle: state.originAngle, originFrame: state.originFrame, gesScale: state.gesScale, gesRotation: state.gesRotation, totalTranslationPoint: state.totalTranslationPoint, showBorder: false)
    }
    
    init(text: String, textColor: UIColor, bgColor: UIColor, zoomScale: CGFloat, originAngle: CGFloat, originFrame: CGRect, gesScale: CGFloat = 1, gesRotation: CGFloat = 0, totalTranslationPoint: CGPoint = .zero, showBorder: Bool = true) {
        self.zoomScale = zoomScale
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
        if showBorder {
            self.borderView.layer.borderWidth = ZLTextStickerView.borderWidth
            self.borderView.layer.borderColor = UIColor.white.cgColor
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
        
        self.pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        self.pinchGes.delegate = self
        self.addGestureRecognizer(self.pinchGes)
        
        let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))
        rotationGes.delegate = self
        self.addGestureRecognizer(rotationGes)
        
        self.tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.addGestureRecognizer(self.tapGes)
        
        self.panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        self.panGes.delegate = self
        self.addGestureRecognizer(self.panGes)
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
        
        self.transform = self.transform.scaledBy(x: self.zoomScale, y: self.zoomScale)
        
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
    
    @objc func pinchAction(_ ges: UIPinchGestureRecognizer) {
        self.gesScale *= ges.scale
        ges.scale = 1
        self.updateTransform()
        if ges.state == .began {
            self.setOperation(true)
        } else if (ges.state == .ended || ges.state == .cancelled){
            self.setOperation(false)
        }
    }
    
    @objc func rotationAction(_ ges: UIRotationGestureRecognizer) {
        self.gesRotation += ges.rotation
        ges.rotation = 0
        self.updateTransform()
        if ges.state == .began {
            self.setOperation(true)
        } else if (ges.state == .ended || ges.state == .cancelled){
            self.setOperation(false)
        }
    }
    
    @objc func tapAction(_ ges: UITapGestureRecognizer) {
        if !self.isSelected {
            self.borderView.layer.borderWidth = ZLTextStickerView.borderWidth
            self.borderView.layer.borderColor = UIColor.white.cgColor
            self.superview?.bringSubviewToFront(self)
            self.startTimer()
        } else {
            self.editText?(self.text)
        }
        self.isSelected = !self.isSelected
    }
    
    @objc func panAction(_ ges: UIPanGestureRecognizer) {
        let point = ges.translation(in: self.superview)
        self.gesTranslationPoint = CGPoint(x: point.x / self.zoomScale, y: point.y / self.zoomScale)
        self.updateTransform()
        
        if ges.state == .began {
            self.setOperation(true)
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
            self.cleanTimer()
            self.borderView.layer.borderColor = UIColor.white.cgColor
            self.superview?.bringSubviewToFront(self)
            self.onOperation = true
            self.beginOperation?()
        } else if !isOn, self.onOperation {
            self.startTimer()
            self.onOperation = false
            self.endOperation?()
        }
    }
    
    func updateTransform() {
        self.borderView.layer.borderWidth = ZLTextStickerView.borderWidth
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
    }
    
    @objc func hideBorder() {
        self.isSelected = false
        self.borderView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func startTimer() {
        self.cleanTimer()
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
            self.hideBorder()
            self.cleanTimer()
        })
        RunLoop.current.add(self.timer!, forMode: .default)
    }
    
    func cleanTimer() {
        self.timer?.invalidate()
        self.timer = nil
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
    let zoomScale: CGFloat
    let originAngle: CGFloat
    let originFrame: CGRect
    let gesScale: CGFloat
    let gesRotation: CGFloat
    let totalTranslationPoint: CGPoint
    
    init(text: String, textColor: UIColor, bgColor: UIColor, zoomScale: CGFloat, originAngle: CGFloat, originFrame: CGRect, gesScale: CGFloat, gesRotation: CGFloat, totalTranslationPoint: CGPoint) {
        self.text = text
        self.textColor = textColor
        self.bgColor = bgColor
        self.zoomScale = zoomScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        super.init()
    }
    
}
