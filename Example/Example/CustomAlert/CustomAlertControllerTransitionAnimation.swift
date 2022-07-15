//
//  CustomAlertControllerTransitionAnimation.swift
//  Example
//
//  Created by long on 2022/7/1.
//

import UIKit
import ZLPhotoBrowser

private let animateDuration: TimeInterval = 0.25

class CustomAlertControllerTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    private let preferredStyle: ZLCustomAlertStyle
    
    init(preferredStyle: ZLCustomAlertStyle) {
        self.preferredStyle = preferredStyle
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animateDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        let isPresent = toVC.presentingViewController == fromVC
        
        switch preferredStyle {
        case .alert:
            showAlertAnimation(transitionContext: transitionContext, fromVC: fromVC, toVC: toVC, isPresent: isPresent)
        case .actionSheet:
            showActionSheetAnimation(transitionContext: transitionContext, fromVC: fromVC, toVC: toVC, isPresent: isPresent)
        }
    }
    
    private func showAlertAnimation(
        transitionContext: UIViewControllerContextTransitioning,
        fromVC: UIViewController,
        toVC: UIViewController,
        isPresent: Bool
    ) {
        let containerView = transitionContext.containerView
        
        if isPresent {
            toVC.view.alpha = 0
            containerView.addSubview(toVC.view)
            
            UIView.animate(withDuration: animateDuration) {
                toVC.view.alpha = 1
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            UIView.animate(withDuration: animateDuration) {
                fromVC.view.alpha = 0
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private func showActionSheetAnimation(
        transitionContext: UIViewControllerContextTransitioning,
        fromVC: UIViewController,
        toVC: UIViewController,
        isPresent: Bool
    ) {
        let bgColor = UIColor.black.withAlphaComponent(0.5)
        let containerView = transitionContext.containerView
        let shadowView = UIView(frame: containerView.bounds)
        shadowView.backgroundColor = bgColor
        containerView.addSubview(shadowView)
        
        if isPresent {
            shadowView.alpha = 0
            toVC.view.backgroundColor = .clear
            let animateDistance = (toVC as? CustomAlertController)?.alertFrame.height ?? 0
            toVC.view.frame.origin.y = containerView.frame.height - animateDistance
            containerView.addSubview(toVC.view)
            
            UIView.animate(withDuration: animateDuration) {
                shadowView.alpha = 1
                toVC.view.frame.origin.y = 0
            } completion: { _ in
                toVC.view.backgroundColor = bgColor
                shadowView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            containerView.sendSubviewToBack(shadowView)
            fromVC.view.backgroundColor = .clear
            let animateDistance = (fromVC as? CustomAlertController)?.alertFrame.height ?? containerView.frame.height
            
            UIView.animate(withDuration: animateDuration) {
                shadowView.alpha = 0
                fromVC.view.frame.origin.y = animateDistance
            } completion: { _ in
                shadowView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
