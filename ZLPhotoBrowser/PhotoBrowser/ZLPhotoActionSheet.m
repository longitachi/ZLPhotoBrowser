//
//  ZLPhotoActionSheet.m
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLPhotoActionSheet.h"
#import "ZLCollectionCell.h"
#import "ZLPhotoManager.h"
#import "ZLAlbumListController.h"
#import "ZLShowBigImgViewController.h"
#import "ZLThumbnailViewController.h"
#import "ZLNoAuthorityViewController.h"
#import "ToastUtils.h"
#import "ZLEditViewController.h"
#import "ZLEditVideoController.h"
#import "ZLCustomCamera.h"
#import "ZLDefine.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kBaseViewHeight (self.configuration.maxPreviewCount ? 300 : 142)

double const ScalePhotoWidth = 1000;

@interface ZLPhotoActionSheet () <UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>
{
    CGPoint _panBeginPoint;
    ZLCollectionCell *_panCell;
    UIImageView *_panView;
    ZLPhotoModel *_panModel;
}

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnAblum;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verColHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verBottomSpace;


@property (nonatomic, assign) BOOL animate;
@property (nonatomic, assign) BOOL preview;

@property (nonatomic, strong) NSMutableArray<ZLPhotoModel *> *arrDataSources;

@property (nonatomic, copy) NSMutableArray<ZLPhotoModel *> *arrSelectedModels;

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, assign) BOOL previousStatusBarIsHidden;
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

#pragma mark - setter
- (void)setArrSelectedAssets:(NSMutableArray<PHAsset *> *)arrSelectedAssets
{
    _arrSelectedAssets = arrSelectedAssets;
    [self.arrSelectedModels removeAllObjects];
    for (PHAsset *asset in arrSelectedAssets) {
        ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:[ZLPhotoManager transformAssetType:asset] duration:nil];
        model.selected = YES;
        [self.arrSelectedModels addObject:model];
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
        
        _configuration = [ZLPhotoConfiguration defaultPhotoConfiguration];
        
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerClass:NSClassFromString(@"ZLCollectionCell") forCellWithReuseIdentifier:@"ZLCollectionCell"];
        if (![ZLPhotoManager havePhotoLibraryAuthority]) {
            //注册实施监听相册变化
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.configuration.allowSelectImage && self.configuration.allowRecordVideo) {
        [self.btnCamera setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCameraRecordText) forState:UIControlStateNormal];
    } else {
        [self.btnCamera setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCameraText) forState:UIControlStateNormal];
    }
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
    NSAssert(self.sender != nil, @"sender 对象不能为空");
    
    self.animate = animate;
    self.preview = preview;
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.previousStatusBarIsHidden = [UIApplication sharedApplication].isStatusBarHidden;
    
    [ZLPhotoManager setSortAscending:self.configuration.sortAscending];
    
    if (!self.configuration.maxPreviewCount) {
        self.verColHeight.constant = .0;
    } else if (self.configuration.allowDragSelect) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self.baseView addGestureRecognizer:pan];
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        [self showNoAuthorityVC];
        return;
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
        
        [self.sender.view addSubview:self];
    }
    
    if (preview) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self loadPhotoFromAlbum];
            [self show];
        }
    } else {
        if (status == PHAuthorizationStatusAuthorized) {
            [self.sender.view addSubview:self];
            [self btnPhotoLibrary_Click:nil];
        }
    }
}

- (void)previewSelectedPhotos:(NSArray<UIImage *> *)photos assets:(NSArray<PHAsset *> *)assets index:(NSInteger)index isOriginal:(BOOL)isOriginal
{
    self.isSelectOriginalPhoto = isOriginal;
    //将assets转换为对应类型的model
    NSMutableArray<ZLPhotoModel *> *models = [NSMutableArray arrayWithCapacity:assets.count];
    for (PHAsset *asset in assets) {
        ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:[ZLPhotoManager transformAssetType:asset] duration:nil];
        model.selected = YES;
        [models addObject:model];
    }
    
    [self.arrSelectedModels removeAllObjects];
    ZLShowBigImgViewController *svc = [self pushBigImageToPreview:photos models:models index:index];
    
    zl_weakify(self);
    __weak typeof(svc.navigationController) weakNav = svc.navigationController;
    svc.previewSelectedImageBlock = ^(NSArray<UIImage *> *arrP, NSArray<PHAsset *> *arrA) {
        zl_strongify(weakSelf);
        strongSelf.arrSelectedAssets = assets.mutableCopy;
        __strong typeof(weakNav) strongNav = weakNav;
        if (strongSelf.selectImageBlock) {
            strongSelf.selectImageBlock(arrP, arrA, NO);
        }
        [strongSelf hide];
        [strongNav dismissViewControllerAnimated:YES completion:nil];
    };
    
    svc.cancelPreviewBlock = ^{
        zl_strongify(weakSelf);
        [strongSelf hide];
    };
}

