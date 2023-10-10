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
import AVFoundation

class ZLPhotoPreviewPopInteractiveTransition: UIPercentDrivenInteractiveTransition {
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    weak var viewController: ZLPhotoPreviewController?
    
    lazy var dismissPanGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissPanAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    var shadowView: UIView?
    
    var imageView: UIImageView?
    
    var playerLayer: AVPlayerLayer?
    
    var imageViewOriginalFrame: CGRect = .zero
    
    var startPanPoint: CGPoint = .zero
    
    var interactive = false
    
    var currentCell: ZLPreviewBaseCell?
    /// 取消动画时候，是否需要将Y值修正为0
    var needCorrectYToZeroWhenCancel = false
    
    var translationBeforeInteractive: CGPoint = .zero
    
    var shouldStartTransition: ((CGPoint) -> Bool)?
    
    var startTransition: (() -> Void)?
    
    var cancelTransition: (() -> Void)?
    
    var finishTransition: (() -> Void)?
    
    deinit {
        zl_debugPrint("ZLPhotoPreviewPopInteractiveTransition deinit")
    }
    
    init(viewController: ZLPhotoPreviewController) {
        self.viewController = viewController
        super.init()
        
        viewController.view.addGestureRecognizer(dismissPanGes)
    }
    
    @objc func dismissPanAction(_ pan: UIPanGestureRecognizer) {
        guard canStartPan() else { return }
        
        if pan.state == .began {
            beginInterative(pan)
        } else if pan.state == .changed {
            if !interactive {
                beginInterative(pan)
                if interactive {
                    translationBeforeInteractive = pan.translation(in: viewController?.view)
                }
                return
            }
            
            let result = panResult(pan)
            imageView?.transform = CGAffineTransform(scaleX: result.scale, y: result.scale)
            imageView?.center = CGPoint(x: result.frame.midX, y: result.frame.midY)
//            imageView?.frame = result.frame
            
            shadowView?.alpha = pow(result.scale, 2)
            
            update(result.scale)
        } else if pan.state == .cancelled || pan.state == .ended {
            guard interactive else { return }
            
            let vel = pan.velocity(in: viewController?.view)
            let p = pan.translation(in: viewController?.view)
            let transY = p.y - translationBeforeInteractive.y
            let percent = max(0.0, transY / (viewController?.view.bounds.height ?? UIScreen.main.bounds.height))
            
            let dismiss = vel.y > 300 || (percent > 0.1 && vel.y >= 0)
            
            if dismiss {
                finish()
            } else {
                cancel()
            }
            
            imageViewOriginalFrame = .zero
            startPanPoint = .zero
            translationBeforeInteractive = .zero
            interactive = false
        }
    }
    
    /// 判断是否开始手势
    func canStartPan() -> Bool {
        guard !interactive else { return true }
        
        guard let viewController,
              let cell = viewController.collectionView.cellForItem(
                  at: IndexPath(row: viewController.currentIndex, section: 0)
              ) as? ZLPreviewBaseCell,
              let scrollView = cell.scrollView,
              let contentView = scrollView.subviews.first else {
            return true
        }
        
        let convertRect = contentView.convert(contentView.bounds, to: scrollView)
        if scrollView.isZooming ||
            scrollView.isZoomBouncing ||
            scrollView.contentOffset.y > 0 ||
            // cell放大时候，当拖拽到最左和最右时，会拉动vc的collectionView，这时不能进行pop动画
            (convertRect.minX != 0 && contentView.zl.width > scrollView.zl.width) {
            return false
        }
        
        return true
    }
    
