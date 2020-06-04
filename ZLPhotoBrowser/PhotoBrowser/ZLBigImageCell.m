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
#import "ZLAlbumListController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImage+Metadata.h>
#import "ToastUtils.h"
#import "ZLProgressView.h"
#import "ZLVideoPlayerControl.h"

@interface ZLBigImageCell ()

@end

@implementation ZLBigImageCell

- (void)dealloc
{
    ZLLoggerDebug(@"---- ZLBigImageCell dealloc");
}

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
        @zl_weakify(self);
        self.previewView.singleTapCallBack = ^() {
            @zl_strongify(self);
            if (self.singleTapCallBack) self.singleTapCallBack();
        };
        self.previewView.longPressCallBack = ^{
            @zl_strongify(self);
            if (self.longPressCallBack)
                self.longPressCallBack();
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

- (void)reloadGifLivePhotoVideo
{
    if (self.willDisplaying) {
        self.willDisplaying = NO;
        [self.previewView reload];
    } else {
        [self.previewView resumePlay];
    }
}

@end

//!!!!: ZLPreviewView
@implementation ZLPreviewView

- (void)dealloc
{
    ZLLoggerDebug(@"---- ZLPreviewView dealloc");
}

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
    } else if (self.model.type == ZLAssetMediaTypeNetVideo) {
        self.netVideoView.frame = self.bounds;
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

- (ZLPreviewLivePhoto *)livePhotoView API_AVAILABLE(ios(9.1)){
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

- (ZLPreviewNetVideo *)netVideoView
{
    if (!_netVideoView) {
        _netVideoView = [[ZLPreviewNetVideo alloc] initWithFrame:self.bounds];
        _netVideoView.singleTapCallBack = self.singleTapCallBack;
    }
    return _netVideoView;
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
            BOOL showLivePhoto = NO;
            if (@available(iOS 9.1, *)) {
                if (self.showLivePhoto) {
                    showLivePhoto = YES;
                }
            }
            if (showLivePhoto) {
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
        case ZLAssetMediaTypeNetVideo: {
            [self addSubview:self.netVideoView];
            [self.netVideoView loadNetVideo:model.url];
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
    } else if (self.model.type == ZLAssetMediaTypeVideo) {
        // 暂时不用这种界面停止滑动在加载视频的方法，因为未解决 force touch 预览视频进入界面后直接加载视频和gif的情况
//        [self.videoView loadVideo:self.model.asset];
    }
}

- (void)resumePlay
{
    if (self.model.type == ZLAssetMediaTypeGif ||
        self.model.type == ZLAssetMediaTypeNetImage) {
        [self.imageGifView resumeGif];
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
    } else if (self.model.type == ZLAssetMediaTypeNetVideo) {
        [self.netVideoView seekToZero];
    }
}

- (void)resetScale
{
    if (self.model.type == ZLAssetMediaTypeImage ||
        self.model.type == ZLAssetMediaTypeGif ||
        self.model.type == ZLAssetMediaTypeNetImage) {
        [self.imageGifView resetScale];
    }
}

- (UIImage *)image
{
    if (self.model.type == ZLAssetMediaTypeImage ||
        self.model.type == ZLAssetMediaTypeGif ||
        self.model.type == ZLAssetMediaTypeNetImage) {
        return self.imageGifView.imageView.image;
    }
    return nil;
}

@end

//!!!!: ZLBasePreviewView
@implementation ZLBasePreviewView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = 40;
    CGFloat x = (GetViewWidth(self) - width) / 2;
    CGFloat y = (GetViewHeight(self) - width) / 2;
    self.indicator.frame = CGRectMake(x, y, width, width);
}

- (ZLProgressView *)indicator
{
    if (!_indicator) {
        _indicator = [[ZLProgressView alloc] init];
        _indicator.hidden = YES;
    }
    return _indicator;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[SDAnimatedImageView alloc] init];
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
        
        [self placeSubviews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerScrollViewDidScroll) name:@"controllerScrollViewDidScroll" object:nil];
    }
    return self;
}

- (void)placeSubviews
{
    
}

- (void)controllerScrollViewDidScroll
{
    
}

