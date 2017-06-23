//
//  ZLBigImageCell.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoModel;
@class PHAsset;
@class ZLBigImageView;

@interface ZLBigImageCell : UICollectionViewCell

@property (nonatomic, strong) ZLBigImageView *bigImageView;
@property (nonatomic, strong) ZLPhotoModel *model;
@property (nonatomic, copy)   void (^singleTapCallBack)();

- (void)resetCellStatus;

@end

@interface ZLBigImageView : UIView


@property (nonatomic, copy)   void (^singleTapCallBack)();

- (void)loadNormalImage:(PHAsset *)asset;
- (void)loadGifImage:(PHAsset *)asset;
- (void)resetScale;

- (UIImage *)image;

@end
