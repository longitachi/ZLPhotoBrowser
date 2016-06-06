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
#import "ZLDefine.h"
#import "ZLSelectPhotoModel.h"
#import "ZLPhotoTool.h"
#import "ZLNoAuthorityViewController.h"
#import "ZLPhotoBrowser.h"
#import "ToastUtils.h"

double const ScalePhotoWidth = 1000;

typedef void (^handler)(NSArray<UIImage *> *selectPhotos, NSArray<ZLSelectPhotoModel *> *selectPhotoModels);

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
    self = [[kZLPhotoBrowserBundle loadNibNamed:@"ZLPhotoActionSheet" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, kViewWidth, kViewHeight);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerNib:[UINib nibWithNibName:@"ZLCollectionCell" bundle:kZLPhotoBrowserBundle] forCellWithReuseIdentifier:@"ZLCollectionCell"];
        
        self.maxSelectCount = 10;
        self.maxPreviewCount = 20;
        self.arrayDataSources  = [NSMutableArray array];
        self.arraySelectPhotos = [NSMutableArray array];
        
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

- (void)showWithSender:(UIViewController *)sender animate:(BOOL)animate lastSelectPhotoModels:(NSArray<ZLSelectPhotoModel *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<ZLSelectPhotoModel *> * _Nonnull))completion
{
    self.handler = completion;
    self.animate = animate;
    self.sender  = sender;
    [self.arraySelectPhotos removeAllObjects];
    [self.arraySelectPhotos addObjectsFromArray:lastSelectPhotoModels];
    
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
    [self.arrayDataSources removeAllObjects];
    [self.arrayDataSources addObjectsFromArray:[[ZLPhotoTool sharePhotoTool] getAllAssetInPhotoAblumWithAscending:NO]];
    
    [self.collectionView reloadData];
}

#pragma mark - 显示隐藏视图及相关动画
- (void)resetSubViewState
{
    self.hidden = NO;
    self.baseView.hidden = NO;
    if (self.arraySelectPhotos.count == 0) {
        [self.btnCamera setTitle:@"拍照" forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        [self.btnCamera setTitle:[NSString stringWithFormat:@"确定(%ld)", self.arraySelectPhotos.count] forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:kRGB(19, 153, 231) forState:UIControlStateNormal];
    }
    [self.collectionView setContentOffset:CGPointZero];
}

- (void)show
{
    [self.sender.view addSubview:self];
    
    [self resetSubViewState];
    
    if (self.animate) {
        CGPoint fromPoint = CGPointMake(kViewWidth/2, kViewHeight+kBaseViewHeight/2);
        CGPoint toPoint   = CGPointMake(kViewWidth/2, kViewHeight-kBaseViewHeight/2);
        CABasicAnimation *animation = GetPositionAnimation([NSValue valueWithCGPoint:fromPoint], [NSValue valueWithCGPoint:toPoint], 0.2, @"position");
        [self.baseView.layer addAnimation:animation forKey:nil];
    }
}

- (void)hide
{
    if (self.animate) {
        CGPoint fromPoint = self.baseView.layer.position;
        CGPoint toPoint   = CGPointMake(fromPoint.x, fromPoint.y+kBaseViewHeight);
        CABasicAnimation *animation = GetPositionAnimation([NSValue valueWithCGPoint:fromPoint], [NSValue valueWithCGPoint:toPoint], 0.1, @"position");
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
    if (self.arraySelectPhotos.count > 0) {
        [self requestSelPhotos:nil];
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
            [self.sender presentViewController:picker animated:YES completion:nil];
        }
    }
}

- (IBAction)btnPhotoLibrary_Click:(id)sender
{
    if (![self judgeIsHavePhotoAblumAuthority]) {
        //无相册访问权限
        ZLNoAuthorityViewController *nvc = [[ZLNoAuthorityViewController alloc] initWithNibName:@"ZLNoAuthorityViewController" bundle:kZLPhotoBrowserBundle];
        [self presentVC:nvc];
    } else {
        self.animate = NO;
        
        ZLPhotoBrowser *photoBrowser = [[ZLPhotoBrowser alloc] initWithStyle:UITableViewStylePlain];
        photoBrowser.maxSelectCount = self.maxSelectCount;
        photoBrowser.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
        
        weakify(self);
        __weak typeof(photoBrowser) weakPB = photoBrowser;
        [photoBrowser setDoneBlock:^(NSArray<ZLSelectPhotoModel *> *selPhotoModels, BOOL isSelectOriginalPhoto) {
            strongify(weakSelf);
            __strong typeof(weakPB) strongPB = weakPB;
            strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
            [strongSelf.arraySelectPhotos removeAllObjects];
            [strongSelf.arraySelectPhotos addObjectsFromArray:selPhotoModels];
            [strongSelf requestSelPhotos:strongPB];
        }];
        
        [photoBrowser setCancelBlock:^{
            strongify(weakSelf);
            [strongSelf hide];
        }];
        
        [self presentVC:photoBrowser];
    }
}

- (IBAction)btnCancel_Click:(id)sender
{
    [self.arraySelectPhotos removeAllObjects];
    [self hide];
}

- (void)cell_btn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        ShowToastLong(@"最多只能选择%ld张图片", self.maxSelectCount);
        return;
    }
    
    PHAsset *asset = self.arrayDataSources[btn.tag];
    
    if (!btn.selected) {
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        if (![[ZLPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"该图片尚未从iCloud下载，请在系统相册中下载到本地后重新尝试，或在预览大图中加载完毕后选择");
            return;
        }
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [self.arraySelectPhotos addObject:model];
    } else {
        for (ZLSelectPhotoModel *model in self.arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                [self.arraySelectPhotos removeObject:model];
                break;
            }
        }
    }
    
    btn.selected = !btn.selected;
    [self changeBtnCameraTitle];
}

