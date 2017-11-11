//
//  ZLBigImageCell.m
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLBigImageCell.h"
#import "ZLPhotoManager.h"
#import "ZLDefine.h"
#import <Photos/Photos.h>
#import "ZLPhotoModel.h"
#import "ZLPhotoBrowser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ToastUtils.h"

@interface ZLBigImageCell ()

@end

@implementation ZLBigImageCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (ZLPreviewView *)previewView
{
    if (!_previewView) {
        _previewView = [[ZLPreviewView alloc] initWithFrame:self.bounds];
        _previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _previewView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.previewView];
        zl_weakify(self);
        self.previewView.singleTapCallBack = ^() {
            zl_strongify(weakSelf);
            if (strongSelf.singleTapCallBack) strongSelf.singleTapCallBack();
        };
        self.previewView.longPressCallBack = ^{
            zl_strongify(weakSelf);
            if (strongSelf.longPressCallBack) 
                strongSelf.longPressCallBack();
        };
    }
    return self;
}

- (void)setModel:(ZLPhotoModel *)model
{
    _model = model;
    self.previewView.showGif = self.showGif;
    self.previewView.showLivePhoto = self.showLivePhoto;
    self.previewView.model = model;
}

- (void)resetCellStatus
{
    [self.previewView resetScale];
}

- (void)reloadGifLivePhoto
{
    if (self.willDisplaying) {
        self.willDisplaying = NO;
        [self.previewView reload];
    } else {
        [self.previewView resumePlay];
    }
}

- (void)pausePlay
{
    [self.previewView pausePlay];
}

@end

//!!!!: ZLPreviewView
@implementation ZLPreviewView

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.model.type == ZLAssetMediaTypeImage ||
        self.model.type == ZLAssetMediaTypeGif ||
        (self.model.type == ZLAssetMediaTypeLivePhoto && !self.showLivePhoto) ||
        self.model.type == ZLAssetMediaTypeNetImage) {
        self.imageGifView.frame = self.bounds;
    } else if (self.model.type == ZLAssetMediaTypeLivePhoto) {
        self.livePhotoView.frame = self.bounds;
    } else if (self.model.type == ZLAssetMediaTypeVideo) {
        self.videoView.frame = self.bounds;
    }
}

- (ZLPreviewImageAndGif *)imageGifView
{
    if (!_imageGifView) {
        _imageGifView = [[ZLPreviewImageAndGif alloc] initWithFrame:self.bounds];
        _imageGifView.singleTapCallBack = self.singleTapCallBack;
        _imageGifView.longPressCallBack = self.longPressCallBack;
    }
    return _imageGifView;
}

- (ZLPreviewLivePhoto *)livePhotoView
{
    if (!_livePhotoView) {
        _livePhotoView = [[ZLPreviewLivePhoto alloc] initWithFrame:self.bounds];
        _livePhotoView.singleTapCallBack = self.singleTapCallBack;
    }
    return _livePhotoView;
}

- (ZLPreviewVideo *)videoView
{
    if (!_videoView) {
        _videoView = [[ZLPreviewVideo alloc] initWithFrame:self.bounds];
        _videoView.singleTapCallBack = self.singleTapCallBack;
    }
    return _videoView;
}

- (void)setModel:(ZLPhotoModel *)model
{
    _model = model;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    switch (model.type) {
        case ZLAssetMediaTypeImage: {
            [self addSubview:self.imageGifView];
            [self.imageGifView loadNormalImage:model.asset];
        }
            break;
        case ZLAssetMediaTypeGif: {
            [self addSubview:self.imageGifView];
            [self.imageGifView loadNormalImage:model.asset];
        }
            break;
        case ZLAssetMediaTypeLivePhoto: {
            if (self.showLivePhoto) {
                [self addSubview:self.livePhotoView];
                [self.livePhotoView loadNormalImage:model.asset];
            } else {
                [self addSubview:self.imageGifView];
                [self.imageGifView loadNormalImage:model.asset];
            }
        }
            break;
        case ZLAssetMediaTypeVideo: {
            [self addSubview:self.videoView];
            [self.videoView loadNormalImage:model.asset];
        }
            break;
        case ZLAssetMediaTypeNetImage: {
            [self addSubview:self.imageGifView];
            [self.imageGifView loadImage:model.image?:model.url];
        }
            break;
            
        default:
            break;
    }
}

- (void)reload
{
    if (self.showGif &&
        self.model.type == ZLAssetMediaTypeGif) {
        [self.imageGifView loadGifImage:self.model.asset];
    } else if (self.showLivePhoto &&
               self.model.type == ZLAssetMediaTypeLivePhoto) {
        [self.livePhotoView loadLivePhoto:self.model.asset];
    }
}

