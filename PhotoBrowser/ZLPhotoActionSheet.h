//
//  ZLPhotoActionSheet.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZLPhotoModel;
@class PHAsset;
@class AVPlayerItem;

@interface ZLPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

/**最大选择数 默认10张*/
@property (nonatomic, assign) NSInteger maxSelectCount;

/**预览图最大显示数 默认20张*/
@property (nonatomic, assign) NSInteger maxPreviewCount;

/**允许选择视频的最大时长，单位：秒， 默认 120s*/
@property (nonatomic, assign) NSInteger maxVideoDuration;

/**cell的圆角弧度 默认为0*/
@property (nonatomic, assign) CGFloat cellCornerRadio;

/**是否允许混合选择，即可以同时选择image(image/gif/livephoto)、video类型*/
@property (nonatomic, assign) BOOL allowMixSelect;

/**是否允许选择照片 默认YES*/
@property (nonatomic, assign) BOOL allowSelectImage;

/**是否允许选择视频 默认YES*/
@property (nonatomic, assign) BOOL allowSelectVideo;

/**是否允许选择Gif，只是控制是否选择，并不控制是否显示，如果为NO，则不显示gif标识 默认YES*/
@property (nonatomic, assign) BOOL allowSelectGif;

/**
 * 是否允许选择Live Photo，只是控制是否选择，并不控制是否显示，如果为NO，则不显示Live Photo标识 默认NO
 * @warning ios9 以上系统支持
 */
@property (nonatomic, assign) BOOL allowSelectLivePhoto;

/**是否允许相册内部拍照 默认YES*/
@property (nonatomic, assign) BOOL allowTakePhotoInLibrary;

/**是否允许Force Touch功能 默认YES*/
@property (nonatomic, assign) BOOL allowForceTouch;

/**是否允许编辑图片，选择一张时候才允许编辑，默认YES*/
@property (nonatomic, assign) BOOL allowEditImage;

/**是否在相册内部拍照按钮上面实时显示相机俘获的影像 默认 YES*/
@property (nonatomic, assign) BOOL showCaptureImageOnTakePhotoBtn;

/**是否升序排列，预览界面不受该参数影响，默认升序 YES*/
@property (nonatomic, assign) BOOL sortAscending;

/**控制单选模式下，是否显示选择按钮，默认 NO，多选模式不受控制*/
@property (nonatomic, assign) BOOL showSelectBtn;

/**已选择的asset对象数组*/
@property (nonatomic, strong) NSMutableArray<PHAsset *> *arrSelectedAssets;

/**选择照片回调，回调解析好的图片、对应的asset对象、是否原图*/
@property (nonatomic, copy) void (^selectImageBlock)(NSArray<UIImage *> *images, NSArray<PHAsset *> *assets, BOOL isOriginal);

/**选择gif照片回调，回调解析好的gif图片、对应的asset对象*/
@property (nonatomic, copy) void (^selectGifBlock)(UIImage *gif, PHAsset *asset) NS_DEPRECATED_IOS(2_0, 8_0, "pod 2.2.6版本之后已废弃，删除使用的地方即可， 统一通过selectImageBlock回调，后续将删除");

/**选择live photo照片回调，回调解析好的live photo图片、对应的asset对象*/
@property (nonatomic, copy) void (^selectLivePhotoBlock)(UIImage *livePhoto, PHAsset *asset) NS_DEPRECATED_IOS(2_0, 8_0, "pod 2.2.6版本之后已废弃，删除使用的地方即可， 统一通过selectImageBlock回调，后续将删除");

/**选择视频回调，回调第一帧封面图片、对应的asset对象*/
@property (nonatomic, copy) void (^selectVideoBlock)(UIImage *cover, PHAsset *asset) NS_DEPRECATED_IOS(2_0, 8_0, "pod 2.2.6版本之后已废弃，删除使用的地方即可， 统一通过selectImageBlock回调，后续将删除");

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;


/**
 显示ZLPhotoActionSheet选择照片视图
 
 @warning 需提前赋值 sender 对象
 @param animate 是否显示动画效果
 */
- (void)showPreviewAnimated:(BOOL)animate;


/**
 显示ZLPhotoActionSheet选择照片视图

 @param animate 是否显示动画效果
 @param sender 调用该对象的控制器
 */
- (void)showPreviewAnimated:(BOOL)animate sender:(UIViewController *)sender;


/**
 直接进入相册选择界面
 */
- (void)showPhotoLibrary;

/**
 直接进入相册选择界面
 
 @param sender 调用该对象的控制器
 */
- (void)showPhotoLibraryWithSender:(UIViewController *)sender;



/**
 提供 预览用户已选择的照片(非gif与video类型)，并可以取消已选择的照片

 @param photos 已选择的uiimage照片数组
 @param assets 已选择的phasset照片数组
 @param index 点击的照片索引
 */
- (void)previewSelectedPhotos:(NSArray<UIImage *> *)photos assets:(NSArray<PHAsset *> *)assets index:(NSInteger)index;

NS_ASSUME_NONNULL_END

@end

