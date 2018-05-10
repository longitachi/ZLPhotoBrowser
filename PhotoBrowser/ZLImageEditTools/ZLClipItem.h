//
//  ZLClipItem.h
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/6.
//  Copyright © 2018年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLClippingCircle : UIView

@property (nonatomic, strong) UIColor *bgColor;

@end


@interface ZLGridLayar : CALayer
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;

@end


@interface ZLClipRatio : NSObject
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, readonly) CGFloat ratio;
@property (nonatomic, strong) NSString *titleFormat;

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2;

@end


@interface ZLClipItem : UIView
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@property (nonatomic, strong) ZLClipRatio *ratio;

- (instancetype)initWithFrame:(CGRect)frame
                        image:(UIImage *)image
                       target:(id)target
                       action:(SEL)action NS_DESIGNATED_INITIALIZER;

- (void)refreshViews;

- (void)changeOrientation;

@end
