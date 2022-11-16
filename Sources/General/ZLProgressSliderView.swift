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
    lazy var currentSlider: ZLSlider = {
        let currentSlider = ZLSlider.init()
        currentSlider.frame = CGRect.init(x: 60, y: (bounds.height - 20) / 2, width: bounds.size.width - 120, height: 20)
        currentSlider.backgroundColor = UIColor.clear
        currentSlider.maximumValue = 1
        currentSlider.minimumValue = 0
        currentSlider.value = 0
        currentSlider.isContinuous = true
        currentSlider.minimumTrackTintColor = UIColor.green
        currentSlider.maximumTrackTintColor = UIColor.white
        currentSlider.setThumbImage(.zl.getImage("zl_slider_icon"), for: UIControl.State.normal)
        
        return currentSlider
    }()
    
    lazy var totleTimeLabel:UILabel = {
        let totleTimeLabel = UILabel.init()
        totleTimeLabel.frame = CGRect.init(x:self.frame.size.width - 60, y: (bounds.height - 20) / 2, width: 40, height: 20)
        totleTimeLabel.textAlignment = NSTextAlignment.center
        totleTimeLabel.textColor = UIColor.white
        totleTimeLabel.font = UIFont.systemFont(ofSize: 12)
        return totleTimeLabel
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
    
    var totalSeconds: Float = 0.0 {
        didSet {
            currentSlider.isUserInteractionEnabled = totalSeconds > 0
            self.totleTimeLabel.text = caculateTime(seconds: Double(totalSeconds))
        }
    }
    var currentTime: Float = 0.0
    var valueChangedCallback: ((Float) -> Void)?
    var touchDownCallback: (() -> Void)?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        totleTimeLabel.text = "00:00"
        currentTimeLabel.text = "00:00"
        addSubview(totleTimeLabel)
        addSubview(currentTimeLabel)
        addSubview(currentSlider)

        currentSlider.isUserInteractionEnabled = false
        currentSlider.isContinuous = false
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
    
    func updateSlider(_ currentTime: Float) {
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
        guard totalSeconds > 0 else {
            return
        }
        currentTime = currentSlider.value * totalSeconds
        updateSlider(currentTime)
        
        valueChangedCallback?(currentTime)
    }
    
    // 一开始拖动
    @objc func touchDown(_ slider: UISlider) -> Void {
        guard totalSeconds > 0 else {
            return
        }
        touchDownCallback?()
    }

}
