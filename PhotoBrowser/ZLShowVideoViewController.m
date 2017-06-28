//
//  ZLShowVideoViewController.m
//  ZLPhotoBrowser
//
//  Created by long on 17/4/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLShowVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZLPhotoModel.h"
#import "ZLDefine.h"
#import "ZLPhotoManager.h"
#import "ZLPhotoBrowser.h"

@interface ZLShowVideoViewController ()

@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *btnDone;

@property (nonatomic, strong) UILabel *icloudLoadFailedLabel;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@end

@implementation ZLShowVideoViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserVideoPreviewText];
    //left nav btn
    UIImage *navBackImg = GetImageWithName(@"navBackBtn.png");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self requestPlayItem];
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

- (void)requestPlayItem
{
    if ([ZLPhotoManager judgeAssetisInLocalAblum:self.model.asset]) {
        weakify(self);
        [ZLPhotoManager requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongify(weakSelf);
                if (!item) {
                    [strongSelf initVideoLoadFailedFromiCloudUI];
                    return;
                }
                [strongSelf initUI];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
                strongSelf.playLayer.player = player;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
            });
        }];
    } else {
        [self initVideoLoadFailedFromiCloudUI];
    }
}

- (void)btnBack_Click
{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (!vc) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)initUI
{
    self.playLayer = [[AVPlayerLayer alloc] init];
    self.playLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playLayer];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, kViewWidth, 44)];
    self.bottomView.backgroundColor = kBottomView_color;
    
    [self.view addSubview:_bottomView];
    
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
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setBackgroundImage:GetImageWithName(@"playVideo") forState:UIControlStateNormal];
    self.playBtn.frame = CGRectMake(0, 0, 80, 80);
    self.playBtn.center = self.view.center;
    [self.playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playBtnClick)];
    [self.view addGestureRecognizer:tap];
    
    weakify(self);
    [ZLPhotoManager requestOriginalImageForAsset:self.model.asset completion:^(UIImage *image, NSDictionary *info) {
        if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
        strongify(weakSelf);
        strongSelf.coverImage = image;
    }];
}

- (void)initVideoLoadFailedFromiCloudUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    //创建图片附件
    NSTextAttachment *attach = [[NSTextAttachment alloc]init];
    attach.image = GetImageWithName(@"videoLoadFailed");
    attach.bounds = CGRectMake(0, -10, 30, 30);
    //创建属性字符串 通过图片附件
    NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:attach];
    //把NSAttributedString添加到NSMutableAttributedString里面
    [str appendAttributedString:attrStr];
    
    NSAttributedString *lastStr = [[NSAttributedString alloc] initWithString:[NSBundle zlLocalizedStringForKey:ZLPhotoBrowseriCloudVideoText]];
    [str appendAttributedString:lastStr];
    self.icloudLoadFailedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 70, 200, 35)];
    self.icloudLoadFailedLabel.font = [UIFont systemFontOfSize:12];
    self.icloudLoadFailedLabel.attributedText = str;
    self.icloudLoadFailedLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.icloudLoadFailedLabel];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setBackgroundImage:GetImageWithName(@"playVideo") forState:UIControlStateNormal];
    self.playBtn.frame = CGRectMake(0, 0, 80, 80);
    self.playBtn.center = self.view.center;
    self.playBtn.enabled = NO;
    [self.view addSubview:self.playBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapAction
{
    if (self.navigationController.navigationBar.hidden) {
        [self showNavBarAndBottomView];
    } else {
        [self hideNavBarAndBottomView];
    }
}

- (void)btnDone_Click:(UIButton *)btn
{
    if (self.navigationController) {
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        if (nav.callSelectVideoBlock) {
            nav.callSelectVideoBlock(self.coverImage, self.model.asset);
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)playBtnClick
{
    AVPlayer *player = self.playLayer.player;
    CMTime stop = player.currentItem.currentTime;
    CMTime duration = player.currentItem.duration;
    if (player.rate == .0) {
        if (stop.value == duration.value) {
            [player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [player play];
        [self hideNavBarAndBottomView];
    } else {
        [player pause];
        [self showNavBarAndBottomView];
    }
}

- (void)playFinished:(AVPlayerItem *)item
{
    [self.playLayer.player seekToTime:kCMTimeZero];
    [self showNavBarAndBottomView];
}

- (void)showNavBarAndBottomView
{
    self.playBtn.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    CGRect frame = _bottomView.frame;
    frame.origin.y -= frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.frame = frame;
    }];
}

- (void)hideNavBarAndBottomView
{
    self.playBtn.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    CGRect frame = _bottomView.frame;
    frame.origin.y += frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.frame = frame;
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
