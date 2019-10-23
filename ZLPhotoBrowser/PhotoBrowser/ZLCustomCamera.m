//
//  ZLCustomCamera.m
//  CustomCamera
//
//  Created by long on 2017/6/26.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLCustomCamera.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "ZLPlayer.h"
#import "ZLPhotoManager.h"


#define kTopViewScale .5
#define kBottomViewScale .7

#define kAnimateDuration .1

@protocol CameraToolViewDelegate <NSObject>

/**
 单击事件，拍照
 */
- (void)onTakePicture;
/**
 开始录制
 */
- (void)onStartRecord;
/**
 结束录制
 */
- (void)onFinishRecord;
/**
 重新拍照或录制
 */
- (void)onRetake;
/**
 点击确定
 */
- (void)onOkClick;

- (void)onDismiss;

@end

@interface CameraToolView : UIView <CAAnimationDelegate, UIGestureRecognizerDelegate>
{
    struct {
        unsigned int takePic : 1;
        unsigned int startRecord : 1;
        unsigned int finishRecord : 1;
        unsigned int retake : 1;
        unsigned int okClick : 1;
        unsigned int dismiss : 1;
    } _delegateFlag;
    
    //避免动画及长按手势触发两次
    BOOL _stopRecord;
    BOOL _layoutOK;
}

@property (nonatomic, weak) id<CameraToolViewDelegate> delegate;

@property (nonatomic, assign) BOOL allowTakePhoto;
@property (nonatomic, assign) BOOL allowRecordVideo;
@property (nonatomic, strong) UIColor *circleProgressColor;
@property (nonatomic, assign) NSInteger maxRecordDuration;

@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) CAShapeLayer *animateLayer;

@property (nonatomic, assign) CGFloat duration;

@end

@implementation CameraToolView

- (CAShapeLayer *)animateLayer
{
    if (!_animateLayer) {
        _animateLayer = [CAShapeLayer layer];
        CGFloat width = CGRectGetHeight(self.bottomView.frame)*kBottomViewScale;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, width, width) cornerRadius:width/2];
        
        _animateLayer.strokeColor = self.circleProgressColor.CGColor;
        _animateLayer.fillColor = [UIColor clearColor].CGColor;
        _animateLayer.path = path.CGPath;
        _animateLayer.lineWidth = 8;
    }
    return _animateLayer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setDelegate:(id<CameraToolViewDelegate>)delegate
{
    _delegate = delegate;
    _delegateFlag.takePic = [delegate respondsToSelector:@selector(onTakePicture)];
    _delegateFlag.startRecord = [delegate respondsToSelector:@selector(onStartRecord)];
    _delegateFlag.finishRecord = [delegate respondsToSelector:@selector(onFinishRecord)];
    _delegateFlag.retake = [delegate respondsToSelector:@selector(onRetake)];
    _delegateFlag.okClick = [delegate respondsToSelector:@selector(onOkClick)];
    _delegateFlag.dismiss = [delegate respondsToSelector:@selector(onDismiss)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_layoutOK) return;
    
    _layoutOK = YES;
    CGFloat height = GetViewHeight(self);
    self.bottomView.frame = CGRectMake(0, 0, height*kBottomViewScale, height*kBottomViewScale);
    self.bottomView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.bottomView.layer.cornerRadius = height*kBottomViewScale/2;

    self.topView.frame = CGRectMake(0, 0, height*kTopViewScale, height*kTopViewScale);
    self.topView.center = self.bottomView.center;
    self.topView.layer.cornerRadius = height*kTopViewScale/2;
    
    self.dismissBtn.frame = CGRectMake(60, self.bounds.size.height/2-25/2, 25, 25);

    self.cancelBtn.frame = self.bottomView.frame;
    self.cancelBtn.layer.cornerRadius = height*kBottomViewScale/2;
    
    self.doneBtn.frame = self.bottomView.frame;
    self.doneBtn.layer.cornerRadius = height*kBottomViewScale/2;
}

- (void)setAllowTakePhoto:(BOOL)allowTakePhoto
{
    _allowTakePhoto = allowTakePhoto;
    if (allowTakePhoto) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.bottomView addGestureRecognizer:tap];
    }
}

- (void)setAllowRecordVideo:(BOOL)allowRecordVideo
{
    _allowRecordVideo = allowRecordVideo;
    if (allowRecordVideo) {
        UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        longG.minimumPressDuration = 0.3;
        longG.delegate = self;
        [self.bottomView addGestureRecognizer:longG];
    }
}

