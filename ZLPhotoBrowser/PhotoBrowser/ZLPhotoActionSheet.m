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
#import "ZLShowBigImgViewController.h"
#import "ZLAnimationTool.h"
#import "ZLDefine.h"
#import "ZLSelectPhotoModel.h"
#import "ZLPhotoTool.h"
#import "ZLNoAuthorityViewController.h"
#import "ZLPhotoBrowser.h"
#import "ToastUtils.h"

typedef void (^handler)(NSArray<UIImage *> *selectPhotos);

@interface ZLPhotoActionSheet () <UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>

@property (nonatomic, assign) BOOL animate;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *arrayDataSources;
@property (nonatomic, strong) NSMutableArray<ZLSelectPhotoModel *> *arraySelectPhotos;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, copy)   handler handler;

@end

@implementation ZLPhotoActionSheet

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (instancetype)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ZLPhotoActionSheet" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, kViewWidth, kViewHeight);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerNib:[UINib nibWithNibName:@"ZLCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ZLCollectionCell"];
        
        _maxSelectCount = 10;
        _maxPreviewCount = 20;
        _arrayDataSources  = [NSMutableArray array];
        _arraySelectPhotos = [NSMutableArray array];
        
        //注册实施监听相册变化
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

//相册变化回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self loadPhotoFromAlbum];
    });
}

- (void)showWithSender:(UIViewController *)sender animate:(BOOL)animate completion:(void (^)(NSArray<UIImage *> *))completion
{
    if (![self judgeIsHavePhotoAblumAuthority]) {
        
    }
    
    _handler = completion;
    _animate = animate;
    _sender  = sender;
    
    [self loadPhotoFromAlbum];
    
    [self show];
}

#pragma mark - 判断软件是否有相册、相机访问权限
- (BOOL)judgeIsHavePhotoAblumAuthority
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
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
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self.sender presentViewController:alert animated:YES completion:nil];
}

- (void)loadPhotoFromAlbum
{
    [_arrayDataSources removeAllObjects];
    [_arrayDataSources addObjectsFromArray:[[ZLPhotoTool sharePhotoTool] getAllAssetInPhotoAblumWithAscending:NO]];
    
    [self.collectionView reloadData];
}

#pragma mark - 显示隐藏视图及相关动画
- (void)resetSubViewState
{
    self.hidden = NO;
    self.baseView.hidden = NO;
    [self.arraySelectPhotos removeAllObjects];
    [self.btnCamera setTitle:@"拍照" forState:UIControlStateNormal];
    [self.btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.collectionView setContentOffset:CGPointZero];
}

- (void)show
{
    [self.sender.view addSubview:self];
    
    [self resetSubViewState];
    
    if (_animate) {
        CGPoint fromPoint = CGPointMake(kViewWidth/2, kViewHeight+kBaseViewHeight/2);
        CGPoint toPoint   = CGPointMake(kViewWidth/2, kViewHeight-kBaseViewHeight/2);
        CABasicAnimation *animation = [ZLAnimationTool animateWithFromValue:[NSValue valueWithCGPoint:fromPoint] toValue:[NSValue valueWithCGPoint:toPoint] duration:0.2 keyPath:@"position"];
        [self.baseView.layer addAnimation:animation forKey:nil];
    }
}

- (void)hide
{
    if (_animate) {
        CGPoint fromPoint = self.baseView.layer.position;
        CGPoint toPoint   = CGPointMake(fromPoint.x, fromPoint.y+kBaseViewHeight);
        CABasicAnimation *animation = [ZLAnimationTool animateWithFromValue:[NSValue valueWithCGPoint:fromPoint] toValue:[NSValue valueWithCGPoint:toPoint] duration:0.1 keyPath:@"position"];
        animation.delegate = self;
        
        [self.baseView.layer addAnimation:animation forKey:nil];
    } else {
        self.hidden = YES;
        [self removeFromSuperview];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hide];
}

