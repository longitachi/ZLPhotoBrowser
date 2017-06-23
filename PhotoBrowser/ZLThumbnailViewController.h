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

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verLeftSpace;
@property (weak, nonatomic) IBOutlet UIButton *btnPreView;
@property (weak, nonatomic) IBOutlet UIButton *btnOriginalPhoto;
@property (weak, nonatomic) IBOutlet UILabel *labPhotosBytes;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

//相册model
@property (nonatomic, strong) ZLAlbumListModel *albumListModel;

@end
