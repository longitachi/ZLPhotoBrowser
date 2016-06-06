//
//  ZLBigImageCell.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;

@interface ZLBigImageCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy)   void (^singleTapCallBack)();

@end
