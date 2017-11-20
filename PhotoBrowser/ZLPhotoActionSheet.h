//
//  ZLPhotoActionSheet.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//
//pods version 2.5.1.1 - 2017.11.15 update

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZLPhotoModel;
@class PHAsset;
@class ZLPhotoConfiguration;

@interface ZLPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

/**相册框架配置*/
@property (nonatomic, strong) ZLPhotoConfiguration *configuration;

/**
 已选择的asset对象数组，用于标记已选择的图片
 */
@property (nonatomic, strong, nullable) NSMutableArray<PHAsset *> *arrSelectedAssets;


/**
 选择照片回调，回调解析好的图片、对应的asset对象、是否原图
 pod 2.2.6版本之后 统一通过selectImageBlock回调
 */
@property (nonatomic, copy) void (^selectImageBlock)(NSArray<UIImage *> *__nullable images, NSArray<PHAsset *> *assets, BOOL isOriginal);

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
 提供 预览用户已选择的照片，并可以取消已选择的照片

 @param photos 已选择的uiimage照片数组
 @param assets 已选择的phasset照片数组
 @param index 点击的照片索引
 @param isOriginal 是否为原图
 */
- (void)previewSelectedPhotos:(NSArray<UIImage *> *)photos assets:(NSArray<PHAsset *> *)assets index:(NSInteger)index isOriginal:(BOOL)isOriginal;


/**
 提供 预览照片网络/本地图片
 
 @param photos 接收对象 UIImage / NSURL(网络url或本地图片url)
 @param index 点击的照片索引
 @param hideToolBar 是否隐藏底部工具栏和导航右上角选择按钮
 @param complete 回调 (数组内为接收的UIImage / NSUrl 对象)
 */
- (void)previewPhotos:(NSArray *)photos index:(NSInteger)index hideToolBar:(BOOL)hideToolBar complete:(void (^)(NSArray *photos))complete;

NS_ASSUME_NONNULL_END

@end

