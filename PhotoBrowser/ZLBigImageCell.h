//
//  ZLBigImageCell.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

@class ZLPhotoModel;
@class PHAsset;
@class ZLPreviewView;

@interface ZLBigImageCell : UICollectionViewCell


@property (nonatomic, assign) BOOL showGif;
@property (nonatomic, assign) BOOL showLivePhoto;

@property (nonatomic, strong) ZLPreviewView *previewView;
@property (nonatomic, strong) ZLPhotoModel *model;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);
@property (nonatomic, copy)   void (^longPressCallBack)(void);
@property (nonatomic, assign) BOOL willDisplaying;


/**
 界面停止滑动后，加载gif和livephoto，保持界面流畅
 */
- (void)reloadGifLivePhoto;

/**
 界面滑动时，停止播放gif、livephoto、video
 */
- (void)pausePlay;

@end


@class ZLPreviewImageAndGif;
@class ZLPreviewLivePhoto;
@class ZLPreviewVideo;

//预览大图，image、gif、livephoto、video
@interface ZLPreviewView : UIView

@property (nonatomic, assign) BOOL showGif;
@property (nonatomic, assign) BOOL showLivePhoto;

@property (nonatomic, strong) ZLPreviewImageAndGif *imageGifView;
@property (nonatomic, strong) ZLPreviewLivePhoto *livePhotoView;
@property (nonatomic, strong) ZLPreviewVideo *videoView;
@property (nonatomic, strong) ZLPhotoModel *model;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);
@property (nonatomic, copy)   void (^longPressCallBack)(void);

/**
 界面每次即将显示时，重置scrollview缩放状态
 */
- (void)resetScale;

/**
 处理划出界面后操作
 */
- (void)handlerEndDisplaying;

/**
 reload gif,livephoto,video
 */
- (void)reload;

- (void)resumePlay;

- (void)pausePlay;

- (UIImage *)image;

@end


//---------------base preview---------------
@interface ZLBasePreviewView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);

- (void)singleTapAction;

- (void)loadNormalImage:(PHAsset *)asset;

- (void)resetScale;

- (UIImage *)image;

@end

//---------------image与gif---------------
@interface ZLPreviewImageAndGif : ZLBasePreviewView

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, copy)   void (^longPressCallBack)(void);

- (void)loadGifImage:(PHAsset *)asset;
- (void)loadImage:(id)obj;

- (void)resumeGif;
- (void)pauseGif;

@end


//---------------livephoto---------------
@interface ZLPreviewLivePhoto : ZLBasePreviewView

@property (nonatomic, strong) PHLivePhotoView *lpView;

- (void)loadLivePhoto:(PHAsset *)asset;

- (void)stopPlayLivePhoto;

@end


//---------------video---------------
@interface ZLPreviewVideo : ZLBasePreviewView

@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UILabel *icloudLoadFailedLabel;
@property (nonatomic, strong) UIButton *playBtn;

- (BOOL)haveLoadVideo;

- (void)stopPlayVideo;

@end

