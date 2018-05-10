//
//  ZLFilterTool.h
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/6.
//  Copyright © 2018年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLFilterItem.h"
#import <GPUImage/GPUImage.h>

@interface ZLFilterTool : NSObject

+ (UIImage *)filterImage:(UIImage *)image filterType:(ZLFilterType)filterType;

@end