- (CGSize)requestImageSize:(PHAsset *)asset
{
    CGFloat scale = 2;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    return size;
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
    self.imageView.image = nil;
    
    if (self.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
}

- (void)resetScale
{
    //子类重写
}

@end


//!!!!: ZLPreviewImageAndGif
@interface ZLPreviewImageAndGif () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL isGif;

@end

@implementation ZLPreviewImageAndGif {
    __weak id<SDWebImageOperation> _combineOperation;
}

- (void)dealloc
{
    [self cancelCurrentImageLoad];
    ZLLoggerDebug(@"---- ZLPreviewImageAndGif dealloc");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    [self resetScale];
    if (self.loadOK) {
        [self resetSubviewSize:self.asset?:self.imageView.image];
    }
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

- (void)placeSubviews
{
    [super placeSubviews];
    
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.imageView];
    [self addSubview:self.indicator];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [self.singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)controllerScrollViewDidScroll
{
    [self pauseGif];
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
    [self.imageView startAnimating];
}

- (void)pauseGif
{
    [self.imageView stopAnimating];
}

- (void)loadGifImage:(PHAsset *)asset
{
    @zl_weakify(self);
    
    [ZLPhotoManager requestOriginalImageDataForAsset:asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        @zl_strongify(self);
        self.indicator.progress = progress;
        if (progress >= 1) {
            self.indicator.hidden = YES;
        } else {
            self.indicator.hidden = NO;
        }
    } completion:^(NSData *data, NSDictionary *info) {
        @zl_strongify(self);
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            self.indicator.hidden = YES;
            self.imageView.image = [SDAnimatedImage imageWithData:data];
            [self resetSubviewSize:asset];
        }
    }];
}

- (void)loadNormalImage:(PHAsset *)asset
{
    [super loadNormalImage:asset];
    
    self.asset = asset;
    
    @zl_weakify(self);
    self.imageRequestID = [ZLPhotoManager requestImageForAsset:asset size:[self requestImageSize:asset] progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        @zl_strongify(self);
        self.indicator.progress = progress;
        if (progress >= 1) {
            self.indicator.hidden = YES;
        } else {
            self.indicator.hidden = NO;
        }
    } completion:^(UIImage *image, NSDictionary *info) {
        @zl_strongify(self);
        self.imageView.image = image;
        [self resetSubviewSize:asset];
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            self.indicator.hidden = YES;
            self.loadOK = YES;
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
        @zl_weakify(self);
        [self cancelCurrentImageLoad];
        self.imageView.image = nil;
        _combineOperation = [SDWebImageManager.sharedManager loadImageWithURL:obj options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            @zl_strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = (float)receivedSize / (float)expectedSize;
                self.indicator.progress = progress;
                if (progress >= 1) {
                    self.indicator.hidden = YES;
                } else {
                    self.indicator.hidden = NO;
                }
            });
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            @zl_strongify(self);
            self.indicator.hidden = YES;
            if (error) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserLoadNetImageFailed));
            } else {
                self.imageView.image = image;
                self.loadOK = YES;
                [self resetSubviewSize:image];
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
    
    if (isLandscape) {
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
    if (!isLandscape) {
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

- (void)cancelCurrentImageLoad {
    if (_combineOperation && [_combineOperation conformsToProtocol:@protocol(SDWebImageOperation)]) {
        [_combineOperation cancel];
    }
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

- (void)placeSubviews
{
    [super placeSubviews];
    
    [self addSubview:self.imageView];
    [self addSubview:self.lpView];
    [self addSubview:self.indicator];
}

- (void)controllerScrollViewDidScroll
{
    [self.lpView stopPlayback];
}

- (void)loadNormalImage:(PHAsset *)asset
{
    [super loadNormalImage:asset];
    
    self.asset = asset;
    
    if (_lpView) {
        [_lpView removeFromSuperview];
        _lpView = nil;
    }
    
    @zl_weakify(self);
    self.imageRequestID = [ZLPhotoManager requestImageForAsset:asset size:[self requestImageSize:asset] progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        @zl_strongify(self);
        self.indicator.progress = progress;
        if (progress >= 1) {
            self.indicator.hidden = YES;
        } else {
            self.indicator.hidden = NO;
        }
    } completion:^(UIImage *image, NSDictionary *info) {
        @zl_strongify(self);
        self.imageView.image = image;
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            self.indicator.hidden = YES;
        }
    }];
}

- (void)loadLivePhoto:(PHAsset *)asset
{
    @zl_weakify(self);
    [ZLPhotoManager requestLivePhotoForAsset:asset completion:^(PHLivePhoto *lv, NSDictionary *info) {
        @zl_strongify(self);
        if (lv) {
            self.lpView.livePhoto = lv;
            [self.lpView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    }];
}

@end


//!!!!: ZLPreviewVideo
@implementation ZLPreviewVideo

- (void)dealloc
{
    [self stopPlayVideo];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    _playLayer.frame = self.bounds;
    _playBtn.frame = CGRectMake(0, 64, GetViewWidth(self), GetViewHeight(self) - 64 - 44);
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
        [_playBtn setImage:GetImageWithName(@"zl_playVideo") forState:UIControlStateNormal];
        _playBtn.frame = CGRectMake(0, 64, GetViewWidth(self), GetViewHeight(self) - 64 - 44);
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
        attach.image = GetImageWithName(@"zl_videoLoadFailed");
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

- (void)placeSubviews
{
    [super placeSubviews];
    
    [self addSubview:self.imageView];
    [self addSubview:self.indicator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)controllerScrollViewDidScroll
{
    if (_playLayer.player && _playLayer.player.rate != 0) {
        [self playBtnClick];
    }
}

- (void)appDidEnterBackground:(NSNotification *)notify
{
    if (_playLayer.player && _playLayer.player.rate != 0) {
        [self playBtnClick];
    }
}

- (void)loadNormalImage:(PHAsset *)asset
{
    [super loadNormalImage:asset];
    
    self.asset = asset;
    
    if (_playLayer) {
        _playLayer.player = nil;
        [_playLayer removeFromSuperlayer];
        _playLayer = nil;
    }
    
    self.imageView.image = nil;
    
//    if (![ZLPhotoManager judgeAssetisInLocalAblum:asset]) {
//        [self initVideoLoadFailedFromiCloudUI];
//        return;
//    }
    
    self.playBtn.userInteractionEnabled = YES;
    self.icloudLoadFailedLabel.hidden = YES;
    self.imageView.hidden = NO;
    
    @zl_weakify(self);
    self.imageRequestID = [ZLPhotoManager requestImageForAsset:asset size:[self requestImageSize:asset] progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        @zl_strongify(self);
        self.imageView.image = image;
    }];
    [self loadVideo:asset];
}

- (void)loadVideo:(PHAsset *)asset
{
    @zl_weakify(self);
    [ZLPhotoManager requestVideoForAsset:asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        @zl_strongify(self);
        self.indicator.progress = progress;
        if (progress >= 1) {
            self.indicator.hidden = YES;
        } else {
            self.indicator.hidden = NO;
        }
    } completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @zl_strongify(self);
//            if (!item) {
//                [strongSelf initVideoLoadFailedFromiCloudUI];
//                return;
//            }
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            [self.layer addSublayer:self.playLayer];
            self.playLayer.player = player;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
            [self addSubview:self.playBtn];
        });
    }];
}

- (void)initVideoLoadFailedFromiCloudUI
{
    self.icloudLoadFailedLabel.hidden = NO;
    self.playBtn.userInteractionEnabled = NO;
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
        [self.playBtn setImage:GetImageWithName(@"zl_playVideo") forState:UIControlStateNormal];
    }
}

