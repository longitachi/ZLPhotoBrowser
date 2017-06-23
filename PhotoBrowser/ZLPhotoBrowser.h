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

/** 最大选择数 默认10张*/
@property (nonatomic, assign) NSInteger maxSelectCount;

/**是否允许选择照片 默认YES*/
@property (nonatomic, assign) BOOL allowSelectImage;

/**是否允许选择视频 默认YES*/
@property (nonatomic, assign) BOOL allowSelectVideo;

/**cell的圆角弧度 默认为0*/
@property (nonatomic, assign) CGFloat cellCornerRadio;

/**是否允许选择Gif 默认YES*/
@property (nonatomic, assign) BOOL allowSelectGif;

/**是否允许选择Live Photo，默认NO*/
@property (nonatomic, assign) BOOL allowSelectLivePhoto;

/**是否允许相册内部拍照 默认YES*/
@property (nonatomic, assign) BOOL allowTakePhotoInLibrary;

/**是否Force Touch 功能 默认YES*/
@property (nonatomic, assign) BOOL allowForceTouch;

/**是否允许编辑图片，选择一张时候才允许编辑，默认YES*/
@property (nonatomic, assign) BOOL allowEditImage;

/**是否在相册内部拍照按钮上面实时显示相机俘获的影像 默认 YES*/
@property (nonatomic, assign) BOOL showCaptureImageOnTakePhotoBtn;

/**是否升序排列，预览界面不受该参数影响，默认升序 YES*/
@property (nonatomic, assign) BOOL sortAscending;

/**控制单选模式下，是否显示选择按钮，默认 NO，多选模式不受控制*/
@property (nonatomic, assign) BOOL showSelectBtn;

/**是否选择了原图*/
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSMutableArray<ZLPhotoModel *> *arrSelectedModels;

/**点击确定选择照片回调*/
@property (nonatomic, copy) void (^callSelectImageBlock)();

/**点击确定gif回调*/
@property (nonatomic, copy) void (^callSelectGifBlock)(UIImage *, PHAsset *);

/**点击确定live photo回调*/
@property (nonatomic, copy) void (^callSelectLivePhotoBlock)(UIImage *, PHAsset *);

/**点击确定video回调*/
@property (nonatomic, copy) void (^callSelectVideoBlock)(UIImage *, PHAsset *);

/**编辑图片后回调*/
@property (nonatomic, copy) void (^callSelectClipImageBlock)(UIImage *, PHAsset *);

/**取消block*/
@property (nonatomic, copy) void (^cancelBlock)();

@end



@interface ZLPhotoBrowser : UITableViewController

@end
