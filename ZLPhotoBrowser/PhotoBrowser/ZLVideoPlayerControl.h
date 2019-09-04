//
//  ZLVideoPlayerControl.h
//  ZLPhotoBrowserFramework
//
//  Created by long on 2019/9/2.
//  Copyright © 2019 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLVideoPlayerControl : UIView

@property (nonatomic, assign, getter=isPlaying) BOOL playing;

@property (nonatomic, copy) void (^playActionBlock)(BOOL isPlaying);
@property (nonatomic, copy) void (^sliderValueChangedBlock)(CGFloat value, BOOL endChange);

- (void)updateProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
