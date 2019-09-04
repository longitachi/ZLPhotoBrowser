//
//  ZLVideoPlayerControl.m
//  ZLPhotoBrowserFramework
//
//  Created by long on 2019/9/2.
//  Copyright © 2019 long. All rights reserved.
//

#import "ZLVideoPlayerControl.h"
#import "ZLDefine.h"

@interface ZLVideoPlayerControl ()

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UISlider *slider;

@end

@implementation ZLVideoPlayerControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playBtn.frame = CGRectMake(13, (GetViewHeight(self) - 40)/2, 40, 40);
    self.slider.frame = CGRectMake(70, (GetViewHeight(self) - 22)/2, GetViewWidth(self) - 70 - 24, 22);
}

- (void)setupUI
{
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:GetImageWithName(@"zl_playButtonWhite") forState:UIControlStateNormal];
    [self.playBtn setImage:GetImageWithName(@"zl_pauseButtonWhite") forState:UIControlStateSelected];
    [self.playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playBtn];
    
    self.slider = [[UISlider alloc] init];
    self.slider.minimumTrackTintColor = [UIColor whiteColor];
    self.slider.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.slider];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.slider addGestureRecognizer:pan];
}

- (BOOL)isPlaying
{
    return self.playBtn.isSelected;
}

- (void)setPlaying:(BOOL)playing
{
    self.playBtn.selected = playing;
}

- (void)updateProgress:(CGFloat)progress
{
    self.slider.value = progress;
}

#pragma mark - actions
- (void)playAction
{
    if (self.playActionBlock) {
        self.playActionBlock([self isPlaying]);
    }
}

- (void)sliderValueChanged:(UISlider *)slider forEvent:(UIEvent *)event
{
    if (!self.sliderValueChangedBlock) return;
    
    UITouch *touchEvent = event.allTouches.anyObject;
    
    if (touchEvent.phase == UITouchPhaseEnded) {
        self.sliderValueChangedBlock(self.slider.value, YES);
    } else {
        self.sliderValueChangedBlock(self.slider.value, NO);
    }
}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint p = [pan locationInView:self.slider];
    CGFloat percentage = p.x / GetViewWidth(self.slider);
    CGFloat delta = percentage * (self.slider.maximumValue - self.slider.minimumValue);
    CGFloat value = self.slider.minimumValue + delta;
    [self.slider setValue:value animated:YES];
    
    if (!self.sliderValueChangedBlock) return;
    
    if (pan.state == UIGestureRecognizerStateEnded ||
        pan.state == UIGestureRecognizerStateCancelled) {
        self.sliderValueChangedBlock(value, YES);
    } else {
        self.sliderValueChangedBlock(value, NO);
    }
}

@end
