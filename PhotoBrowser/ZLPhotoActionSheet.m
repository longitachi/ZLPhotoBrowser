//
//  ZLPhotoActionSheet.m
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLPhotoActionSheet.h"
#import <Photos/Photos.h>
#import "ZLCollectionCell.h"
#import "ZLDefine.h"
#import "ZLPhotoModel.h"
#import "ZLPhotoManager.h"
#import "ZLPhotoBrowser.h"
#import "ZLShowBigImgViewController.h"
#import "ZLThumbnailViewController.h"
#import "ZLNoAuthorityViewController.h"
#import "ToastUtils.h"
#import "ZLShowGifViewController.h"
#import "ZLShowVideoViewController.h"
#import "ZLShowLivePhotoViewController.h"

#define kBaseViewHeight (self.maxPreviewCount ? 300 : 142)

double const ScalePhotoWidth = 1000;

@interface ZLPhotoActionSheet () <UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnAblum;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verColHeight;


@property (nonatomic, assign) BOOL animate;
@property (nonatomic, assign) BOOL preview;

@property (nonatomic, strong) NSMutableArray<ZLPhotoModel *> *arrDataSources;

@property (nonatomic, copy) NSMutableArray<ZLPhotoModel *> *arrSelectedModels;

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, assign) BOOL senderTabBarIsShow;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation ZLPhotoActionSheet

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (NSMutableArray<ZLPhotoModel *> *)arrDataSources
{
    if (!_arrDataSources) {
        _arrDataSources = [NSMutableArray array];
    }
    return _arrDataSources;
}

- (NSMutableArray<ZLPhotoModel *> *)arrSelectedModels
{
    if (!_arrSelectedModels) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}

- (UILabel *)placeholderLabel
{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 100)];
        _placeholderLabel.text = GetLocalLanguageTextValue(ZLPhotoBrowserNoPhotoText);
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderLabel.textColor = [UIColor darkGrayColor];
        _placeholderLabel.font = [UIFont systemFontOfSize:15];
        _placeholderLabel.center = self.collectionView.center;
        [self.collectionView addSubview:_placeholderLabel];
        _placeholderLabel.hidden = YES;
    }
    return _placeholderLabel;
}

- (void)setArrSelectedAssets:(NSMutableArray<PHAsset *> *)arrSelectedAssets
{
    _arrSelectedAssets = arrSelectedAssets;
    [self.arrSelectedModels removeAllObjects];
    for (PHAsset *asset in arrSelectedAssets) {
        if (asset.mediaType != PHAssetMediaTypeImage) {
            //选择的视频不做保存
            continue;
        }
        ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeImage duration:nil];
        model.isSelected = YES;
        [self.arrSelectedModels addObject:model];
    }
}

- (void)setAllowSelectLivePhoto:(BOOL)allowSelectLivePhoto
{
    _allowSelectLivePhoto = allowSelectLivePhoto;
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
        _allowSelectLivePhoto = NO;
    }
}

- (instancetype)init
{
    self = [[kZLPhotoBrowserBundle loadNibNamed:@"ZLPhotoActionSheet" owner:self options:nil] lastObject];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerClass:NSClassFromString(@"ZLCollectionCell") forCellWithReuseIdentifier:@"ZLCollectionCell"];
        
        self.maxSelectCount = 10;
        self.maxPreviewCount = 20;
        self.cellCornerRadio = .0;
        self.allowSelectImage = YES;
        self.allowSelectVideo = YES;
        self.allowSelectGif = YES;
        self.allowSelectLivePhoto = NO;
        self.allowTakePhotoInLibrary = YES;
        self.allowForceTouch = YES;
        self.allowEditImage = YES;
        self.showCaptureImageOnTakePhotoBtn = YES;
        self.sortAscending = YES;
        self.showSelectBtn = NO;
        
        if (![self judgeIsHavePhotoAblumAuthority]) {
            //注册实施监听相册变化
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.btnCamera setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCameraText) forState:UIControlStateNormal];
    [self.btnAblum setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserAblumText) forState:UIControlStateNormal];
    [self.btnCancel setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [self resetSubViewState];
}

//相册变化回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.preview) {
            [self loadPhotoFromAlbum];
            [self show];
        } else {
            [self btnPhotoLibrary_Click:nil];
        }
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    });
}

- (void)showPreviewAnimated:(BOOL)animate sender:(UIViewController *)sender
{
    self.sender = sender;
    [self showPreviewAnimated:animate];
}

- (void)showPreviewAnimated:(BOOL)animate
{
    [self showPreview:YES animate:animate];
}

