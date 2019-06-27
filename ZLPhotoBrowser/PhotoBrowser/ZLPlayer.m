//
//  ZLPlayer.m
//  CustomCamera
//
//  Created by long on 2017/11/9.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface ZLPlayer ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation ZLPlayer

- (void)dealloc
{
    [_player pause];
    _player = nil;
//    NSLog(@"---- %s", __FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor blackColor];
    self.playerLayer = [[AVPlayerLayer alloc] init];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
}

- (void)setVideoUrl:(NSURL *)videoUrl
{
    _player = [AVPlayer playerWithURL:videoUrl];
    if (@available(iOS 10.0, *)) {
        _player.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.playerLayer.player = _player;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)playFinished
{
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

- (void)play
{
    [_player play];
}

- (void)pause
{
    [_player pause];
}

- (void)reset
{
    [_player pause];
    _player = nil;
}

- (BOOL)isPlay
{
    return _player && _player.rate > 0;
}

@end
