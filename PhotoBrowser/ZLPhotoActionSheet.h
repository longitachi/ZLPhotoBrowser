//
//  ZLPhotoActionSheet.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//
//pods version 2.7.7 - 2019.01.13 update

#import <UIKit/UIKit.h>
#import "ZLPhotoConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class ZLPhotoModel;
@class PHAsset;


@interface ZLPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

/**相册框架配置，默认为 [ZLPhotoConfiguration defaultPhotoConfiguration]*/
@property (nonatomic, strong, readonly) ZLPhotoConfiguration *configuration;

/**
 已选择的asset对象数组，用于标记已选择的图片
 */
@property (nonatomic, strong, nullable) NSMutableArray<PHAsset *> *arrSelectedAssets;


/**
 选择照片回调，回调解析好的图片、对应的asset对象、是否原图
 pod 2.2.6版本之后 统一通过selectImageBlock回调
 */
@property (nonatomic, copy, nullable) void (^selectImageBlock)(NSArray<UIImage *> *_Nullable images, NSArray<PHAsset *> *assets, BOOL isOriginal);

/**
 选择照片回调，如果存在解析失败的图片，则单独把失败的asset及对应的选择时的index回调出去
 */
@property (nonatomic, copy, nullable) void (^selectImageRequestErrorBlock)(NSArray<PHAsset *> *errorAssets, NSArray<NSNumber *> *errorIndex);

/**
 取消选择回调
 */
@property (nonatomic, copy) void (^cancleBlock)(void);


- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;


/**
 显示ZLPhotoActionSheet选择照片视图
 
 @warning 需提前赋值 sender 对象
 @param animate 是否显示动画效果
 */
- (void)showPreviewAnimated:(BOOL)animate NS_SWIFT_NAME(showPreview(animate:));


/**
 显示ZLPhotoActionSheet选择照片视图

 @param animate 是否显示动画效果
 @param sender 调用该对象的控制器
 */
- (void)showPreviewAnimated:(BOOL)animate sender:(UIViewController *)sender NS_SWIFT_NAME(showPreview(animate:sender:));


/**
 直接进入相册选择界面
 */
- (void)showPhotoLibrary NS_SWIFT_NAME(showPhotoLibrary());

/**
 直接进入相册选择界面
 
 @param sender 调用该对象的控制器
 */
- (void)showPhotoLibraryWithSender:(UIViewController *)sender NS_SWIFT_NAME(showPhotoLibrary(sender:));


/**
 提供 预览用户已选择的照片，并可以取消已选择的照片 （需先设置 sender 参数）

 @param photos 已选择的uiimage照片数组
 @param assets 已选择的phasset照片数组
 @param index 点击的照片索引
 @param isOriginal 是否为原图
 */
- (void)previewSelectedPhotos:(NSArray<UIImage *> *)photos assets:(NSArray<PHAsset *> *)assets index:(NSInteger)index isOriginal:(BOOL)isOriginal;


/**
 提供 混合预览照片及视频的方法， 相册PHAsset / 网络、本地图片 / 网络、本地视频，（需先设置 sender 参数）
 
 @warning photos 内对象请调用 ZLDefine 中 GetDictForPreviewPhoto 方法，e.g.: GetDictForPreviewPhoto(image, ZLPreviewPhotoTypeUIImage)
 
 @param photos 接收对象 ZLDefine 中 GetDictForPreviewPhoto 生成的字典
 @param index 点击的照片/视频索引
 @param hideToolBar 是否隐藏底部工具栏和导航右上角选择按钮
 @param complete 回调 (数组内为接收的 PHAsset / UIImage / NSURL 对象)
 */
- (void)previewPhotos:(NSArray<NSDictionary *> *)photos index:(NSInteger)index hideToolBar:(BOOL)hideToolBar complete:(void (^)(NSArray *photos))complete;

NS_ASSUME_NONNULL_END

@end

