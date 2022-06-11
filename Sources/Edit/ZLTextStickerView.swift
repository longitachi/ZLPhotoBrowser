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
    static let fontSize: CGFloat = 30
    
    static let borderWidth = 1 / UIScreen.main.scale
    
    private static let edgeInset: CGFloat = 20
    
    private var firstLayout = true
    
    private let originScale: CGFloat
    
    private let originAngle: CGFloat
    
    private var originTransform: CGAffineTransform = .identity
    
    private lazy var borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = ZLTextStickerView.borderWidth
        return view
    }()
    
    private var timer: Timer?
    
    private var totalTranslationPoint: CGPoint = .zero
    
    private var gesTranslationPoint: CGPoint = .zero
    
    private var gesRotation: CGFloat = 0
    
    private var gesScale: CGFloat = 1
    
    private var onOperation = false
    
    private lazy var tapGes: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    
    lazy var pinchGes: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        pinch.delegate = self
        return pinch
    }()
    
    lazy var panGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    weak var delegate: ZLTextStickerViewDelegate?
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        label.textColor = textColor
        label.backgroundColor = bgColor
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    var gesIsEnabled = true
    
    var originFrame: CGRect
    
    var text: String {
        didSet {
            label.text = text
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
    // Conver all states to model.
    var state: ZLTextStickerState {
        return ZLTextStickerState(
            text: text,
            textColor:
                textColor,
            bgColor: bgColor,
            originScale: originScale,
            originAngle: originAngle,
            originFrame: originFrame,
            gesScale: gesScale,
            gesRotation: gesRotation,
            totalTranslationPoint: totalTranslationPoint
        )
    }
    
    deinit {
        zl_debugPrint("ZLTextStickerView deinit")
        cleanTimer()
    }
    
    convenience init(from state: ZLTextStickerState) {
        self.init(
            text: state.text,
            textColor: state.textColor,
            bgColor: state.bgColor,
            originScale: state.originScale,
            originAngle: state.originAngle,
            originFrame: state.originFrame,
            gesScale: state.gesScale,
            gesRotation: state.gesRotation,
            totalTranslationPoint: state.totalTranslationPoint,
            showBorder: false
        )
    }
    
    init(
        text: String,
        textColor: UIColor,
        bgColor: UIColor,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat = 1,
        gesRotation: CGFloat = 0,
        totalTranslationPoint: CGPoint = .zero,
        showBorder: Bool = true
    ) {
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
        
        hideBorder()
        if showBorder {
            startTimer()
        }
        addSubview(borderView)
        borderView.addSubview(label)
        addGestureRecognizer(tapGes)
        addGestureRecognizer(pinchGes)
        
        let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))
        rotationGes.delegate = self
        addGestureRecognizer(rotationGes)
        
        addGestureRecognizer(panGes)
        tapGes.require(toFail: panGes)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard firstLayout else {
            return
        }
        
        // Rotate must be first when first layout.
        transform = transform.rotated(by: originAngle.zl.toPi)
        
        if totalTranslationPoint != .zero {
            if originAngle == 90 {
                transform = transform.translatedBy(x: totalTranslationPoint.y, y: -totalTranslationPoint.x)
            } else if originAngle == 180 {
                transform = transform.translatedBy(x: -totalTranslationPoint.x, y: -totalTranslationPoint.y)
            } else if originAngle == 270 {
                transform = transform.translatedBy(x: -totalTranslationPoint.y, y: totalTranslationPoint.x)
            } else {
                transform = transform.translatedBy(x: totalTranslationPoint.x, y: totalTranslationPoint.y)
            }
        }
        
        transform = transform.scaledBy(x: originScale, y: originScale)
        
        originTransform = transform
        
        if gesScale != 1 {
            transform = transform.scaledBy(x: gesScale, y: gesScale)
        }
        if gesRotation != 0 {
            transform = transform.rotated(by: gesRotation)
        }
        
        firstLayout = false
        borderView.frame = bounds.insetBy(dx: ZLTextStickerView.edgeInset, dy: ZLTextStickerView.edgeInset)
        label.frame = borderView.bounds.insetBy(dx: ZLTextStickerView.edgeInset, dy: ZLTextStickerView.edgeInset)
    }
    
    @objc private func tapAction(_ ges: UITapGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        if let timer = timer, timer.isValid {
            delegate?.sticker(self, editText: text)
        } else {
            superview?.bringSubviewToFront(self)
            delegate?.stickerDidTap(self)
            startTimer()
        }
    }
    
    @objc private func pinchAction(_ ges: UIPinchGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        gesScale *= ges.scale
        ges.scale = 1
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            setOperation(false)
        }
    }
    
    @objc private func rotationAction(_ ges: UIRotationGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        gesRotation += ges.rotation
        ges.rotation = 0
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            setOperation(false)
        }
    }
    
    @objc private func panAction(_ ges: UIPanGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        let point = ges.translation(in: superview)
        gesTranslationPoint = CGPoint(x: point.x / originScale, y: point.y / originScale)
        
        if ges.state == .began {
            setOperation(true)
        } else if ges.state == .changed {
            updateTransform()
        } else if ges.state == .ended || ges.state == .cancelled {
            totalTranslationPoint.x += point.x
            totalTranslationPoint.y += point.y
            setOperation(false)
            if originAngle == 90 {
                originTransform = originTransform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
            } else if originAngle == 180 {
                originTransform = originTransform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
            } else if originAngle == 270 {
                originTransform = originTransform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
            } else {
                originTransform = originTransform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
            }
            gesTranslationPoint = .zero
        }
    }
    
    private func setOperation(_ isOn: Bool) {
        if isOn, !onOperation {
            onOperation = true
            cleanTimer()
            borderView.layer.borderColor = UIColor.white.cgColor
            superview?.bringSubviewToFront(self)
            delegate?.stickerBeginOperation(self)
        } else if !isOn, onOperation {
            onOperation = false
            startTimer()
            delegate?.stickerEndOperation(self, panGes: panGes)
        }
    }
    
    private func updateTransform() {
        var transform = originTransform
        
        if originAngle == 90 {
            transform = transform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
        } else if originAngle == 180 {
            transform = transform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
        } else if originAngle == 270 {
            transform = transform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
        } else {
            transform = transform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
        }
        // Scale must after translate.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Rotate must after scale.
        transform = transform.rotated(by: gesRotation)
        self.transform = transform
        
        delegate?.stickerOnOperation(self, panGes: panGes)
    }
    
    @objc private func hideBorder() {
        borderView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func startTimer() {
        cleanTimer()
        borderView.layer.borderColor = UIColor.white.cgColor
        timer = Timer.scheduledTimer(timeInterval: 2, target: ZLWeakProxy(target: self), selector: #selector(hideBorder), userInfo: nil, repeats: false)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetState() {
        onOperation = false
        cleanTimer()
        hideBorder()
    }
    
    func moveToAshbin() {
        cleanTimer()
        removeFromSuperview()
    }
    
    func addScale(_ scale: CGFloat) {
        // Revert zoom scale.
        transform = transform.scaledBy(x: 1 / originScale, y: 1 / originScale)
        // Revert ges scale.
        transform = transform.scaledBy(x: 1 / gesScale, y: 1 / gesScale)
        // Revert ges rotation.
        transform = transform.rotated(by: -gesRotation)
        
        var origin = frame.origin
        origin.x *= scale
        origin.y *= scale
        
        let newSize = CGSize(width: frame.width * scale, height: frame.height * scale)
        let newOrigin = CGPoint(x: frame.minX + (frame.width - newSize.width) / 2, y: frame.minY + (frame.height - newSize.height) / 2)
        let diffX: CGFloat = (origin.x - newOrigin.x)
        let diffY: CGFloat = (origin.y - newOrigin.y)
        
        if originAngle == 90 {
            transform = transform.translatedBy(x: diffY, y: -diffX)
            originTransform = originTransform.translatedBy(x: diffY / originScale, y: -diffX / originScale)
        } else if originAngle == 180 {
            transform = transform.translatedBy(x: -diffX, y: -diffY)
            originTransform = originTransform.translatedBy(x: -diffX / originScale, y: -diffY / originScale)
        } else if originAngle == 270 {
            transform = transform.translatedBy(x: -diffY, y: diffX)
            originTransform = originTransform.translatedBy(x: -diffY / originScale, y: diffX / originScale)
        } else {
            transform = transform.translatedBy(x: diffX, y: diffY)
            originTransform = originTransform.translatedBy(x: diffX / originScale, y: diffY / originScale)
        }
        totalTranslationPoint.x += diffX
        totalTranslationPoint.y += diffY
        
        transform = transform.scaledBy(x: scale, y: scale)
        
        // Readd zoom scale.
        transform = transform.scaledBy(x: originScale, y: originScale)
        // Readd ges scale.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Readd ges rotation.
        transform = transform.rotated(by: gesRotation)
        
        gesScale *= scale
    }
    
    func changeSize(to newSize: CGSize) {
        // Revert zoom scale.
        transform = transform.scaledBy(x: 1 / originScale, y: 1 / originScale)
        // Revert ges scale.
        transform = transform.scaledBy(x: 1 / gesScale, y: 1 / gesScale)
        // Revert ges rotation.
        transform = transform.rotated(by: -gesRotation)
        transform = transform.rotated(by: -originAngle.zl.toPi)
        
        // Recalculate current frame.
        let center = CGPoint(x: self.frame.midX, y: self.frame.midY)
        var frame = self.frame
        frame.origin.x = center.x - newSize.width / 2
        frame.origin.y = center.y - newSize.height / 2
        frame.size = newSize
        self.frame = frame
        
        let oc = CGPoint(x: originFrame.midX, y: originFrame.midY)
        var of = originFrame
        of.origin.x = oc.x - newSize.width / 2
        of.origin.y = oc.y - newSize.height / 2
        of.size = newSize
        originFrame = of
        
        borderView.frame = bounds.insetBy(dx: ZLTextStickerView.edgeInset, dy: ZLTextStickerView.edgeInset)
        label.frame = borderView.bounds.insetBy(dx: ZLTextStickerView.edgeInset, dy: ZLTextStickerView.edgeInset)
        
        // Readd zoom scale.
        transform = transform.scaledBy(x: originScale, y: originScale)
        // Readd ges scale.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Readd ges rotation.
        transform = transform.rotated(by: gesRotation)
        transform = transform.rotated(by: originAngle.zl.toPi)
    }
    
    class func calculateSize(text: String, width: CGFloat) -> CGSize {
        let diff = ZLTextStickerView.edgeInset * 2
        let size = text.zl.boundingRect(
            font: UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize),
            limitSize: CGSize(width: width - diff, height: CGFloat.greatestFiniteMagnitude)
        )
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
    
    init(
        text: String,
        textColor: UIColor,
        bgColor: UIColor,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat,
        gesRotation: CGFloat,
        totalTranslationPoint: CGPoint
    ) {
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
