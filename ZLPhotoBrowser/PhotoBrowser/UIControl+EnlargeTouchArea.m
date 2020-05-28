//
//  UIControl+EnlargeTouchArea.m
//  ZLPhotoBrowserFramework
//
//  Created by long on 2020/5/8.
//  Copyright © 2020 long. All rights reserved.
//

#import "UIControl+EnlargeTouchArea.h"
#import <objc/runtime.h>

@implementation UIControl (EnlargeTouchArea)

- (void)setZl_insets:(UIEdgeInsets)insets
{
    objc_setAssociatedObject(self, @selector(zl_insets), [NSValue valueWithUIEdgeInsets:insets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)zl_insets
{
    NSValue *value = objc_getAssociatedObject(self, @selector(zl_insets));
    if (value) {
        return value.UIEdgeInsetsValue;
    }
    return UIEdgeInsetsZero;
}

- (void)zl_enlargeValidTouchAreaWithInset:(CGFloat)inset
{
    [self setZl_insets:UIEdgeInsetsMake(inset, inset, inset, inset)];
}

- (void)zl_enlargeValidTouchAreaWithInsets:(UIEdgeInsets)insets
{
    [self setZl_insets:insets];
}

- (CGRect)enlargeRect {
    UIEdgeInsets insets = self.zl_insets;
    return CGRectMake(CGRectGetMinX(self.bounds)-insets.left, CGRectGetMinY(self.bounds)-insets.top, self.bounds.size.width+insets.left+insets.right, self.bounds.size.height+insets.top+insets.bottom);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.isHidden || self.alpha == 0) {
        return NO;
    }
    CGRect largeRect = [self enlargeRect];
    if (CGRectEqualToRect(largeRect, self.bounds)) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(largeRect, point);
}


@end
