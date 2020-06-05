//
//  ZLCollectionCell.m
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLCollectionCell.h"
#import "ZLPhotoModel.h"
#import "ZLPhotoManager.h"
#import "ZLDefine.h"
#import "ToastUtils.h"
#import "UIControl+EnlargeTouchArea.h"
#import "ZLProgressView.h"

@interface ZLCollectionCell ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, assign) PHImageRequestID bigImageRequestID;

@end

@implementation ZLCollectionCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.maskView = [[UIView alloc] init];
    self.maskView.userInteractionEnabled = NO;
    self.maskView.hidden = YES;
    [self.contentView addSubview:self.maskView];
    
    self.videoBottomView = [[UIImageView alloc] initWithImage:GetImageWithName(@"zl_videoView")];
    self.videoBottomView.frame = CGRectMake(0, GetViewHeight(self)-15, GetViewWidth(self), 15);
    [self.contentView addSubview:_videoBottomView];
    
    self.btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSelect.frame = CGRectMake(GetViewWidth(self.contentView)-26, 5, 23, 23);
    [self.btnSelect setBackgroundImage:GetImageWithName(@"zl_btn_unselected") forState:UIControlStateNormal];
    [self.btnSelect setBackgroundImage:GetImageWithName(@"zl_btn_selected") forState:UIControlStateSelected];
    [self.btnSelect addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.btnSelect];
    
    self.indexLabel = [[UILabel alloc] init];
    self.indexLabel.layer.cornerRadius = 23.0 / 2;
    self.indexLabel.layer.masksToBounds = YES;
    self.indexLabel.textColor = [UIColor whiteColor];
    self.indexLabel.font = [UIFont systemFontOfSize:14];
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    self.indexLabel.hidden = YES;
    [self.contentView addSubview:self.indexLabel];
    
    self.videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 1, 16, 12)];
    self.videoImageView.image = GetImageWithName(@"zl_video");
    [self.videoBottomView addSubview:self.videoImageView];
    
    self.liveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, -1, 15, 15)];
    self.liveImageView.image = GetImageWithName(@"zl_livePhoto");
    [self.videoBottomView addSubview:self.liveImageView];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 1, GetViewWidth(self)-35, 12)];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.font = [UIFont systemFontOfSize:13];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.videoBottomView addSubview:self.timeLabel];
    
    self.progressView = [[ZLProgressView alloc] init];
    self.progressView.hidden = YES;
    [self.contentView addSubview:self.progressView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.btnSelect.frame = CGRectMake(GetViewWidth(self.contentView)-26, 5, 23, 23);
    self.indexLabel.frame = self.btnSelect.frame;
    self.maskView.frame = self.bounds;
    
    self.videoBottomView.frame = CGRectMake(0, GetViewHeight(self)-15, GetViewWidth(self), 15);
    self.videoImageView.frame = CGRectMake(5, 1, 16, 12);
    self.liveImageView.frame = CGRectMake(5, -1, 15, 15);
    self.timeLabel.frame = CGRectMake(30, 1, GetViewWidth(self)-35, 12);
    [self.contentView sendSubviewToBack:self.imageView];
    
    CGFloat progressOriginXY = (GetViewWidth(self) - 20) / 2;
    self.progressView.frame = CGRectMake(progressOriginXY, progressOriginXY, 20, 20);
}

