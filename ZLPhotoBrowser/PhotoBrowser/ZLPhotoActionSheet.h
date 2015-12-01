//
//  ZLPhotoActionSheet.h
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//最大选择数 default is 20
@property (nonatomic, assign) NSInteger maxSelectCount;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (void)showWithSender:(UIViewController *)sender animate:(BOOL)animate completion:(void (^)(NSArray<UIImage *> *selectPhotos))completion;

NS_ASSUME_NONNULL_END

@end
