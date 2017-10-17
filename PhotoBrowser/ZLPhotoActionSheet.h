//
//  ZLPhotoActionSheet.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//
//pods version 2.4.8 - 2017.10.17 update

#import <UIKit/UIKit.h>
#import "ZLDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class ZLPhotoModel;
@class PHAsset;
@class AVPlayerItem;

@interface ZLPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

/**
 最大选择数 默认10张
 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/**
 预览图最大显示数 默认20张
 */
@property (nonatomic, assign) NSInteger maxPreviewCount;

/**
 cell的圆角弧度 默认为0
 */
@property (nonatomic, assign) CGFloat cellCornerRadio;

/**
 是否允许混合选择，即可以同时选择image(image/gif/livephoto)、video类型
 */
@property (nonatomic, assign) BOOL allowMixSelect;

/**
 是否允许选择照片 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectImage;

/**
 是否允许选择视频 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectVideo;

/**
 是否允许选择Gif，只是控制是否选择，并不控制是否显示，如果为NO，则不显示gif标识 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectGif;

/**
 * 是否允许选择Live Photo，只是控制是否选择，并不控制是否显示，如果为NO，则不显示Live Photo标识 默认NO
 * @warning ios9 以上系统支持
 */
@property (nonatomic, assign) BOOL allowSelectLivePhoto;

/**
 是否允许相册内部拍照 默认YES
 */
@property (nonatomic, assign) BOOL allowTakePhotoInLibrary;

/**
 是否允许Force Touch功能 默认YES
 */
@property (nonatomic, assign) BOOL allowForceTouch;

/**
 是否允许编辑图片，选择一张时候才允许编辑，默认YES
 */
@property (nonatomic, assign) BOOL allowEditImage;

/**
 是否允许编辑视频，选择一张时候才允许编辑，默认NO
 */
@property (nonatomic, assign) BOOL allowEditVideo;

/**
 编辑视频时最大裁剪时间，单位：秒，默认10s 且最低10s
 
 @discussion 当该参数为10s时，所选视频时长必须大于等于10s才允许进行编辑
 */
@property (nonatomic, assign) NSInteger maxEditVideoTime;

/**
 允许选择视频的最大时长，单位：秒， 默认 120s
 */
@property (nonatomic, assign) NSInteger maxVideoDuration;

/**
 是否允许滑动选择 默认 YES
 */
@property (nonatomic, assign) BOOL allowSlideSelect;

/**
 预览界面是否允许拖拽选择 默认 NO
 */
@property (nonatomic, assign) BOOL allowDragSelect;

/**
 根据需要设置自身需要的裁剪比例
 
 @discussion e.g.:1:1，请使用ZLDefine中所提供方法 GetClipRatio(NSInteger value1, NSInteger value2)，该数组可不设置，有默认比例，为（Custom, 1:1, 4:3, 3:2, 16:9）
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *clipRatios;

/**
 在小图界面选择 图片/视频 后直接进入编辑界面，默认NO
 
 @discussion 编辑图片 仅在allowEditImage为YES 且 maxSelectCount为1 的情况下，置为YES有效，编辑视频则在 allowEditVideo为YES 且 maxSelectCount为1情况下，置为YES有效
 */
@property (nonatomic, assign) BOOL editAfterSelectThumbnailImage;

/**
 是否在相册内部拍照按钮上面实时显示相机俘获的影像 默认 YES
 */
@property (nonatomic, assign) BOOL showCaptureImageOnTakePhotoBtn;

/**
 是否升序排列，预览界面不受该参数影响，默认升序 YES
 */
@property (nonatomic, assign) BOOL sortAscending;

/**
 控制单选模式下，是否显示选择按钮，默认 NO，多选模式不受控制
 */
@property (nonatomic, assign) BOOL showSelectBtn;

/**
 已选择的asset对象数组
 */
@property (nonatomic, strong) NSMutableArray<PHAsset *> *arrSelectedAssets;

/**
 导航条颜色，默认 rgb(19, 153, 231)
 */
@property (nonatomic, strong) UIColor *navBarColor;

/**
 导航标题颜色，默认 rgb(255, 255, 255)
 */
@property (nonatomic, strong) UIColor *navTitleColor;

/**
 底部工具条底色，默认 rgb(255, 255, 255)
 */
@property (nonatomic, strong) UIColor *bottomViewBgColor;

/**
 底部工具栏按钮 可交互 状态标题颜色，底部 toolbar 按钮可交互状态title颜色均使用这个，确定按钮 可交互 的背景色为这个，默认rgb(80, 180, 234)
 */
@property (nonatomic, strong) UIColor *bottomBtnsNormalTitleColor;

/**
 底部工具栏按钮 不可交互 状态标题颜色，底部 toolbar 按钮不可交互状态颜色均使用这个，确定按钮 不可交互 的背景色为这个，默认rgb(200, 200, 200)
 */
@property (nonatomic, strong) UIColor *bottomBtnsDisableBgColor;

/**
 是否在已选择的图片上方覆盖一层已选中遮罩层，默认 NO
 */
@property (nonatomic, assign) BOOL showSelectedMask;

/**
 遮罩层颜色，内部会默认调整颜色的透明度为0.2， 默认 blackColor
 */
@property (nonatomic, strong) UIColor *selectedMaskColor;

/**
 支持开发者自定义图片，但是所自定义图片资源名称必须与被替换的bundle中的图片名称一致
 @example: 开发者需要替换选中与未选中的图片资源，则需要传入的数组为 @[@"btn_selected", @"btn_unselected"]，则框架内会使用开发者项目中的图片资源，而其他图片则用框架bundle中的资源
 */
@property (nonatomic, strong) NSArray<NSString *> *customImageNames;

/**
 选择照片回调，回调解析好的图片、对应的asset对象、是否原图
 pod 2.2.6版本之后 统一通过selectImageBlock回调
 */
@property (nonatomic, copy) void (^selectImageBlock)(NSArray<UIImage *> *images, NSArray<PHAsset *> *assets, BOOL isOriginal);

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

