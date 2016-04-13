//
//  ZLAnimationTool.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZLAnimationTool : NSObject

+ (CABasicAnimation *)animateWithFromValue:(id)fromValue toValue:(id)toValue duration:(CFTimeInterval)duration keyPath:(NSString *)keyPath;

/**
 * @brief 照片选择状态按钮改变动画
 */
+ (CAKeyframeAnimation *)animateWithBtnStatusChanged;

@end
