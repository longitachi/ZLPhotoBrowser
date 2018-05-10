//
//  ZLFilterItem.h
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/6.
//  Copyright © 2018年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZLFilterType) {
    ZLFilterTypeOriginal,          // 原图
    ZLFilterTypeSepia,             // 怀旧
    ZLFilterTypeGrayscale,         // 黑白
    ZLFilterTypeBrightness,        // 高亮
    ZLFilterTypeSketch,            // 素描
    ZLFilterTypeSmoothToon,        // 卡通
    ZLFilterTypeGaussianBlur,      // 毛玻璃
    ZLFilterTypeVignette,          // 晕影
    ZLFilterTypeEmboss,            // 浮雕
    ZLFilterTypeGamma,             // 伽马
    ZLFilterTypeBulgeDistortion,   // 鱼眼
    ZLFilterTypeStretchDistortion, // 哈哈镜
    ZLFilterTypePinchDistortion,   // 凹面镜
    ZLFilterTypeColorInvert,       // 反色
};

@interface ZLFilterItem : UIView

- (instancetype)initWithFrame:(CGRect)frame
                        Image:(UIImage *)image
                   filterType:(ZLFilterType)filterType
                       target:(id)target
                       action:(SEL)action NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) ZLFilterType filterType;
@property (nonatomic, strong) UIImage *iconImage;

@end