- (void)previewPhotos:(NSArray<NSDictionary *> *)photos index:(NSInteger)index hideToolBar:(BOOL)hideToolBar complete:(void (^)(NSArray * _Nonnull))complete
{
    //转换为对应类型的model对象
    NSMutableArray<ZLPhotoModel *> *models = [NSMutableArray arrayWithCapacity:photos.count];
    for (NSDictionary *dic in photos) {
        ZLPhotoModel *model = [[ZLPhotoModel alloc] init];
        ZLPreviewPhotoType type = [dic[ZLPreviewPhotoTyp] integerValue];
        id obj = dic[ZLPreviewPhotoObj];
        switch (type) {
            case ZLPreviewPhotoTypePHAsset:
                model.asset = obj;
                model.type = [ZLPhotoManager transformAssetType:obj];
                break;
            case ZLPreviewPhotoTypeUIImage:
                model.image = obj;
                model.type = ZLAssetMediaTypeNetImage;
                break;
            case ZLPreviewPhotoTypeURLImage:
                model.url = obj;
                model.type = ZLAssetMediaTypeNetImage;
                break;
            case ZLPreviewPhotoTypeURLVideo:
                model.url = obj;
                model.type = ZLAssetMediaTypeNetVideo;
                break;
        }
        model.selected = YES;
        [models addObject:model];
    }
    
    [self.arrSelectedModels removeAllObjects];
    ZLShowBigImgViewController *svc = [self pushBigImageToPreview:photos models:models index:index];
    svc.hideToolBar = hideToolBar;
    
    zl_weakify(self);
    __weak typeof(svc.navigationController) weakNav = svc.navigationController;
    [svc setPreviewNetImageBlock:^(NSArray *photos) {
        zl_strongify(weakSelf);
        __strong typeof(weakNav) strongNav = weakNav;
        if (complete) complete(photos);
        [strongSelf hide];
        [strongNav dismissViewControllerAnimated:YES completion:nil];
    }];
    svc.cancelPreviewBlock = ^{
        zl_strongify(weakSelf);
        [strongSelf hide];
    };
}

- (void)loadPhotoFromAlbum
{
    [self.arrDataSources removeAllObjects];
    
    [self.arrDataSources addObjectsFromArray:[ZLPhotoManager getAllAssetInPhotoAlbumWithAscending:NO limitCount:self.configuration.maxPreviewCount allowSelectVideo:self.configuration.allowSelectVideo allowSelectImage:self.configuration.allowSelectImage allowSelectGif:self.configuration.allowSelectGif allowSelectLivePhoto:self.configuration.allowSelectLivePhoto]];
    [ZLPhotoManager markSelectModelInArr:self.arrDataSources selArr:self.arrSelectedModels];
    [self.collectionView reloadData];
}

#pragma mark - 显示隐藏视图及相关动画
- (void)resetSubViewState
{
    self.hidden = ![ZLPhotoManager havePhotoLibraryAuthority] || !self.preview;
    [self changeCancelBtnTitle];
//    [self.collectionView setContentOffset:CGPointZero];
}

