//
//  ZLEditViewController.m
//  ZLPhotoBrowser
//
//  Created by long on 2017/6/23.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLEditViewController.h"
#import "ZLPhotoModel.h"
#import "ZLDefine.h"
#import "ZLPhotoManager.h"
#import "ToastUtils.h"
#import "ZLProgressHUD.h"
#import "ZLAlbumListController.h"
#import "ZLImageEditTool.h"
#import <Photos/Photos.h>

//!!!!: edit vc
@interface ZLEditViewController ()
{
    UIActivityIndicatorView *_indicator;
    
    ZLImageEditTool *_editTool;
}

@end

@implementation ZLEditViewController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _editTool.frame = self.view.bounds;
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    //禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self loadEditTool];
    [self loadImage];
}

- (void)loadImage
{
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.center = self.view.center;
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _indicator.hidesWhenStopped = YES;
    [self.view addSubview:_indicator];
    
    CGFloat scale = 3;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*self.model.asset.pixelHeight/self.model.asset.pixelWidth);
    
    [_indicator startAnimating];
    @zl_weakify(self);
    [ZLPhotoManager requestImageForAsset:self.model.asset size:size progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            @zl_strongify(self);
            if (!self) return;
            [self->_indicator stopAnimating];
            self->_editTool.editImage = image;
        }
    }];
}

- (void)loadEditTool
{
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    _editTool = [[ZLImageEditTool alloc] initWithEditType:ZLImageEditTypeClip image:_oriImage configuration:configuration];
    @zl_weakify(self);
    _editTool.cancelEditBlock = ^{
        @zl_strongify(self);
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        ZLPhotoConfiguration *configuration = nav.configuration;
        
        if (configuration.editAfterSelectThumbnailImage &&
            configuration.maxSelectCount == 1) {
            [nav.arrSelectedModels removeAllObjects];
        }
        UIViewController *vc = [self.navigationController popViewControllerAnimated:NO];
        if (!vc) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (self.cancelEditBlock) {
            self.cancelEditBlock();
        }
    };
    _editTool.doneEditBlock = ^(UIImage *image) {
        @zl_strongify(self);
        [self saveImage:image];
    };
    [self.view addSubview:_editTool];
}

- (void)saveImage:(UIImage *)image
{
    //确定裁剪，返回
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    if (nav.configuration.saveNewImageAfterEdit) {
        @zl_weakify(self);
        __weak typeof(nav) weakNav = nav;
        [ZLPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            [hud hide];
            if (suc) {
                @zl_strongify(self);
                __strong typeof(weakNav) strongNav = weakNav;
                if (strongNav.callSelectClipImageBlock) {
                    strongNav.callSelectClipImageBlock(image, asset);
                }
                if (self.editResultBlock) {
                    self.editResultBlock(image, asset);
                }
            } else {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveImageErrorText));
            }
        }];
    } else {
        [hud hide];
        if (image) {
            if (nav.callSelectClipImageBlock) {
                nav.callSelectClipImageBlock(image, self.model.asset);
            }
            if (self.editResultBlock) {
                self.editResultBlock(image, self.model.asset);
            }
        } else {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveImageErrorText));
        }
    }
}

@end
