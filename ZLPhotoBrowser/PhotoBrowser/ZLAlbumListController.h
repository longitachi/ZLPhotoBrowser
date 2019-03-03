//
//  ZLPhotoBrowser.h
//  多选相册照片
//
//  Created by long on 15/11/27.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLDefine.h"
#import "ZLPhotoConfiguration.h"

@class ZLPhotoModel;

@interface ZLImageNavigationController : UINavigationController

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

/**
 是否选择了原图
 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSMutableArray<ZLPhotoModel *> *arrSelectedModels;

/**
 相册框架配置
 */
@property (nonatomic, strong) ZLPhotoConfiguration *configuration;

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



@interface ZLAlbumListController : UITableViewController

@end
