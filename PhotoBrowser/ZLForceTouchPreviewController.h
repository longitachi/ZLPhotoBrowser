//
//  ZLForceTouchPreviewController.h
//  ZLPhotoBrowser
//
//  Created by long on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoModel;

@interface ZLForceTouchPreviewController : UIViewController

@property (nonatomic, assign) BOOL allowSelectGif;
@property (nonatomic, assign) BOOL allowSelectLivePhoto;
@property (nonatomic, strong) ZLPhotoModel *model;

@end
