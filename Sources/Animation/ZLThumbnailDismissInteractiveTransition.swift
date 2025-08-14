//
//  ZLThumbnailDismissInteractiveTransition.swift
//  ZLPhotoBrowser
//
//  Created by long on 2025/7/16.
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

class ZLThumbnailDismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    weak var viewController: UIViewController?
    
    lazy var edgePan: UIScreenEdgePanGestureRecognizer = {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanAction(_:)))
        edgePan.edges = isRTL() ? .right : .left
        return edgePan
    }()
    
    var interactive = false
    
    var shadowView: UIView?
    
    var startTransition: (() -> Void)?
    
    var cancelTransition: (() -> Void)?
    
    var finishTransition: (() -> Void)?
    
    private let dismissProgress = 0.5
    
    deinit {
        zl_debugPrint("ZLThumbnailDismissInteractiveTransition deinit")
    }
    
    init(viewController: ZLThumbnailViewController) {
        self.viewController = viewController
        super.init()
        
        viewController.view.addGestureRecognizer(edgePan)
        viewController.panGes.require(toFail: edgePan)
    }
    
    @objc private func edgePanAction(_ ges: UIScreenEdgePanGestureRecognizer) {
        let transformValue: ((CGFloat) -> CGFloat) = { value -> CGFloat in
            isRTL() ? -value : value
        }
        
        let translationX = transformValue(ges.translation(in: viewController?.view).x)
        let viewW = viewController?.view.zl.width ?? UIScreen.main.bounds.width
        let viewH = viewController?.view.zl.height ?? UIScreen.main.bounds.height
        let length = min(viewW, viewH)
        let progress = max(0, min(1, translationX / length))
        
        switch ges.state {
        case .began:
            interactive = true
            viewController?.navigationController?.dismiss(animated: true, completion: nil)
        case .changed:
            updateAnimate(progress: progress)
        case .cancelled, .ended:
            guard interactive else { return }
            
            let velX = transformValue(ges.velocity(in: viewController?.view).x)
            if progress > dismissProgress || velX > 300 {
                finish()
            } else {
                cancel()
            }
            
            interactive = false
        default:
            break
        }
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        startAnimate()
    }
    
    func startAnimate() {
        guard let transitionContext,
              let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        startTransition?()
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        shadowView = UIView(frame: containerView.bounds)
        shadowView?.backgroundColor = ZLPhotoUIConfiguration.default().previewVCBgColor
        containerView.addSubview(shadowView!)
        containerView.addSubview(fromVC.view)
    }
    
    /// 将线性进度转换为一个自定义的动画曲线进度
    private func applyCustomAnimationCurve(to progress: CGFloat) -> CGFloat {
        // 调整这个值 (0.0 - 1.0) 来改变初始/结束速度。
        // 0.0 = 纯 EaseInOut (启动慢)
        // 1.0 = 纯线性 (无缓动)
        // 推荐值: 0.2 - 0.4
        let linearity: CGFloat = 0.4

        // EaseInOut 曲线分量
        let easeInOutProgress = 0.5 * (1 - cos(progress * .pi))
        // 线性分量
        let linearProgress = progress

        // 将 EaseInOut 曲线与线性曲线按 "linearity" 比例进行混合
        // 这能确保 progress 为 0 时，函数结果为 0；progress 为 1 时，函数结果为 1
        return linearity * linearProgress + (1 - linearity) * easeInOutProgress
    }
    
    func updateAnimate(progress: CGFloat) {
        guard let transitionContext,
              let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let progress = applyCustomAnimationCurve(to: progress)
        shadowView?.alpha = (1 - progress) / 2
        let top = fromVC.view.zl.height * 0.8 * progress
        fromVC.view.frame = CGRect(x: 0, y: top, width: fromVC.view.zl.width, height: fromVC.view.zl.height)
        update(progress)
    }
    
    override func cancel() {
        super.cancel()
        cancelAnimate()
    }
    
    func cancelAnimate() {
        guard let transitionContext,
              let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let currY = fromVC.view.zl.top
        let totalDistance = fromVC.view.zl.height * dismissProgress
        let totalDuration = 0.15
        var duration = currY / totalDistance * totalDuration
        duration = max(0, min(0.15, duration))
        
        UIView.animate(withDuration: duration) {
            self.shadowView?.alpha = 0.5
            fromVC.view.frame = CGRect(x: 0, y: 0, width: fromVC.view.zl.width, height: fromVC.view.zl.height)
        } completion: { _ in
            self.shadowView?.removeFromSuperview()
            self.cancelTransition?()
            transitionContext.cancelInteractiveTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    override func finish() {
        super.finish()
        finishAnimate()
    }
    
    func finishAnimate() {
        guard let transitionContext,
              let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let currY = fromVC.view.zl.top
        let totalDistance = fromVC.view.zl.height * (1 - dismissProgress)
        let totalDuration = 0.15
        var duration = (fromVC.view.zl.height - currY) / totalDistance * totalDuration
        duration = max(0, min(0.2, duration))
        
        UIView.animate(withDuration: duration) {
            self.shadowView?.alpha = 0
            fromVC.view.frame = CGRect(x: 0, y: fromVC.view.zl.height, width: fromVC.view.zl.width, height: fromVC.view.zl.height)
        } completion: { _ in
            self.shadowView?.removeFromSuperview()
            self.finishTransition?()
            transitionContext.finishInteractiveTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
