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
    
    var shouldStartTransition: ( (CGPoint) -> Bool )?
    
    var startTransition: ( () -> Void )?
    
    var cancelTransition: ( () -> Void )?
    
    var finishTransition: ( () -> Void )?
    
    init(viewController: ZLPhotoPreviewController) {
        super.init()
        self.viewController = viewController
        let dismissPan = UIPanGestureRecognizer(target: self, action: #selector(dismissPanAction(_:)))
        viewController.view.addGestureRecognizer(dismissPan)
    }
    
    @objc func dismissPanAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: self.viewController?.view)
        
        if pan.state == .began {
            guard self.shouldStartTransition?(point) == true else {
                self.interactive = false
                return
            }
            self.startPanPoint = point
            self.interactive = true
            self.startTransition?()
            self.viewController?.navigationController?.popViewController(animated: true)
        } else if pan.state == .changed {
            guard self.interactive else {
                return
            }
            let result = self.panResult(pan)
            self.imageView?.frame = result.frame
            self.shadowView?.alpha = pow(result.scale, 2)
            
            self.update(result.scale)
        } else if pan.state == .cancelled || pan.state == .ended {
            guard self.interactive else {
                return
            }
            
            let vel = pan.velocity(in: self.viewController?.view)
            let p = pan.translation(in: self.viewController?.view)
            let percent: CGFloat = max(0.0, p.y / (self.viewController?.view.bounds.height ?? UIScreen.main.bounds.height))
            
            let dismiss = vel.y > 300 || (percent > 0.2 && vel.y > -300)
            
            if dismiss {
                self.finish()
                self.finishAnimate()
            } else {
                self.cancel()
                self.cancelAnimate()
            }
            self.imageViewOriginalFrame = .zero
            self.startPanPoint = .zero
            self.interactive = false
        }
    }
    
    func panResult(_ pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: self.viewController?.view)
        let currentTouch = pan.location(in: self.viewController?.view)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / UIScreen.main.bounds.height))
        
        let width = self.imageViewOriginalFrame.size.width * scale
        let height = self.imageViewOriginalFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        let xRate = (self.startPanPoint.x - self.imageViewOriginalFrame.origin.x) / self.imageViewOriginalFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (self.startPanPoint.y - self.imageViewOriginalFrame.origin.y) / self.imageViewOriginalFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.startAnimate()
    }
    
    func startAnimate() {
        guard let context = self.transitionContext else {
            return
        }
        guard let fromVC = context.viewController(forKey: .from) as? ZLPhotoPreviewController, let toVC = context.viewController(forKey: .to) as? ZLThumbnailViewController else {
            return
        }
        let containerView = context.containerView
        
        containerView.addSubview(toVC.view)
        
        self.shadowView = UIView(frame: containerView.bounds)
        self.shadowView?.backgroundColor = UIColor.black
        containerView.addSubview(self.shadowView!)
        
        let cell = fromVC.collectionView.cellForItem(at: IndexPath(row: fromVC.currentIndex, section: 0)) as! ZLPreviewBaseCell
        
        let fromImageViewFrame = cell.animateImageFrame(convertTo: containerView)
        
        self.imageView = UIImageView(frame: fromImageViewFrame)
        self.imageView?.contentMode = .scaleAspectFill
        self.imageView?.clipsToBounds = true
        self.imageView?.image = cell.currentImage
        containerView.addSubview(self.imageView!)
        
        self.imageViewOriginalFrame = self.imageView!.frame
    }
    
    func finishAnimate() {
        guard let context = self.transitionContext else {
            return
        }
        guard let fromVC = context.viewController(forKey: .from) as? ZLPhotoPreviewController, let toVC = context.viewController(forKey: .to) as? ZLThumbnailViewController else {
            return
        }
        
        let fromVCModel = fromVC.arrDataSources[fromVC.currentIndex]
        let toVCVisiableIndexPaths = toVC.collectionView.indexPathsForVisibleItems
        
        var diff = 0
        if toVC.showCameraCell, !ZLPhotoConfiguration.default().sortAscending {
            diff = -1
        }
        var toIndex: Int? = nil
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
        
        var toFrame: CGRect? = nil
        
        if let toIdx = toIndex, let toCell = toVC.collectionView.cellForItem(at: IndexPath(row: toIdx, section: 0)) {
            toFrame = toVC.collectionView.convert(toCell.frame, to: context.containerView)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            if let to = toFrame {
                self.imageView?.frame = to
            } else {
                self.imageView?.alpha = 0
            }
            self.shadowView?.alpha = 0
        }) { (_) in
            self.imageView?.removeFromSuperview()
            self.shadowView?.removeFromSuperview()
            self.imageView = nil
            self.shadowView = nil
            self.finishTransition?()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    func cancelAnimate() {
        guard let context = self.transitionContext else {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.imageView?.frame = self.imageViewOriginalFrame
            self.shadowView?.alpha = 1
        }) { (_) in
            self.imageView?.removeFromSuperview()
            self.shadowView?.removeFromSuperview()
            self.cancelTransition?()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
}
