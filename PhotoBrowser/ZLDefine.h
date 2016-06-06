//
//  ZLDefine.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#ifndef ZLDefine_h
#define ZLDefine_h

#import "ZLProgressHUD.h"

#define kRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define weakify(var)   __weak typeof(var) weakSelf = var
#define strongify(var) __strong typeof(var) strongSelf = var

#define kZLPhotoBrowserBundle [NSBundle bundleForClass:[self class]]

// 图片路径
#define kZLPhotoBrowserSrcName(file) [@"ZLPhotoBrowser.bundle" stringByAppendingPathComponent:file]
#define kZLPhotoBrowserFrameworkSrcName(file) [@"Frameworks/ZLPhotoBrowser.framework/ZLPhotoBrowser.bundle" stringByAppendingPathComponent:file]

#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
//如果项目中设置了导航条为不透明，即[UINavigationBar appearance].translucent=NO，那么这里的kViewHeight需要-64
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

////////ZLPhotoActionSheet
#define kBaseViewHeight 300

////////ZLShowBigImgViewController
#define kItemMargin 30

///////ZLBigImageCell 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500

static inline void SetViewWidth (UIView *view, CGFloat width) {
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

static inline CGFloat GetViewWidth (UIView *view) {
    return view.frame.size.width;
}

static inline void SetViewHeight (UIView *view, CGFloat height) {
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
}

static inline CGFloat GetViewHeight (UIView *view) {
    return view.frame.size.height;
}

static inline CABasicAnimation * GetPositionAnimation (id fromValue, id toValue, CFTimeInterval duration, NSString *keyPath) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    //以下两个设置，保证了动画结束后，layer不会回到初始位置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}

#endif /* ZLDefine_h */