- (void)setupUI
{
    self.bottomView = [[UIView alloc] init];
    self.bottomView.layer.masksToBounds = YES;
    self.bottomView.backgroundColor = [kRGB(244, 244, 244) colorWithAlphaComponent:.9];
    [self addSubview:self.bottomView];
    
    self.topView = [[UIView alloc] init];
    self.topView.layer.masksToBounds = YES;
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.userInteractionEnabled = NO;
    [self addSubview:self.topView];
    
    self.dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dismissBtn.frame = CGRectMake(60, self.bounds.size.height/2-25/2, 25, 25);
    [self.dismissBtn setImage:GetImageWithName(@"zl_arrow_down") forState:UIControlStateNormal];
    [self.dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.dismissBtn];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.backgroundColor = [kRGB(244, 244, 244) colorWithAlphaComponent:.9];
    [self.cancelBtn setImage:GetImageWithName(@"zl_retake") forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(retake) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn.layer.masksToBounds = YES;
    self.cancelBtn.hidden = YES;
    [self addSubview:self.cancelBtn];
    
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneBtn.frame = self.bottomView.frame;
    self.doneBtn.backgroundColor = [UIColor whiteColor];
    [self.doneBtn setImage:GetImageWithName(@"zl_takeok") forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    self.doneBtn.layer.masksToBounds = YES;
    self.doneBtn.hidden = YES;
    [self addSubview:self.doneBtn];
}

#pragma mark - GestureRecognizer
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    [self stopAnimate];
    if (_delegateFlag.takePic) [self.delegate performSelector:@selector(onTakePicture)];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longG
{
    switch (longG.state) {
        case UIGestureRecognizerStateBegan:
        {
            //此处不启动动画，由vc界面开始录制之后启动
            _stopRecord = NO;
            if (_delegateFlag.startRecord) [self.delegate performSelector:@selector(onStartRecord)];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            if (_stopRecord) return;
            _stopRecord = YES;
            [self stopAnimate];
            if (_delegateFlag.finishRecord) [self.delegate performSelector:@selector(onFinishRecord)];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])) {
        return YES;
    }
    return NO;
}

#pragma mark - 动画
- (void)startAnimate
{
    self.dismissBtn.hidden = YES;
    
    [UIView animateWithDuration:kAnimateDuration animations:^{
        self.bottomView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1/kBottomViewScale, 1/kBottomViewScale, 1);
        self.topView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.7, 0.7, 1);
    } completion:^(BOOL finished) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.duration = self.maxRecordDuration;
        animation.delegate = self;
        [self.animateLayer addAnimation:animation forKey:nil];

        [self.bottomView.layer addSublayer:self.animateLayer];
    }];
}

- (void)stopAnimate
{
    if (_animateLayer) {
        [self.animateLayer removeFromSuperlayer];
        [self.animateLayer removeAllAnimations];
    }
    
    self.bottomView.hidden = YES;
    self.topView.hidden = YES;
    self.dismissBtn.hidden = YES;
    
    self.bottomView.layer.transform = CATransform3DIdentity;
    self.topView.layer.transform = CATransform3DIdentity;
    
    [self showCancelDoneBtn];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_stopRecord) return;
    
    _stopRecord = YES;
    [self stopAnimate];
    if (_delegateFlag.finishRecord) [self.delegate performSelector:@selector(onFinishRecord)];
}

- (void)showCancelDoneBtn
{
    self.cancelBtn.hidden = NO;
    self.doneBtn.hidden = NO;
    
    CGRect cancelRect = self.cancelBtn.frame;
    cancelRect.origin.x = 40;
    
    CGRect doneRect = self.doneBtn.frame;
    doneRect.origin.x = GetViewWidth(self)-doneRect.size.width-40;
    
    [UIView animateWithDuration:kAnimateDuration animations:^{
        self.cancelBtn.frame = cancelRect;
        self.doneBtn.frame = doneRect;
    }];
}

- (void)resetUI
{
    if (_animateLayer.superlayer) {
        [self.animateLayer removeAllAnimations];
        [self.animateLayer removeFromSuperlayer];
    }
    self.dismissBtn.hidden = NO;
    self.bottomView.hidden = NO;
    self.topView.hidden = NO;
    self.cancelBtn.hidden = YES;
    self.doneBtn.hidden = YES;
    
    self.cancelBtn.frame = self.bottomView.frame;
    self.doneBtn.frame = self.bottomView.frame;
}

#pragma mark - btn actions
- (void)dismissVC
{
    if (_delegateFlag.dismiss) [self.delegate performSelector:@selector(onDismiss)];
}

