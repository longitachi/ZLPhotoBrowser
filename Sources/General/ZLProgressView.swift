//
//  ZLProgressView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/13.
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
