//
//  ZLAnimationTool.m
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLAnimationTool.h"

@implementation ZLAnimationTool

+ (CABasicAnimation *)animateWithFromValue:(id)fromValue toValue:(id)toValue duration:(CFTimeInterval)duration keyPath:(NSString *)keyPath
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    //以下两个设置，保证了动画结束后，layer不会回到初始位置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

+ (CAKeyframeAnimation *)animateWithBtnStatusChanged
{
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];

    
    return animate;
}

@end