- (void)show
{
    self.frame = self.sender.view.bounds;
    [self.collectionView setContentOffset:CGPointZero];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (!self.superview) {
        [self.sender.view addSubview:self];
    }
    
    if (self.sender.tabBarController.tabBar && self.sender.tabBarController.tabBar.hidden == NO) {
        self.senderTabBarIsShow = YES;
        self.sender.tabBarController.tabBar.hidden = YES;
    }
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        double flag = .0;
        if (self.senderTabBarIsShow) {
            flag = 49;
        }
        inset = self.sender.view.safeAreaInsets;
        inset.bottom -= flag;
        [self.verBottomSpace setConstant:inset.bottom];
    }
    if (self.animate) {
        __block CGRect frame = self.baseView.frame;
        frame.origin.y = kViewHeight;
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
        UIEdgeInsets inset = UIEdgeInsetsZero;
        if (@available(iOS 11, *)) {
            inset = self.sender.view.safeAreaInsets;
        }
        __block CGRect frame = self.baseView.frame;
        frame.origin.y += (kBaseViewHeight+inset.bottom);
        [UIView animateWithDuration:0.2 animations:^{
            self.baseView.frame = frame;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            [UIApplication sharedApplication].statusBarHidden = self.previousStatusBarIsHidden;
            [self removeFromSuperview];
        }];
    } else {
        self.hidden = YES;
        [UIApplication sharedApplication].statusBarHidden = self.previousStatusBarIsHidden;
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

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.baseView];
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (!CGRectContainsPoint(self.collectionView.frame, point)) {
            _panBeginPoint = CGPointZero;
            return;
        }
        _panBeginPoint = [pan locationInView:self.collectionView];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (CGPointEqualToPoint(_panBeginPoint, CGPointZero)) return;
        
        CGPoint cp = [pan locationInView:self.collectionView];
        
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:_panBeginPoint];
        
        if (!indexPath) return;
        
        if (!_panView) {
            if (cp.y > _panBeginPoint.y) {
                _panBeginPoint = CGPointZero;
                return;
            }
            
            _panModel = self.arrDataSources[indexPath.row];
            
            ZLCollectionCell *cell = (ZLCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            _panCell = cell;
            _panView = [[UIImageView alloc] initWithFrame:cell.bounds];
            _panView.image = cell.imageView.image;
            
            cell.imageView.image = nil;
            
            [self addSubview:_panView];
        }
        
        _panView.center = [self convertPoint:point fromView:self.baseView];
    } else if (pan.state == UIGestureRecognizerStateCancelled ||
               pan.state == UIGestureRecognizerStateEnded) {
        if (!_panView) return;
        
        CGRect panViewRect = [self.baseView convertRect:_panView.frame fromView:self];
        BOOL callBack = NO;
        if (CGRectGetMidY(panViewRect) < -10) {
            //如果往上拖动距离中心点与collectionview间距大于10，则回调
            [self requestSelPhotos:nil data:@[_panModel] hideAfterCallBack:NO];
            callBack = YES;
        }
        
        _panModel = nil;
        if (!callBack) {
            CGRect toRect = [self convertRect:_panCell.frame fromView:self.collectionView];
            [UIView animateWithDuration:0.25 animations:^{
                self->_panView.frame = toRect;
            } completion:^(BOOL finished) {
                self->_panCell.imageView.image = self->_panView.image;
                self->_panCell = nil;
                [self->_panView removeFromSuperview];
                self->_panView = nil;
            }];
        } else {
            _panCell.imageView.image = _panView.image;
            _panCell.imageView.frame = CGRectZero;
            _panCell.imageView.center = _panCell.contentView.center;
            [_panView removeFromSuperview];
            _panView = nil;
            [UIView animateWithDuration:0.25 animations:^{
                self->_panCell.imageView.frame = self->_panCell.contentView.frame;
            } completion:^(BOOL finished) {
                self->_panCell = nil;
            }];
        }
    }
}

