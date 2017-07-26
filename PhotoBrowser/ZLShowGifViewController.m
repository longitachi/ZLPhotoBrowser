//
//  ZLShowGifViewController.m
//  ZLPhotoBrowser
//
//  Created by long on 17/4/19.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLShowGifViewController.h"
#import "ZLDefine.h"
#import "ZLPhotoModel.h"
#import "ZLBigImageCell.h"
#import "ZLPhotoBrowser.h"
#import "ZLPhotoManager.h"
#import "ToastUtils.h"

@interface ZLShowGifViewController ()

@property (nonatomic, strong) ZLPreviewImageAndGif *bigImageView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *labPhotosBytes;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

@end

@implementation ZLShowGifViewController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
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

- (void)initUI
{
    self.title = [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserGifPreviewText];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    //left nav btn
    UIImage *navBackImg = GetImageWithName(@"navBackBtn.png");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    self.bigImageView = [[ZLPreviewImageAndGif alloc] initWithFrame:self.view.bounds];
    weakify(self);
    self.bigImageView.singleTapCallBack = ^() {
        strongify(weakSelf);
        if (strongSelf.bottomView.hidden) {
            [strongSelf showNavBarAndBottomView];
        } else {
            [strongSelf hideNavBarAndBottomView];
        }
    };
    [self.bigImageView loadGifImage:self.model.asset];
    [self.view addSubview:self.bigImageView];
    
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, kViewWidth, 44)];
    self.bottomView.backgroundColor = kBottomView_color;
    [self.view addSubview:_bottomView];
    
    self.labPhotosBytes = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, 80, 30)];
    self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
    self.labPhotosBytes.textColor = kDoneButton_bgColor;
    [self.bottomView addSubview:self.labPhotosBytes];
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDone.frame = CGRectMake(kViewWidth - 82, 7, 70, 30);
    [self.btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    self.btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnDone setBackgroundColor:kDoneButton_bgColor];
    [self.btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnDone];
    
    [ZLPhotoManager getPhotosBytesWithArray:@[self.model] completion:^(NSString *photosBytes) {
        strongify(weakSelf);
        strongSelf.labPhotosBytes.text = photosBytes;
    }];
}

- (void)btnBack_Click
{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (!vc) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

- (void)btnDone_Click:(UIButton *)btn
{
    if (!self.bigImageView.image) {
        ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserLoadingText));
        return;
    }
    if (self.navigationController) {
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        if (nav.callSelectGifBlock) {
            nav.callSelectGifBlock(self.bigImageView.image, self.model.asset);
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
