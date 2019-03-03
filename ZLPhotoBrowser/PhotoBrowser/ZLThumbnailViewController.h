//
//  ZLThumbnailViewController.h
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLAlbumListModel;

@interface ZLThumbnailViewController : UIViewController

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *bline;
@property (nonatomic, strong) UIButton *btnEdit;
@property (nonatomic, strong) UIButton *btnPreView;
@property (nonatomic, strong) UIButton *btnOriginalPhoto;
@property (nonatomic, strong) UILabel *labPhotosBytes;
@property (nonatomic, strong) UIButton *btnDone;

//相册model
@property (nonatomic, strong) ZLAlbumListModel *albumListModel;

@end