#pragma mark - UIButton Action
- (IBAction)btnCamera_Click:(id)sender
{
    if (![ZLPhotoManager haveCameraAuthority]) {
        NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoCameraAuthorityText), kAPPName];
        ShowAlert(message, self.sender);
        [self hide];
        return;
    }
    if (!self.configuration.allowSelectImage &&
        !self.configuration.allowRecordVideo) {
        ShowAlert(@"allowSelectImage与allowRecordVideo不能同时为NO", self.sender);
        return;
    }
    if (self.configuration.useSystemCamera) {
        //系统相机拍照
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSArray *a1 = self.configuration.allowSelectImage?@[(NSString *)kUTTypeImage]:@[];
            NSArray *a2 = (self.configuration.allowSelectVideo && self.configuration.allowRecordVideo)?@[(NSString *)kUTTypeMovie]:@[];
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObjectsFromArray:a1];
            [arr addObjectsFromArray:a2];
            
            picker.mediaTypes = arr;
            picker.videoMaximumDuration = self.configuration.maxRecordDuration;
            [self.sender showDetailViewController:picker sender:nil];
        }
    } else {
        if (![ZLPhotoManager haveMicrophoneAuthority]) {
            NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoMicrophoneAuthorityText), kAPPName];
            ShowAlert(message, self.sender);
            [self hide];
            return;
        }
        ZLCustomCamera *camera = [[ZLCustomCamera alloc] init];
        camera.allowTakePhoto = self.configuration.allowSelectImage;
        camera.allowRecordVideo = self.configuration.allowSelectVideo && self.configuration.allowRecordVideo;
        camera.sessionPreset = self.configuration.sessionPreset;
        camera.videoType = self.configuration.exportVideoType;
        camera.circleProgressColor = self.configuration.bottomBtnsNormalTitleColor;
        camera.maxRecordDuration = self.configuration.maxRecordDuration;
        zl_weakify(self);
        camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
            zl_strongify(weakSelf);
            [strongSelf saveImage:image videoUrl:videoUrl];
        };
        [self.sender showDetailViewController:camera sender:nil];
    }
}

- (IBAction)btnPhotoLibrary_Click:(id)sender
{
    if (![ZLPhotoManager havePhotoLibraryAuthority]) {
        [self showNoAuthorityVC];
    } else {
        self.animate = NO;
        [self pushThumbnailViewController];
    }
}

- (IBAction)btnCancel_Click:(id)sender
{
    if (self.arrSelectedModels.count) {
        [self requestSelPhotos:nil data:self.arrSelectedModels hideAfterCallBack:YES];
        return;
    }
    
    if (self.cancleBlock) self.cancleBlock();
    [self hide];
}

