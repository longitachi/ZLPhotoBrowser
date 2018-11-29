//
//  ZLPullDownInteractiveTransition.m
//  ZLPhotoBrowser
//
//  Created by long on 2018/11/29.
//  Copyright © 2018年 long. All rights reserved.
//

#import "ZLPullDownInteractiveTransition.h"

@interface ZLPullDownInteractiveTransition ()

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, assign) ZLDismissType type;
@property (nonatomic, assign) BOOL shouldStartInteractive;
@property (nonatomic, assign) NSUInteger panCount;
@property (nonatomic, assign) BOOL hadStartDismiss;
@property (nonatomic, strong) UIView *shadowView;

@end

@implementation ZLPullDownInteractiveTransition

- (UIView *)shadowView
{
    if (!_shadowView) {
        _shadowView = [UIView new];
    }
    return _shadowView;
}

- (instancetype)initWithViewController:(UIViewController *)vc type:(ZLDismissType)type
{
    if (self = [super init]) {
        self.viewController = vc;
        self.type = type;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [vc.view addGestureRecognizer:pan];
    }
    return self;
}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint p = [pan translationInView:self.viewController.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.shouldStartInteractive = p.y >= 0;
        self.panCount = 0;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (!self.shouldStartInteractive) return;
        
        self.panCount++;
        
        if (self.panCount == 1 && (p.y < 0 || atan(fabs(p.x)/fabs(p.y)) > M_PI_2/3)) {
            // 不满足下拉手势返回
            self.shouldStartInteractive = NO;
        } else if (_panCount == 1) {
            self.shouldStartInteractive = YES;
            self.interactive = YES;
            
            if (!self.hadStartDismiss) {
                if (self.type == ZLDismissTypeDismiss) {
                    [self.viewController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.viewController.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        if (self.shouldStartInteractive) {
            CGFloat percent = 0;
            percent = p.y / (self.viewController.view.frame.size.height);
            percent = MAX(percent, 0);
            [self updatePercent:percent];
            [self updateInteractiveTransition:percent];
        }
    } else if (pan.state == UIGestureRecognizerStateCancelled ||
               pan.state == UIGestureRecognizerStateEnded) {
        if (!self.shouldStartInteractive || !self.hadStartDismiss) return;
        
        CGPoint vel = [pan velocityInView:self.viewController.view];
        
        CGFloat percent = 0;
        percent = p.y / (self.viewController.view.frame.size.height);
        percent = MAX(percent, 0);
        
        BOOL dismiss = vel.y > 300 || (percent > 0.4 && vel.y > -300);
        
        if (dismiss) {
            [self finishInteractiveTransition];
            [self finishAnimate];
        } else {
            [self cancelInteractiveTransition];
            [self cancelAnimate];
        }
        self.shouldStartInteractive = NO;
        self.interactive = NO;
    }
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    self.hadStartDismiss = YES;
    [self beginAnimate];
}

- (void)beginAnimate
{
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [self.transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = self.transitionContext.containerView;
    
    if (fromView && toView) {
        self.shadowView.backgroundColor = [UIColor blackColor];
        self.shadowView.frame = toView.bounds;
        
        [containerView addSubview:toView];
        [containerView addSubview:self.shadowView];
        [containerView addSubview:fromView];
    }
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
    self.hadStartDismiss = NO;
    
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
    self.hadStartDismiss = NO;
    
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGRect frame = fromView.frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        fromView.frame = frame;
        self.shadowView.alpha = 1;
    } completion:^(BOOL finished) {
        [self.shadowView removeFromSuperview];
        [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
    }];
}

@end