- (void)resumePlay
{
    if (self.model.type == ZLAssetMediaTypeGif) {
        [self.imageGifView resumeGif];
    }
}

- (void)pausePlay
{
    if (self.model.type == ZLAssetMediaTypeGif) {
        [self.imageGifView pauseGif];
    } else if (self.model.type == ZLAssetMediaTypeLivePhoto) {
        [self.livePhotoView stopPlayLivePhoto];
    } else if (self.model.type == ZLAssetMediaTypeVideo) {
        [self.videoView stopPlayVideo];
    }
}

- (void)handlerEndDisplaying
{
    if (self.model.type == ZLAssetMediaTypeGif) {
        if ([self.imageGifView.imageView.image isKindOfClass:NSClassFromString(@"_UIAnimatedImage")]) {
            [self.imageGifView loadNormalImage:self.model.asset];
        }
    } else if (self.model.type == ZLAssetMediaTypeVideo) {
        if ([self.videoView haveLoadVideo]) {
            [self.videoView loadNormalImage:self.model.asset];
        }
    }
}

- (void)resetScale
{
    [self.imageGifView resetScale];
}

- (UIImage *)image
{
    if (self.model.type == ZLAssetMediaTypeImage ||
        self.model.type == ZLAssetMediaTypeNetImage) {
        return self.imageGifView.imageView.image;
    }
    return nil;
}

@end

//!!!!: ZLBasePreviewView
@implementation ZLBasePreviewView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicator.center = self.center;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = self.center;
    }
    return _indicator;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        [self addGestureRecognizer:self.singleTap];
    }
    return self;
}

- (void)singleTapAction
{
    if (self.singleTapCallBack) self.singleTapCallBack();
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)loadNormalImage:(PHAsset *)asset
{
    //子类重写
}

- (void)resetScale
{
    //子类重写
}

@end


//!!!!: ZLPreviewImageAndGif
@interface ZLPreviewImageAndGif () <UIScrollViewDelegate>
{
    BOOL _loadOK;
}
@end

@implementation ZLPreviewImageAndGif

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    [self.scrollView setZoomScale:1.0];
    if (_loadOK) {
        [self resetSubviewSize:self.asset?:self.imageView.image];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.imageView];
    [self addSubview:self.indicator];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [self.singleTap requireGestureRecognizerToFail:doubleTap];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.bounds;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
//        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
    }
    return _scrollView;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (void)resetScale
{
    self.scrollView.zoomScale = 1;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)resumeGif
{
    CALayer *layer = self.imageView.layer;
    if (layer.speed != 0) return;
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)pauseGif
{
    CALayer *layer = self.imageView.layer;
    if (layer.speed == .0) return;
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (void)loadGifImage:(PHAsset *)asset
{
    [self.indicator startAnimating];
    zl_weakify(self);
    
    [ZLPhotoManager requestOriginalImageDataForAsset:asset completion:^(NSData *data, NSDictionary *info) {
        zl_strongify(weakSelf);
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            strongSelf.imageView.image = [ZLPhotoManager transformToGifImageWithData:data];
            [strongSelf resumeGif];
            [strongSelf resetSubviewSize:asset];
            [strongSelf.indicator stopAnimating];
        }
    }];
}

- (void)loadNormalImage:(PHAsset *)asset
{
    if (self.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.asset = asset;
    
    [self.indicator startAnimating];
    CGFloat scale = 2;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    zl_weakify(self);
    self.imageRequestID = [ZLPhotoManager requestImageForAsset:asset size:size completion:^(UIImage *image, NSDictionary *info) {
        zl_strongify(weakSelf);
        strongSelf.imageView.image = image;
        [strongSelf resetSubviewSize:asset];
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [strongSelf.indicator stopAnimating];
            strongSelf->_loadOK = YES;
        }
    }];
}

/**
 @param obj UIImage/NSURL
 */
- (void)loadImage:(id)obj
{
    if (!_longPressGesture) {
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        self.longPressGesture.minimumPressDuration = .5;
        [self addGestureRecognizer:self.longPressGesture];
    }
    if ([obj isKindOfClass:UIImage.class]) {
        self.imageView.image = obj;
        [self resetSubviewSize:obj];
    } else {
        [self.indicator startAnimating];
        zl_weakify(self);
        [self.imageView sd_setImageWithURL:obj placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            zl_strongify(weakSelf);
            [strongSelf.indicator stopAnimating];
            if (error) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserLoadNetImageFailed));
            } else {
                strongSelf->_loadOK = YES;
                [strongSelf resetSubviewSize:image];
            }
        }];
    }
}

