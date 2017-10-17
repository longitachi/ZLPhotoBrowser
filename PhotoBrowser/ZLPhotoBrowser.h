//
//  ZLPhotoBrowser.h
//  多选相册照片
//
//  Created by long on 15/11/27.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoModel;
@class PHAsset;
@class AVPlayerItem;

@interface ZLImageNavigationController : UINavigationController

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

/**
 最大选择数 默认10张
 */
@property (nonatomic, assign) NSInteger maxSelectCount;

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
 是否允许选择Gif 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectGif;

/**
 是否允许选择Live Photo，默认NO
 */
@property (nonatomic, assign) BOOL allowSelectLivePhoto;

/**
 是否允许相册内部拍照 默认YES
 */
@property (nonatomic, assign) BOOL allowTakePhotoInLibrary;

/**
 是否Force Touch 功能 默认YES
 */
@property (nonatomic, assign) BOOL allowForceTouch;

/**
 是否允许编辑图片，选择一张时候才允许编辑，默认YES
 */
@property (nonatomic, assign) BOOL allowEditImage;

/**
 是否允许编辑视频，选择一张时候才允许编辑，默认NO，编辑视频
 */
@property (nonatomic, assign) BOOL allowEditVideo;

/**
 编辑视频时最大裁剪时间，单位：秒，默认10s
 
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
 根据需要设置自身需要的裁剪比例
 
 @discussion e.g.:1:1，请使用ZLDefine中所提供方法 GetClipRatio(NSInteger value1, NSInteger value2)，该数组可不设置，有默认比例，为（Custom, 1:1, 4:3, 3:2, 16:9）
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *clipRatios;

/**
 在小图界面选择图片后直接进入编辑界面，默认NO， 仅在allowEditImage为YES且maxSelectCount为1 的情况下，置为YES有效
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
 是否选择了原图
 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSMutableArray<ZLPhotoModel *> *arrSelectedModels;

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
 点击确定选择照片回调
 */
@property (nonatomic, copy) void (^callSelectImageBlock)(void);

/**
 编辑图片后回调
 */
@property (nonatomic, copy) void (^callSelectClipImageBlock)(UIImage *, PHAsset *);

/**
 取消block
 */
@property (nonatomic, copy) void (^cancelBlock)(void);

@end



@interface ZLPhotoBrowser : UITableViewController

@end