- (void)changeCancelBtnTitle
{
    if (self.arrSelectedModels.count > 0) {
        [self.btnCancel setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), self.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:self.configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
    } else {
        [self.btnCancel setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 请求所选择图片、回调
- (void)requestSelPhotos:(UIViewController *)vc data:(NSArray<ZLPhotoModel *> *)data hideAfterCallBack:(BOOL)hide
{
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    
    if (!self.configuration.shouldAnialysisAsset) {
        NSMutableArray *assets = [NSMutableArray arrayWithCapacity:data.count];
        for (ZLPhotoModel *m in data) {
            [assets addObject:m.asset];
        }
        [hud hide];
        if (self.selectImageBlock) {
            self.selectImageBlock(nil, assets, self.isSelectOriginalPhoto);
            [self.arrSelectedModels removeAllObjects];
        }
        if (hide) {
            [self hide];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }
        return;
    }
    
    __block NSMutableArray *photos = [NSMutableArray arrayWithCapacity:data.count];
    __block NSMutableArray *assets = [NSMutableArray arrayWithCapacity:data.count];
    __block NSMutableArray *errorAssets = [NSMutableArray array];
    __block NSMutableArray *errorIndexs = [NSMutableArray array];
    for (int i = 0; i < data.count; i++) {
        [photos addObject:@""];
        [assets addObject:@""];
    }
    
    zl_weakify(self);
    __block NSInteger doneCount = 0;
    for (int i = 0; i < data.count; i++) {
        ZLPhotoModel *model = data[i];
        [ZLPhotoManager requestSelectedImageForAsset:model isOriginal:self.isSelectOriginalPhoto allowSelectGif:self.configuration.allowSelectGif completion:^(UIImage *image, NSDictionary *info) {
            if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
            
            doneCount++;
            zl_strongify(weakSelf);
            
            if (image) {
                [photos replaceObjectAtIndex:i withObject:[ZLPhotoManager scaleImage:image original:strongSelf->_isSelectOriginalPhoto]];
                [assets replaceObjectAtIndex:i withObject:model.asset];
            } else {
                [errorAssets addObject:model.asset];
                [errorIndexs addObject:@(i)];
            }
            
            if (doneCount < data.count) {
                return;
            }
            
            NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
            for (NSNumber *errorIndex in errorIndexs) {
                [set addIndex:errorIndex.integerValue];
            }
            
            [photos removeObjectsAtIndexes:set];
            [assets removeObjectsAtIndexes:set];
            
            [hud hide];
            if (strongSelf.selectImageBlock) {
                strongSelf.selectImageBlock(photos, assets, strongSelf.isSelectOriginalPhoto);
                [strongSelf.arrSelectedModels removeAllObjects];
            }
            if (errorAssets.count > 0 && strongSelf.selectImageRequestErrorBlock) {
                strongSelf.selectImageRequestErrorBlock(errorAssets, errorIndexs);
            }
            if (hide) {
                [strongSelf.arrDataSources removeAllObjects];
                [strongSelf hide];
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
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
    
    zl_weakify(self);
    __weak typeof(cell) weakCell = cell;
    cell.selectedBlock = ^(BOOL selected) {
        zl_strongify(weakSelf);
        __strong typeof(weakCell) strongCell = weakCell;
        if (!selected) {
            //选中
            if (strongSelf.arrSelectedModels.count >= strongSelf.configuration.maxSelectCount) {
                ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxSelectCountText), strongSelf.configuration.maxSelectCount);
                return;
            }
            if (strongSelf.arrSelectedModels.count > 0) {
                ZLPhotoModel *sm = strongSelf.arrSelectedModels.firstObject;
                if (!strongSelf.configuration.allowMixSelect &&
                    ((model.type < ZLAssetMediaTypeVideo && sm.type == ZLAssetMediaTypeVideo) || (model.type == ZLAssetMediaTypeVideo && sm.type < ZLAssetMediaTypeVideo))) {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserCannotSelectVideo));
                    return;
                }
            }
            if (![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowseriCloudPhotoText));
                return;
            }
            if (model.type == ZLAssetMediaTypeVideo && GetDuration(model.duration) > strongSelf.configuration.maxVideoDuration) {
                ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxVideoDurationText), strongSelf.configuration.maxVideoDuration);
                return;
            }
            
            if (![strongSelf shouldDirectEdit:model]) {
                model.selected = YES;
                [strongSelf.arrSelectedModels addObject:model];
                strongCell.btnSelect.selected = YES;
            }
        } else {
            strongCell.btnSelect.selected = NO;
            model.selected = NO;
            for (ZLPhotoModel *m in strongSelf.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [strongSelf.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
        
        if (strongSelf.configuration.showSelectedMask) {
            strongCell.topView.hidden = !model.isSelected;
        }
        [strongSelf changeCancelBtnTitle];
    };
    
    cell.allSelectGif = self.configuration.allowSelectGif;
    cell.allSelectLivePhoto = self.configuration.allowSelectLivePhoto;
    cell.showSelectBtn = self.configuration.showSelectBtn;
    cell.cornerRadio = self.configuration.cellCornerRadio;
    cell.showMask = self.configuration.showSelectedMask;
    cell.maskColor = self.configuration.selectedMaskColor;
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
    
    if ([self shouldDirectEdit:model]) return;
    
    if (self.arrSelectedModels.count > 0) {
        ZLPhotoModel *sm = self.arrSelectedModels.firstObject;
        if (!self.configuration.allowMixSelect &&
            ((model.type < ZLAssetMediaTypeVideo && sm.type == ZLAssetMediaTypeVideo) || (model.type == ZLAssetMediaTypeVideo && sm.type < ZLAssetMediaTypeVideo))) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserCannotSelectVideo));
            return;
        }
    }
    
    BOOL allowSelImage = !(model.type==ZLAssetMediaTypeVideo)?YES:self.configuration.allowMixSelect;
    BOOL allowSelVideo = model.type==ZLAssetMediaTypeVideo?YES:self.configuration.allowMixSelect;
    
    NSArray *arr = [ZLPhotoManager getAllAssetInPhotoAlbumWithAscending:self.configuration.sortAscending limitCount:NSIntegerMax allowSelectVideo:allowSelVideo allowSelectImage:allowSelImage allowSelectGif:self.configuration.allowSelectGif allowSelectLivePhoto:self.configuration.allowSelectLivePhoto];
    
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
            m.selected = YES;
        }
        if (!isFind) {
            i++;
        }
    }
    
    [self pushBigImageViewControllerWithModels:arr index:i];
}

