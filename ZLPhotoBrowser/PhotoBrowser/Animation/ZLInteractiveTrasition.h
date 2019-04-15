//
//  ZLInteractiveTrasition.h
//  ZLPhotoBrowser
//
//  Created by long on 2018/8/12.
//  Copyright © 2018年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLInteractiveTrasition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign, readonly) BOOL isStartTransition;

@property (nonatomic, copy, nullable) void (^beginTransitionBlock)(void);
@property (nonatomic, copy, nullable) void (^cancelTransitionBlock)(void);
@property (nonatomic, copy, nullable) void (^finishTransitionBlock)(void);

- (void)updatePercent:(CGFloat)percent;
- (void)cancelAnimate;
- (void)finishAnimate;

@end

NS_ASSUME_NONNULL_END
