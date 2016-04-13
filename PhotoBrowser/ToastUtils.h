//
//  ToastUtils.h
//  vsfa
//
//  Created by long on 15/7/29.
//  Copyright © 2015年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ShowToastAtTop(format, ...) \
[ToastUtils showAtTop:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToast(format, ...) \
[ToastUtils show:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToastLongAtTop(format, ...) \
[ToastUtils showLongAtTop:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToastLong(format, ...) \
[ToastUtils showLong:[NSString stringWithFormat:format, ## __VA_ARGS__]]

@interface ToastUtils : NSObject

//显示提示视图, 默认显示在屏幕上方，防止被软键盘覆盖，1.5s后自动消失
+ (void)showAtTop:(NSString *)message;

//显示提示视图, 默认显示在屏幕下方，1.5s后自动消失
+ (void)show:(NSString *)message;

//显示提示视图, 默认显示在屏幕上方，防止被软键盘覆盖,3s后自动消失
+ (void)showLongAtTop:(NSString *)message;

//显示提示视图, 默认显示在屏幕下方,3s后自动消失
+ (void)showLong:(NSString *)message;

@end
