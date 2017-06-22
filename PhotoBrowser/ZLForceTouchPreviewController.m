//
//  ZLForceTouchPreviewController.m
//  ZLPhotoBrowser
//
//  Created by long on 2017/6/20.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLForceTouchPreviewController.h"
#import "ZLDefine.h"
#import "ZLPhotoManager.h"
#import "ZLPhotoModel.h"
#import <PhotosUI/PhotosUI.h>

@interface ZLForceTouchPreviewController ()

@end

@implementation ZLForceTouchPreviewController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
    
    switch (self.model.type) {
        case ZLAssetMediaTypeImage:
            [self loadNormalImage];
            break;
        
        case ZLAssetMediaTypeGif:
            self.allowSelectGif ? [self loadGifImage] : [self loadNormalImage];
            break;
            
        case ZLAssetMediaTypeLivePhoto:
            self.allowSelectLivePhoto ? [self loadLivePhoto] : [self loadNormalImage];
            break;
            
        case ZLAssetMediaTypeVideo:
            [self loadVideo];
            break;
            
        default:
            break;
    }
}

#pragma mark - 加载静态图
- (void)loadNormalImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGSize size = [self getSize];
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [ZLPhotoManager requestImageForAsset:self.model.asset size:CGSizeMake(size.width*2, size.height*2) completion:^(UIImage *img, NSDictionary *info) {
        imageView.image = img;
    }];
}

- (void)loadGifImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [ZLPhotoManager requestOriginalImageDataForAsset:self.model.asset completion:^(NSData *data, NSDictionary *info) {
        imageView.image = [ZLPhotoManager transformToGifImageWithData:data];
    }];
}

- (void)loadLivePhoto
{
    PHLivePhotoView *lpView = [[PHLivePhotoView alloc] init];
    lpView.contentMode = UIViewContentModeScaleAspectFit;
    lpView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:lpView];
    
    [ZLPhotoManager requestLivePhotoForAsset:self.model.asset completion:^(PHLivePhoto *lv, NSDictionary *info) {
        lpView.livePhoto = lv;
        [lpView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    }];
}

- (void)loadVideo
{
    AVPlayerLayer *playLayer = [[AVPlayerLayer alloc] init];
    playLayer.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view.layer addSublayer:playLayer];
    
    [ZLPhotoManager requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            playLayer.player = player;
            [player play];
        });
    }];
}

- (CGSize)getSize
{
    CGFloat w = MIN(self.model.asset.pixelWidth, kViewWidth);
    CGFloat h = w * self.model.asset.pixelHeight / self.model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kViewHeight) {
        h = kViewHeight;
        w = h * self.model.asset.pixelWidth / self.model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
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
