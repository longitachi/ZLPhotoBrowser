//
//  ZLBrushBoardImageView.m
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/9.
//  Copyright © 2018年 long. All rights reserved.
//

#import "ZLBrushBoardImageView.h"

@interface ZLPath : UIBezierPath

@property (nonatomic, strong) UIColor *lineColor;

@end

@implementation ZLPath

@end


@interface ZLBrushBoardImageView () <UIGestureRecognizerDelegate>
{
    ZLPath *_path;
    NSMutableArray *_paths;
    UIImage *_originImage;
    BOOL _isDrawing; //是否正在涂鸦，涂鸦过程的重绘不需要重置原图，其他情况都需要重绘原图
}

@end

@implementation ZLBrushBoardImageView

- (instancetype)init {
    self = [super init];
    if (self) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];

        _paths = [NSMutableArray array];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    if (!self.drawEnable) return;

    CGPoint curP = [pan locationInView:self];

    if (pan.state == UIGestureRecognizerStateBegan) {
        _path = [[ZLPath alloc] init];
        _path.lineWidth = 5;
        _path.lineColor = self.drawColor;
        [_path moveToPoint:curP];
        [_paths addObject:_path];
    }

    [_path addLineToPoint:curP];

    [self draw];
}

- (void)draw {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //去掉锯齿
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    [_originImage drawInRect:self.bounds];

    for (ZLPath *path in _paths) {
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        [path.lineColor setStroke];
        [path stroke];
    }
    
    _isDrawing = YES;
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    _isDrawing = NO;

    UIGraphicsEndImageContext();
}

- (void)revoke {
    if (_paths.count <= 0) return;

    [_paths removeLastObject];
    [self draw];
}

- (void)setImage:(UIImage *)image {
    if (!_isDrawing) {
        _originImage = image;
        if (_paths) {
            [_paths removeAllObjects];
        }
    }
    [super setImage:image];
}

@end
