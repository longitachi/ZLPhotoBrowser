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

/**是否允许选择Gif 默认YES*/
@property (nonatomic, assign) BOOL allowSelectGif;

/**是否允许相册内部拍照 默认YES*/
@property (nonatomic, assign) BOOL allowTakePhotoInLibrary;

/**是否升序排列，预览界面不受该参数影响，默认升序 YES*/
@property (nonatomic, assign) BOOL sortAscending;

/**是否选择了原图*/
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSMutableArray<ZLPhotoModel *> *arrSelectedModels;

/**点击确定选择照片回调*/
@property (nonatomic, copy) void (^callSelectImageBlock)();

/**点击确定gif回调*/
@property (nonatomic, copy) void (^callSelectGifBlock)(UIImage *, PHAsset *);

/**点击确定video回调*/
@property (nonatomic, copy) void (^callSelectVideoBlock)(UIImage *, PHAsset *);

/**取消block*/
@property (nonatomic, copy) void (^cancelBlock)();

@end



@interface ZLPhotoBrowser : UITableViewController

@end
