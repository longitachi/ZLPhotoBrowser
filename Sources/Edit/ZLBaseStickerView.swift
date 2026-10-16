//
//  ZLBaseStickerView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2022/11/28.
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
    /// Called when scale or rotate or move.
    func stickerBeginOperation(_ sticker: ZLBaseStickerView)
    
    /// Called during scale or rotate or move.
    /// - Parameter point: current touch location in the editor view's coordinate space.
    func stickerOnOperation(_ sticker: ZLBaseStickerView, locationInView point: CGPoint)
    
    /// Called after scale or rotate or move.
    /// - Parameter point: last touch location in the editor view's coordinate space, or nil if unavailable.
    func stickerEndOperation(_ sticker: ZLBaseStickerView, locationInView point: CGPoint?)
    
    /// Called when tap sticker.
    func stickerDidTap(_ sticker: ZLBaseStickerView)
    
    func sticker(_ textSticker: ZLTextStickerView, editText text: String)
}

protocol ZLStickerViewAdditional: NSObject {
    var gesIsEnabled: Bool { get set }
    
    func resetState()
    
    func moveToAshbin()
    
    func addScale(_ scale: CGFloat)
}

class ZLBaseStickerView: UIView {
    private enum Direction: Int {
        case up = 0
        case right = 90
        case bottom = 180
        case left = 270
    }
    
    private let borderColor: CGColor = UIColor.zl.rgba(240, 240, 240, 0.7).cgColor
    
    var id: String
    
    var firstLayout = true
    
