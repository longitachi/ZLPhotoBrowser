//
//  ZLProgressHUD.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/17.
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

public class ZLProgressHUD: UIView {
    @objc public enum HUDStyle: Int {
        case light
        case lightBlur
        case dark
        case darkBlur
        
        var bgColor: UIColor {
            switch self {
            case .light:
                return .white
            case .dark:
                return .darkGray
            case .lightBlur:
                return UIColor.white.withAlphaComponent(0.8)
            case .darkBlur:
                return UIColor.darkGray.withAlphaComponent(0.8)
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .light, .lightBlur:
                return .black
            case .dark, .darkBlur:
                return .white
            }
        }
        
        var blurEffectStyle: UIBlurEffect.Style? {
            switch self {
            case .light, .dark:
                return nil
            case .lightBlur:
                return .extraLight
            case .darkBlur:
                return .dark
            }
        }
    }
    
    private let style: ZLProgressHUD.HUDStyle
    
    private lazy var loadingView = ZLLoadingView(frame: CGRect(x: 135 / 2 - 22, y: 25, width: 44, height: 44), style: style)
    
    private var timer: Timer?
    
    var timeoutBlock: (() -> Void)?
    
    deinit {
        zl_debugPrint("ZLProgressHUD deinit")
        self.cleanTimer()
    }
    
    @objc public init(style: ZLProgressHUD.HUDStyle) {
        self.style = style
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 135, height: 135))
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.backgroundColor = style.bgColor
        view.clipsToBounds = true
        view.center = center
        
        if let effectStyle = style.blurEffectStyle {
            let effect = UIBlurEffect(style: effectStyle)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = view.bounds
            view.addSubview(effectView)
        }
        
        view.addSubview(loadingView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 85, width: view.bounds.width, height: 30))
        label.textAlignment = .center
        label.textColor = style.textColor
        label.font = getFont(16)
        label.text = localLanguageTextValue(.hudLoading)
        view.addSubview(label)
        
        addSubview(view)
    }
    
    @objc public func show(timeout: TimeInterval = 100) {
        ZLMainAsync {
            self.loadingView.startLoading()
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        if timeout > 0 {
            cleanTimer()
            timer = Timer.scheduledTimer(timeInterval: timeout, target: ZLWeakProxy(target: self), selector: #selector(timeout(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer!, forMode: .default)
        }
    }
    
    @objc public func hide() {
        cleanTimer()
        ZLMainAsync {
            self.loadingView.stopLading()
            self.removeFromSuperview()
        }
    }
    
    @objc func timeout(_ timer: Timer) {
        timeoutBlock?()
        hide()
    }
    
    func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
}

class ZLLoadingView: UIView {
    private let style: ZLProgressHUD.HUDStyle
    
    private lazy var mainLayer = CAShapeLayer()

    deinit {
        zl_debugPrint("ZLLoadingView deinit")
    }
    
    init(frame: CGRect, style: ZLProgressHUD.HUDStyle) {
        self.style = style
        super.init(frame: frame)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        mainLayer.frame = bounds
        layer.addSublayer(mainLayer)
        
        let topColors: [CGColor]
        let bottomColors: [CGColor]
        
        switch style {
        case .light, .lightBlur:
            topColors = [
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.black.withAlphaComponent(0.8).cgColor,
            ]
            bottomColors = [
                UIColor.black.withAlphaComponent(0.55).cgColor,
                UIColor.black.withAlphaComponent(0.05).cgColor,
            ]
        case .dark, .darkBlur:
            topColors = [
                UIColor.white.withAlphaComponent(0.5).cgColor,
                UIColor.white.withAlphaComponent(0.8).cgColor,
            ]
            bottomColors = [
                UIColor.white.withAlphaComponent(0.55).cgColor,
                UIColor.white.withAlphaComponent(0.05).cgColor,
            ]
        }
        
        let topLayer = CAGradientLayer()
        topLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height / 2)
        topLayer.colors = topColors
        topLayer.startPoint = CGPoint(x: 0, y: 0.5)
        topLayer.endPoint = CGPoint(x: 1, y: 0.5)
        mainLayer.addSublayer(topLayer)
        
        let bottomLayer = CAGradientLayer()
        bottomLayer.frame = CGRect(x: 0, y: bounds.height / 2, width: bounds.width, height: bounds.height / 2)
        bottomLayer.colors = bottomColors
        bottomLayer.startPoint = CGPoint(x: 0, y: 0.5)
        bottomLayer.endPoint = CGPoint(x: 1, y: 0.5)
        mainLayer.addSublayer(bottomLayer)
        
        // 创建一个圆形layer
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2),
            radius: bounds.width / 2 - 3.5,
            startAngle: .pi / 15, endAngle: .pi * 2,
            clockwise: true
        ).cgPath
        maskLayer.lineWidth = 3.5
        maskLayer.lineCap = .round
        maskLayer.lineJoin = .round
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeEnd = 0.95
        mainLayer.mask = maskLayer
    }
    
    func startLoading() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 0.8
        animation.repeatCount = .infinity
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: nil)
    }
    
    func stopLading() {
        layer.removeAllAnimations()
    }
}