- (BOOL)shouldDirectEdit:(ZLPhotoModel *)model
{
    //当前点击图片可编辑
    BOOL editImage = self.configuration.editAfterSelectThumbnailImage && self.configuration.allowEditImage && self.configuration.maxSelectCount == 1 && model.type < ZLAssetMediaTypeVideo;
    //当前点击视频可编辑
    BOOL editVideo = self.configuration.editAfterSelectThumbnailImage && self.configuration.allowEditVideo && model.type == ZLAssetMediaTypeVideo && self.configuration.maxSelectCount == 1 && round(model.asset.duration) >= self.configuration.maxEditVideoTime;
    //当前未选择图片 或已经选择了一张并且点击的是已选择的图片
    BOOL flag = self.arrSelectedModels.count == 0 || (self.arrSelectedModels.count == 1 && [self.arrSelectedModels.firstObject.asset.localIdentifier isEqualToString:model.asset.localIdentifier]);
    
    if (editImage && flag) {
        [self pushEditVCWithModel:model];
    } else if (editVideo && flag) {
        [self pushEditVideoVCWithModel:model];
    }
    
    return self.configuration.editAfterSelectThumbnailImage && self.configuration.maxSelectCount == 1 && (self.configuration.allowEditImage || self.configuration.allowEditVideo);
}

#pragma mark - 显示无权限视图
- (void)showNoAuthorityVC
{
    //无相册访问权限
    ZLNoAuthorityViewController *nvc = [[ZLNoAuthorityViewController alloc] init];
    [self.sender showDetailViewController:[self getImageNavWithRootVC:nvc] sender:nil];
}

- (ZLImageNavigationController *)getImageNavWithRootVC:(UIViewController *)rootVC
{
    ZLImageNavigationController *nav = [[ZLImageNavigationController alloc] initWithRootViewController:rootVC];
    zl_weakify(self);
    __weak typeof(ZLImageNavigationController *) weakNav = nav;
    [nav setCallSelectImageBlock:^{
        zl_strongify(weakSelf);
        strongSelf.isSelectOriginalPhoto = weakNav.isSelectOriginalPhoto;
        [strongSelf.arrSelectedModels removeAllObjects];
        [strongSelf.arrSelectedModels addObjectsFromArray:weakNav.arrSelectedModels];
        [strongSelf requestSelPhotos:weakNav data:strongSelf.arrSelectedModels hideAfterCallBack:YES];
    }];
    
    [nav setCallSelectClipImageBlock:^(UIImage *image, PHAsset *asset){
        zl_strongify(weakSelf);
        if (strongSelf.selectImageBlock) {
            strongSelf.selectImageBlock(@[image], @[asset], NO);
        }
        [weakNav dismissViewControllerAnimated:YES completion:nil];
        [strongSelf hide];
    }];
    
    [nav setCancelBlock:^{
        zl_strongify(weakSelf);
        if (strongSelf.cancleBlock) strongSelf.cancleBlock();
        [strongSelf hide];
    }];

    nav.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    nav.previousStatusBarStyle = self.previousStatusBarStyle;
    nav.configuration = self.configuration;
    [nav.arrSelectedModels removeAllObjects];
    [nav.arrSelectedModels addObjectsFromArray:self.arrSelectedModels];
    
    return nav;
}

//预览界面
- (void)pushThumbnailViewController
{
    ZLAlbumListController *albumListVC = [[ZLAlbumListController alloc] initWithStyle:UITableViewStylePlain];
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:albumListVC];
    ZLThumbnailViewController *tvc = [[ZLThumbnailViewController alloc] init];
    [nav pushViewController:tvc animated:YES];
    [self.sender showDetailViewController:nav sender:nil];
}

