//
//  ZLThumbnailViewController.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLThumbnailViewController.h"
#import <Photos/Photos.h>
#import "ZLDefine.h"
#import "ZLCollectionCell.h"
#import "ZLPhotoTool.h"
#import "ZLSelectPhotoModel.h"
#import "ZLAnimationTool.h"
#import "ZLShowBigImgViewController.h"
#import "ZLPhotoBrowser.h"
#import "ToastUtils.h"

@interface ZLThumbnailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray<PHAsset *> *_arrayDataSources;
    
    BOOL _isLayoutOK;
}
@end

@implementation ZLThumbnailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrayDataSources = [NSMutableArray array];
    
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    
    [self initNavBtn];
    [self initCollectionView];
    [self getAssetInAssetCollection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isLayoutOK = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!_isLayoutOK) {
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
            [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height-self.collectionView.frame.size.height)];
        }
    }
}

- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((kViewWidth-9)/4, (kViewWidth-9)/4);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZLCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ZLCollectionCell"];
}

- (void)getAssetInAssetCollection
{
    [_arrayDataSources addObjectsFromArray:[[ZLPhotoTool sharePhotoTool] getAssetsInAssetCollection:self.assetCollection ascending:YES]];
    self.labCount.text = [NSString stringWithFormat:@"共%ld张照片", _arrayDataSources.count];
}

- (void)initNavBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navBackBtn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(navLeftBtn_Click)];
}

#pragma mark - UIButton Action
- (void)cell_btn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount) {
        ShowToastLong(@"最多只能选择%ld张图片", self.maxSelectCount);
        return;
    }
    btn.selected = !btn.selected;
    
    PHAsset *asset = _arrayDataSources[btn.tag];
    ZLCollectionCell *cell = (ZLCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:btn.tag inSection:0]];
    if (btn.selected) {
        [btn.layer addAnimation:[ZLAnimationTool animateWithBtnStatusChanged] forKey:nil];
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.image = cell.imageView.image;
        model.imageName = [asset valueForKey:@"filename"];
        [_arraySelectPhotos addObject:model];
    } else {
        for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
            if ([model.imageName isEqualToString:[asset valueForKey:@"filename"]]) {
                [_arraySelectPhotos removeObject:model];
                break;
            }
        }
    }
}

- (IBAction)btnDone_Click:(id)sender
{
    if (self.DoneBlock) {
        self.DoneBlock(self.arraySelectPhotos);
    }
    [self.navigationController.view.layer addAnimation:[ZLAnimationTool animateWithType:kCATransitionMoveIn subType:kCATransitionFromBottom duration:0.3] forKey:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)navLeftBtn_Click
{
    self.sender.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    [self.navigationController.view.layer addAnimation:[ZLAnimationTool animateWithType:kCATransitionMoveIn subType:kCATransitionFromBottom duration:0.3] forKey:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrayDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    
    cell.btnSelect.selected = NO;
    PHAsset *asset = _arrayDataSources[indexPath.row];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    
    CGSize size = cell.frame.size;
    size.width *= 2;
    size.height *= 2;
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image) {
        cell.imageView.image = image;
        for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
            if ([model.imageName isEqualToString:[asset valueForKey:@"filename"]]) {
                cell.btnSelect.selected = YES;
                break;
            }
        }
    }];
    
    cell.btnSelect.tag = indexPath.row;
    [cell.btnSelect addTarget:self action:@selector(cell_btn_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLShowBigImgViewController *svc = [[ZLShowBigImgViewController alloc] init];
    svc.assets         = _arrayDataSources;
    svc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    svc.selectIndex    = indexPath.row;
    svc.maxSelectCount = _maxSelectCount;
    svc.showPopAnimate = NO;
    svc.shouldReverseAssets = NO;
    __weak typeof(ZLThumbnailViewController *) weakSelf = self;
    [svc setOnSelectedPhotos:^(NSArray<ZLSelectPhotoModel *> *selectedPhotos) {
        [_arraySelectPhotos removeAllObjects];
        [_arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [weakSelf.collectionView reloadData];
    }];
    
    [self.navigationController pushViewController:svc animated:YES];
}

@end
