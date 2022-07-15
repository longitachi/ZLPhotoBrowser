//
//  ZLAdjustSlider.swift
//  ZLPhotoBrowser
//
//  Created by long on 2021/12/17.
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

class ZLAdjustSlider: UIView {
    private static let maximumValue: Float = 1
    
    private static let minimumValue: Float = -1
    
    private let sliderWidth: CGFloat = 5
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .zl.font(ofSize: 12)
        label.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 1
        label.textColor = .white
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.rgba(230, 230, 230)
        return view
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.adjustSliderNormalColor
        view.layer.cornerRadius = sliderWidth / 2
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 3
        return view
    }()
    
    private lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.adjustSliderNormalColor
        view.layer.cornerRadius = sliderWidth / 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var tintView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.adjustSliderTintColor
        return view
    }()
    
    private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
    
    private var impactFeedback: UIImpactFeedbackGenerator?
    
    private var valueForPanBegan: Float = 0
    
    var value: Float = 0 {
        didSet {
            valueLabel.text = String(Int(roundf(value * 100)))
            tintView.frame = calculateTintFrame()
        }
    }
    
    var beginAdjust: (() -> Void)?
    
    var valueChanged: ((Float) -> Void)?
    
    var endAdjust: (() -> Void)?
    
    deinit {
        zl_debugPrint("ZLAdjustSlider deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        let editConfig = ZLPhotoConfiguration.default().editImageConfiguration
        if editConfig.impactFeedbackWhenAdjustSliderValueIsZero {
            impactFeedback = UIImpactFeedbackGenerator(style: editConfig.impactFeedbackStyle)
        }
        addGestureRecognizer(pan)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowView.frame = CGRect(x: 40, y: 0, width: sliderWidth, height: bounds.height)
        whiteView.frame = CGRect(x: 40, y: 0, width: sliderWidth, height: bounds.height)
        tintView.frame = calculateTintFrame()
        let separatorH: CGFloat = 1
        separator.frame = CGRect(x: 0, y: (bounds.height - separatorH) / 2, width: sliderWidth, height: separatorH)
        valueLabel.frame = CGRect(x: 0, y: bounds.height / 2 - 10, width: 38, height: 20)
    }
    
    private func setupUI() {
        addSubview(shadowView)
        addSubview(whiteView)
        whiteView.addSubview(tintView)
        whiteView.addSubview(separator)
        addSubview(valueLabel)
    }
    
    private func calculateTintFrame() -> CGRect {
        let totalH = bounds.height / 2
        let tintH = totalH * abs(CGFloat(value)) / CGFloat(ZLAdjustSlider.maximumValue)
        if value > 0 {
            return CGRect(x: 0, y: totalH - tintH, width: sliderWidth, height: tintH)
        } else {
            return CGRect(x: 0, y: totalH, width: sliderWidth, height: tintH)
        }
    }
    
    @objc private func panAction(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self)
        
        if pan.state == .began {
            valueForPanBegan = value
            beginAdjust?()
            impactFeedback?.prepare()
        } else if pan.state == .changed {
            let y = -translation.y / 100
            var temp = valueForPanBegan + Float(y)
            temp = max(ZLAdjustSlider.minimumValue, min(ZLAdjustSlider.maximumValue, temp))
            
            if (-0.0049..<0.005) ~= temp {
                temp = 0
            }
            
            guard value != temp else { return }
            
            value = temp
            if value == 0, ZLPhotoConfiguration.default().editImageConfiguration.impactFeedbackWhenAdjustSliderValueIsZero {
                impactFeedback?.impactOccurred()
            }
            valueChanged?(value)
        } else {
            valueForPanBegan = value
            endAdjust?()
        }
    }
}