- (void)retake
{
    [self resetUI];
    if (_delegateFlag.retake) [self.delegate performSelector:@selector(onRetake)];
}

- (void)doneClick
{
    if (_delegateFlag.okClick) [self.delegate performSelector:@selector(onOkClick)];
}

@end



//--------------------------------------------------------//
//--------------------------------------------------------//
@interface ZLCustomCamera () <CameraToolViewDelegate, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate>
{
    //拖拽手势开始的录制
    BOOL _dragStart;
    BOOL _layoutOK;
}

@property (nonatomic, strong) CameraToolView *toolView;
//拍照录视频相关
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession *session;
//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
//照片输出流对象
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;
//视频输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutPut;

//预览图层，显示相机拍摄到的画面
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
//切换摄像头按钮
@property (nonatomic, strong) UIButton *toggleCameraBtn;
//聚焦图
@property (nonatomic, strong) UIImageView *focusCursorImageView;
//录制视频保存的url
@property (nonatomic, strong) NSURL *videoUrl;
//拍照照片显示
@property (nonatomic, strong) UIImageView *takedImageView;
//拍照的照片
@property (nonatomic, strong) UIImage *takedImage;
//播放视频
@property (nonatomic, strong) ZLPlayer *playerView;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, assign) AVCaptureVideoOrientation orientation;

@end

@implementation ZLCustomCamera

- (void)dealloc
{
    if ([_session isRunning]) {
        [_session stopRunning];
    }
    
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.allowTakePhoto = YES;
        self.allowRecordVideo = YES;
        self.maxRecordDuration = 15;
        self.sessionPreset = ZLCaptureSessionPreset1280x720;
        self.videoType = ZLExportVideoTypeMp4;
        self.circleProgressColor = kRGB(80, 169, 56);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupCamera];
    [self observeDeviceMotion];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            if (self.allowRecordVideo) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    if (!granted) {
                        [self onDismiss];
                    } else {
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
                    }
                }];
            } else {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
            }
        } else {
            [self onDismiss];
        }
    }];
    
    //暂停其他音乐，
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.session startRunning];
    [self setFocusCursorWithPoint:self.view.center];
    if (!self.allowTakePhoto && !self.allowRecordVideo) {
        ShowAlert(@"allowTakePhoto与allowRecordVideo不能同时为NO", self);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.session) {
        [self.session stopRunning];
    }
}

#pragma mark - 监控设备方向
- (void)observeDeviceMotion
{
    self.motionManager = [[CMMotionManager alloc] init];
    // 提供设备运动数据到指定的时间间隔
    self.motionManager.deviceMotionUpdateInterval = .5;
    
    if (self.motionManager.deviceMotionAvailable) {  // 确定是否使用任何可用的态度参考帧来决定设备的运动是否可用
        // 启动设备的运动更新，通过给定的队列向给定的处理程序提供数据。
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    } else {
        self.motionManager = nil;
    }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    
    if (fabs(y) >= fabs(x)) {
        if (y >= 0){
            // UIDeviceOrientationPortraitUpsideDown;
            self.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
        } else {
            // UIDeviceOrientationPortrait;
            self.orientation = AVCaptureVideoOrientationPortrait;
        }
    } else {
        if (x >= 0) {
            //视频拍照转向，左右和屏幕转向相反
            // UIDeviceOrientationLandscapeRight;
            self.orientation = AVCaptureVideoOrientationLandscapeLeft;
        } else {
            // UIDeviceOrientationLandscapeLeft;
            self.orientation = AVCaptureVideoOrientationLandscapeRight;
        }
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willResignActive
{
    if ([self.session isRunning]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_layoutOK) return;
    _layoutOK = YES;
    
    self.toolView.frame = CGRectMake(0, kViewHeight-150-ZL_SafeAreaBottom(), kViewWidth, 100);
    self.previewLayer.frame = self.view.layer.bounds;
    self.toggleCameraBtn.frame = CGRectMake(kViewWidth-50, UIApplication.sharedApplication.statusBarFrame.size.height, 30, 30);
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.toolView = [[CameraToolView alloc] init];
    self.toolView.delegate = self;
    self.toolView.allowTakePhoto = self.allowTakePhoto;
    self.toolView.allowRecordVideo = self.allowRecordVideo;
    self.toolView.circleProgressColor = self.circleProgressColor;
    self.toolView.maxRecordDuration = self.maxRecordDuration;
    [self.view addSubview:self.toolView];
    
    self.focusCursorImageView = [[UIImageView alloc] initWithImage:GetImageWithName(@"zl_focus")];
    self.focusCursorImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.focusCursorImageView.clipsToBounds = YES;
    self.focusCursorImageView.frame = CGRectMake(0, 0, 70, 70);
    self.focusCursorImageView.alpha = 0;
    [self.view addSubview:self.focusCursorImageView];
    
    self.toggleCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toggleCameraBtn setImage:GetImageWithName(@"zl_toggle_camera") forState:UIControlStateNormal];
    [self.toggleCameraBtn addTarget:self action:@selector(btnToggleCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggleCameraBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adjustFocusPoint:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    if (self.allowRecordVideo) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(adjustCameraFocus:)];
        pan.maximumNumberOfTouches = 1;
        [self.view addGestureRecognizer:pan];
    }
}

- (void)setupCamera
{
    self.session = [[AVCaptureSession alloc] init];
    
    //相机画面输入流
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backCamera] error:nil];
    
    //照片输出流
    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    NSDictionary *dicOutputSetting = [NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey];
    [self.imageOutPut setOutputSettings:dicOutputSetting];
    
    //音频输入流
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].firstObject;
    AVCaptureDeviceInput *audioInput = nil;
    if (self.allowRecordVideo) {
        audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:nil];
    }
    
    
    //视频输出流
    //设置视频格式
    NSString *preset = [self transformSessionPreset];
    if ([self.session canSetSessionPreset:preset]) {
        self.session.sessionPreset = preset;
    } else {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    
    self.movieFileOutPut = [[AVCaptureMovieFileOutput alloc] init];
    // 解决视频录制超过10s没有声音的bug
    self.movieFileOutPut.movieFragmentInterval = kCMTimeInvalid;
    
    //将视频及音频输入流添加到session
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if (audioInput && [self.session canAddInput:audioInput]) {
        [self.session addInput:audioInput];
    }
    //将输出流添加到session
    if ([self.session canAddOutput:self.imageOutPut]) {
        [self.session addOutput:self.imageOutPut];
    }
    if ([self.session canAddOutput:self.movieFileOutPut]) {
        [self.session addOutput:self.movieFileOutPut];
    }
    //预览层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.view.layer setMasksToBounds:YES];
    
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
}

