//
//  ZLCollectionCell.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoModel;

@interface ZLCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *btnSelect;
@property (nonatomic, strong) UIImageView *videoBottomView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UILabel *timeLabel;
//@property (nonatomic, strong) UIView *topView;

@property (nonatomic, assign) BOOL allSelectGif;
@property (nonatomic, strong) ZLPhotoModel *model;

@property (nonatomic, copy) void (^selectedBlock)(BOOL);

@property (nonatomic, copy) BOOL (^isSelectedImage)();

@end



@interface ZLTakePhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end
