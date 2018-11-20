//
//  ZLInteractiveTrasition.h
//  ZLPhotoBrowser
//
//  Created by long on 2018/8/12.
//  Copyright © 2018年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLInteractiveTrasition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign, readonly) BOOL isStartTransition;

- (void)updatePercent:(CGFloat)percent;
- (void)cancelAnimate;
- (void)finishAnimate;

@end
