//
//  ZLEditVideoController.m
//  ZLPhotoBrowser
//
//  Created by long on 2017/9/15.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLEditVideoController.h"
#import "ZLDefine.h"
#import "ZLAlbumListController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZLPhotoManager.h"
#import "ZLPhotoModel.h"
#import "ZLProgressHUD.h"
#import "ToastUtils.h"
#import <objc/runtime.h>

#define kItemWidth kItemHeight * 2/3
#define kItemHeight 50

///////-----cell
@interface ZLEditVideoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZLEditVideoCell

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end

@protocol ZLEditFrameViewDelegate <NSObject>

- (void)editViewValidRectChanged;

- (void)editViewValidRectEndChanged;

@end

///////-----编辑框
@interface ZLEditFrameView : UIView
{
    UIImageView *_leftView;
    UIImageView *_rightView;
}

@property (nonatomic, assign) CGRect validRect;
@property (nonatomic, weak) id<ZLEditFrameViewDelegate> delegate;

@end

@implementation ZLEditFrameView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //扩大下有效范围
    CGRect left = _leftView.frame;
    left.origin.x -= kItemWidth/2;
    left.size.width += kItemWidth/2;
    CGRect right = _rightView.frame;
    right.size.width += kItemWidth/2;
    
    if (CGRectContainsPoint(left, point)) {
        return _leftView;
    }
    if (CGRectContainsPoint(right, point)) {
        return _rightView;
    }
    return nil;
}

- (void)setupUI
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    
    _leftView = [[UIImageView alloc] initWithImage:GetImageWithName(@"zl_ic_left")];
    _leftView.userInteractionEnabled = YES;
    _leftView.tag = 0;
    UIPanGestureRecognizer *lg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_leftView addGestureRecognizer:lg];
    [self addSubview:_leftView];
    
    _rightView = [[UIImageView alloc] initWithImage:GetImageWithName(@"zl_ic_right")];
    _rightView.userInteractionEnabled = YES;
    _rightView.tag = 1;
    UIPanGestureRecognizer *rg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_rightView addGestureRecognizer:rg];
    [self addSubview:_rightView];
}

- (void)panAction:(UIGestureRecognizer *)pan
{
    self.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.4].CGColor;
    CGPoint point = [pan locationInView:self];
    
    CGRect rct = self.validRect;
    
    const CGFloat W = GetViewWidth(self);
    CGFloat minX = 0;
    CGFloat maxX = W;
    
    switch (pan.view.tag) {
        case 0: {
            //left
            maxX = rct.origin.x + rct.size.width - kItemWidth;
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width -= (point.x - rct.origin.x);
            rct.origin.x = point.x;
        }
            break;
            
        case 1:
        {
            //right
            minX = rct.origin.x + kItemWidth/2;
            maxX = W - kItemWidth/2;
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width = (point.x - rct.origin.x + kItemWidth/2);
        }
            break;
    }
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            if (self.delegate && [self.delegate respondsToSelector:@selector(editViewValidRectChanged)]) {
                [self.delegate editViewValidRectChanged];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.layer.borderColor = [UIColor clearColor].CGColor;
            if (self.delegate && [self.delegate respondsToSelector:@selector(editViewValidRectEndChanged)]) {
                [self.delegate editViewValidRectEndChanged];
            }
            break;
            
        default:
            break;
    }
    
    
    self.validRect = rct;
}

- (void)setValidRect:(CGRect)validRect
{
    _validRect = validRect;
    _leftView.frame = CGRectMake(validRect.origin.x, 0, kItemWidth/2, kItemHeight);
    _rightView.frame = CGRectMake(validRect.origin.x+validRect.size.width-kItemWidth/2, 0, kItemWidth/2, kItemHeight);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.validRect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    
    CGPoint topPoints[2];
    topPoints[0] = CGPointMake(self.validRect.origin.x, 0);
    topPoints[1] = CGPointMake(self.validRect.origin.x+self.validRect.size.width, 0);
    
    CGPoint bottomPoints[2];
    bottomPoints[0] = CGPointMake(self.validRect.origin.x, kItemHeight);
    bottomPoints[1] = CGPointMake(self.validRect.origin.x+self.validRect.size.width, kItemHeight);
    
    CGContextAddLines(context, topPoints, 2);
    CGContextAddLines(context, bottomPoints, 2);
    
    CGContextDrawPath(context, kCGPathStroke);
}

@end


///////-----editvc
@interface ZLEditVideoController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ZLEditFrameViewDelegate>
{
    UIView *_bottomView;
    UIButton *_cancelBtn;
    UIButton *_doneBtn;
    
    NSTimer *_timer;
    
