//
//  ZLProgressHUD.h
//  ZLPhotoBrowser
//
//  Created by long on 16/2/15.
//  Copyright © 2016年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLProgressHUD : UIView

@property (nonatomic, copy, nullable) void (^timeoutBlock)(void);

- (void)show;

- (void)showWithTimeout:(NSTimeInterval)timeout;

- (void)hide;

@end
