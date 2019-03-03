//
//  ZLEditViewController.h
//  ZLPhotoBrowser
//
//  Created by long on 2017/6/23.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoModel;

@interface ZLEditViewController : UIViewController

@property (nonatomic, strong) UIImage *oriImage;
@property (nonatomic, strong) ZLPhotoModel *model;

@end