- (NSString *)transformSessionPreset
{
    switch (self.sessionPreset) {
        case ZLCaptureSessionPreset325x288:
            return AVCaptureSessionPreset352x288;
            
        case ZLCaptureSessionPreset640x480:
            return AVCaptureSessionPreset640x480;
            
        case ZLCaptureSessionPreset1280x720:
            return AVCaptureSessionPreset1280x720;
        
        case ZLCaptureSessionPreset1920x1080:
            return AVCaptureSessionPreset1920x1080;
            
        case ZLCaptureSessionPreset3840x2160:
        {
            if (@available(iOS 9.0, *)) {
                return AVCaptureSessionPreset3840x2160;
            } else {
                return AVCaptureSessionPreset1920x1080;
            }
        }
        default:
            return AVCaptureSessionPreset1920x1080;
    }
}

#pragma mark - 设置聚焦点
- (void)adjustFocusPoint:(UITapGestureRecognizer *)tap
{
    if (!self.session.isRunning) return;
    
    CGPoint point = [tap locationInView:self.view];
    
    if (point.y > CGRectGetMinY(self.toolView.frame)) {
        return;
    }
    
    [self setFocusCursorWithPoint:point];
}

//设置聚焦光标位置
- (void)setFocusCursorWithPoint:(CGPoint)point
{
    self.focusCursorImageView.center = point;
    self.focusCursorImageView.alpha = 1;
    self.focusCursorImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:0.5 animations:^{
        self.focusCursorImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursorImageView.alpha=0;
    }];
    
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

