//
//  ZLPhotoActionSheetViewController.h
//  ZLPhotoBrowser
//
//  Created by Yalin on 16/7/11.
//  Copyright © 2016年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoActionSheet;

@interface ZLPhotoActionSheetViewController : UIViewController

+ (instancetype)createWithActionSheetView:(ZLPhotoActionSheet *)actionSheetView;

- (void)showWithController:(UIViewController *)controller;
- (void)hide;

@end
