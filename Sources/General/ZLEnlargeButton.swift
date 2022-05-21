//
//  ZLEnlargeButton.swift
//  ZLPhotoBrowser
//
//  Created by long on 2022/4/24.
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

public class ZLEnlargeButton: UIButton {
    
    /// 扩大点击区域
    public var enlargeInsets: UIEdgeInsets = .zero
    
    /// 上下左右均扩大该值的点击范围
    public var enlargeInset: CGFloat = 0 {
        didSet {
            let inset = max(0, enlargeInset)
            enlargeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard !isHidden, alpha != 0 else {
            return false
        }
        
        let rect = enlargeRect()
        if rect.equalTo(bounds) {
            return super.point(inside: point, with: event)
        }
        return rect.contains(point) ? true : false
    }
    
    private func enlargeRect() -> CGRect {
        guard enlargeInsets != .zero else {
            return bounds
        }
        
        let rect = CGRect(
            x: bounds.minX - enlargeInsets.left,
            y: bounds.minY - enlargeInsets.top,
            width: bounds.width + enlargeInsets.left + enlargeInsets.right,
            height: bounds.height + enlargeInsets.top + enlargeInsets.bottom
        )
        return rect
    }
    
}
