//
//  ZLInteractiveTrasition.m
//  ZLPhotoBrowser
//
//  Created by long on 2018/8/12.
//  Copyright © 2018年 long. All rights reserved.
//

#import "ZLInteractiveTrasition.h"
#import "ZLShowBigImgViewController.h"
#import "ZLInteractiveAnimateProtocol.h"

@interface ZLInteractiveTrasition ()

@property (nonatomic, assign, readwrite) BOOL isStartTransition;

@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation ZLInteractiveTrasition

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.isStartTransition = YES;
    
    self.transitionContext = transitionContext;
    [self beginAnimate];
}

- (void)beginAnimate
{
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [self.transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ZLShowBigImgViewController *imageVC = (ZLShowBigImgViewController *)fromVC;
    imageVC->_navView.hidden = YES;
    
    NSInteger index = imageVC->_currentPage-1;
    
    UIViewController *toVC = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if ([toVC conformsToProtocol:@protocol(ZLInteractiveAnimateProtocol)]) {
        if ([(id<ZLInteractiveAnimateProtocol>)toVC respondsToSelector:@selector(scrollToIndex:)]) {
            [(id<ZLInteractiveAnimateProtocol>)toVC scrollToIndex:index];
        }
    }
    
    UIView *containerView = self.transitionContext.containerView;
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor blackColor];
    self.shadowView.frame = toView.bounds;
    
    [containerView addSubview:toView];
    [containerView addSubview:self.shadowView];
    [containerView addSubview:fromView];
}

- (void)updatePercent:(CGFloat)percent
{
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGRect frame = CGRectMake(0, CGRectGetHeight(fromView.bounds)*percent, CGRectGetWidth(fromView.bounds), CGRectGetHeight(fromView.bounds));
    
    fromView.frame = frame;
    
    self.shadowView.alpha = MIN(1, MAX(0, 1-percent));
}

- (void)finishAnimate
{
    self.isStartTransition = NO;
    
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGRect frame = fromView.frame;
    frame.origin.y = frame.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        fromView.frame = frame;
        self.shadowView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.shadowView removeFromSuperview];
        [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
    }];
}

- (void)cancelAnimate
{
    self.isStartTransition = NO;
    
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ZLShowBigImgViewController *imageVC = (ZLShowBigImgViewController *)fromVC;
    
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGRect frame = fromView.frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        fromView.frame = frame;
        self.shadowView.alpha = 1;
    } completion:^(BOOL finished) {
        imageVC->_navView.hidden = NO;
        [self.shadowView removeFromSuperview];
        [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
    }];
}

@end
