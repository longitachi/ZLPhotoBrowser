//
//  ZLPhotoConfiguration.h
//  ZLPhotoBrowser
//
//  Created by long on 2017/11/16.
//  Copyright © 2017年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLDefine.h"
#import "ZLImageEditTool.h"

@class PHAsset;

@interface ZLPhotoConfiguration : NSObject

- (instancetype)init NS_UNAVAILABLE;


/**
 默认相册配置
 */
+ (instancetype)defaultPhotoConfiguration;


/**
 状态栏样式 默认 UIStatusBarStyleLightContent
 
 @discussion 需要在info.plist中添加键 "View controller-based status bar appearance" 值设置为 "NO"
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 最大选择数 默认9张，最小 1
 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/**
 预览图最大显示数 默认20张，该值为0时将不显示上方预览图，仅显示 '拍照、相册、取消' 按钮
 */
@property (nonatomic, assign) NSInteger maxPreviewCount;

/**
 cell的圆角弧度 默认为0
 */
@property (nonatomic, assign) CGFloat cellCornerRadio;

/**
 是否允许混合选择，即可以同时选择image(image/gif/livephoto)、video类型， 默认YES
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
 是否允许选择Live Photo，只是控制是否选择，并不控制是否显示，如果为NO，则不显示Live Photo标识 默认NO
 
 @warning ios9 以上系统支持
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
 @warning: 2.7.9 版本移除滤镜功能，暂时只留下裁剪功能，进入编辑界面后可直接进行裁剪
 
 //编辑类型，至少要有一种，默认 ZLImageEditTypeClip | ZLImageEditTypeRotate
 */
//@property (nonatomic, assign) ZLImageEditType editType;

/**
 是否允许选择原图，默认YES
 */
@property (nonatomic, assign) BOOL allowSelectOriginal;

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
 隐藏裁剪图片界面下方比例工具条
 */
@property (nonatomic, assign) BOOL hideClipRatiosToolBar;

/**
 根据需要设置自身需要的裁剪比例
 
 @discussion e.g.:1:1，请使用ZLDefine中所提供方法 GetClipRatio(NSInteger value1, NSInteger value2)，该数组可不设置，有默认比例，为（Custom, 1:1, 4:3, 3:2, 16:9），如果所设置比例只有一个且 为 Custom 或 1:1，则编辑图片界面隐藏下方比例工具条
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *clipRatios;

/**
 在小图界面选择 图片/视频 后直接进入编辑界面，默认NO
 
 @discussion 编辑图片 仅在allowEditImage为YES 且 maxSelectCount为1 的情况下，置为YES有效，编辑视频则在 allowEditVideo为YES 且 maxSelectCount为1情况下，置为YES有效
 */
@property (nonatomic, assign) BOOL editAfterSelectThumbnailImage;

/**
 编辑图片后是否保存编辑后的图片至相册，默认YES
 */
@property (nonatomic, assign) BOOL saveNewImageAfterEdit;

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
 @example: 开发者需要替换选中与未选中的图片资源，则需要传入的数组为 @[@"zl_btn_selected", @"zl_btn_unselected"]，则框架内会使用开发者项目中的图片资源，而其他图片则用框架bundle中的资源
 */
@property (nonatomic, strong) NSArray<NSString *> *customImageNames;

/**
 回调时候是否允许框架解析图片，默认YES
 
 @discussion 如果选择了大量图片，框架一下解析大量图片会耗费一些内存，开发者此时可置为NO，拿到assets数组后使用 ZLPhotoManager 中提供的 "anialysisAssets:original:completion:" 方法进行逐个解析，以达到缓解内存瞬间暴涨的效果，该值为NO时，回调的图片数组为nil
 */
@property (nonatomic, assign) BOOL shouldAnialysisAsset;

/**
 框架语言，默认 ZLLanguageSystem (跟随系统语言)
 */
@property (nonatomic, assign) ZLLanguageType languageType;

/**
 支持开发者自定义多语言提示，但是所自定义多语言的key必须与原key一致
 @example: 开发者需要替换 key: "ZLPhotoBrowserLoadingText"，value:"正在处理..." 的多语言，则需要传入的字典为 @{@"ZLPhotoBrowserLoadingText": @"需要替换的文字"}，而其他多语言则用框架中的（更改时请注意多语言中包含的占位符，如%ld、%@）
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *customLanguageKeyValue;

/**
 使用系统相机，默认NO
 */
@property (nonatomic, assign) BOOL useSystemCamera;

/**
 是否允许录制视频，默认YES
 */
@property (nonatomic, assign) BOOL allowRecordVideo;

/**
 最大录制时长，默认 10s，最小为 1s
 */
@property (nonatomic, assign) NSInteger maxRecordDuration;

/**
 视频清晰度，默认ZLCaptureSessionPreset1280x720
 */
@property (nonatomic, assign) ZLCaptureSessionPreset sessionPreset;

/**
 录制视频及编辑视频时候的视频导出格式，默认ZLExportVideoTypeMov
 */
@property (nonatomic, assign) ZLExportVideoType exportVideoType;

@end
