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
        
        func bgColor() -> UIColor {
            switch self {
            case .light:
                return .white
            case .dark:
                return .darkGray
            default:
                return .clear
            }
        }
        
        func textColor() -> UIColor {
            switch self {
            case .light, .lightBlur:
                return .black
            case .dark, .darkBlur:
                return .white
            }
        }
        
        func indicatorStyle() -> UIActivityIndicatorView.Style {
            switch self {
            case .light, .lightBlur:
                return .gray
            case .dark, .darkBlur:
                return .white
            }
        }
        
        func blurEffectStyle() -> UIBlurEffect.Style? {
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
    
    let style: ZLProgressHUD.HUDStyle
    
    var timeoutBlock: ( () -> Void )?
    
    var timer: Timer?
    
    deinit {
        self.cleanTimer()
    }
    
    @objc public init(style: ZLProgressHUD.HUDStyle) {
        self.style = style
        super.init(frame: UIScreen.main.bounds)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 90))
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5.0
        view.backgroundColor = self.style.bgColor()
        view.clipsToBounds = true
        view.alpha = 0.8
        view.center = self.center
        
        if self.style == .lightBlur || self.style == .darkBlur {
            let effect = UIBlurEffect(style: self.style.blurEffectStyle()!)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = view.bounds
            view.addSubview(effectView)
        }
        
        let indicator = UIActivityIndicatorView(style: self.style.indicatorStyle())
        indicator.frame = CGRect(x: (view.bounds.width - indicator.bounds.width)/2, y: 18, width: indicator.bounds.width, height: indicator.bounds.height)
        indicator.startAnimating()
        view.addSubview(indicator)
        
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: view.bounds.width, height: 30))
        label.textAlignment = .center
        label.textColor = self.style.textColor()
        label.font = getFont(16)
        label.text = localLanguageTextValue(.hudLoading)
        view.addSubview(label)
        
        self.addSubview(view)
    }
    
    @objc public func show(timeout: TimeInterval = 100) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        if timeout > 0 {
            self.cleanTimer()
            self.timer = Timer.scheduledTimer(timeInterval: timeout, target: ZLWeakProxy(target: self), selector: #selector(timeout(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    @objc public func hide() {
        self.cleanTimer()
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    @objc func timeout(_ timer: Timer) {
        self.timeoutBlock?()
        self.hide()
    }
    
    func cleanTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
}
