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

/**是否允许选择照片 默认YES*/
@property (nonatomic, assign) BOOL allowSelectImage;

/**是否允许选择视频 默认YES*/
@property (nonatomic, assign) BOOL allowSelectVideo;

/**是否允许选择Gif，只是控制是否选择，并不控制是否显示，如果为NO，则不显示gif标识 默认YES*/
@property (nonatomic, assign) BOOL allowSelectGif;

/**是否允许相册内部拍照 默认YES*/
@property (nonatomic, assign) BOOL allowTakePhotoInLibrary;

/**是否升序排列，预览界面不受该参数影响，默认升序 YES*/
@property (nonatomic, assign) BOOL sortAscending;

/**已选择的asset对象数组*/
@property (nonatomic, strong) NSMutableArray<PHAsset *> *arrSelectedAssets;

/**选择照片回调，回调解析好的图片、对应的asset对象、是否原图*/
@property (nonatomic, copy) void (^selectImageBlock)(NSArray<UIImage *> *, NSArray<PHAsset *> *, BOOL);

/**选择gif照片回调，回调解析好的gif图片、对应的asset对象*/
@property (nonatomic, copy) void (^selectGifBlock)(UIImage *, PHAsset *);

/**选择视频回调，回调第一帧封面图片、对应的asset对象，对应的AVPlayerItem对象*/
@property (nonatomic, copy) void (^selectVideoBlock)(UIImage *, PHAsset *);

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