//设置聚焦点
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point
{
    AVCaptureDevice * captureDevice = [self.videoInput device];
    NSError * error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if (![captureDevice lockForConfiguration:&error]) {
        return;
    }
    //聚焦模式
    if ([captureDevice isFocusModeSupported:focusMode]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    //聚焦点
    if ([captureDevice isFocusPointOfInterestSupported]) {
        [captureDevice setFocusPointOfInterest:point];
    }
    //曝光模式
    if ([captureDevice isExposureModeSupported:exposureMode]) {
        [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    //曝光点
    if ([captureDevice isExposurePointOfInterestSupported]) {
        [captureDevice setExposurePointOfInterest:point];
    }
    [captureDevice unlockForConfiguration];
}

#pragma mark - 手势调整焦距
- (void)adjustCameraFocus:(UIPanGestureRecognizer *)pan
{
    CGRect caremaViewRect = [self.toolView convertRect:self.toolView.bottomView.frame toView:self.view];
    CGPoint point = [pan locationInView:self.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (!CGRectContainsPoint(caremaViewRect, point)) {
            return;
        }
        _dragStart = YES;
        [self onStartRecord];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (!_dragStart) return;
        
        CGFloat zoomFactor = (CGRectGetMidY(caremaViewRect)-point.y)/CGRectGetMidY(caremaViewRect) * 10;
        [self setVideoZoomFactor:MIN(MAX(zoomFactor, 1), 10)];
    } else if (pan.state == UIGestureRecognizerStateCancelled ||
               pan.state == UIGestureRecognizerStateEnded) {
        if (!_dragStart) return;
        
        _dragStart = NO;
        [self onFinishRecord];
        //这里需要结束动画
        [self.toolView stopAnimate];
    }
}

- (void)setVideoZoomFactor:(CGFloat)zoomFactor
{
    AVCaptureDevice * captureDevice = [self.videoInput device];
    NSError *error = nil;
    [captureDevice lockForConfiguration:&error];
    if (error) return;
    captureDevice.videoZoomFactor = zoomFactor;
    [captureDevice unlockForConfiguration];
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - 切换前后相机
//切换摄像头
- (void)btnToggleCameraAction
{
    NSUInteger cameraCount = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = self.videoInput.device.position;
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        } else {
            return;
        }
        
        if (newVideoInput) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                self.videoInput = newVideoInput;
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            ZLLoggerDebug(@"切换前后摄像头失败");
        }
    }
}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - CircleViewDelegate
//拍照
- (void)onTakePicture
{
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = self.orientation;
    if (!videoConnection) {
        ZLLoggerDebug(@"take photo failed!");
        return;
    }
    
    if (!_takedImageView) {
        _takedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _takedImageView.backgroundColor = [UIColor blackColor];
        _takedImageView.hidden = YES;
        _takedImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view insertSubview:_takedImageView belowSubview:self.toolView];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        weakSelf.takedImage = image;
        weakSelf.takedImageView.hidden = NO;
        weakSelf.takedImageView.image = image;
        [weakSelf.session stopRunning];
    }];
}

//开始录制
- (void)onStartRecord
{
    AVCaptureConnection *movieConnection = [self.movieFileOutPut connectionWithMediaType:AVMediaTypeVideo];
    movieConnection.videoOrientation = self.orientation;
    [movieConnection setVideoScaleAndCropFactor:1.0];
    if (![self.movieFileOutPut isRecording]) {
        NSURL *url = [NSURL fileURLWithPath:[ZLPhotoManager getVideoExportFilePath:self.videoType]];
        [self.movieFileOutPut startRecordingToOutputFileURL:url recordingDelegate:self];
    }
}

//结束录制
- (void)onFinishRecord
{
    [self.movieFileOutPut stopRecording];
    [self setVideoZoomFactor:1];
}

//重新拍照或录制
- (void)onRetake
{
    [self.session startRunning];
    [self setFocusCursorWithPoint:self.view.center];
    if (self.takedImage != nil) {
        [UIView animateWithDuration:0.25 animations:^{
            self.takedImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.takedImageView.hidden = YES;
            self.takedImageView.alpha = 1;
        }];
    }
    
    [self deleteVideo];
}

//确定选择
- (void)onOkClick
{
    [self.playerView reset];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.doneBlock) {
            self.doneBlock(self.takedImage, self.videoUrl);
        }
    }];
}

//dismiss
- (void)onDismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)playVideo
{
    if (!_playerView) {
        self.playerView = [[ZLPlayer alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:self.playerView belowSubview:self.toolView];
    }
    self.playerView.hidden = NO;
    self.playerView.videoUrl = self.videoUrl;
    [self.playerView play];
}

- (void)deleteVideo
{
    if (self.videoUrl) {
        [self.playerView reset];
        [UIView animateWithDuration:0.25 animations:^{
            self.playerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.playerView.hidden = YES;
            self.playerView.alpha = 1;
        }];
        [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:nil];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections
{
    [self.toolView startAnimate];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    if (CMTimeGetSeconds(output.recordedDuration) < 0.3) {
        if (self.allowTakePhoto) {
            //视频长度小于0.3s 允许拍照则拍照，不允许拍照，则保存小于0.3s的视频
            ZLLoggerDebug(@"视频长度小于0.3s，按拍照处理");
            [self onTakePicture];
            return;
        }
    }
    [self.session stopRunning];
    self.videoUrl = outputFileURL;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playVideo];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
