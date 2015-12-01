//
//  ZLPhotoBrowser.h
//  多选相册照片
//
//  Created by long on 15/11/27.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLSelectPhotoModel;

@interface ZLPhotoBrowser : UITableViewController

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectCount;

//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray<ZLSelectPhotoModel *> *arraySelectPhotos;

//选则完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray<ZLSelectPhotoModel *> *);
//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)();

@end
