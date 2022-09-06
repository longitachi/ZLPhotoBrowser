//
//  ZLPhotoPreviewPopInteractiveTransition.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/9/3.
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

class ZLPhotoPreviewPopInteractiveTransition: UIPercentDrivenInteractiveTransition {
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    weak var viewController: ZLPhotoPreviewController?
    
    var shadowView: UIView?
    
    var imageView: UIImageView?
    
    var imageViewOriginalFrame: CGRect = .zero
    
    var startPanPoint: CGPoint = .zero
    
    var interactive: Bool = false
    
    var shouldStartTransition: ((CGPoint) -> Bool)?
    
    var startTransition: (() -> Void)?
    
    var cancelTransition: (() -> Void)?
    
    var finishTransition: (() -> Void)?
    
    init(viewController: ZLPhotoPreviewController) {
        super.init()
        self.viewController = viewController
        let dismissPan = UIPanGestureRecognizer(target: self, action: #selector(dismissPanAction(_:)))
        viewController.view.addGestureRecognizer(dismissPan)
    }
    
    @objc func dismissPanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: viewController?.view)
        
        if pan.state == .began {
            guard shouldStartTransition?(point) == true else {
                interactive = false
                return
            }
            startPanPoint = point
            interactive = true
            startTransition?()
            viewController?.navigationController?.popViewController(animated: true)
        } else if pan.state == .changed {
            guard interactive else {
                return
            }
            let result = panResult(pan)
            imageView?.frame = result.frame
            shadowView?.alpha = pow(result.scale, 2)
            
            update(result.scale)
        } else if pan.state == .cancelled || pan.state == .ended {
            guard interactive else {
                return
            }
            
            let vel = pan.velocity(in: viewController?.view)
            let p = pan.translation(in: viewController?.view)
            let percent: CGFloat = max(0.0, p.y / (viewController?.view.bounds.height ?? UIScreen.main.bounds.height))
            
            let dismiss = vel.y > 300 || (percent > 0.1 && vel.y > -300)
            
            if dismiss {
                finish()
            } else {
                cancel()
            }
            imageViewOriginalFrame = .zero
            startPanPoint = .zero
            interactive = false
        }
    }
    
    func panResult(_ pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: viewController?.view)
        let currentTouch = pan.location(in: viewController?.view)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / UIScreen.main.bounds.height))
        
        let width = imageViewOriginalFrame.size.width * scale
        let height = imageViewOriginalFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        let xRate = (startPanPoint.x - imageViewOriginalFrame.origin.x) / imageViewOriginalFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (startPanPoint.y - imageViewOriginalFrame.origin.y) / imageViewOriginalFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        startAnimate()
    }
    
    func startAnimate() {
        guard let transitionContext = transitionContext else {
            return
        }
        
        guard let fromVC = transitionContext.viewController(forKey: .from) as? ZLPhotoPreviewController,
              let toVC = transitionContext.viewController(forKey: .to) as? ZLThumbnailViewController else {
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        guard let cell = fromVC.collectionView.cellForItem(at: IndexPath(row: fromVC.currentIndex, section: 0)) as? ZLPreviewBaseCell else {
            return
        }
        
        shadowView = UIView(frame: containerView.bounds)
        shadowView?.backgroundColor = ZLPhotoUIConfiguration.default().previewVCBgColor
        containerView.addSubview(shadowView!)
        
        let fromImageViewFrame = cell.animateImageFrame(convertTo: containerView)
        
        imageView = UIImageView(frame: fromImageViewFrame)
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        imageView?.image = cell.currentImage
        containerView.addSubview(imageView!)
        
        imageViewOriginalFrame = imageView!.frame
    }
    
    override func finish() {
        super.finish()
        finishAnimate()
    }
    
    func finishAnimate() {
        guard let transitionContext = transitionContext else {
            return
        }
        guard let fromVC = transitionContext.viewController(forKey: .from) as? ZLPhotoPreviewController,
              let toVC = transitionContext.viewController(forKey: .to) as? ZLThumbnailViewController else {
            return
        }
        
        let fromVCModel = fromVC.arrDataSources[fromVC.currentIndex]
        let toVCVisiableIndexPaths = toVC.collectionView.indexPathsForVisibleItems
        
        var diff = 0
        if !ZLPhotoConfiguration.default().sortAscending {
            if toVC.showCameraCell {
                diff = -1
            }
            if #available(iOS 14.0, *), toVC.showAddPhotoCell {
                diff -= 1
            }
        }
        var toIndex: Int?
        for indexPath in toVCVisiableIndexPaths {
            let idx = indexPath.row + diff
            if idx >= toVC.arrDataSources.count || idx < 0 {
                continue
            }
            let m = toVC.arrDataSources[idx]
            if m == fromVCModel {
                toIndex = indexPath.row
                break
            }
        }
        
        var toFrame: CGRect?
        
        if let toIndex = toIndex, let toCell = toVC.collectionView.cellForItem(at: IndexPath(row: toIndex, section: 0)) {
            toFrame = toVC.collectionView.convert(toCell.frame, to: transitionContext.containerView)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            if let toFrame = toFrame {
                self.imageView?.frame = toFrame
            } else {
                self.imageView?.alpha = 0
            }
            self.shadowView?.alpha = 0
        }) { _ in
            self.imageView?.removeFromSuperview()
            self.shadowView?.removeFromSuperview()
            self.imageView = nil
            self.shadowView = nil
            self.finishTransition?()
            transitionContext.finishInteractiveTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    override func cancel() {
        super.cancel()
        cancelAnimate()
    }
    
    func cancelAnimate() {
        guard let transitionContext = transitionContext else {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.imageView?.frame = self.imageViewOriginalFrame
            self.shadowView?.alpha = 1
        }) { _ in
            self.imageView?.removeFromSuperview()
            self.shadowView?.removeFromSuperview()
            self.cancelTransition?()
            transitionContext.cancelInteractiveTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