- (void)changeBtnCameraTitle
{
    if (self.arraySelectPhotos.count > 0) {
        [self.btnCamera setTitle:[NSString stringWithFormat:@"确定(%ld)", self.arraySelectPhotos.count] forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:kRGB(19, 153, 231) forState:UIControlStateNormal];
    } else {
        [self.btnCamera setTitle:@"拍照" forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 请求所选择图片、回调
- (void)requestSelPhotos:(UIViewController *)vc
{
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    
    weakify(self);
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.arraySelectPhotos.count];
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        [photos addObject:@""];
    }
    
    CGFloat scale = self.isSelectOriginalPhoto?1:[UIScreen mainScreen].scale;
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        ZLSelectPhotoModel *model = self.arraySelectPhotos[i];
        [[ZLPhotoTool sharePhotoTool] requestImageForAsset:model.asset scale:scale resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            strongify(weakSelf);
            if (image) [photos replaceObjectAtIndex:i withObject:[self scaleImage:image]];
            
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) return;
            }
            
            [hud hide];
            [strongSelf done:photos];
            [strongSelf hide];
            [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

/**
 * @brief 这里对拿到的图片进行缩放，不然原图直接返回的话会造成内存暴涨
 */
- (UIImage *)scaleImage:(UIImage *)image
{
    CGSize size = CGSizeMake(ScalePhotoWidth, ScalePhotoWidth * image.size.height / image.size.width);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)done:(NSArray<UIImage *> *)photos
{
    if (self.handler) {
        self.handler(photos, self.arraySelectPhotos.copy);
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
    weakify(self);
    [self getImageWithAsset:asset completion:^(UIImage *image, NSDictionary *info) {
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.arrayDataSources[indexPath.row];
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
    weakify(self);
    __weak typeof(svc) weakSvc  = svc;
    [svc setOnSelectedPhotos:^(NSArray<ZLSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        strongify(weakSelf);
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf.arraySelectPhotos removeAllObjects];
        [strongSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf changeBtnCameraTitle];
        [strongSelf.collectionView reloadData];
    }];
    [svc setBtnDoneBlock:^(NSArray<ZLSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        strongify(weakSelf);
        __strong typeof(weakSvc) strongSvc = weakSvc;
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf.arraySelectPhotos removeAllObjects];
        [strongSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf requestSelPhotos:strongSvc];
    }];
    [self presentVC:svc];
}

- (void)presentVC:(UIViewController *)vc
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = YES;
    
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [nav.navigationBar setBackgroundImage:[self imageWithColor:kRGB(19, 153, 231)] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    [self.sender presentViewController:nav animated:YES completion:nil];
}

- (UIImage *)imageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        strongify(weakSelf);
        if (strongSelf.handler) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
            [hud show];
            
            [[ZLPhotoTool sharePhotoTool] saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (suc) {
                        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
                        model.asset = asset;
                        model.localIdentifier = asset.localIdentifier;
                        strongSelf.handler(@[[strongSelf scaleImage:image]], @[model]);
                    } else {
                        ShowToastLong(@"保存图片到相册失败");
                    }
                    [hud hide];
                    [strongSelf hide];
                });
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        strongify(weakSelf);
        [strongSelf hide];
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

- (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    CGSize size = [self getSizeWithAsset:asset];
    size.width  *= 1.5;
    size.height *= 1.5;
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
}

@end