- (void)resetSubviewSize:(id)obj
{
    CGRect frame;
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    CGFloat w, h;
    if ([obj isKindOfClass:PHAsset.class]) {
        w = [(PHAsset *)obj pixelWidth];
        h = [(PHAsset *)obj pixelHeight];
    } else {
        w = ((UIImage *)obj).size.width;
        h = ((UIImage *)obj).size.height;
    }
    
    CGFloat width = MIN(kViewWidth, w);
    BOOL orientationIsUpOrDown = YES;
    if (isLandscape) {
        orientationIsUpOrDown = NO;
        CGFloat height = MIN(GetViewHeight(self), h);
        frame.origin = CGPointZero;
        frame.size.height = height;
        UIImage *image = self.imageView.image;

        CGFloat imageScale = image.size.width/image.size.height;
        CGFloat screenScale = kViewWidth/GetViewHeight(self);

        if (imageScale > screenScale) {
            frame.size.width = floorf(height * imageScale);
            if (frame.size.width > kViewWidth) {
                frame.size.width = kViewWidth;
                frame.size.height = kViewWidth / imageScale;
            }
        } else {
            CGFloat width = floorf(height * imageScale);
            if (width < 1 || isnan(width)) {
                //iCloud图片height为NaN
                width = GetViewWidth(self);
            }
            frame.size.width = width;
        }
    } else {
        frame.origin = CGPointZero;
        frame.size.width = width;
        UIImage *image = self.imageView.image;
        
        CGFloat imageScale = image.size.height/image.size.width;
        CGFloat screenScale = GetViewHeight(self)/kViewWidth;
        
        if (imageScale > screenScale) {
            frame.size.height = floorf(width * imageScale);
        } else {
            CGFloat height = floorf(width * imageScale);
            if (height < 1 || isnan(height)) {
                //iCloud图片height为NaN
                height = GetViewHeight(self);
            }
            frame.size.height = height;
        }
    }
    
    self.containerView.frame = frame;
    
    
    CGSize contentSize;
    if (orientationIsUpOrDown) {
        contentSize = CGSizeMake(width, MAX(GetViewHeight(self), frame.size.height));
        if (frame.size.height < GetViewHeight(self)) {
            self.containerView.center = CGPointMake(GetViewWidth(self)/2, GetViewHeight(self)/2);
        } else {
            self.containerView.frame = (CGRect){CGPointMake((GetViewWidth(self)-frame.size.width)/2, 0), frame.size};
        }
    } else {
        contentSize = frame.size;
        if (frame.size.width < GetViewWidth(self) ||
            frame.size.height < GetViewHeight(self)) {
            self.containerView.center = CGPointMake(GetViewWidth(self)/2, GetViewHeight(self)/2);
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollView.contentSize = contentSize;
        
        self.imageView.frame = self.containerView.bounds;
        
        [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    });
}

#pragma mark - 手势点击事件
- (void)longPressAction:(UILongPressGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateBegan) {
        if (self.longPressCallBack) {
            self.longPressCallBack();
        }
    }
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap
{
    UIScrollView *scrollView = self.scrollView;
    
    CGFloat scale = 1;
    if (scrollView.zoomScale != 3.0) {
        scale = 3;
    } else {
        scale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:[tap locationInView:tap.view]];
    [scrollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return scrollView.subviews[0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (GetViewWidth(scrollView) > scrollView.contentSize.width) ? (GetViewWidth(scrollView) - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (GetViewHeight(scrollView) > scrollView.contentSize.height) ? (GetViewHeight(scrollView) - scrollView.contentSize.height) * 0.5 : 0.0;
    self.containerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resumeGif];
}

@end



//!!!!: ZLPreviewLivePhoto
@implementation ZLPreviewLivePhoto

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    _lpView.frame = self.bounds;
}

- (PHLivePhotoView *)lpView
{
    if (!_lpView) {
        _lpView = [[PHLivePhotoView alloc] initWithFrame:self.bounds];
        _lpView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_lpView];
    }
    return _lpView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.imageView];
    [self addSubview:self.lpView];
    [self addSubview:self.indicator];
}

- (void)loadNormalImage:(PHAsset *)asset
{
    if (self.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.asset = asset;
    
    if (_lpView) {
        [_lpView removeFromSuperview];
        _lpView = nil;
    }
    
    [self.indicator startAnimating];
    CGFloat scale = 2;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    zl_weakify(self);
    self.imageRequestID = [ZLPhotoManager requestImageForAsset:asset size:size completion:^(UIImage *image, NSDictionary *info) {
        zl_strongify(weakSelf);
        strongSelf.imageView.image = image;
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [strongSelf.indicator stopAnimating];
        }
    }];
}

