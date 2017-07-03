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
#import "ZLShowLivePhotoViewController.h"
#import "ZLForceTouchPreviewController.h"
#import "ZLEditViewController.h"

@interface ZLThumbnailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerPreviewingDelegate>
{
    BOOL _isLayoutOK;
    BOOL _haveTakePic;
}

@property (nonatomic, strong) NSMutableArray<ZLPhotoModel *> *arrDataSources;
@property (nonatomic, assign) BOOL allowTakePhoto;

@end

@implementation ZLThumbnailViewController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

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
    
    [self.btnEdit setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserEditText) forState:UIControlStateNormal];
    [self.btnPreView setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserPreviewText) forState:UIControlStateNormal];
    [self.btnOriginalPhoto setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText) forState:UIControlStateNormal];
    [self.btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    self.bottomView.backgroundColor = kBottomView_color;
    
    if (!nav.allowEditImage) {
        [self.verLeftSpace setConstant:-5-self.btnEdit.bounds.size.width];
        self.btnEdit.hidden = YES;
    }
    
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

- (BOOL)forceTouchAvailable
{
    return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
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
        if (nav.isSelectOriginalPhoto) {
            [self getOriginalImageBytes];
        } else {
            self.labPhotosBytes.text = nil;
        }
        self.btnOriginalPhoto.selected = nav.isSelectOriginalPhoto;
        [self.btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), nav.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:kDoneButton_bgColor forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:kDoneButton_bgColor forState:UIControlStateNormal];
        self.btnDone.backgroundColor = kDoneButton_bgColor;
        [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.btnOriginalPhoto.selected = NO;
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        self.labPhotosBytes.text = nil;
        [self.btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateDisabled];
        [self.btnOriginalPhoto setTitleColor:kButtonUnable_textColor forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:kButtonUnable_textColor forState:UIControlStateDisabled];
        self.btnDone.backgroundColor = kButtonUnable_textColor;
        [self.btnDone setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
    
    [self.btnEdit setTitleColor:nav.arrSelectedModels.count==1?kDoneButton_bgColor:kButtonUnable_textColor forState:UIControlStateNormal];
    self.btnEdit.userInteractionEnabled = nav.arrSelectedModels.count==1;
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
    //注册3d touch
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.allowForceTouch && [self forceTouchAvailable]) {
        [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
    }
}

- (void)initNavBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:kNavBar_tintColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - UIButton Action
- (IBAction)btnEdit_Click:(id)sender {
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLEditViewController *vc = [[ZLEditViewController alloc] init];
    vc.model = nav.arrSelectedModels.firstObject;
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)btnPreview_Click:(id)sender
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    UIViewController *vc = [self getBigImageVCWithData:nav.arrSelectedModels index:nav.arrSelectedModels.count-1];
    [self.navigationController showViewController:vc sender:nil];
}

- (UIViewController *)getBigImageVCWithData:(NSArray<ZLPhotoModel *> *)data index:(NSInteger)index
{
    ZLShowBigImgViewController *vc = [[ZLShowBigImgViewController alloc] init];
    vc.models = data.copy;
    vc.selectIndex = index;
    weakify(self);
    [vc setBtnBackBlock:^(NSArray<ZLPhotoModel *> *selectedModels, BOOL isOriginal) {
        strongify(weakSelf);
        [ZLPhotoManager markSelcectModelInArr:strongSelf.arrDataSources selArr:selectedModels];
        [strongSelf.collectionView reloadData];
    }];
    return vc;
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
    [nav dismissViewControllerAnimated:YES completion:nil];
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
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = nav.cellCornerRadio;
        if (nav.showCaptureImageOnTakePhotoBtn) {
            if (!_isLayoutOK || _haveTakePic) {
                [cell restartCapture];
            } else {
                [cell startCapture];
            }
        }
        return cell;
    }
    
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    
    ZLPhotoModel *model;
    if (!self.allowTakePhoto || nav.sortAscending) {
        model = self.arrDataSources[indexPath.row];
    } else {
        model = self.arrDataSources[indexPath.row-1];
    }

    weakify(self);
    __weak typeof(cell) weakCell = cell;
    
    cell.selectedBlock = ^(BOOL selected) {
        strongify(weakSelf);
        __strong typeof(weakCell) strongCell = weakCell;
        
        ZLImageNavigationController *weakNav = (ZLImageNavigationController *)strongSelf.navigationController;
        if (!selected) {
            //选中
            if (weakNav.arrSelectedModels.count >= weakNav.maxSelectCount) {
                ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxSelectCountText), weakNav.maxSelectCount);
                return;
            }
            if (![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowseriCloudPhotoText));
                return;
            }
            model.isSelected = YES;
            [weakNav.arrSelectedModels addObject:model];
            strongCell.btnSelect.selected = YES;
        } else {
            strongCell.btnSelect.selected = NO;
            model.isSelected = NO;
            for (ZLPhotoModel *m in weakNav.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [weakNav.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
//        [collectionView reloadItemsAtIndexPaths:[collectionView indexPathsForVisibleItems]];
        [strongSelf resetBottomBtnsStatus];
    };
////    cell.isSelectedImage = ^BOOL() {
////        strongify(weakSelf);
////        ZLImageNavigationController *nav = (ZLImageNavigationController *)strongSelf.navigationController;
////        return nav.arrSelectedModels.count > 0;
////    };
    cell.allSelectGif = nav.allowSelectGif;
    cell.allSelectLivePhoto = nav.allowSelectLivePhoto;
    cell.showSelectBtn = nav.showSelectBtn;
    cell.cornerRadio = nav.cellCornerRadio;
    cell.model = model;

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (self.allowTakePhoto && ((nav.sortAscending && indexPath.row >= self.arrDataSources.count) || (!nav.sortAscending && indexPath.row == 0))) {
        //拍照
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusRestricted ||
            status == AVAuthorizationStatusDenied) {
            NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoCameraAuthorityText), [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(ZLPhotoBrowserOKText) style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        [self takePhoto];
        return;
    }
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !nav.sortAscending) {
        index = indexPath.row - 1;
    }
    ZLPhotoModel *model = self.arrDataSources[index];
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:nil];
    }
}