- (void)showPhotoLibraryWithSender:(UIViewController *)sender
{
    self.sender = sender;
    [self showPhotoLibrary];
}

- (void)showPhotoLibrary
{
    [self showPreview:NO animate:NO];
}

- (void)showPreview:(BOOL)preview animate:(BOOL)animate
{
    if (!self.allowSelectImage && self.arrSelectedModels.count) {
        [self.arrSelectedAssets removeAllObjects];
        [self.arrSelectedModels removeAllObjects];
    }
    if (self.maxSelectCount > 1) {
        self.showSelectBtn = YES;
    }
    self.animate = animate;
    self.preview = preview;
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    [ZLPhotoManager setSortAscending:self.sortAscending];
    
    if (!self.maxPreviewCount) {
        self.verColHeight.constant = .0;
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        [self showNoAuthorityVC];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
        
        [self.sender.view addSubview:self];
    }
    
    if (preview) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self loadPhotoFromAlbum];
            [self show];
        } else if (status == PHAuthorizationStatusRestricted ||
                   status == PHAuthorizationStatusDenied) {
            [self showNoAuthorityVC];
        }
    } else {
        if (status == PHAuthorizationStatusAuthorized) {
            [self.sender.view addSubview:self];
            [self btnPhotoLibrary_Click:nil];
        } else if (status == PHAuthorizationStatusRestricted ||
                   status == PHAuthorizationStatusDenied) {
            [self showNoAuthorityVC];
        }
    }
}

- (void)previewSelectedPhotos:(NSArray<UIImage *> *)photos assets:(NSArray<PHAsset *> *)assets index:(NSInteger)index
{
    self.arrSelectedAssets = [NSMutableArray arrayWithArray:assets];
    ZLShowBigImgViewController *svc = [[ZLShowBigImgViewController alloc] init];
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:svc];
    nav.showSelectBtn = YES;
    svc.selectIndex = index;
    svc.arrSelPhotos = [NSMutableArray arrayWithArray:photos];
    svc.models = self.arrSelectedModels;
    weakify(self);
    __weak typeof(nav) weakNav = nav;
    [svc setBtnDonePreviewBlock:^(NSArray<UIImage *> *photos, NSArray<PHAsset *> *assets) {
        strongify(weakSelf);
        __strong typeof(weakNav) strongNav = weakNav;
        if (strongSelf.selectImageBlock) {
            strongSelf.selectImageBlock(photos, assets, NO);
        }
        [strongNav dismissViewControllerAnimated:YES completion:nil];
    }];
    self.preview = NO;
    [self.sender.view addSubview:self];
    [self.sender showDetailViewController:nav sender:nil];
}

#pragma mark - 判断软件是否有相册、相机访问权限
- (BOOL)judgeIsHavePhotoAblumAuthority
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

- (BOOL)judgeIsHaveCameraAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(ZLPhotoBrowserOKText) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self.sender presentViewController:alert animated:YES completion:nil];
}

- (void)loadPhotoFromAlbum
{
    [self.arrDataSources removeAllObjects];
    //因为预览界面需快速选择最近图片，所以不受self.sortAscending限制，
    //这里allow gif和allow liveohoto 置为yes，为了获取所有asset
    [self.arrDataSources addObjectsFromArray:[ZLPhotoManager getAllAssetInPhotoAlbumWithAscending:NO limitCount:self.maxPreviewCount allowSelectVideo:self.allowSelectVideo allowSelectImage:self.allowSelectImage allowSelectGif:YES allowSelectLivePhoto:YES]];
    [ZLPhotoManager markSelcectModelInArr:self.arrDataSources selArr:self.arrSelectedModels];
    [self.collectionView reloadData];
}

#pragma mark - 显示隐藏视图及相关动画
- (void)resetSubViewState
{
    self.hidden = ![self judgeIsHavePhotoAblumAuthority] || !self.preview;
    [self changeCancelBtnTitle];
    [self.collectionView setContentOffset:CGPointZero];
}

- (void)show
{
    self.frame = self.sender.view.bounds;
    if (!self.superview) {
        [self.sender.view addSubview:self];
    }
    if (self.sender.tabBarController.tabBar.hidden == NO) {
        self.senderTabBarIsShow = YES;
        self.sender.tabBarController.tabBar.hidden = YES;
    }
    
    if (self.animate) {
        __block CGRect frame = self.baseView.frame;
        frame.origin.y += kBaseViewHeight;
        self.baseView.frame = frame;
        [UIView animateWithDuration:0.2 animations:^{
            frame.origin.y -= kBaseViewHeight;
            self.baseView.frame = frame;
        } completion:nil];
    }
}

