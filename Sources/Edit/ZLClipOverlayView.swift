//
//  ZLClipOverlayView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2024/6/28.
//

import UIKit

// MARK: 裁剪网格视图

class ZLClipOverlayView: UIView {
    static let cornerLineWidth: CGFloat = 3
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.layer.mask = shadowMaskLayer
        return view
    }()
    
    private lazy var shadowMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        return layer
    }()
    
    private lazy var cornerLinesView: UIView = {
        let view = UIView()
        view.layer.addSublayer(cornerLinesLayer)
        return view
    }()
    
    private lazy var cornerLinesLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = ZLClipOverlayView.cornerLineWidth
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    private lazy var frameBorderView: UIView = {
        let view = UIView()
        view.layer.addSublayer(frameBorderLayer)
        return view
    }()
    
    private lazy var frameBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1.2
        layer.contentsScale = UIScreen.main.scale
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 1
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
        return layer
    }()
    
    private lazy var gridLinesView: UIView = {
        let view = UIView()
        view.layer.addSublayer(gridLinesLayer)
        view.alpha = 0
        return view
    }()
    
    private lazy var gridLinesLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 0.5
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    var cropRect: CGRect = .zero
    
    var isCircle = false {
        didSet {
            guard oldValue != isCircle else {
                return
            }
            
            shadowMaskLayer.path = getShadowMaskLayerPath().cgPath
            gridLinesLayer.path = getGridLinesLayerPath().cgPath
        }
    }
    
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
        
        updateSubviewsFrame()
    }
    
    private func setupUI() {
        addSubview(shadowView)
        addSubview(frameBorderView)
        addSubview(cornerLinesView)
        addSubview(gridLinesView)
        
        updateSubviewsFrame()
    }
    
    private func updateSubviewsFrame() {
        shadowView.frame = bounds
        shadowMaskLayer.frame = shadowView.bounds
        frameBorderView.frame = bounds
        frameBorderLayer.frame = frameBorderView.bounds
        cornerLinesView.frame = bounds
        cornerLinesLayer.frame = cornerLinesView.bounds
        gridLinesView.frame = bounds
        gridLinesLayer.frame = gridLinesView.bounds
    }
    
    private func getShadowMaskLayerPath() -> UIBezierPath {
        let path = UIBezierPath(rect: shadowView.frame)
        let transparentPath: UIBezierPath
        if isCircle {
            transparentPath = UIBezierPath(roundedRect: cropRect, cornerRadius: cropRect.width / 2)
        } else {
            transparentPath = UIBezierPath(rect: cropRect)
        }
        path.append(transparentPath.reversing())
        return path
    }
    
    private func getCornerLinesLayerPath() -> UIBezierPath {
        let rect = cropRect.insetBy(dx: -Self.cornerLineWidth / 2, dy: -Self.cornerLineWidth / 2)
        let path = UIBezierPath()
        let length: CGFloat = 20
        
        // 左上
        path.move(to: CGPoint(x: rect.minX + length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + length))

        // 右上
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        // 左下
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        
        // 右下
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        
        return path
    }
    
    private func getGridLinesLayerPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        let r = cropRect.width / 2
        let diff = isCircle ? r - sqrt(pow(r, 2) - pow(r / 3, 2)) : 0
        // 画竖线
        let dw = cropRect.width / 3
        for i in 1...2 {
            let x = CGFloat(i) * dw + cropRect.minX
            path.move(to: CGPoint(x: x, y: cropRect.minY + diff))
            path.addLine(to: CGPoint(x: x, y: cropRect.maxY - diff))
        }
        
        // 画横线
        let dh = cropRect.height / 3
        for i in 1...2 {
            let y = CGFloat(i) * dh + cropRect.minY
            path.move(to: CGPoint(x: cropRect.minX + diff, y: y))
            path.addLine(to: CGPoint(x: cropRect.maxX - diff, y: y))
        }
        
        return path
    }
    
    func beginUpdate() {
        let config = ZLPhotoConfiguration.default().editImageConfiguration
        shadowView.alpha = config.dimClippedAreaDuringAdjustments ? 1 : 0
        gridLinesView.alpha = 1
    }
    
    func endUpdate(delay: TimeInterval = 0) {
        UIView.animate(withDuration: 0.15, delay: delay) {
            if !ZLPhotoConfiguration.default().editImageConfiguration.dimClippedAreaDuringAdjustments {
                self.shadowView.alpha = 1
            }
            self.gridLinesView.alpha = 0
        }
    }
    
    func updateLayers(_ rect: CGRect, animate: Bool, endEditing: Bool) {
        cropRect = rect
        
        let shadowMaskPath = getShadowMaskLayerPath()
        let frameBorderPath = UIBezierPath(rect: rect)
        let cornerLinesPath = getCornerLinesLayerPath()
        let gridLinesPath = getGridLinesLayerPath()
        
        let duration: TimeInterval = 0.25
        func animateShadowMaskLayer() {
            guard animate else { return }
            
            shadowMaskLayer.removeAnimation(forKey: "shadowMaskAnimation")
            let animation = ZLAnimationUtils.animation(
                type: .path,
                fromValue: shadowMaskLayer.path,
                toValue: shadowMaskPath.cgPath,
                duration: duration,
                isRemovedOnCompletion: true,
                timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
            shadowMaskLayer.add(animation, forKey: "shadowMaskAnimation")
        }
        
        func animateFrameBorderLayer() {
            guard animate else { return }
            
            frameBorderLayer.removeAnimation(forKey: "frameBorderAnimation")
            let animation = ZLAnimationUtils.animation(
                type: .path,
                fromValue: frameBorderLayer.path,
                toValue: frameBorderPath.cgPath,
                duration: duration,
                isRemovedOnCompletion: true,
                timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
            frameBorderLayer.add(animation, forKey: "frameBorderAnimation")
        }
        
        func animateCornerLinesLayer() {
            guard animate else { return }
            
            cornerLinesLayer.removeAnimation(forKey: "cornerLinesAnimation")
            let animation = ZLAnimationUtils.animation(
                type: .path,
                fromValue: cornerLinesLayer.path,
                toValue: cornerLinesPath.cgPath,
                duration: duration,
                isRemovedOnCompletion: true,
                timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
            cornerLinesLayer.add(animation, forKey: "cornerLinesAnimation")
        }
        
        func animateGridLinesLayer() {
            guard animate else { return }
            
            gridLinesLayer.removeAnimation(forKey: "gridLinesAnimation")
            let animation = ZLAnimationUtils.animation(
                type: .path,
                fromValue: gridLinesLayer.path,
                toValue: gridLinesPath.cgPath,
                duration: duration,
                isRemovedOnCompletion: true,
                timingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
            gridLinesLayer.add(animation, forKey: "gridLinesAnimation")
        }
        
        animateShadowMaskLayer()
        animateFrameBorderLayer()
        animateCornerLinesLayer()
        animateGridLinesLayer()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shadowMaskLayer.path = shadowMaskPath.cgPath
        frameBorderLayer.path = frameBorderPath.cgPath
        cornerLinesLayer.path = cornerLinesPath.cgPath
        gridLinesLayer.path = gridLinesPath.cgPath
        
        CATransaction.commit()
        
        if animate, endEditing {
            endUpdate(delay: duration)
        }
    }
}
