//
//  ZLProgressHUD.m
//  ZLPhotoBrowser
//
//  Created by long on 16/2/15.
//  Copyright © 2016年 long. All rights reserved.
//

#import "ZLProgressHUD.h"
#import "ZLDefine.h"

@interface ZLProgressHUD ()
{
    BOOL _isHide;
}

@end

@implementation ZLProgressHUD

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    self.frame = [UIScreen mainScreen].bounds;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 80)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 5.0f;
    view.backgroundColor = [UIColor darkGrayColor];
    view.alpha = 0.8;
    view.center = self.center;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(40, 15, 30, 30)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [indicator startAnimating];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 110, 30)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:16];
    lab.text = GetLocalLanguageTextValue(ZLPhotoBrowserHandleText);
    
    [view addSubview:indicator];
    [view addSubview:lab];
    
    [self addSubview:view];
}

- (void)show
{
    [self showWithTimeout:100];
}

- (void)showWithTimeout:(NSTimeInterval)timeout
{
    _isHide = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    if (timeout < 100) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self->_isHide && self.timeoutBlock) {
                self.timeoutBlock();
            }
            [self hide];
        });
    }
}

- (void)hide
{
    _isHide = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

@end
