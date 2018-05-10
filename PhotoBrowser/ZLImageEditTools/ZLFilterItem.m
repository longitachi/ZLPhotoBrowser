//
//  ZLFilterItem.m
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/6.
//  Copyright © 2018年 long. All rights reserved.
//

#import "ZLFilterItem.h"
#import "ZLDefine.h"
#import "ZLFilterTool.h"

@interface ZLFilterItem ()
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@end

@implementation ZLFilterItem

- (void)dealloc
{
//    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:CGRectZero Image:nil filterType:ZLFilterTypeOriginal target:nil action:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithFrame:CGRectZero Image:nil filterType:ZLFilterTypeOriginal target:nil action:nil];
}

- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image filterType:(ZLFilterType)filterType target:(id)target action:(SEL)action
{
    self = [super initWithFrame:frame];
    if(self){
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        CGFloat W = frame.size.width;
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, W-20, W-20)];
        _iconView.image = image;
        _iconView.clipsToBounds = YES;
        _iconView.layer.cornerRadius = 5;
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconView.frame) + 5, W, 15)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        self.filterType = filterType;
        self.iconImage = image;
    }
    return self;
}

- (void)setFilterType:(ZLFilterType)filterType
{
    _filterType = filterType;
    NSString *title = nil;
    switch (filterType) {
        case ZLFilterTypeOriginal: title = @"原图"; break;
        case ZLFilterTypeSepia: title = @"怀旧"; break;
        case ZLFilterTypeGrayscale: title = @"黑白"; break;
        case ZLFilterTypeBrightness: title = @"高亮"; break;
        case ZLFilterTypeSketch: title = @"素描"; break;
        case ZLFilterTypeSmoothToon: title = @"卡通"; break;
        case ZLFilterTypeGaussianBlur: title = @"毛玻璃"; break;
        case ZLFilterTypeVignette: title = @"晕影"; break;
        case ZLFilterTypeEmboss: title = @"浮雕"; break;
        case ZLFilterTypeGamma: title = @"伽马"; break;
        case ZLFilterTypeBulgeDistortion: title = @"鱼眼"; break;
        case ZLFilterTypeStretchDistortion: title = @"哈哈镜"; break;
        case ZLFilterTypePinchDistortion: title = @"凹透镜"; break;
        case ZLFilterTypeColorInvert: title = @"反色"; break;
        default: title = nil;
    }
    _titleLabel.text = title;
}

- (void)setIconImage:(UIImage *)iconImage
{
    _iconImage = iconImage;
    [self filterImage:iconImage];
}

- (void)filterImage:(UIImage *)image
{
    if (!image) return;
    //加滤镜
    image = [ZLFilterTool filterImage:image filterType:self.filterType];
    _iconView.image = image;
}

@end
