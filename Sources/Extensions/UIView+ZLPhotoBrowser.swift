//
//  UIView+ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by long on 2022/9/27.
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

extension ZLPhotoBrowserWrapper where Base: UIView {
    var top: CGFloat {
        base.frame.minY
    }
    
    var bottom: CGFloat {
        base.frame.maxY
    }
    
    var left: CGFloat {
        base.frame.minX
    }
    
    var right: CGFloat {
        base.frame.maxX
    }
    
    var width: CGFloat {
        base.frame.width
    }
    
    var height: CGFloat {
        base.frame.height
    }
    
    var size: CGSize {
        base.frame.size
    }
    
    var center: CGPoint {
        base.center
    }
    
    var centerX: CGFloat {
        base.center.x
    }
    
    var centerY: CGFloat {
        base.center.y
    }
    
    var snapshotImage: UIImage {
        return UIGraphicsImageRenderer.zl.renderImage(size: base.zl.size) { format in
            format.opaque = base.isOpaque
        } imageActions: { context in
            base.layer.render(in: context)
        }
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        base.layer.cornerRadius = radius
        base.layer.masksToBounds = true
    }
    
    func addBorder(color: UIColor, width: CGFloat) {
        base.layer.borderColor = color.cgColor
        base.layer.borderWidth = width
    }
    
    func addShadow(color: UIColor, radius: CGFloat, opacity: Float = 1, offset: CGSize = .zero) {
        base.layer.shadowColor = color.cgColor
        base.layer.shadowRadius = radius
        base.layer.shadowOpacity = opacity
        base.layer.shadowOffset = offset
    }
    
    /// 判断 view 是否在 window 树中
    var isInWindowHierarchy: Bool {
        var v: UIView? = base
        while let view = v {
            if view is UIWindow { return true }
            v = view.superview
        }
        return false
    }
    
    var owningViewController: UIViewController? {
        var responder: UIResponder? = base
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
    
    var owningVCRootViewModifiedSafeAreaInsets: UIEdgeInsets {
        var insets = base.safeAreaInsets
        insets.top = max(20, insets.top)
        
        guard let vc = owningViewController else {
            return insets
        }
        
        // 分屏/折叠下，另一半屏的挖孔 inset 会被系统报过来，这里按边缘归属过滤掉
        if #available(iOS 27.1, *) {
            if let screen = base.window?.screen {
                if !CGRectEqualToRect(base.bounds, screen.bounds) {
                    switch base.traitCollection.verticalBarEdge {
                    case .leading:
                        // 分屏在左侧
                        insets.left = 0
                        insets.right = 0
                    case .trailing:
                        // 分屏在右侧
                        insets.left = 0
                        if ZLCommonTools.deviceIsFoldableDevice(), vc.prefersStatusBarHidden {
                            // 折叠屏，且状态栏隐藏，修改右侧insets也为0
                            insets.right = 0
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        return insets
    }
}
