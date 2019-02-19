//
//  ZLProgressView.m
//  ZLPhotoBrowser
//
//  Created by long on 2019/1/23.
//  Copyright © 2019年 long. All rights reserved.
//

#import "ZLProgressView.h"

@interface ZLProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation ZLProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.progressLayer.lineCap = kCALineCapButt;
        self.progressLayer.lineWidth = 4;
        
        [self.layer addSublayer:self.progressLayer];
    }
    return self;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = rect.size.width / 2;
    CGFloat end = - M_PI_2 + (M_PI * 2 * self.progress);
    self.progressLayer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:end clockwise:YES];
    self.progressLayer.path = [path CGPath];
}

@end