//查看大图界面
- (void)pushBigImageViewControllerWithModels:(NSArray<ZLPhotoModel *> *)models index:(NSInteger)index
{
    ZLShowBigImgViewController *svc = [[ZLShowBigImgViewController alloc] init];
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:svc];
    
    svc.models = models;
    svc.selectIndex = index;
    zl_weakify(self);
    [svc setBtnBackBlock:^(NSArray<ZLPhotoModel *> *selectedModels, BOOL isOriginal) {
        zl_strongify(weakSelf);
        [ZLPhotoManager markSelectModelInArr:strongSelf.arrDataSources selArr:selectedModels];
        strongSelf.isSelectOriginalPhoto = isOriginal;
        [strongSelf.arrSelectedModels removeAllObjects];
        [strongSelf.arrSelectedModels addObjectsFromArray:selectedModels];
        [strongSelf.collectionView reloadData];
        [strongSelf changeCancelBtnTitle];
    }];
    
    [self.sender showDetailViewController:nav sender:nil];
}

- (ZLShowBigImgViewController *)pushBigImageToPreview:(NSArray *)photos models:(NSArray<ZLPhotoModel *> *)models index:(NSInteger)index
{
    [self.arrSelectedModels addObjectsFromArray:models];
    
    ZLShowBigImgViewController *svc = [[ZLShowBigImgViewController alloc] init];
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:svc];
    svc.selectIndex = index;
    svc.arrSelPhotos = [NSMutableArray arrayWithArray:photos];
    svc.models = models;
    svc.isPush = NO;
    
    self.preview = NO;
    [self.sender.view addSubview:self];
    [self.sender showDetailViewController:nav sender:nil];
    
    return svc;
}

- (void)pushEditVCWithModel:(ZLPhotoModel *)model
{
    ZLEditViewController *vc = [[ZLEditViewController alloc] init];
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:vc];
    [nav.arrSelectedModels addObject:model];
    vc.model = model;
    [self.sender showDetailViewController:nav sender:nil];
}

- (void)pushEditVideoVCWithModel:(ZLPhotoModel *)model
{
    ZLEditVideoController *vc = [[ZLEditVideoController alloc] init];
    ZLImageNavigationController *nav = [self getImageNavWithRootVC:vc];
    [nav.arrSelectedModels addObject:model];
    vc.model = model;
    [self.sender showDetailViewController:nav sender:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSURL *url = [info valueForKey:UIImagePickerControllerMediaURL];
        [self saveImage:image videoUrl:url];
    }];
}

- (void)saveImage:(UIImage *)image videoUrl:(NSURL *)videoUrl
{
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    zl_weakify(self);
    if (image) {
        [ZLPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            zl_strongify(weakSelf);
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
    } else if (videoUrl) {
        [ZLPhotoManager saveVideoToAblum:videoUrl completion:^(BOOL suc, PHAsset *asset) {
            zl_strongify(weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (suc) {
                    ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeVideo duration:nil];
                    model.duration = [ZLPhotoManager getDuration:asset];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveVideoFailed));
                }
                [hud hide];
            });
        }];
    }
}

- (void)handleDataArray:(ZLPhotoModel *)model
{
    zl_weakify(self);
    BOOL (^shouldSelect)(void) = ^BOOL() {
        zl_strongify(weakSelf);
        if (model.type == ZLAssetMediaTypeVideo) {
            return (model.asset.duration <= strongSelf.configuration.maxVideoDuration);
        }
        return YES;
    };
    
    [self.arrDataSources insertObject:model atIndex:0];
    if (self.arrDataSources.count > self.configuration.maxPreviewCount) {
        [self.arrDataSources removeLastObject];
    }
    BOOL sel = shouldSelect();
    if (self.configuration.maxSelectCount > 1 && self.arrSelectedModels.count < self.configuration.maxSelectCount && sel) {
        model.selected = sel;
        [self.arrSelectedModels addObject:model];
    } else if (self.configuration.maxSelectCount == 1 && !self.arrSelectedModels.count && sel) {
        if (![self shouldDirectEdit:model]) {
            model.selected = sel;
            [self.arrSelectedModels addObject:model];
            [self requestSelPhotos:nil data:self.arrSelectedModels hideAfterCallBack:YES];
            return;
        }
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
    CGFloat scale = MIN(1.7, MAX(0.5, width/height));
    
    return CGSizeMake(self.collectionView.frame.size.height*scale, self.collectionView.frame.size.height);
}

@end
