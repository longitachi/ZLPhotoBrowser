//
//  ZLPhotoActionSheet.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZLSelectPhotoModel;

@interface ZLPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

/** 最大选择数 default is 10 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/** 预览图最大显示数 default is 20 */
@property (nonatomic, assign) NSInteger maxPreviewCount;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 * @brief 显示多选照片视图
 * @param sender
 *              调用该空间的视图控制器
 * @param animate
 *              是否显示动画效果
 * @param selectedAssets
 *              已选择的PHAsset，再次调用"showWithSender:animate:lastSelectPhotoModels:completion:"方法之前，可以把上次回调中selectAssets赋值给该属性，便可实现记录上次选择照片的功能，若不需要记录上次选择照片的功能，则该值传nil即可
 * @param completion
 *              完成回调
 */
- (void)showWithSender:(UIViewController *)sender
               animate:(BOOL)animate
        lastSelectPhotoModels:( NSArray<ZLSelectPhotoModel *> * _Nullable )lastSelectPhotoModels
            completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<ZLSelectPhotoModel *> *selectPhotoModels))completion;

NS_ASSUME_NONNULL_END

@end
