//
//  ZLProgressView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/13.
//

import UIKit

class ZLProgressView: UIView {

    private var progressLayer: CAShapeLayer!
    
    var progress: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.progressLayer = CAShapeLayer()
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.strokeColor = UIColor.white.cgColor
        self.progressLayer.lineCap = .round
        self.progressLayer.lineWidth = 4
        
        self.layer.addSublayer(self.progressLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = rect.width / 2
        let end = -(.pi / 2) + (.pi * 2 * self.progress)
        self.progressLayer.frame = self.bounds
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(.pi / 2), endAngle: end, clockwise: true)
        self.progressLayer.path = path.cgPath
    }
    
}