    //下方collectionview偏移量
    CGFloat _offsetX;
    BOOL _orientationChanged;
    
    UIView *_indicatorLine;
    
    AVAsset *_avAsset;
    
    NSTimeInterval _interval;
    
    NSInteger _measureCount;
    NSOperationQueue *_queue;
    NSMutableDictionary<NSString *, UIImage *> *_imageCache;
    NSMutableDictionary<NSString *, NSBlockOperation *> *_opCache;
}

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZLEditFrameView *editView;
@property (nonatomic, strong) AVAssetImageGenerator *generator;

@end

@implementation ZLEditVideoController

- (void)dealloc
{
    [_queue cancelAllOperations];
    [self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (AVAssetImageGenerator *)generator
{
    if (!_generator) {
        _generator = [[AVAssetImageGenerator alloc] initWithAsset:_avAsset];
        _generator.maximumSize = CGSizeMake(kItemWidth*4, kItemHeight*4);
        _generator.appliesPreferredTrackTransform = YES;
        _generator.requestedTimeToleranceBefore = kCMTimeZero;
        _generator.requestedTimeToleranceAfter = kCMTimeZero;
        _generator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture;
    }
    return _generator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self analysisAssetImages];
    
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 3;
    
    _imageCache = [NSMutableDictionary dictionary];
    _opCache = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    
    self.playerLayer.frame = CGRectMake(15, inset.top>0?inset.top:30, kViewWidth-30, kViewHeight-160-inset.bottom);
    
    self.editView.frame = CGRectMake((kViewWidth-kItemWidth*10)/2, kViewHeight-100-inset.bottom, kItemWidth*10, kItemHeight);
    self.editView.validRect = self.editView.bounds;
    self.collectionView.frame = CGRectMake(inset.left, kViewHeight-100-inset.bottom, kViewWidth-inset.left-inset.right, kItemHeight);
    
    CGFloat leftOffset = ((kViewWidth-kItemWidth*10)/2-inset.left);
    CGFloat rightOffset = ((kViewWidth-kItemWidth*10)/2-inset.right);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, leftOffset, 0, rightOffset)];
    [self.collectionView setContentOffset:CGPointMake(_offsetX-leftOffset, 0)];
    
    CGFloat bottomViewH = 44;
    CGFloat bottomBtnH = 30;
    _bottomView.frame = CGRectMake(0, kViewHeight-bottomViewH-inset.bottom, kViewWidth, kItemHeight);
    _cancelBtn.frame = CGRectMake(10+inset.left, 7, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 15, YES, bottomBtnH), bottomBtnH);
    _doneBtn.frame = CGRectMake(kViewWidth-70-inset.right, 7, 60, bottomBtnH);
}

#pragma mark - notifies
//设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    _offsetX = self.collectionView.contentOffset.x + self.collectionView.contentInset.left;
    _orientationChanged = YES;
}

- (void)appResignActive
{
    [self stopTimer];
}

- (void)appBecomeActive
{
    [self startTimer];
}

- (void)setupUI
{
    //禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerLayer = [[AVPlayerLayer alloc] init];
    [self.view.layer addSublayer:self.playerLayer];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:ZLEditVideoCell.class forCellWithReuseIdentifier:@"ZLEditVideoCell"];
    
    [self.view addSubview:self.collectionView];
    
    [self creatBottomView];
    
    self.editView = [[ZLEditFrameView alloc] init];
    self.editView.delegate = self;
    [self.view addSubview:self.editView];
    
    _indicatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, kItemHeight)];
    _indicatorLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
}

- (void)creatBottomView
{
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    //下方视图
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
    [self.view addSubview:_bottomView];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelBtn_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_cancelBtn];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    [_doneBtn setBackgroundColor:configuration.bottomBtnsNormalTitleColor];
    [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _doneBtn.layer.masksToBounds = YES;
    _doneBtn.layer.cornerRadius = 3.0f;
    [_doneBtn addTarget:self action:@selector(btnDone_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_doneBtn];
}

#pragma mark - 解析视频每一帧图片
- (void)analysisAssetImages
{
    float duration = roundf(self.model.asset.duration);
    
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    _interval = configuration.maxEditVideoTime/10.0;
    
    _measureCount = (NSInteger)(duration / _interval);
    
    zl_weakify(self);
    [ZLPhotoManager requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            zl_strongify(weakSelf);
            if (!item) return;
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            strongSelf.playerLayer.player = player;
            [strongSelf startTimer];
        });
    }];
    
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.model.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        zl_strongify(weakSelf);
        strongSelf->_avAsset = asset;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.collectionView reloadData];
        });
    }];
}

#pragma mark - action
- (void)cancelBtn_click
{
    [self stopTimer];
    
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
}