/**
 获取对应的vc
 */
- (UIViewController *)getMatchVCWithModel:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    if (model.type == ZLAssetMediaTypeVideo) {
        if (nav.arrSelectedModels.count > 0) {
            ShowToastLong(@"%@", [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserCannotSelectVideo]);
            return nil;
        }
        //跳转预览视频
        ZLShowVideoViewController *vc = [[ZLShowVideoViewController alloc] init];
        vc.model = model;
        return vc;
    } else if (nav.allowSelectGif && model.type == ZLAssetMediaTypeGif) {
        if (nav.arrSelectedModels.count > 0) {
            ShowToastLong(@"%@", [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserCannotSelectGIF]);
            return nil;
        }
        //跳转预览GIF
        ZLShowGifViewController *vc = [[ZLShowGifViewController alloc] init];
        vc.model = model;
        return vc;
    } else if (nav.allowSelectLivePhoto && model.type == ZLAssetMediaTypeLivePhoto) {
        if (nav.arrSelectedModels.count > 0) {
            ShowToastLong(@"%@", [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserCannotSelectLivePhoto]);
            return nil;
        }
        //跳转预览GIF
        ZLShowLivePhotoViewController *vc = [[ZLShowLivePhotoViewController alloc] init];
        vc.model = model;
        return vc;
    } else {
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        
        NSArray *arr = [ZLPhotoManager getPhotoInResult:self.albumListModel.result allowSelectVideo:NO allowSelectImage:YES allowSelectGif:!nav.allowSelectGif allowSelectLivePhoto:!nav.allowSelectLivePhoto];
        
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
        
        return [self getBigImageVCWithData:arr index:i];
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
    if (nav.maxSelectCount > 1 && nav.arrSelectedModels.count < nav.maxSelectCount) {
        model.isSelected = YES;
        [nav.arrSelectedModels addObject:model];
        self.albumListModel = [ZLPhotoManager getCameraRollAlbumList:nav.allowSelectVideo allowSelectImage:nav.allowSelectImage];
    } else if (nav.maxSelectCount == 1 && !nav.arrSelectedModels.count) {
        model.isSelected = YES;
        [nav.arrSelectedModels addObject:model];
        [self btnDone_Click:nil];
        return;
    }
    [self.collectionView reloadData];
    [self scrollToBottom];
    [self resetBottomBtnsStatus];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - UIViewControllerPreviewingDelegate
//!!!!: 3D Touch
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if (!indexPath) {
        return nil;
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZLTakePhotoCell class]]) {
        return nil;
    }
    
    //设置突出区域
    previewingContext.sourceRect = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    
    ZLForceTouchPreviewController *vc = [[ZLForceTouchPreviewController alloc] init];
    
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !nav.sortAscending) {
        index = indexPath.row - 1;
    }
    ZLPhotoModel *model = self.arrDataSources[index];
    vc.model = model;
    vc.allowSelectGif = nav.allowSelectGif;
    vc.allowSelectLivePhoto = nav.allowSelectLivePhoto;
    
    vc.preferredContentSize = [self getSize:model];
    
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    ZLPhotoModel *model = [(ZLForceTouchPreviewController *)viewControllerToCommit model];
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:self];
    }
}

- (CGSize)getSize:(ZLPhotoModel *)model
{
    CGFloat w = MIN(model.asset.pixelWidth, kViewWidth);
    CGFloat h = w * model.asset.pixelHeight / model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kViewHeight || isnan(h)) {
        h = kViewHeight;
        w = h * model.asset.pixelWidth / model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
}

@end
