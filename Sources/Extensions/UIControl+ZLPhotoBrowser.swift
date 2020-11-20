//
//  UIControl+ZLPhotoBrowser.swift
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

private var edgeKey = "edgeKey"

extension UIControl {
    
    private var zl_insets: UIEdgeInsets? {
        get {
            if let temp = objc_getAssociatedObject(self, &edgeKey) as? UIEdgeInsets  {
                return temp
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &edgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard !self.isHidden && self.alpha != 0 else {
            return false
        }
        
        let rect = self.enlargeRect()
        
        if rect.equalTo(self.bounds) {
            return super.point(inside: point, with: event)
        }
        return rect.contains(point) ? true : false
    }
    
    private func enlargeRect() -> CGRect {
        guard let edge = self.zl_insets else {
            return self.bounds
        }
        
        let rect = CGRect(x: self.bounds.minX - edge.left, y: self.bounds.minY - edge.top, width: self.bounds.width + edge.left + edge.right, height: self.bounds.height + edge.top + edge.bottom)
        
        return rect
    }
    
    func zl_enlargeValidTouchArea(insets: UIEdgeInsets) {
        self.zl_insets = insets
    }
    
    func zl_enlargeValidTouchArea(inset: CGFloat) {
        guard inset != 0 else {
            return
        }
        self.zl_insets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
}
