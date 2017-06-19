//
//  ZLShowLivePhotoViewController.m
//  ZLPhotoBrowser
//
//  Created by long on 2017/6/17.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLShowLivePhotoViewController.h"
#import <PhotosUI/PhotosUI.h>
#import "ZLDefine.h"
#import "ZLPhotoManager.h"
#import "ZLPhotoModel.h"
#import "ZLPhotoBrowser.h"

@interface ZLShowLivePhotoViewController ()

@property (nonatomic, strong) PHLivePhotoView *lpView;

@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *labVideoBytes;
@property (nonatomic, strong) UIButton *btnDone;

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

@end

@implementation ZLShowLivePhotoViewController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserLivePhotoPreviewText];
    //left nav btn
    UIImage *navBackImg = GetImageWithName(@"navBackBtn.png");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self requestLivePhoto];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
}

- (void)btnBack_Click
{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (!vc) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)requestLivePhoto
{
    weakify(self);
    [ZLPhotoManager requestLivePhotoForAsset:self.model.asset completion:^(PHLivePhoto *lv, NSDictionary *info) {
        strongify(weakSelf);
        if (lv) {
            [strongSelf initUI];
            strongSelf.lpView.livePhoto = lv;
            [strongSelf.lpView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    }];
}

- (void)initUI
{
    self.lpView = [[PHLivePhotoView alloc] initWithFrame:self.view.bounds];
    self.lpView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.lpView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, kViewWidth, 44)];
    self.bottomView.backgroundColor = kBottomView_color;
    
    [self.view addSubview:_bottomView];
    
    self.labVideoBytes = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, 80, 30)];
    self.labVideoBytes.font = [UIFont systemFontOfSize:15];
    self.labVideoBytes.textColor = kDoneButton_bgColor;
    [self.bottomView addSubview:self.labVideoBytes];
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDone.frame = CGRectMake(kViewWidth - 82, 7, 70, 30);
    [self.btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    self.btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    [self.btnDone setTitleColor:kDoneButton_textColor forState:UIControlStateNormal];
    [self.btnDone setBackgroundColor:kDoneButton_bgColor];
    [self.btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnDone];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
    
    weakify(self);
    [ZLPhotoManager getPhotosBytesWithArray:@[self.model] completion:^(NSString *photosBytes) {
        strongify(weakSelf);
        strongSelf.labVideoBytes.text = photosBytes;
    }];
    [ZLPhotoManager requestOriginalImageForAsset:self.model.asset completion:^(UIImage *image, NSDictionary *info) {
        if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
        strongify(weakSelf);
        strongSelf.coverImage = image;
    }];
}

- (void)btnDone_Click:(UIButton *)btn
{
    if (self.navigationController) {
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        if (nav.callSelectLivePhotoBlock) {
            nav.callSelectLivePhotoBlock(self.coverImage, self.model.asset);
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tapAction
{
    if (self.bottomView.hidden) {
        [self showNavBarAndBottomView];
    } else {
        [self hideNavBarAndBottomView];
    }
}

- (void)showNavBarAndBottomView
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    CGRect frame = _bottomView.frame;
    frame.origin.y -= frame.size.height;
    _bottomView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.frame = frame;
    }];
}

- (void)hideNavBarAndBottomView
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    CGRect frame = _bottomView.frame;
    frame.origin.y += frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.frame = frame;
    } completion:^(BOOL finished) {
        _bottomView.hidden = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