- (void)hide
{
    if (self.animate) {
        __block CGRect frame = self.baseView.frame;
        frame.origin.y += kBaseViewHeight;
        [UIView animateWithDuration:0.2 animations:^{
            self.baseView.frame = frame;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            [self removeFromSuperview];
        }];
    } else {
        self.hidden = YES;
        [self removeFromSuperview];
    }
    if (self.senderTabBarIsShow) {
        self.sender.tabBarController.tabBar.hidden = NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hide];
}

#pragma mark - UIButton Action
- (IBAction)btnCamera_Click:(id)sender
{
    if (![self judgeIsHaveCameraAuthority]) {
        NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoCameraAuthorityText), [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];
        [self showAlertWithTitle:nil message:message];
        [self hide];
        return;
    }
    //拍照
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.sender presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)btnPhotoLibrary_Click:(id)sender
{
    if (![self judgeIsHavePhotoAblumAuthority]) {
        [self showNoAuthorityVC];
    } else {
        self.animate = NO;
        [self pushThumbnailViewController];
    }
}

- (IBAction)btnCancel_Click:(id)sender
{
    if (self.arrSelectedModels.count) {
        [self requestSelPhotos:nil];
        return;
    }
    [self hide];
}

- (void)changeCancelBtnTitle
{
    if (self.arrSelectedModels.count > 0) {
        [self.btnCancel setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), self.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:kDoneButton_bgColor forState:UIControlStateNormal];
    } else {
        [self.btnCancel setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 请求所选择图片、回调
- (void)requestSelPhotos:(UIViewController *)vc
{
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.arrSelectedModels.count];
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:self.arrSelectedModels.count];
    for (int i = 0; i < self.arrSelectedModels.count; i++) {
        [photos addObject:@""];
        [assets addObject:@""];
    }
    
    weakify(self);
    for (int i = 0; i < self.arrSelectedModels.count; i++) {
        ZLPhotoModel *model = self.arrSelectedModels[i];
        [ZLPhotoManager requestSelectedImageForAsset:model isOriginal:self.isSelectOriginalPhoto allowSelectGif:self.allowSelectGif completion:^(UIImage *image, NSDictionary *info) {
            if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
            
            strongify(weakSelf);
            if (image) {
                [photos replaceObjectAtIndex:i withObject:[self scaleImage:image]];
                [assets replaceObjectAtIndex:i withObject:model.asset];
            }
            
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) return;
            }
            
            [hud hide];
            if (strongSelf.selectImageBlock) {
                strongSelf.selectImageBlock(photos, assets, strongSelf.isSelectOriginalPhoto);
            }
            [strongSelf hide];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

/**
 * @brief 这里对拿到的图片进行缩放，不然原图直接返回的话会造成内存暴涨
 */
- (UIImage *)scaleImage:(UIImage *)image
{
    CGSize size = CGSizeMake(ScalePhotoWidth, ScalePhotoWidth * image.size.height / image.size.width);
    if (image.size.width < size.width
        ) {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.arrDataSources.count == 0) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
    return self.arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    
    ZLPhotoModel *model = self.arrDataSources[indexPath.row];
    
    weakify(self);
    __weak typeof(cell) weakCell = cell;
    cell.selectedBlock = ^(BOOL selected) {
        strongify(weakSelf);
        __strong typeof(weakCell) strongCell = weakCell;
        if (!selected) {
            //选中
            if (strongSelf.arrSelectedModels.count >= strongSelf.maxSelectCount) {
                ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxSelectCountText), strongSelf.maxSelectCount);
                return;
            }
            if (![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowseriCloudPhotoText));
                return;
            }
            model.isSelected = YES;
            [strongSelf.arrSelectedModels addObject:model];
            strongCell.btnSelect.selected = YES;
        } else {
            strongCell.btnSelect.selected = NO;
            model.isSelected = NO;
            for (ZLPhotoModel *m in strongSelf.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [strongSelf.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
        [strongSelf changeCancelBtnTitle];
//        [collectionView reloadItemsAtIndexPaths:[collectionView indexPathsForVisibleItems]];
    };
    
    cell.isSelectedImage = ^BOOL() {
        strongify(weakSelf);
        return strongSelf.arrSelectedModels.count > 0;
    };
    cell.allSelectGif = self.allowSelectGif;
    cell.allSelectLivePhoto = self.allowSelectLivePhoto;
    cell.showSelectBtn = self.showSelectBtn;
    cell.cornerRadio = self.cellCornerRadio;
    cell.model = model;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLPhotoModel *model = self.arrDataSources[indexPath.row];
    return [self getSizeWithAsset:model.asset];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLPhotoModel *model = self.arrDataSources[indexPath.row];
    if (model.type == ZLAssetMediaTypeVideo) {
        if (self.arrSelectedModels.count > 0) {
            ShowToastLong(@"%@", [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserCannotSelectVideo]);
            return;
        }
        //跳转预览视频
        [self pushVideoViewControllerWithModel:model];
    } else if (self.allowSelectGif && model.type == ZLAssetMediaTypeGif) {
        if (self.arrSelectedModels.count > 0) {
            ShowToastLong(@"%@", [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserCannotSelectGIF]);
            return;
        }
        //跳转预览GIF
        [self pushGifViewControllerWithModel:model];
    } else if (self.allowSelectLivePhoto && model.type == ZLAssetMediaTypeLivePhoto) {
        if (self.arrSelectedModels.count > 0) {
            ShowToastLong(@"%@", [NSBundle zlLocalizedStringForKey:ZLPhotoBrowserCannotSelectLivePhoto]);
            return;
        }
        //跳转预览Live Photo
        [self pushLivePhotoViewControllerWithModel:model];
    } else {
        NSArray *arr = [ZLPhotoManager getAllAssetInPhotoAlbumWithAscending:self.sortAscending limitCount:NSIntegerMax allowSelectVideo:NO allowSelectImage:self.allowSelectImage allowSelectGif:!self.allowSelectGif allowSelectLivePhoto:!self.allowSelectLivePhoto];
        
        NSMutableArray *selIdentifiers = [NSMutableArray array];
        for (ZLPhotoModel *m in self.arrSelectedModels) {
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
        
        [self pushBigImageViewControllerWithModels:arr index:i];
    }
}

#pragma mark - 显示无权限视图
- (void)showNoAuthorityVC
{
    //无相册访问权限
    ZLNoAuthorityViewController *nvc = [[ZLNoAuthorityViewController alloc] initWithNibName:@"ZLNoAuthorityViewController" bundle:kZLPhotoBrowserBundle];
    [self.sender showDetailViewController:[self getImageNavWithRootVC:nvc] sender:nil];
}

- (ZLImageNavigationController *)getImageNavWithRootVC:(UIViewController *)rootVC
{
    ZLImageNavigationController *nav = [[ZLImageNavigationController alloc] initWithRootViewController:rootVC];
    weakify(self);
    __weak typeof(ZLImageNavigationController *) weakNav = nav;
    [nav setCallSelectImageBlock:^{
        strongify(weakSelf);
        strongSelf.isSelectOriginalPhoto = weakNav.isSelectOriginalPhoto;
        [strongSelf.arrSelectedModels removeAllObjects];
        [strongSelf.arrSelectedModels addObjectsFromArray:weakNav.arrSelectedModels];
        [strongSelf requestSelPhotos:weakNav];
    }];
    [nav setCallSelectGifBlock:^(UIImage *gif, PHAsset *asset) {
        strongify(weakSelf);
        if (strongSelf.selectGifBlock) {
            strongSelf.selectGifBlock(gif, asset);
        }
        [strongSelf hide];
        [weakNav dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [nav setCallSelectLivePhotoBlock:^(UIImage *lv, PHAsset *asset){
        strongify(weakSelf);
        if (strongSelf.selectLivePhotoBlock) {
            strongSelf.selectGifBlock(lv, asset);
        }
        [strongSelf hide];
        [weakNav dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [nav setCallSelectVideoBlock:^(UIImage *coverImage, PHAsset *asset) {
        strongify(weakSelf);
        if (strongSelf.selectVideoBlock) {
            strongSelf.selectVideoBlock(coverImage, asset);
        }
        [strongSelf hide];
        [weakNav dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [nav setCallSelectClipImageBlock:^(UIImage *image, PHAsset *asset){
        strongify(weakSelf);
        if (strongSelf.selectImageBlock) {
            strongSelf.selectImageBlock(@[image], @[asset], NO);
        }
        [strongSelf hide];
        [weakNav dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [nav setCancelBlock:^{
        strongify(weakSelf);
        [strongSelf hide];
    }];

    nav.previousStatusBarStyle = self.previousStatusBarStyle;
    nav.maxSelectCount = self.maxSelectCount;
    nav.cellCornerRadio = self.cellCornerRadio;
    nav.allowSelectVideo = self.allowSelectVideo;
    nav.allowSelectImage = self.allowSelectImage;
    nav.allowSelectGif = self.allowSelectGif;
    nav.allowSelectLivePhoto = self.allowSelectLivePhoto;
    nav.allowTakePhotoInLibrary = self.allowTakePhotoInLibrary;
    nav.allowForceTouch = self.allowForceTouch;
    nav.allowEditImage = self.allowEditImage;
    nav.showCaptureImageOnTakePhotoBtn = self.showCaptureImageOnTakePhotoBtn;
    nav.sortAscending = self.sortAscending;
    nav.showSelectBtn = self.showSelectBtn;
    nav.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    [nav.arrSelectedModels removeAllObjects];
    [nav.arrSelectedModels addObjectsFromArray:self.arrSelectedModels];
    
    return nav;
}

//预览界面
- (void)pushThumbnailViewController
{
    ZLPhotoBrowser *photoBrowser = [[ZLPhotoBrowser alloc] initWithStyle:UITableViewStylePlain];
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:photoBrowser];
    ZLThumbnailViewController *tvc = [[ZLThumbnailViewController alloc] initWithNibName:@"ZLThumbnailViewController" bundle:kZLPhotoBrowserBundle];
    ZLAlbumListModel *m = [ZLPhotoManager getCameraRollAlbumList:self.allowSelectVideo allowSelectImage:self.allowSelectImage];
    tvc.albumListModel = m;
    [nav pushViewController:tvc animated:YES];
    [self.sender presentViewController:nav animated:YES completion:nil];
}

//查看大图界面
- (void)pushBigImageViewControllerWithModels:(NSArray<ZLPhotoModel *> *)models index:(NSInteger)index
{
    ZLShowBigImgViewController *svc = [[ZLShowBigImgViewController alloc] init];
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:svc];
    
    svc.models = models;
    svc.selectIndex = index;
    weakify(self);
    [svc setBtnBackBlock:^(NSArray<ZLPhotoModel *> *selectedModels, BOOL isOriginal) {
        strongify(weakSelf);
        [ZLPhotoManager markSelcectModelInArr:strongSelf.arrDataSources selArr:selectedModels];
        strongSelf.isSelectOriginalPhoto = isOriginal;
        [strongSelf.arrSelectedModels removeAllObjects];
        [strongSelf.arrSelectedModels addObjectsFromArray:selectedModels];
        [strongSelf.collectionView reloadData];
        [strongSelf changeCancelBtnTitle];
    }];
    
    [self.sender showDetailViewController:nav sender:nil];
}

- (void)pushGifViewControllerWithModel:(ZLPhotoModel *)model
{
    ZLShowGifViewController *vc = [[ZLShowGifViewController alloc] init];
    vc.model = model;
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:vc];
    [self.sender showDetailViewController:nav sender:nil];
}

- (void)pushLivePhotoViewControllerWithModel:(ZLPhotoModel *)model
{
    ZLShowLivePhotoViewController *vc = [[ZLShowLivePhotoViewController alloc] init];
    vc.model = model;
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:vc];
    [self.sender showDetailViewController:nav sender:nil];
}

- (void)pushVideoViewControllerWithModel:(ZLPhotoModel *)model
{
    ZLShowVideoViewController *vc = [[ZLShowVideoViewController alloc] init];
    vc.model = model;
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:vc];
    [self.sender showDetailViewController:nav sender:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        strongify(weakSelf);
        if (strongSelf.selectImageBlock) {
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
        }
    }];
}

- (void)handleDataArray:(ZLPhotoModel *)model
{
    [self.arrDataSources insertObject:model atIndex:0];
    if (self.maxSelectCount > 1 && self.arrSelectedModels.count < self.maxSelectCount) {
        model.isSelected = YES;
        [self.arrSelectedModels addObject:model];
    } else if (self.maxSelectCount == 1 && !self.arrSelectedModels.count) {
        model.isSelected = YES;
        [self.arrSelectedModels addObject:model];
        [self requestSelPhotos:nil];
        return;
    }
    [self.collectionView reloadData];
    [self changeCancelBtnTitle];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 获取图片及图片尺寸的相关方法
- (CGSize)getSizeWithAsset:(PHAsset *)asset
{
    CGFloat width  = (CGFloat)asset.pixelWidth;
    CGFloat height = (CGFloat)asset.pixelHeight;
    CGFloat scale = MAX(0.5, width/height);
    
    return CGSizeMake(self.collectionView.frame.size.height*scale, self.collectionView.frame.size.height);
}

@end
