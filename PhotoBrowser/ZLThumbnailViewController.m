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
#import "ZLPhotoManager.h"
#import "ZLPhotoModel.h"
#import "ZLShowBigImgViewController.h"
#import "ZLPhotoBrowser.h"
#import "ToastUtils.h"
#import "ZLProgressHUD.h"
#import "ZLShowGifViewController.h"
#import "ZLShowVideoViewController.h"

@interface ZLThumbnailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    BOOL _isLayoutOK;
}

@property (nonatomic, strong) NSMutableArray<ZLPhotoModel *> *arrDataSources;
@property (nonatomic, assign) BOOL allowTakePhoto;

@end

@implementation ZLThumbnailViewController

- (NSMutableArray<ZLPhotoModel *> *)arrDataSources
{
    if (!_arrDataSources) {
        ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
        [hud show];
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        [ZLPhotoManager markSelcectModelInArr:self.albumListModel.models selArr:nav.arrSelectedModels];
        _arrDataSources = [NSMutableArray arrayWithArray:self.albumListModel.models];
        [hud hide];
    }
    return _arrDataSources;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.albumListModel.title;
    
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (self.albumListModel.isCameraRoll && nav.allowTakePhotoInLibrary && nav.allowSelectImage) {
        self.allowTakePhoto = YES;
    }
    
    [self.btnPreView setTitle:[NSBundle zlLocalizedStringForKey:ZLPhotoBrowserPreviewText] forState:UIControlStateNormal];
    [self.btnOriginalPhoto setTitle:[NSBundle zlLocalizedStringForKey:ZLPhotoBrowserOriginalText] forState:UIControlStateNormal];
    [self.btnDone setTitle:[NSBundle zlLocalizedStringForKey:ZLPhotoBrowserDoneText] forState:UIControlStateNormal];
    
    [self initNavBtn];
    [self initCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetBottomBtnsStatus];
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
        [self scrollToBottom];
    }
}

- (void)scrollToBottom
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (!nav.sortAscending) {
        return;
    }
    if (self.arrDataSources.count > 0) {
        NSInteger index = self.arrDataSources.count-1;
        if (self.allowTakePhoto) {
            index += 1;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)resetBottomBtnsStatus
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.arrSelectedModels.count > 0) {
        self.btnOriginalPhoto.enabled = YES;
        self.btnPreView.enabled = YES;
        self.btnDone.enabled = YES;
        [self.btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), nav.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:kDoneButton_bgColor forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:kDoneButton_bgColor forState:UIControlStateNormal];
        self.btnDone.backgroundColor = kDoneButton_bgColor;
        [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        [self.btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateDisabled];
        [self.btnOriginalPhoto setTitleColor:kButtonUnable_textColor forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:kButtonUnable_textColor forState:UIControlStateDisabled];
        self.btnDone.backgroundColor = kButtonUnable_textColor;
        [self.btnDone setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
    self.btnOriginalPhoto.selected = nav.isSelectOriginalPhoto;
    if (nav.isSelectOriginalPhoto) {
        [self getOriginalImageBytes];
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
    
    [self.collectionView registerClass:NSClassFromString(@"ZLTakePhotoCell") forCellWithReuseIdentifier:@"ZLTakePhotoCell"];
    [self.collectionView registerClass:NSClassFromString(@"ZLCollectionCell") forCellWithReuseIdentifier:@"ZLCollectionCell"];
}

- (void)initNavBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
//    UIImage *navBackImg = GetImageWithName(@"navBackBtn.png");
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(navLeftBtn_Click)];
}

#pragma mark - UIButton Action
- (IBAction)btnPreview_Click:(id)sender
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    [self pushShowBigImgVCWithDataArray:nav.arrSelectedModels selectIndex:nav.arrSelectedModels.count-1];
}

- (IBAction)btnOriginalPhoto_Click:(id)sender
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    self.btnOriginalPhoto.selected = !self.btnOriginalPhoto.selected;
    nav.isSelectOriginalPhoto = self.btnOriginalPhoto.selected;
    if (nav.isSelectOriginalPhoto) {
        [self getOriginalImageBytes];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (IBAction)btnDone_Click:(id)sender
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.callSelectImageBlock) {
        nav.callSelectImageBlock();
    }
}

