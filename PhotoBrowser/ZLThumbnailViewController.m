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
    
    [self resetBottomBtnsStatus];
    [self getOriginalImageBytes];
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

- (void)resetBottomBtnsStatus
{
    if (self.arraySelectPhotos.count > 0) {
        self.btnOriginalPhoto.enabled = YES;
        self.btnPreView.enabled = YES;
        self.btnDone.enabled = YES;
        [self.btnDone setTitle:[NSString stringWithFormat:@"确定(%ld)", self.arraySelectPhotos.count] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:kRGB(80, 180, 234) forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:kRGB(80, 180, 234) forState:UIControlStateNormal];
        self.btnDone.backgroundColor = kRGB(80, 180, 234);
        [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        [self.btnDone setTitle:@"确定" forState:UIControlStateDisabled];
        [self.btnOriginalPhoto setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
        self.btnDone.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self.btnDone setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
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
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZLCollectionCell" bundle:kZLPhotoBrowserBundle] forCellWithReuseIdentifier:@"ZLCollectionCell"];
}

- (void)getAssetInAssetCollection
{
    [_arrayDataSources addObjectsFromArray:[[ZLPhotoTool sharePhotoTool] getAssetsInAssetCollection:self.assetCollection ascending:YES]];
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
    
    UIImage *navBackImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"navBackBtn.png")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"navBackBtn.png")];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(navLeftBtn_Click)];
}

#pragma mark - UIButton Action
- (void)cell_btn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        ShowToastLong(@"最多只能选择%ld张图片", self.maxSelectCount);
        return;
    }
    
    PHAsset *asset = _arrayDataSources[btn.tag];

    if (!btn.selected) {
        //添加图片到选中数组
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        if (![[ZLPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"该图片尚未从iCloud下载，请在系统相册中下载到本地后重新尝试，或在预览大图中加载完毕后选择");
            return;
        }
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    } else {
        for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                [_arraySelectPhotos removeObject:model];
                break;
            }
        }
    }
    
    btn.selected = !btn.selected;
    [self resetBottomBtnsStatus];
    [self getOriginalImageBytes];
}

- (IBAction)btnPreview_Click:(id)sender
{
    NSMutableArray<PHAsset *> *arrSel = [NSMutableArray array];
    for (ZLSelectPhotoModel *model in self.arraySelectPhotos) {
        [arrSel addObject:model.asset];
    }
    [self pushShowBigImgVCWithDataArray:arrSel selectIndex:arrSel.count-1];
}

- (IBAction)btnOriginalPhoto_Click:(id)sender
{
    self.isSelectOriginalPhoto = !self.btnOriginalPhoto.selected;
    [self getOriginalImageBytes];
}

- (IBAction)btnDone_Click:(id)sender
{
    if (self.DoneBlock) {
        self.DoneBlock(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
}

- (void)navLeftBtn_Click
{
    self.sender.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    self.sender.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    size.width *= 3;
    size.height *= 3;
    weakify(self);
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
        strongify(weakSelf);
        cell.imageView.image = image;
        for (ZLSelectPhotoModel *model in strongSelf.arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
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
    [self pushShowBigImgVCWithDataArray:_arrayDataSources selectIndex:indexPath.row];
}

- (void)pushShowBigImgVCWithDataArray:(NSArray<PHAsset *> *)dataArray selectIndex:(NSInteger)selectIndex
{
    ZLShowBigImgViewController *svc = [[ZLShowBigImgViewController alloc] init];
    svc.assets         = dataArray;
    svc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    svc.selectIndex    = selectIndex;
    svc.maxSelectCount = _maxSelectCount;
    svc.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    svc.isPresent = NO;
    svc.shouldReverseAssets = NO;
    
    weakify(self);
    [svc setOnSelectedPhotos:^(NSArray<ZLSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        strongify(weakSelf);
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf.arraySelectPhotos removeAllObjects];
        [strongSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf.collectionView reloadData];
        [strongSelf getOriginalImageBytes];
        [strongSelf resetBottomBtnsStatus];
    }];
    [svc setBtnDoneBlock:^(NSArray<ZLSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        strongify(weakSelf);
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf.arraySelectPhotos removeAllObjects];
        [strongSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf btnDone_Click:nil];
    }];
    
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)getOriginalImageBytes
{
    weakify(self);
    if (self.isSelectOriginalPhoto && self.arraySelectPhotos.count > 0) {
        [[ZLPhotoTool sharePhotoTool] getPhotosBytesWithArray:self.arraySelectPhotos completion:^(NSString *photosBytes) {
            strongify(weakSelf);
            strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
        }];
        self.btnOriginalPhoto.selected = self.isSelectOriginalPhoto;
    } else {
        self.btnOriginalPhoto.selected = NO;
        self.labPhotosBytes.text = nil;
    }
}

@end