    /// 开始手势
    func beginInterative(_ pan: UIPanGestureRecognizer) {
        guard !interactive else { return }
        
        let vel = pan.velocity(in: viewController?.view)
        if abs(vel.x) >= abs(vel.y) || vel.y <= 0 {
            return
        }
        
        startPanPoint = pan.location(in: viewController?.view)
        interactive = true
        startTransition?()
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func panResult(_ pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: viewController?.view)
        let transY = translation.y - translationBeforeInteractive.y
        let currentTouch = pan.location(in: viewController?.view)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - transY / UIScreen.main.bounds.height))
        
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
        
        currentCell = cell
        shadowView = UIView(frame: containerView.bounds)
        shadowView?.backgroundColor = ZLPhotoUIConfiguration.default().previewVCBgColor
        containerView.addSubview(shadowView!)
        
        let fromImageViewFrame = cell.animateImageFrame(convertTo: containerView)
        
        imageView = UIImageView(frame: fromImageViewFrame)
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        
        if let videoCell = cell as? ZLVideoPreviewCell, let playerLayer = videoCell.playerLayer, videoCell.imageView.isHidden {
            playerLayer.removeFromSuperlayer()
            self.playerLayer = playerLayer
            imageView?.layer.insertSublayer(playerLayer, at: 0)
        } else {
            imageView?.image = cell.currentImage
        }
        
        containerView.addSubview(imageView!)
        containerView.addSubview(fromVC.view)
        
        imageViewOriginalFrame = imageView!.frame
        resetViewStatus(isStart: true)
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
        if !ZLPhotoUIConfiguration.default().sortAscending {
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
        
        toVC.endPopTransition()
        
        UIView.animate(withDuration: 0.3, animations: {
            if let toFrame = toFrame, self.playerLayer == nil {
                self.imageView?.transform = .identity
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
        
        var toFrame = imageViewOriginalFrame
        if needCorrectYToZeroWhenCancel {
            toFrame.origin.y = 0
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.imageView?.transform = .identity
            self.imageView?.frame = toFrame
            self.shadowView?.alpha = 1
        }) { _ in
            self.resetViewStatus(isStart: false)
            if let playerLayer = self.playerLayer {
                playerLayer.removeFromSuperlayer()
                (self.currentCell as? ZLVideoPreviewCell)?.playerView.layer.insertSublayer(playerLayer, at: 0)
            }
            self.currentCell = nil
            self.playerLayer = nil
            self.imageView?.removeFromSuperview()
            self.shadowView?.removeFromSuperview()
            self.cancelTransition?()
            transitionContext.cancelInteractiveTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func resetViewStatus(isStart: Bool) {
        currentCell?.scrollView?.isScrollEnabled = !isStart
        currentCell?.scrollView?.pinchGestureRecognizer?.isEnabled = !isStart
        (currentCell as? ZLVideoPreviewCell)?.singleTapGes.isEnabled = !isStart
        
        guard let transitionContext = transitionContext,
              let fromVC = transitionContext.viewController(forKey: .from) as? ZLPhotoPreviewController else {
            return
        }
        
        fromVC.view.backgroundColor = isStart ? .clear : ZLPhotoUIConfiguration.default().previewVCBgColor
        fromVC.collectionView.isHidden = isStart
    }
}

extension ZLPhotoPreviewPopInteractiveTransition: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: viewController?.view)
        let shouldBegin = shouldStartTransition?(point) == true
        if shouldBegin,
           let viewController,
           let cell = viewController.collectionView.cellForItem(
               at: IndexPath(row: viewController.currentIndex, section: 0)
           ) as? ZLPreviewBaseCell,
           let scrollView = cell.scrollView {
            let contentSizeH = scrollView.contentSize.height
            needCorrectYToZeroWhenCancel = contentSizeH > scrollView.zl.height && scrollView.contentOffset.y >= 0
        }
        
        return shouldBegin
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UITapGestureRecognizer,
           otherGestureRecognizer.view is UIScrollView {
            return false
        }
        
        if otherGestureRecognizer == viewController?.collectionView.panGestureRecognizer {
            return false
        }
        
        return !(viewController?.collectionView.isDragging ?? false)
    }
}