#pragma mark - UIButton Action
- (IBAction)btnCamera_Click:(id)sender
{
    if (_arraySelectPhotos.count > 0) {
        [self requestSelPhotos];
        [self hide];
    } else {
        if (![self judgeIsHaveCameraAuthority]) {
            [self showAlertWithTitle:@"无法使用相机" message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机"];
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
            [self.sender presentViewController:picker animated:YES completion:^{
            }];
            picker = nil;
        }
    }
}

- (IBAction)btnPhotoLibrary_Click:(id)sender
{
    if (![self judgeIsHavePhotoAblumAuthority]) {
        //无相册访问权限
        ZLNoAuthorityViewController *nvc = [[ZLNoAuthorityViewController alloc] init];
        [self presentVC:nvc];
    } else {
        _animate = NO;
        
        ZLPhotoBrowser *photoBrowser = [[ZLPhotoBrowser alloc] initWithStyle:UITableViewStylePlain];
        photoBrowser.maxSelectCount = self.maxSelectCount;
        photoBrowser.arraySelectPhotos = _arraySelectPhotos.mutableCopy;
        
        __weak typeof(ZLPhotoActionSheet *) weakSelf = self;
        [photoBrowser setDoneBlock:^(NSArray<ZLSelectPhotoModel *> *selPhotoModels, NSArray<UIImage *> *selPhotos) {
            [weakSelf.arraySelectPhotos removeAllObjects];
            [weakSelf.arraySelectPhotos addObjectsFromArray:selPhotoModels];
            [weakSelf done:selPhotos];
            [weakSelf hide];
        }];
        [photoBrowser setCancelBlock:^{
            [weakSelf hide];
        }];
        
        [self presentVC:photoBrowser];
    }
}

- (IBAction)btnCancel_Click:(id)sender
{
    [_arraySelectPhotos removeAllObjects];
    [self hide];
}

- (void)cell_btn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        ShowToastLong(@"最多只能选择%ld张图片", self.maxSelectCount);
        return;
    }
    btn.selected = !btn.selected;
    
    PHAsset *asset = _arrayDataSources[btn.tag];
    
    if (btn.selected) {
        [btn.layer addAnimation:[ZLAnimationTool animateWithBtnStatusChanged] forKey:nil];
        if (![[ZLPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"该图片尚未从iCloud下载，请在系统相册中下载到本地后重新尝试，或在预览大图中加载完毕后选择");
            return;
        }
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.asset = asset;
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
    
    [self changeBtnCameraTitle];
}

- (void)changeBtnCameraTitle
{
    if (_arraySelectPhotos.count > 0) {
        [self.btnCamera setTitle:[NSString stringWithFormat:@"确定(%ld)", _arraySelectPhotos.count] forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:kRGB(19, 153, 231) forState:UIControlStateNormal];
    } else {
        [self.btnCamera setTitle:@"拍照" forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 请求所选择图片、回调
- (void)requestSelPhotos
{
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.arraySelectPhotos.count];
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        [photos addObject:@""];
    }
    
    CGFloat scale = self.isSelectOriginalPhoto?1:[UIScreen mainScreen].scale;
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        ZLSelectPhotoModel *model = self.arraySelectPhotos[i];
        [[ZLPhotoTool sharePhotoTool] requestImageForAsset:model.asset scale:scale resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            [photos replaceObjectAtIndex:i withObject:image];
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) return;
            }
            [hud hide];
            [weakSelf done:photos];
        }];
    }
}

- (void)done:(NSArray<UIImage *> *)photos
{
    if (self.handler) {
        self.handler(photos);
        self.handler = nil;
    }
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.maxPreviewCount>_arrayDataSources.count?_arrayDataSources.count:self.maxPreviewCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    
    cell.btnSelect.selected = NO;
    PHAsset *asset = _arrayDataSources[indexPath.row];
    [self getImageWithAsset:asset completion:^(UIImage *image) {
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = _arrayDataSources[indexPath.row];
    return [self getSizeWithAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLShowBigImgViewController *svc = [[ZLShowBigImgViewController alloc] init];
    svc.assets         = _arrayDataSources;
    svc.arraySelectPhotos = [NSMutableArray arrayWithArray:_arraySelectPhotos];
    svc.selectIndex    = indexPath.row;
    svc.maxSelectCount = _maxSelectCount;
    svc.isPresent = YES;
    svc.shouldReverseAssets = YES;
    __weak typeof(self) weakSelf = self;
    __weak typeof(svc)  weakSvc  = svc;
    [svc setOnSelectedPhotos:^(NSArray<ZLSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf.arraySelectPhotos removeAllObjects];
        [weakSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [weakSelf changeBtnCameraTitle];
        [weakSelf.collectionView reloadData];
    }];
    [svc setBtnDoneBlock:^(NSArray<ZLSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf.arraySelectPhotos removeAllObjects];
        [weakSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [weakSelf requestSelPhotos];
        [weakSelf hide];
        [weakSvc.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentVC:svc];
}

- (void)presentVC:(UIViewController *)vc
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = YES;
    [self.sender presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    __weak typeof(ZLPhotoActionSheet *) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.handler) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            weakSelf.handler(@[image]);
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextinfo:), nil);
        }
        [weakSelf hide];
    }];
}

//写入相册后回调方法
- (void)image:(NSString *)video didFinishSavingWithError:(NSError *)error contextinfo:(void *)contextInfo
{
    //do something
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    __weak typeof(ZLPhotoActionSheet *) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf hide];
    }];
}

#pragma mark - 获取图片及图片尺寸的相关方法
- (CGSize)getSizeWithAsset:(PHAsset *)asset
{
    CGFloat width  = (CGFloat)asset.pixelWidth;
    CGFloat height = (CGFloat)asset.pixelHeight;
    CGFloat scale = width/height;
    
    return CGSizeMake(self.collectionView.frame.size.height*scale, self.collectionView.frame.size.height);
}

- (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion
{
    CGSize size = [self getSizeWithAsset:asset];
    size.width  *= 2;
    size.height *= 2;
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
}

@end
