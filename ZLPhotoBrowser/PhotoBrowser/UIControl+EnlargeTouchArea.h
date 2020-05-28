//
//  UIControl+EnlargeTouchArea.h
//  ZLPhotoBrowserFramework
//
//  Created by long on 2020/5/8.
//  Copyright © 2020 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (EnlargeTouchArea)

- (void)zl_enlargeValidTouchAreaWithInsets:(UIEdgeInsets)insets;

- (void)zl_enlargeValidTouchAreaWithInset:(CGFloat)inset;

@end

NS_ASSUME_NONNULL_END