- (void)navLeftBtn_Click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.cancelBlock) {
        nav.cancelBlock();
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
    if (self.allowTakePhoto) {
        return self.arrDataSources.count + 1;
    }
    return self.arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    if (self.allowTakePhoto && ((nav.sortAscending && indexPath.row >= self.arrDataSources.count) || (!nav.sortAscending && indexPath.row == 0))) {
        ZLTakePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLTakePhotoCell" forIndexPath:indexPath];
        return cell;
    }
    
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    
    ZLPhotoModel *model;
    if (!self.allowTakePhoto || nav.sortAscending) {
        model = self.arrDataSources[indexPath.row];
    } else {
        model = self.arrDataSources[indexPath.row-1];
    }
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    weakify(self);
    __weak typeof(nav) weakNav = nav;
    __weak typeof(cell) weakCell = cell;
    cell.selectedBlock = ^(BOOL selected) {
        strongify(weakSelf);
        __strong typeof(weakCell) strongCell = weakCell;
        __strong typeof(weakNav) strongNav = weakNav;
        if (!selected) {
            //选中
            if (nav.arrSelectedModels.count >= nav.maxSelectCount) {
                ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxSelectCountText), nav.maxSelectCount);
                return;
            }
            if (![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowseriCloudPhotoText));
                return;
            }
            model.isSelected = YES;
            [strongNav.arrSelectedModels addObject:model];
            strongCell.btnSelect.selected = YES;
        } else {
            strongCell.btnSelect.selected = NO;
            model.isSelected = NO;
            for (ZLPhotoModel *m in nav.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [strongNav.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
//        [collectionView reloadItemsAtIndexPaths:[collectionView indexPathsForVisibleItems]];
        [strongSelf resetBottomBtnsStatus];
    };
    cell.isSelectedImage = ^BOOL() {
        strongify(weakSelf);
        ZLImageNavigationController *nav = (ZLImageNavigationController *)strongSelf.navigationController;
        return nav.arrSelectedModels.count > 0;
    };
    cell.allSelectGif = nav.allowSelectGif;
    cell.model = model;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (self.allowTakePhoto && ((nav.sortAscending && indexPath.row >= self.arrDataSources.count) || (!nav.sortAscending && indexPath.row == 0))) {
        //拍照
        [self takePhoto];
        return;
    }
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !nav.sortAscending) {
        index = indexPath.row - 1;
    }
    ZLPhotoModel *model = self.arrDataSources[index];
    
    if (model.type == ZLAssetMediaTypeVideo) {
        if (nav.arrSelectedModels.count > 0) {
            ShowToastLong(@"%@", [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserCannotSelectVideo]);
            return;
        }
        //跳转预览视频
        ZLShowVideoViewController *vc = [[ZLShowVideoViewController alloc] init];
        vc.model = model;
        [self showViewController:vc sender:self];
    } else if (nav.allowSelectGif && model.type == ZLAssetMediaTypeGif) {
        if (nav.arrSelectedModels.count > 0) {
            ShowToastLong(@"%@", [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserCannotSelectGIF]);
            return;
        }
        //跳转预览GIF
        ZLShowGifViewController *vc = [[ZLShowGifViewController alloc] init];
        vc.model = model;
        [self showViewController:vc sender:self];
    } else {
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        
        NSArray *arr = [ZLPhotoManager getPhotoInResult:self.albumListModel.result allowSelectVideo:NO allowSelectImage:YES allowSelectGif:!nav.allowSelectGif];
        
        NSMutableArray *selIdentifiers = [NSMutableArray array];
        for (ZLPhotoModel *m in nav.arrSelectedModels) {
            [selIdentifiers addObject:m.asset.localIdentifier];
        }
        
        int i = 0;
        BOOL isFind = NO;
        for (ZLPhotoModel *m in arr) {
            if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                isFind = YES;
            }
            if ([selIdentifiers containsObject:m.asset.localIdentifier]) {
                m.isSelected = YES;
            }
            if (!isFind) {
                i++;
            }
        }

        [self pushShowBigImgVCWithDataArray:arr selectIndex:i];
    }
}

- (void)takePhoto
{
    //拍照
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self showDetailViewController:picker sender:self];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        strongify(weakSelf);
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
        [hud show];
        
        [ZLPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (suc) {
                    ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeImage duration:nil];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveImageErrorText));
                }
                [hud hide];
            });
        }];
    }];
}

- (void)handleDataArray:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.sortAscending) {
        [self.arrDataSources addObject:model];
    } else {
        [self.arrDataSources insertObject:model atIndex:0];
    }
    if (nav.arrSelectedModels.count < nav.maxSelectCount) {
        model.isSelected = YES;
        [nav.arrSelectedModels addObject:model];
    }
    [self.collectionView reloadData];
    [self scrollToBottom];
    [self resetBottomBtnsStatus];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushShowBigImgVCWithDataArray:(NSArray<ZLPhotoModel *> *)dataArray selectIndex:(NSInteger)selectIndex
{
    ZLShowBigImgViewController *svc = [[ZLShowBigImgViewController alloc] init];
    svc.models = dataArray;
    svc.selectIndex = selectIndex;
    weakify(self);
    [svc setBtnBackBlock:^(NSArray<ZLPhotoModel *> *selectedModels, BOOL isOriginal) {
        strongify(weakSelf);
        [ZLPhotoManager markSelcectModelInArr:strongSelf.arrDataSources selArr:selectedModels];
        [strongSelf.collectionView reloadData];
    }];
    [self.navigationController showViewController:svc sender:self];
}

- (void)getOriginalImageBytes
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    weakify(self);
    [ZLPhotoManager getPhotosBytesWithArray:nav.arrSelectedModels completion:^(NSString *photosBytes) {
        strongify(weakSelf);
        strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
    }];
}

@end