- (void)btnDone_click
{
    [self stopTimer];
    
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    zl_weakify(self);
    __weak typeof(nav) weakNav = nav;
    [ZLPhotoManager exportEditVideoForAsset:_avAsset range:[self getTimeRange] type:nav.configuration.exportVideoType complete:^(BOOL isSuc, PHAsset *asset) {
        [hud hide];
        if (isSuc) {
            __strong typeof(weakNav) strongNav = weakNav;
            ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeVideo duration:nil];
            [strongNav.arrSelectedModels removeAllObjects];
            [strongNav.arrSelectedModels addObject:model];
            if (strongNav.callSelectImageBlock) {
                strongNav.callSelectImageBlock();
            }
        } else {
            zl_strongify(weakSelf);
            [strongSelf startTimer];
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveVideoFailed));
        }
    }];
}

#pragma mark - timer
- (void)startTimer
{
    [self stopTimer];
    
    CGFloat duration = _interval * self.editView.validRect.size.width / (kItemWidth);
    _timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(playPartVideo:) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    _indicatorLine.frame = CGRectMake(self.editView.validRect.origin.x, 0, 2, kItemHeight);
    [self.editView addSubview:_indicatorLine];
    [UIView animateWithDuration:duration delay:.0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        self->_indicatorLine.frame = CGRectMake(CGRectGetMaxX(self.editView.validRect)-2, 0, 2, kItemHeight);
    } completion:nil];
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
    [_indicatorLine removeFromSuperview];
    [self.playerLayer.player pause];
}

- (CMTime)getStartTime
{
    CGRect rect = [self.collectionView convertRect:self.editView.validRect fromView:self.editView];
    CGFloat s = MAX(0, _interval * rect.origin.x / (kItemWidth));
    return CMTimeMakeWithSeconds(s, self.playerLayer.player.currentTime.timescale);
}

- (CMTimeRange)getTimeRange
{
    CMTime start = [self getStartTime];
    CGFloat d = _interval * self.editView.validRect.size.width / (kItemWidth);
    CMTime duration = CMTimeMakeWithSeconds(d, self.playerLayer.player.currentTime.timescale);
    return CMTimeRangeMake(start, duration);
}

- (void)playPartVideo:(NSTimer *)timer
{
    [self.playerLayer.player play];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - edit view delegate
- (void)editViewValidRectChanged
{
    [self stopTimer];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)editViewValidRectEndChanged
{
    [self startTimer];
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.playerLayer.player || _orientationChanged) {
        _orientationChanged = NO;
        return;
    }
    [self stopTimer];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self startTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startTimer];
}

#pragma mark - collection view data sources
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _measureCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLEditVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLEditVideoCell" forIndexPath:indexPath];
    
    UIImage *image = _imageCache[@(indexPath.row).stringValue];
    if (image) {
        cell.imageView.image = image;
    }
    
    return cell;
}

static const char _ZLOperationCellKey;
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_avAsset) return;
    
    if (_imageCache[@(indexPath.row).stringValue] || _opCache[@(indexPath.row).stringValue]) {
        return;
    }
    
     NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSInteger row = indexPath.row;
        NSInteger i = row  * self->_interval;
        
        CMTime time = CMTimeMake((i+0.35) * self->_avAsset.duration.timescale, self->_avAsset.duration.timescale);
        
        NSError *error = nil;
        CGImageRef cgImg = [self.generator copyCGImageAtTime:time actualTime:NULL error:&error];
        if (!error && cgImg) {
            UIImage *image = [UIImage imageWithCGImage:cgImg];
            CGImageRelease(cgImg);

            [self->_imageCache setValue:image forKey:@(row).stringValue];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSIndexPath *nowIndexPath = [collectionView indexPathForCell:cell];
                if (row == nowIndexPath.row) {
                    [(ZLEditVideoCell *)cell imageView].image = image;
                } else {
                    UIImage *cacheImage = self->_imageCache[@(nowIndexPath.row).stringValue];
                    if (cacheImage) {
                        [(ZLEditVideoCell *)cell imageView].image = cacheImage;
                    }
                }
            });
            [self->_opCache removeObjectForKey:@(row).stringValue];
        }
        objc_removeAssociatedObjects(cell);
    }];
    [_queue addOperation:op];
    [_opCache setValue:op forKey:@(indexPath.row).stringValue];
    
    objc_setAssociatedObject(cell, &_ZLOperationCellKey, op, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSBlockOperation *op = objc_getAssociatedObject(cell, &_ZLOperationCellKey);
    if (op) {
        [op cancel];
        objc_removeAssociatedObjects(cell);
        [_opCache removeObjectForKey:@(indexPath.row).stringValue];
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
