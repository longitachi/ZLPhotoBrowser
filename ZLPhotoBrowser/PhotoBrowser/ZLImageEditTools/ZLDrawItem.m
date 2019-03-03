//
//  ZLDrawItem.m
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/9.
//  Copyright © 2018年 long. All rights reserved.
//

#import "ZLDrawItem.h"

@interface ZLDrawItem ()
{
    ZLDrawItemColorType _type;
    UIView *_colorView;
}

@end

@implementation ZLDrawItem

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:CGRectZero colorType:ZLDrawItemColorTypeWhite target:nil action:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithFrame:CGRectZero colorType:ZLDrawItemColorTypeWhite target:nil action:nil];
}

- (instancetype)initWithFrame:(CGRect)frame colorType:(ZLDrawItemColorType)colorType target:(id)target action:(SEL)action
{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        _type = colorType;
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds)-10, CGRectGetMidY(self.bounds)-10, 20, 20)];
        _colorView.layer.masksToBounds = YES;
        _colorView.layer.cornerRadius = 10;
        _colorView.backgroundColor = [self colorWithType:colorType];;
        [self addSubview:_colorView];
    }
    return self;
}

- (UIColor *)color
{
    return [self colorWithType:_type];
}

- (UIColor *)colorWithType:(ZLDrawItemColorType)colorType
{
    switch (colorType) {
        case ZLDrawItemColorTypeWhite:    return [UIColor whiteColor];
        case ZLDrawItemColorTypeDarkGray: return [UIColor darkGrayColor];
        case ZLDrawItemColorTypeRed:      return [UIColor redColor];
        case ZLDrawItemColorTypeYellow:   return [UIColor yellowColor];
        case ZLDrawItemColorTypeGreen:    return [UIColor greenColor];
        case ZLDrawItemColorTypeBlue:     return [UIColor blueColor];
        case ZLDrawItemColorTypePurple:   return [UIColor purpleColor];
        default:                          return [UIColor redColor];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected) {
        [UIView animateWithDuration:0.15 animations:^{
            self->_colorView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        }];
    } else {
        _colorView.transform = CGAffineTransformIdentity;
    }
}

@end
