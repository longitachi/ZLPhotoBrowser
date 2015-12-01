//
//  ZLShowBigImgViewController.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class ZLSelectPhotoModel;

@interface ZLShowBigImgViewController : UIViewController

@property (nonatomic, strong) NSArray<PHAsset *> *assets;

@property (nonatomic, strong) NSMutableArray<ZLSelectPhotoModel *> *arraySelectPhotos;

@property (nonatomic, assign) NSInteger selectIndex; //选中的图片下标

@property (nonatomic, assign) NSInteger maxSelectCount; //最大选择照片数

@property (nonatomic, assign) BOOL showPopAnimate; //pop时是否使用过渡动画

@property (nonatomic, assign) BOOL shouldReverseAssets; //是否需要对接收到的图片数组进行逆序排列

@property (nonatomic, copy) void (^onSelectedPhotos)(NSArray<ZLSelectPhotoModel *> *);

@end
