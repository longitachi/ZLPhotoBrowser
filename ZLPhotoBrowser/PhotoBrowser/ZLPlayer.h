//
//  ZLPlayer.h
//  CustomCamera
//
//  Created by long on 2017/11/9.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLPlayer : UIView

@property (nonatomic, strong) NSURL *videoUrl;


/**
 开始播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 重置
 */
- (void)reset;

/**
 是否正在播放
 */
- (BOOL)isPlay;

@end
