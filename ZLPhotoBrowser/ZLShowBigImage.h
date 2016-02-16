//
//  ZLShowBigImage.h
//  点击图片放大
//
//  Created by qianfeng on 15-1-9.
//  Copyright (c) 2015年 张龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZLShowBigImage : NSObject

/**
 *	@brief	浏览头像
 *
 *	@param 	oldImageView 	头像所在的imageView
 */
+ (void)showBigImage:(UIImageView *)selectedImageView;

@end