- (void)setModel:(ZLPhotoModel *)model
{
    _model = model;
    
    if (self.cornerRadio > .0) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.cornerRadio;
    }
    
    if (model.type == ZLAssetMediaTypeVideo) {
        self.videoBottomView.hidden = NO;
        self.videoImageView.hidden = NO;
        self.liveImageView.hidden = YES;
        self.timeLabel.text = model.duration;
    } else if (model.type == ZLAssetMediaTypeGif) {
        self.videoBottomView.hidden = !self.allSelectGif;
        self.videoImageView.hidden = YES;
        self.liveImageView.hidden = YES;
        self.timeLabel.text = @"GIF";
    } else if (model.type == ZLAssetMediaTypeLivePhoto) {
        self.videoBottomView.hidden = !self.allSelectLivePhoto;
        self.videoImageView.hidden = YES;
        self.liveImageView.hidden = NO;
        self.timeLabel.text = @"Live";
    } else {
        self.videoBottomView.hidden = YES;
    }
    
    self.btnSelect.hidden = !self.showSelectBtn;
    self.btnSelect.enabled = self.showSelectBtn;
    self.btnSelect.selected = model.isSelected;
    
    if (model.isSelected) {
        [self requestBigImage];
    } else {
        [self cancelRequestBigImage];
    }
    
    if (self.showSelectBtn) {
        //扩大点击区域
        [_btnSelect zl_enlargeValidTouchAreaWithInsets:UIEdgeInsetsMake(0, 20, 20, 0)];
    }
    
    CGSize size;
    size.width = GetViewWidth(self) * 1.7;
    size.height = GetViewHeight(self) * 1.7;
    
    @zl_weakify(self);
    if (model.asset && self.imageRequestID > PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.identifier = model.asset.localIdentifier;
    self.imageView.image = nil;
    self.imageRequestID = [ZLPhotoManager requestImageForAsset:model.asset size:size progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        @zl_strongify(self);
        
        if ([self.identifier isEqualToString:model.asset.localIdentifier]) {
            self.imageView.image = image;
        }
        
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            self.imageRequestID = -1;
        }
    }];
}

- (void)setShowIndexLabel:(BOOL)showIndexLabel
{
    _showIndexLabel = showIndexLabel;
    self.indexLabel.hidden = !showIndexLabel;
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    self.indexLabel.text = @(index).stringValue;
}

- (void)btnSelectClick:(UIButton *)sender {
    if (!self.btnSelect.selected) {
        [self.btnSelect.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
    if (self.selectedBlock) {
        self.selectedBlock(self.btnSelect.selected);
    }
    
    if (self.btnSelect.isSelected) {
        [self requestBigImage];
    } else {
        self.progressView.hidden = YES;
        [self cancelRequestBigImage];
    }
}

- (void)requestBigImage
{
    [self cancelRequestBigImage];
    
    @zl_weakify(self);
    self.bigImageRequestID = [ZLPhotoManager requestOriginalImageDataForAsset:self.model.asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
        @zl_strongify(self);
        if (self.model.isSelected) {
            self.progressView.hidden = NO;
            self.progressView.progress = MAX(0.1, progress);
            self.imageView.alpha = 0.5;
            if (progress >= 1) {
                [self resetProgressViewStatus];
            }
        } else {
            [self cancelRequestBigImage];
        }
    } completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull dic) {
        [self resetProgressViewStatus];
    }];
}

- (void)cancelRequestBigImage
{
    if (self.bigImageRequestID > PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.bigImageRequestID];
    }
    [self resetProgressViewStatus];
}

- (void)resetProgressViewStatus
{
    self.progressView.hidden = YES;
    self.imageView.alpha = 1;
}

@end


//////////////////////////////////////

#if __has_feature(modules)
@import AVFoundation;
#else
#import <AVFoundation/AVFoundation.h>
#endif

@interface ZLTakePhotoCell ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutPut;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ZLTakePhotoCell

- (void)dealloc
{
    if ([_session isRunning]) {
        [_session stopRunning];
    }
    _session = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithImage:GetImageWithName(@"zl_takePhoto")];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGFloat width = GetViewHeight(self)/3;
        self.imageView.frame = CGRectMake(0, 0, width, width);
        self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    }
    return self;
}

- (void)restartCapture
{
    [self.session stopRunning];
    [self startCapture];
}

- (void)startCapture
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (![UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera] ||
        status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.session stopRunning];
                [self.previewLayer removeFromSuperlayer];
            });
        }
    }];
    
    if (self.session && [self.session isRunning]) {
        return;
    }
    
    [self.session stopRunning];
    [self.session removeInput:self.videoInput];
    [self.session removeOutput:self.stillImageOutPut];
    self.session = nil;
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
    self.session = [[AVCaptureSession alloc] init];
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backCamera] error:nil];
    self.stillImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    NSDictionary *dicOutputSetting = [NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey];
    [self.stillImageOutPut setOutputSettings:dicOutputSetting];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutPut]) {
        [self.session addOutput:self.stillImageOutPut];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.contentView.layer setMasksToBounds:YES];
    
    self.previewLayer.frame = self.contentView.layer.bounds;
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.contentView.layer insertSublayer:self.previewLayer atIndex:0];

    [self.session startRunning];
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

@end

