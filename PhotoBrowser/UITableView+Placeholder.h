//
//  UITableView+Placeholder.h
//  FEComps
//
//  Created by wangzhanfeng-PC on 15/12/18.
//  Copyright © 2015年 F.E. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FETablePlaceholderConf;
@interface UITableView (Placeholder)
@property (assign, nonatomic) UITableViewCellSeparatorStyle originalSeparatorStyle; //原始分割线样式
@property (assign, nonatomic) BOOL didSetup; //

// setup placeholder view
- (void)placeholderBaseOnNumber:(NSInteger)numberOfRows iconConfig:(void (^) (UIImageView *imageView))iconConfig textConfig:(void (^) (UILabel *label))textConfig;

- (void)clean;

- (void)placeholderBaseOnNumber:(NSInteger)numberOfRows withConf:(FETablePlaceholderConf *)conf;
@end


@interface UITableViewPlaceholderView : UIView
@property (strong, nonatomic) UIImageView *placeholderImageView; //
@property (strong, nonatomic) UILabel     *placeholderLabel; //
@end


@interface FETablePlaceholderConf : NSObject
@property (copy,   nonatomic) NSString  *placeholderText;  //无数据时的文字提示
@property (strong, nonatomic) UIFont    *placeholderFont;  //文字字体，默认15
@property (strong, nonatomic) UIColor   *placeholderColor; //文字颜色，默认lightGrayColor

@property (copy, nonatomic) UIImage  *placeholderImage; //无数据时的图片
@property (copy, nonatomic) NSArray  *animImages;  //加载数据时的动画图片
@property (assign, nonatomic) NSTimeInterval animDuration;  //动画时间间隔，默认2s
@property (assign, nonatomic) BOOL loadingData; //是否在加载数据

+ (instancetype)defaultConf;
@end