- (void)playBtnClick
{
    [super singleTapAction];
    [self switchVideoStatus];
}

- (void)switchVideoStatus
{
    AVPlayer *player = self.playLayer.player;
    CMTime stop = player.currentItem.currentTime;
    CMTime duration = player.currentItem.duration;
    if (player.rate == .0) {
        [self.playBtn setImage:nil forState:UIControlStateNormal];
        if (stop.value == duration.value) {
            [player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [player play];
    } else {
        [self.playBtn setImage:GetImageWithName(@"zl_playVideo") forState:UIControlStateNormal];
        [player pause];
    }
}

- (void)playFinished:(AVPlayerItem *)item
{
    [super singleTapAction];
    [self.playBtn setImage:GetImageWithName(@"zl_playVideo") forState:UIControlStateNormal];
    self.imageView.hidden = NO;
    [self.playLayer.player seekToTime:kCMTimeZero];
}

@end


//!!!!: ZLPreviewNetVideo
@implementation ZLPreviewNetVideo
{
    id _playerTimeObserver;
    BOOL _isDragingProgress;
}

- (void)dealloc
{
    ZLLoggerDebug(@"---- ZLPreviewNetVideo dealloc");
    if (_playerTimeObserver) {
        [self.playLayer.player removeTimeObserver:_playerTimeObserver];
        _playerTimeObserver = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObeserverOnPlayerItem];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _playLayer.frame = self.bounds;
    _playBtn.frame = CGRectMake(0, 64, GetViewWidth(self), GetViewHeight(self) - 64 - 44);
    _playControl.frame = CGRectMake(0, GetViewHeight(self) - ZL_SafeAreaBottom() - 80, GetViewWidth(self), 80);
}

- (void)controllerScrollViewDidScroll
{
    if (_playLayer.player && _playLayer.player.rate != 0) {
        [self playBtnClick];
    } else if (self.playControl.isHidden == NO) {
        [self.playBtn setImage:GetImageWithName(@"zl_playVideo") forState:UIControlStateNormal];
        [self changePlayControlPlayStatus:NO];
        [super singleTapAction];
    }
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
        [_playBtn setImage:GetImageWithName(@"zl_playVideo") forState:UIControlStateNormal];
        _playBtn.frame = CGRectMake(0, 64, GetViewWidth(self), GetViewHeight(self) - 64 - 44);
        [_playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (ZLVideoPlayerControl *)playControl
{
    if (!_playControl) {
        _playControl = [[ZLVideoPlayerControl alloc] init];
        _playControl.frame = CGRectMake(0, GetViewHeight(self) - ZL_SafeAreaBottom() - 80, GetViewWidth(self), 80);
        
        @zl_weakify(self);
        _playControl.playActionBlock = ^(BOOL isPlaying) {
            @zl_strongify(self);
            if (isPlaying) {
                [self.playLayer.player pause];
            } else {
                [self.playLayer.player play];
            }
            self.playControl.playing = !isPlaying;
        };
        
        _playControl.sliderValueChangedBlock = ^(CGFloat value, BOOL endChange) {
            @zl_strongify(self);
            self->_isDragingProgress = !endChange;
            AVPlayerItem *item = self.playLayer.player.currentItem;
            if (!item) {
                return;
            }
            CGFloat duration = CMTimeGetSeconds(item.duration);
            [self.playLayer.player seekToTime:CMTimeMakeWithSeconds(value * duration, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                
            }];
        };
    }
    return _playControl;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    [self.layer addSublayer:self.playLayer];
    [self addSubview:self.playBtn];
    [self addSubview:self.playControl];
    [self addSubview:self.indicator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)appDidEnterBackground:(NSNotification *)notify
{
    if (_playLayer.player && _playLayer.player.rate != 0) {
        [self playBtnClick];
    }
}

- (void)loadNetVideo:(NSURL *)url
{
    [self clearPreviousItem];
    self.playControl.hidden = YES;
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = self.playLayer.player;
    
    if (!player) {
        player = [AVPlayer playerWithPlayerItem:item];
        self.playLayer.player = player;
    } else {
        [player replaceCurrentItemWithPlayerItem:item];
    }
    
    if (!_playerTimeObserver) {
        @zl_weakify(self);
        CMTime interval = CMTimeMake(1,30);
        _playerTimeObserver =
        [self.playLayer.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            @zl_strongify(self);
            if (!self->_isDragingProgress) {
                [self.playControl updateProgress:CMTimeGetSeconds(time)/CMTimeGetSeconds(item.duration)];
            }
         }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
//    [player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//    [player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)clearPreviousItem
{
    if (self.playLayer.player.status == AVPlayerStatusReadyToPlay) {
        [self.playLayer.player seekToTime:kCMTimeZero];
        [self.playLayer.player pause];
        
        AVPlayerItem *item = self.playLayer.player.currentItem;
        if (item) {
            // 如果有通知，这里移除通知
            [self removeObeserverOnPlayerItem];
        }
    }
}

- (void)removeObeserverOnPlayerItem
{
    
}

- (void)seekToZero
{
    if (self.playLayer.player.status == AVPlayerStatusReadyToPlay) {
        [self.playLayer.player seekToTime:kCMTimeZero];
        [self changePlayControlPlayStatus:NO];
    }
}

- (void)playBtnClick
{
    [super singleTapAction];
    [self switchVideoStatus];
}

- (void)switchVideoStatus
{
    AVPlayer *player = self.playLayer.player;
    CMTime stop = player.currentItem.currentTime;
    CMTime duration = player.currentItem.duration;
    if (player.rate == .0 && self.playControl.isHidden == YES) {
        [self.playBtn setImage:nil forState:UIControlStateNormal];
        if (stop.value == duration.value) {
            [player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [player play];
        [self changePlayControlPlayStatus:YES];
    } else {
        [self.playBtn setImage:GetImageWithName(@"zl_playVideo") forState:UIControlStateNormal];
//        [self.indicator stopAnimating];
        [player pause];
        [self changePlayControlPlayStatus:NO];
    }
}

- (void)playFinished:(AVPlayerItem *)item
{
    [super singleTapAction];
    [self.playBtn setImage:GetImageWithName(@"zl_playVideo") forState:UIControlStateNormal];
//    [self.indicator stopAnimating];
    [self.playLayer.player seekToTime:kCMTimeZero];
    [self changePlayControlPlayStatus:NO];
}

- (void)changePlayControlPlayStatus:(BOOL)playing
{
    self.playControl.hidden = !playing;
    self.playControl.playing = playing;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //缓冲为空
//        NSLog(@"缓冲为空");
        if (self.playLayer.player.rate != 0.0) {
//            NSLog(@"正在播放，显示等待视图");
//            [self.indicator startAnimating];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        //缓冲好了
//        NSLog(@"缓冲好了");
//        [self.indicator stopAnimating];
    }
}

@end
