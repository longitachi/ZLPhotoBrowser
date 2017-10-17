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
#import "NSBundle+ZLPhotoBrowser.h"

#define ZLPhotoBrowserCameraText @"ZLPhotoBrowserCameraText"
#define ZLPhotoBrowserAblumText @"ZLPhotoBrowserAblumText"
#define ZLPhotoBrowserCancelText @"ZLPhotoBrowserCancelText"
#define ZLPhotoBrowserOriginalText @"ZLPhotoBrowserOriginalText"
#define ZLPhotoBrowserDoneText @"ZLPhotoBrowserDoneText"
#define ZLPhotoBrowserOKText @"ZLPhotoBrowserOKText"
#define ZLPhotoBrowserBackText @"ZLPhotoBrowserBackText"
#define ZLPhotoBrowserPhotoText @"ZLPhotoBrowserPhotoText"
#define ZLPhotoBrowserPreviewText @"ZLPhotoBrowserPreviewText"
#define ZLPhotoBrowserLoadingText @"ZLPhotoBrowserLoadingText"
#define ZLPhotoBrowserHandleText @"ZLPhotoBrowserHandleText"
#define ZLPhotoBrowserSaveImageErrorText @"ZLPhotoBrowserSaveImageErrorText"
#define ZLPhotoBrowserMaxSelectCountText @"ZLPhotoBrowserMaxSelectCountText"
#define ZLPhotoBrowserNoCameraAuthorityText @"ZLPhotoBrowserNoCameraAuthorityText"
#define ZLPhotoBrowserNoAblumAuthorityText @"ZLPhotoBrowserNoAblumAuthorityText"
#define ZLPhotoBrowseriCloudPhotoText @"ZLPhotoBrowseriCloudPhotoText"
#define ZLPhotoBrowserGifPreviewText @"ZLPhotoBrowserGifPreviewText"
#define ZLPhotoBrowserVideoPreviewText @"ZLPhotoBrowserVideoPreviewText"
#define ZLPhotoBrowserLivePhotoPreviewText @"ZLPhotoBrowserLivePhotoPreviewText"
#define ZLPhotoBrowserNoPhotoText @"ZLPhotoBrowserNoPhotoText"
#define ZLPhotoBrowserCannotSelectVideo @"ZLPhotoBrowserCannotSelectVideo"
#define ZLPhotoBrowserCannotSelectGIF @"ZLPhotoBrowserCannotSelectGIF"
#define ZLPhotoBrowserCannotSelectLivePhoto @"ZLPhotoBrowserCannotSelectLivePhoto"
#define ZLPhotoBrowseriCloudVideoText @"ZLPhotoBrowseriCloudVideoText"
#define ZLPhotoBrowserEditText @"ZLPhotoBrowserEditText"
#define ZLPhotoBrowserSaveText @"ZLPhotoBrowserSaveText"
#define ZLPhotoBrowserMaxVideoDurationText @"ZLPhotoBrowserMaxVideoDurationText"
#define ZLPhotoBrowserLoadNetImageFailed @"ZLPhotoBrowserLoadNetImageFailed"
#define ZLPhotoBrowserSaveVideoFailed @"ZLPhotoBrowserSaveVideoFailed"

#define kRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kNavBar_color kRGB(19, 153, 231)
#define kNavBar_tintColor kRGB(255, 255, 255)
#define kBottomViewBgColor kRGB(255, 255, 255)
#define kDoneButton_textColor kRGB(255, 255, 255)
#define kBottomBtnsNormalTitleColor kRGB(80, 180, 234)
#define kBottomBtnsDisableTitleColor kRGB(200, 200, 200)

#define zl_weakify(var)   __weak typeof(var) weakSelf = var
#define zl_strongify(var) __strong typeof(var) strongSelf = var

#define ZL_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define ZL_IS_IPHONE_X (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0f)

#define kZLPhotoBrowserBundle [NSBundle bundleForClass:[self class]]

// 图片路径
#define kZLPhotoBrowserSrcName(file) [@"ZLPhotoBrowser.bundle" stringByAppendingPathComponent:file]
#define kZLPhotoBrowserFrameworkSrcName(file) [@"Frameworks/ZLPhotoBrowser.framework/ZLPhotoBrowser.bundle" stringByAppendingPathComponent:file]

#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

//自定义图片名称存于plist中的key
#define ZLCustomImageNames @"ZLCustomImageNames"

////////ZLShowBigImgViewController
#define kItemMargin 40

///////ZLBigImageCell 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500

#define ClippingRatioValue1 @"value1"
#define ClippingRatioValue2 @"value2"
#define ClippingRatioTitleFormat @"titleFormat"

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

static inline NSString *  GetLocalLanguageTextValue (NSString *key) {
    return [NSBundle zlLocalizedStringForKey:key];
}

static inline UIImage * GetImageWithName (NSString *name) {
    NSArray *names = [[NSUserDefaults standardUserDefaults] valueForKey:ZLCustomImageNames];
    if ([names containsObject:name]) {
        return [UIImage imageNamed:name];
    }
    return [UIImage imageNamed:kZLPhotoBrowserSrcName(name)]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(name)];
}

static inline CGFloat GetMatchValue (NSString *text, CGFloat fontSize, BOOL isHeightFixed, CGFloat fixedValue) {
    CGSize size;
    if (isHeightFixed) {
        size = CGSizeMake(MAXFLOAT, fixedValue);
    } else {
        size = CGSizeMake(fixedValue, MAXFLOAT);
    }
    
    CGSize resultSize;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        //返回计算出的size
        resultSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
    }
    if (isHeightFixed) {
        return resultSize.width;
    } else {
        return resultSize.height;
    }
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

static inline NSInteger GetDuration (NSString *duration) {
    NSArray *arr = [duration componentsSeparatedByString:@":"];
    
    NSInteger d = 0;
    for (int i = 0; i < arr.count; i++) {
        d += [arr[i] integerValue] * pow(60, (arr.count-1-i));
    }
    return d;
}


static inline NSDictionary *
GetCustomClipRatio() {
    return @{ClippingRatioValue1: @(0), ClippingRatioValue2: @(0), ClippingRatioTitleFormat: @"Custom"};
}

static inline NSDictionary * GetClipRatio(NSInteger value1, NSInteger value2) {
    return @{ClippingRatioValue1: @(value1), ClippingRatioValue2: @(value2), ClippingRatioTitleFormat: @"%g : %g"};
}

#endif /* ZLDefine_h */
