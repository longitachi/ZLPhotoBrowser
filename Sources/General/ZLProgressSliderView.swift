//
//  ZLProgressSliderView.swift
//  ZLPhotoBrowser
//
//  Created by 王宇 on 2022/11/10.
//

import Foundation
import UIKit

class ZLSlider: UISlider {
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let max = maximumValue == 0 ? 1.0 : maximumValue
        let side: CGFloat = 8
        let centerX: CGFloat = rect.width * CGFloat(value / max)
        let r = CGRect(x: ceil(centerX) - side / 2, y: rect.midY - side / 2, width: side, height: side)
        return r
    }
}

public class ZLProgressSliderView: UIView {
    /// Public
    public var totalSeconds: Float = 0.0 {
        didSet {
            currentSlider.isUserInteractionEnabled = totalSeconds > 0
            self.totalTimeLabel.text = caculateTime(seconds: Double(totalSeconds))
        }
    }
    
    public var thumbImage: UIImage = .zl.getImage("zl_slider_icon") ?? UIImage() {
        didSet {
            currentSlider.setThumbImage(thumbImage, for: UIControl.State.normal)
        }
    }

    public var minimumTrackTintColor: UIColor = UIColor.green {
        didSet {
            currentSlider.minimumTrackTintColor = minimumTrackTintColor
        }
    }
    
    public var maximumTrackTintColor: UIColor = UIColor.white {
        didSet {
            currentSlider.maximumTrackTintColor = maximumTrackTintColor
        }
    }
    
    public var timeLabelTextColor = UIColor.white {
        didSet {
            totalTimeLabel.textColor = timeLabelTextColor
            currentTimeLabel.textColor = timeLabelTextColor
        }
    }
    
    public var valueChangedCallback: ((Float) -> Void)?
    public var touchDownCallback: (() -> Void)?
    var currentTime: Float = 0.0
    
    lazy var currentSlider: ZLSlider = {
        let currentSlider = ZLSlider.init()
        currentSlider.frame = CGRect.init(x: 60, y: (bounds.height - 20) / 2, width: bounds.size.width - 120, height: 20)
        currentSlider.backgroundColor = UIColor.clear
        currentSlider.maximumValue = 1
        currentSlider.minimumValue = 0
        currentSlider.value = 0
        currentSlider.isContinuous = false
        currentSlider.minimumTrackTintColor = minimumTrackTintColor
        currentSlider.maximumTrackTintColor = maximumTrackTintColor
        currentSlider.setThumbImage(thumbImage, for: UIControl.State.normal)
        currentSlider.isUserInteractionEnabled = false
        return currentSlider
    }()
    
    lazy var totalTimeLabel:UILabel = {
        let totalTimeLabel = UILabel.init()
        totalTimeLabel.frame = CGRect.init(x:self.frame.size.width - 60, y: (bounds.height - 20) / 2, width: 40, height: 20)
        totalTimeLabel.textAlignment = NSTextAlignment.center
        totalTimeLabel.textColor = UIColor.white
        totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        return totalTimeLabel
    }()
    
    lazy var currentTimeLabel:UILabel = {
        let currentTimeLabel = UILabel.init()
        currentTimeLabel.frame = CGRect.init(x: 10, y: (bounds.height - 20) / 2, width: 40, height: 20)
        currentTimeLabel.textAlignment = NSTextAlignment.center
        currentTimeLabel.textColor = UIColor.white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        return currentTimeLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        currentSlider.frame = CGRect.init(x: 60, y: (bounds.height - 20) / 2, width: bounds.size.width - 120, height: 20)
        totalTimeLabel.frame = CGRect(x: frame.size.width - 60, y: (bounds.height - 20) / 2, width: 40, height: 20)
        currentTimeLabel.frame = CGRect(x: 10, y: (bounds.height - 20) / 2, width: 40, height: 20)
    }
    
    func setupUI() {
        totalTimeLabel.text = "00:00"
        currentTimeLabel.text = "00:00"
        addSubview(totalTimeLabel)
        addSubview(currentTimeLabel)
        addSubview(currentSlider)

        currentSlider.addTarget(self, action: #selector(valueChanged(_:)), for: UIControl.Event.valueChanged)
        currentSlider.addTarget(self, action: #selector(touchDown(_:)), for: UIControl.Event.touchDown)
    }
    
    func caculateTime(seconds:Double) -> String {
        let hours = Int(seconds / 3600.0)
        var minute:Int!
        var second:Int!
        var timeString:String!
        if hours > 0 {
            minute = Int(seconds / 3600.0 - Double(hours)) * 60
            second = Int((seconds / 60.0 - Double(minute)) * 60)
            timeString = String.init(format: "%02d:%02d:%02d", hours,minute,second)
        }
        if hours <= 0 {
            minute = Int(seconds / 60.0)
            second = Int((seconds / 60.0 - Double(minute)) * 60)
            timeString = String.init(format: "%02d:%02d", minute,second)
        }
        
        return timeString
    }
    
    public func updateSlider(_ currentTime: Float) {
        guard totalSeconds > 0 else {
            return
        }
        self.currentTime = currentTime
        let percent = currentTime / totalSeconds
        //不滑动的时候更新
        self.currentSlider.setValue(Float(percent), animated: true)
        
        self.currentTimeLabel.text = self.caculateTime(seconds: Double(currentTime))
    }
    
    // 滑动终止
    @objc func valueChanged(_ slider: UISlider) -> Void {
        guard totalSeconds > 0 else { return }
        currentTime = currentSlider.value * totalSeconds
        updateSlider(currentTime)
        
        valueChangedCallback?(currentTime)
    }
    
    // 一开始拖动
    @objc func touchDown(_ slider: UISlider) -> Void {
        guard totalSeconds > 0 else { return }
        touchDownCallback?()
    }

}
