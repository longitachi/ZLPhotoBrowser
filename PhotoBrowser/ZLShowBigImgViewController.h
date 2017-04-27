//
//  ZLShowBigImgViewController.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class ZLPhotoModel;

@interface ZLShowBigImgViewController : UIViewController

@property (nonatomic, strong) NSArray<ZLPhotoModel *> *models;

@property (nonatomic, assign) NSInteger selectIndex; //选中的图片下标

@property (nonatomic, copy) void (^btnBackBlock)(NSArray<ZLPhotoModel *> *selectedModels, BOOL isOriginal);


//点击选择后的图片预览数组
@property (nonatomic, strong) NSMutableArray<UIImage *> *arrSelPhotos;

@property (nonatomic, copy) void (^btnDonePreviewBlock)(NSArray<UIImage *> *, NSArray<PHAsset *> *);

@end