    /// Vector border. Replaces `layer.borderWidth/borderColor` so that when
    /// the sticker is zoomed via `transform.scaledBy`, we can both:
    ///   * re-rasterize the stroke at the current pixel density (no aliasing);
    ///   * keep the stroke visually ~1px thick at any zoom (inverse-scale line width).
    let borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.clear.cgColor
        return layer
    }()
    
    let originScale: CGFloat
    
    let originAngle: CGFloat
    
    var maxGesScale: CGFloat
    
    var originTransform: CGAffineTransform = .identity
    
    var timer: Timer?
    
    var totalTranslationPoint: CGPoint = .zero
    
    var gesTranslationPoint: CGPoint = .zero
    
    var gesRotation: CGFloat = 0
    
    var gesScale: CGFloat = 1
    
    var onOperation = false
    
    var gesIsEnabled = true
    
    var originFrame: CGRect
    
    var lastContentsScale: CGFloat = 0
    
    var state: ZLBaseStickertState {
        fatalError()
    }
    
    var borderView: UIView {
        return self
    }
    
    weak var delegate: ZLStickerViewDelegate?
    
    /// Last reported touch location (in editor view coords) during this gesture sequence.
    private var lastOperationLocation: CGPoint?
    
    deinit {
        cleanTimer()
    }
    
    class func initWithState(_ state: ZLBaseStickertState) -> ZLBaseStickerView? {
        if let state = state as? ZLTextStickerState {
            return ZLTextStickerView(state: state)
        } else if let state = state as? ZLImageStickerState {
            return ZLImageStickerView(state: state)
        } else {
            return nil
        }
    }
    
    init(
        id: String = UUID().uuidString,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat = 1,
        gesRotation: CGFloat = 0,
        totalTranslationPoint: CGPoint = .zero,
        showBorder: Bool = true
    ) {
        self.id = id
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        maxGesScale = 4 / originScale
        super.init(frame: .zero)
        
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        
        borderView.layer.addSublayer(borderLayer)
        hideBorder()
        if showBorder {
            startTimer()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateBorderLayer()
        
        guard firstLayout else {
            return
        }
        
        // Rotate must be first when first layout.
        transform = transform.rotated(by: originAngle.zl.toPi)
        
        if totalTranslationPoint != .zero {
            let direction = direction(for: originAngle)
            if direction == .right {
                transform = transform.translatedBy(x: totalTranslationPoint.y, y: -totalTranslationPoint.x)
            } else if direction == .bottom {
                transform = transform.translatedBy(x: -totalTranslationPoint.x, y: -totalTranslationPoint.y)
            } else if direction == .left {
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
        setupUIFrameWhenFirstLayout()
    }
    
    func setupUIFrameWhenFirstLayout() {}
    
    /// Effective scale of the sticker relative to the screen. Used both to
    /// decide the pixel density for re-rasterization and to inverse-scale
    /// the vector border so its visual thickness stays constant.
    var effectiveScale: CGFloat {
        return max(abs(originScale * gesScale), .leastNonzeroMagnitude)
    }
    
    /// Re-lays out the vector border and rasterizes it at the current
    /// effective scale. Call this after any transform / bounds change.
    /// Subclasses override to additionally refresh their own content
    /// (e.g. text vector re-rasterization); must call `super`.
    @discardableResult
    @objc func updateBorderLayer(force: Bool = false) -> Bool {
        guard force || shouldUpdateContentsScale() else {
            return false
        }
        
        let bounds = borderView.bounds
        let effective = effectiveScale
        let lineWidth = min(2.0, max(0.5, 1 / effective))
        let pxScale = max(UIScreen.main.scale, UIScreen.main.scale * effective)
        
        // Disable implicit animations so rapid pinch doesn't smear the border.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLayer.frame = bounds
        borderLayer.lineWidth = lineWidth
        let inset = lineWidth / 2
        borderLayer.path = UIBezierPath(rect: bounds.insetBy(dx: inset, dy: inset)).cgPath
        if abs(borderLayer.contentsScale - pxScale) > .ulpOfOne {
            borderLayer.contentsScale = pxScale
            borderLayer.setNeedsDisplay()
        }
        CATransaction.commit()
        
        return true
    }
    
    func shouldUpdateContentsScale() -> Bool {
        let scale = UIScreen.main.scale * effectiveScale
        // 限制一下，降低更新频率
        if abs(scale - lastContentsScale) >= 0.5 {
            lastContentsScale = scale
            return true
        } else {
            return false
        }
    }
    
    private func direction(for angle: CGFloat) -> ZLBaseStickerView.Direction {
        // 将角度转换为0~360，并对360取余
        let angle = ((Int(angle) % 360) + 360) % 360
        return ZLBaseStickerView.Direction(rawValue: angle) ?? .up
    }
    
    /// Called by `ZLStickerGestureCoordinator` when the user taps on this
    /// sticker (single tap dispatched from the container-level recognizer).
    @objc func handleTap() {
        guard gesIsEnabled else { return }
        
        delegate?.stickerDidTap(self)
        startTimer()
    }
    
    // MARK: - Incremental gesture API (driven by ZLStickerGestureCoordinator)
    
    /// Called when a gesture sequence targeting this sticker begins.
    func beginGesture() {
        lastOperationLocation = nil
        setOperation(true)
    }
    
    /// Apply incremental scale delta from a pinch gesture (delta = pinch.scale, then reset by caller).
    func applyIncrementalScale(_ delta: CGFloat, locationInView point: CGPoint? = nil) {
        guard gesIsEnabled else { return }
        let newScale = min(maxGesScale, gesScale * delta)
        if newScale != gesScale {
            gesScale = newScale
            updateTransform()
        }
        if let point {
            lastOperationLocation = point
            delegate?.stickerOnOperation(self, locationInView: point)
        }
    }
    
    /// Apply incremental rotation delta in radians.
    func applyIncrementalRotation(_ delta: CGFloat, locationInView point: CGPoint? = nil) {
        guard gesIsEnabled else { return }
        gesRotation += delta
        updateTransform()
        if let point {
            lastOperationLocation = point
            delegate?.stickerOnOperation(self, locationInView: point)
        }
    }
    
    /// Apply absolute translation accumulated since pan began. `translation`
    /// is in the sticker's superview coordinate space (i.e. stickersContainer).
    func applyIncrementalTranslation(_ translation: CGPoint, locationInView point: CGPoint? = nil) {
        guard gesIsEnabled else { return }
        gesTranslationPoint = CGPoint(x: translation.x / originScale, y: translation.y / originScale)
        updateTransform()
        if let point {
            lastOperationLocation = point
            delegate?.stickerOnOperation(self, locationInView: point)
        }
    }
    
    /// Finalize a gesture sequence: bake current `gesTranslationPoint` into `originTransform`,
    /// reset transient state and notify the delegate.
    func endGesture(commitPanLocationInView point: CGPoint?) {
        // Bake the pan translation into originTransform so subsequent gestures stack correctly.
        bakeGesTranslation()
        
        setOperation(false)
        let reportPoint = point ?? lastOperationLocation
        delegate?.stickerEndOperation(self, locationInView: reportPoint)
        lastOperationLocation = nil
    }
    
    /// Bake `gesTranslationPoint` into `originTransform` (and accumulate it
    /// into `totalTranslationPoint`), leaving the visible position
    /// unchanged but resetting the incremental translation back to zero.
    /// Used during a still-active gesture sequence whenever we need a clean
    /// translation baseline (anchor snapshot / anchor exit / finger swap).
    func bakeGesTranslation() {
        guard gesTranslationPoint != .zero else { return }
        let direction = direction(for: originAngle)
        if direction == .right {
            originTransform = originTransform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
        } else if direction == .bottom {
            originTransform = originTransform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
        } else if direction == .left {
            originTransform = originTransform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
        } else {
            originTransform = originTransform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
        }
        // Convert back to superview-coords for totalTranslationPoint accounting.
        totalTranslationPoint.x += gesTranslationPoint.x * originScale
        totalTranslationPoint.y += gesTranslationPoint.y * originScale
        gesTranslationPoint = .zero
    }
    
    func setOperation(_ isOn: Bool) {
        if isOn, !onOperation {
            onOperation = true
            cleanTimer()
            borderLayer.strokeColor = borderColor
            delegate?.stickerBeginOperation(self)
        } else if !isOn, onOperation {
            onOperation = false
            startTimer()
        }
    }
    
    func updateTransform() {
        var transform = originTransform
        
        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: gesTranslationPoint.y, y: -gesTranslationPoint.x)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -gesTranslationPoint.x, y: -gesTranslationPoint.y)
        } else if direction == .left {
            transform = transform.translatedBy(x: -gesTranslationPoint.y, y: gesTranslationPoint.x)
        } else {
            transform = transform.translatedBy(x: gesTranslationPoint.x, y: gesTranslationPoint.y)
        }
        // Scale must after translate.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Rotate must after scale.
        transform = transform.rotated(by: gesRotation)
        self.transform = transform
        
        updateBorderLayer()
    }
    
    @objc private func hideBorder() {
        borderLayer.strokeColor = UIColor.clear.cgColor
    }
    
    func startTimer() {
        cleanTimer()
        borderLayer.strokeColor = borderColor
        timer = Timer.scheduledTimer(timeInterval: 2, target: ZLWeakProxy(target: self), selector: #selector(hideBorder), userInfo: nil, repeats: false)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension ZLBaseStickerView: @preconcurrency ZLStickerViewAdditional {
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
        
        let direction = direction(for: originAngle)
        if direction == .right {
            transform = transform.translatedBy(x: diffY, y: -diffX)
            originTransform = originTransform.translatedBy(x: diffY / originScale, y: -diffX / originScale)
        } else if direction == .bottom {
            transform = transform.translatedBy(x: -diffX, y: -diffY)
            originTransform = originTransform.translatedBy(x: -diffX / originScale, y: -diffY / originScale)
        } else if direction == .left {
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
        maxGesScale *= scale
        
        updateBorderLayer()
    }
}
