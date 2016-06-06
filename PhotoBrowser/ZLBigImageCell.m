//
//  ZLBigImageCell.m
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLBigImageCell.h"
#import "ZLPhotoTool.h"
#import "ZLDefine.h"
#import <Photos/Photos.h>

@interface ZLBigImageCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation ZLBigImageCell

- (void)awakeFromNib {
    // Initialization code
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
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        [_scrollView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
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

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = self.contentView.center;
    }
    return _indicator;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.containerView];
        [self.containerView addSubview:self.imageView];
        [self addSubview:self.indicator];
    }
    return self;
}

- (void)setAsset:(PHAsset *)asset
{
    _asset = asset;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    
    [self.indicator startAnimating];
    weakify(self);
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        strongify(weakSelf);
        strongSelf.imageView.image = image;
        [strongSelf resetSubviewSize];
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [strongSelf.indicator stopAnimating];
        }
    }];
}

- (void)resetSubviewSize
{
    CGRect frame;
    frame.origin = CGPointZero;
    
    UIImage *image = self.imageView.image;
    CGFloat imageScale = image.size.height/image.size.width;
    CGFloat screenScale = kViewHeight/kViewWidth;
    if (image.size.width <= GetViewWidth(self) && image.size.height <= GetViewHeight(self)) {
        frame.size.width = image.size.width;
        frame.size.height = image.size.height;
    } else {
        if (imageScale > screenScale) {
            frame.size.height = GetViewHeight(self);
            frame.size.width = GetViewHeight(self)/imageScale;
        } else {
            frame.size.width = GetViewWidth(self);
            frame.size.height = GetViewWidth(self) * imageScale;
        }
    }
    
    self.scrollView.contentSize = frame.size;
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.containerView.frame = frame;
    self.containerView.center = self.scrollView.center;
    self.imageView.frame = self.containerView.bounds;
}

#pragma mark - 手势点击事件
- (void)singleTapAction:(UITapGestureRecognizer *)singleTap
{
    if (self.singleTapCallBack) self.singleTapCallBack();
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap
{
    UIScrollView *scrollView = (UIScrollView *)tap.view;
    
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

@end
