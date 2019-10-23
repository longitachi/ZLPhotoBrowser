//
//  ZLEnlargeButton.m
//  ZLPhotoBrowser
//
//  Created by Samuel's on 2019/10/23.
//  Copyright © 2019 long. All rights reserved.
//

#import "ZLEnlargeButton.h"
#import <objc/runtime.h>

@implementation ZLEnlargeButton

static char enlargeInsetsKey;
static char minClickAreaKey;

- (CGSize)minClickArea {
    NSValue *value = objc_getAssociatedObject(self, &minClickAreaKey);
    if (value != nil) {
        return value.CGSizeValue;
    } else {
        return self.bounds.size;
    }
}

- (void)setMinClickArea:(CGSize)clickArea {
    NSValue *value = [NSValue valueWithCGSize:clickArea];
    objc_setAssociatedObject(self, &minClickAreaKey, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setEnlargeClickInset:(UIEdgeInsets)enlargeClickInset {
    
    NSAssert(enlargeClickInset.top >= 0 && enlargeClickInset.bottom >= 0 && enlargeClickInset.left >= 0 && enlargeClickInset.right >= 0, @"扩大区域必须是正数或0");
    
    NSValue *value = [NSValue valueWithUIEdgeInsets:enlargeClickInset];
    objc_setAssociatedObject(self, &enlargeInsetsKey, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIEdgeInsets)enlargeClickInset {
    NSValue *value = objc_getAssociatedObject(self, &enlargeInsetsKey);
    if (value != nil) {
        return value.UIEdgeInsetsValue;
    } else {
        return UIEdgeInsetsZero;
    }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{

    if (CGSizeEqualToSize([self minClickArea], self.bounds.size) == false){
        CGFloat largerWidth = MAX(self.bounds.size.width, [self minClickArea].width);
        CGFloat largerHeight = MAX(self.bounds.size.height, [self minClickArea].height);
        CGFloat dx = (self.bounds.size.width - largerWidth) / 2.0;
        CGFloat dy = (self.bounds.size.height - largerHeight) / 2.0;
        CGRect newRect = CGRectInset(self.bounds, dx, dy);
        if (CGRectContainsPoint(newRect, point)) {
            return self;
        }
    }
    NSAssert(self.enlargeClickInset.top >= 0 && self.enlargeClickInset.bottom >= 0 && self.enlargeClickInset.left >= 0 && self.enlargeClickInset.right >= 0, @"扩大区域必须是正数或0");
    if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.enlargeClickInset) == false) {
    UIEdgeInsets insets = UIEdgeInsetsMake(-self.enlargeClickInset.top, -self.enlargeClickInset.left, -self.enlargeClickInset.bottom, -self.enlargeClickInset.right);
        CGRect largerRect = UIEdgeInsetsInsetRect(self.bounds,insets);
    if (CGRectContainsPoint(largerRect, point)) {
        return self;
    }
    }
    return [super hitTest:point withEvent:event];
}

@end
