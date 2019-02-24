//
//  ZLImageEditTool.h
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/5.
//  Copyright © 2018年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoConfiguration;

typedef NS_OPTIONS(NSUInteger, ZLImageEditType) {
    ZLImageEditTypeClip     = 1 << 1,
    ZLImageEditTypeRotate   = 1 << 2,
    // 下面这两种暂时无效
    ZLImageEditTypeDraw     = 1 << 3,
    ZLImageEditTypeMosaic   = 1 << 4,
};

@interface ZLImageEditTool : UIView

- (instancetype)initWithEditType:(ZLImageEditType)type
                           image:(UIImage *)image
                   configuration:(ZLPhotoConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) UIImage *editImage;

@property (nonatomic, copy) void (^cancelEditBlock)(void);
@property (nonatomic, copy) void (^doneEditBlock)(UIImage *);

@end