- (void)loadLivePhoto:(PHAsset *)asset
{
    zl_weakify(self);
    [ZLPhotoManager requestLivePhotoForAsset:asset completion:^(PHLivePhoto *lv, NSDictionary *info) {
        zl_strongify(weakSelf);
        if (lv) {
            strongSelf.lpView.livePhoto = lv;
            [strongSelf.lpView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    }];
}

- (void)stopPlayLivePhoto
{
    [self.lpView stopPlayback];
}

@end


//!!!!: ZLPreviewVideo
@implementation ZLPreviewVideo

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    _playLayer.frame = self.bounds;
    self.playBtn.center = self.center;
}

- (AVPlayerLayer *)playLayer
{
    if (!_playLayer) {
        _playLayer = [[AVPlayerLayer alloc] init];
        _playLayer.frame = self.bounds;
    }
    return _playLayer;
}

- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setBackgroundImage:GetImageWithName(@"playVideo") forState:UIControlStateNormal];
        _playBtn.frame = CGRectMake(0, 0, 80, 80);
        _playBtn.center = self.center;
        [_playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [self bringSubviewToFront:_playBtn];
    return _playBtn;
}

- (UILabel *)icloudLoadFailedLabel
{
    if (!_icloudLoadFailedLabel) {
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
        _icloudLoadFailedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 70, 200, 35)];
        _icloudLoadFailedLabel.font = [UIFont systemFontOfSize:12];
        _icloudLoadFailedLabel.attributedText = str;
        _icloudLoadFailedLabel.textColor = [UIColor whiteColor];
        [self addSubview:_icloudLoadFailedLabel];
    }
    return _icloudLoadFailedLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.imageView];
    [self addSubview:self.playBtn];
    [self addSubview:self.indicator];
}

- (void)loadNormalImage:(PHAsset *)asset
{
    if (self.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.asset = asset;
    
    if (_playLayer) {
        _playLayer.player = nil;
        [_playLayer removeFromSuperlayer];
        _playLayer = nil;
    }
    
    self.imageView.image = nil;
    
    if (![ZLPhotoManager judgeAssetisInLocalAblum:asset]) {
        [self initVideoLoadFailedFromiCloudUI];
        return;
    }
    
    self.playBtn.enabled = YES;
    self.icloudLoadFailedLabel.hidden = YES;
    self.imageView.hidden = NO;
    
    [self.indicator startAnimating];
    CGFloat scale = 2;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    zl_weakify(self);
    self.imageRequestID = [ZLPhotoManager requestImageForAsset:asset size:size completion:^(UIImage *image, NSDictionary *info) {
        zl_strongify(weakSelf);
        strongSelf.imageView.image = image;
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [strongSelf.indicator stopAnimating];
        }
    }];
}

- (void)initVideoLoadFailedFromiCloudUI
{
    self.icloudLoadFailedLabel.hidden = NO;
    self.playBtn.enabled = NO;
}

- (BOOL)haveLoadVideo
{
    return _playLayer ? YES : NO;
}

- (void)stopPlayVideo
{
    if (!_playLayer) {
        return;
    }
    AVPlayer *player = self.playLayer.player;
    
    if (player.rate != .0) {
        [player pause];
        self.playBtn.hidden = NO;
    }
}

- (void)singleTapAction
{
    [super singleTapAction];
    
    if (!_playLayer) {
        zl_weakify(self);
        [ZLPhotoManager requestVideoForAsset:self.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                zl_strongify(weakSelf);
                if (!item) {
                    [strongSelf initVideoLoadFailedFromiCloudUI];
                    return;
                }
                AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
                [strongSelf.layer addSublayer:strongSelf.playLayer];
                strongSelf.playLayer.player = player;
                [strongSelf switchVideoStatus];
                [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
            });
        }];
    } else {
        [self switchVideoStatus];
    }
}

- (void)playBtnClick
{
    [self singleTapAction];
}

- (void)switchVideoStatus
{
    AVPlayer *player = self.playLayer.player;
    CMTime stop = player.currentItem.currentTime;
    CMTime duration = player.currentItem.duration;
    if (player.rate == .0) {
        self.playBtn.hidden = YES;
        if (stop.value == duration.value) {
            [player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [player play];
    } else {
        self.playBtn.hidden = NO;
        [player pause];
    }
}

- (void)playFinished:(AVPlayerItem *)item
{
    [super singleTapAction];
    self.playBtn.hidden = NO;
    self.imageView.hidden = NO;
    [self.playLayer.player seekToTime:kCMTimeZero];
}

@end

