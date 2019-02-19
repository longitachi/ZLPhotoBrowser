//
//  ZLPhotoManager.m
//  ZLPhotoBrowser
//
//  Created by long on 17/4/12.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLPhotoManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ZLDefine.h"

static BOOL _sortAscending;

@implementation ZLPhotoManager

+ (void)setSortAscending:(BOOL)ascending
{
    _sortAscending = ascending;
}

+ (BOOL)sortAscending
{
    return _sortAscending;
}

#pragma mark - 保存图片到系统相册
+ (void)saveImageToAblum:(UIImage *)image completion:(void (^)(BOOL, PHAsset *))completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        if (completion) completion(NO, nil);
    } else if (status == PHAuthorizationStatusRestricted) {
        if (completion) completion(NO, nil);
    } else {
        __block PHObjectPlaceholder *placeholderAsset=nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *desCollection = [self getDestinationCollection];
            if (!desCollection) completion(NO, nil);
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) completion(success, asset);
            }];
        }];
    }
}

+ (void)saveVideoToAblum:(NSURL *)url completion:(void (^)(BOOL, PHAsset *))completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        if (completion) completion(NO, nil);
    } else if (status == PHAuthorizationStatusRestricted) {
        if (completion) completion(NO, nil);
    } else {
        __block PHObjectPlaceholder *placeholderAsset=nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *desCollection = [self getDestinationCollection];
            if (!desCollection) completion(NO, nil);
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) completion(success, asset);
            }];
        }];
    }
}

+ (PHAsset *)getAssetFromlocalIdentifier:(NSString *)localIdentifier{
    if(localIdentifier == nil){
        ZLLoggerDebug(@"Cannot get asset from localID because it is nil");
        return nil;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    if(result.count){
        return result[0];
    }
    return nil;
}

//获取自定义相册
+ (PHAssetCollection *)getDestinationCollection
{
    //找是否已经创建自定义相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:kAPPName]) {
            return collection;
        }
    }
    //新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kAPPName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        ZLLoggerDebug(@"创建相册：%@失败", kAPPName);
        return nil;
    }
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

#pragma mark - 在全部照片中获取指定个数、排序方式的部分照片
+ (NSArray<ZLPhotoModel *> *)getAllAssetInPhotoAlbumWithAscending:(BOOL)ascending limitCount:(NSInteger)limit allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    if (!ascending) option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsWithOptions:option];
    
    return [self getPhotoInResult:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage allowSelectGif:allowSelectGif allowSelectLivePhoto:allowSelectLivePhoto limitCount:limit];
}

+ (ZLAlbumListModel *)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!allowSelectVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (!allowSelectImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeVideo];
    if (!self.sortAscending) option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscending]];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    __block ZLAlbumListModel *m;
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        //获取相册内asset result
        if (collection.assetCollectionSubtype == 209) {
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            m = [self getAlbumModeWithTitle:[self getCollectionTitle:collection] result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage];
            m.isCameraRoll = YES;
        }
    }];
    return m;
}

+ (void)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage complete:(void (^)(ZLAlbumListModel *))complete
{
    if (complete) {
        complete([self getCameraRollAlbumList:allowSelectVideo allowSelectImage:allowSelectImage]);
    }
}

+ (void)getPhotoAblumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage complete:(void (^)(NSArray<ZLAlbumListModel *> *))complete
{
    if (!allowSelectImage && !allowSelectVideo) {
        if (complete) complete(nil);
        return;
    }
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!allowSelectVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (!allowSelectImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeVideo];
    if (!self.sortAscending) option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscending]];
    
    //获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *streamAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *arrAllAlbums = @[smartAlbums, streamAlbums, userAlbums, syncedAlbums, sharedAlbums];
    /**
     PHAssetCollectionSubtypeAlbumRegular         = 2,///
     PHAssetCollectionSubtypeAlbumSyncedEvent     = 3,////
     PHAssetCollectionSubtypeAlbumSyncedFaces     = 4,////面孔
     PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5,////
     PHAssetCollectionSubtypeAlbumImported        = 6,////
     
     // PHAssetCollectionTypeAlbum shared subtypes
     PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,///
     PHAssetCollectionSubtypeAlbumCloudShared     = 101,///
     
     // PHAssetCollectionTypeSmartAlbum subtypes        //// collection.localizedTitle
     PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,///
     PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,///全景照片
     PHAssetCollectionSubtypeSmartAlbumVideos     = 202,///视频
     PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,///个人收藏
     PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,///延时摄影
     PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,/// 已隐藏
     PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,///最近添加
     PHAssetCollectionSubtypeSmartAlbumBursts     = 207,///连拍快照
     PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,///慢动作
     PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,///所有照片
     PHAssetCollectionSubtypeSmartAlbumSelfPortraits NS_AVAILABLE_IOS(9_0) = 210,///自拍
     PHAssetCollectionSubtypeSmartAlbumScreenshots NS_AVAILABLE_IOS(9_0) = 211,///屏幕快照
     PHAssetCollectionSubtypeSmartAlbumDepthEffect PHOTOS_AVAILABLE_IOS_TVOS(10_2, 10_1) = 212,///人像
     PHAssetCollectionSubtypeSmartAlbumLivePhotos PHOTOS_AVAILABLE_IOS_TVOS(10_3, 10_2) = 213,//livephotos
     PHAssetCollectionSubtypeSmartAlbumAnimated = 214,///动图
     = 1000000201///最近删除知道值为（1000000201）但没找到对应的TypedefName
     // Used for fetching, if you don't care about the exact subtype
     PHAssetCollectionSubtypeAny = NSIntegerMax /////所有类型
     */
    NSMutableArray<ZLAlbumListModel *> *arrAlbum = [NSMutableArray array];
    for (PHFetchResult<PHAssetCollection *> *album in arrAllAlbums) {
        [album enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            //过滤PHCollectionList对象
            if (![collection isKindOfClass:PHAssetCollection.class]) return;
            //过滤最近删除和已隐藏
            if (collection.assetCollectionSubtype > 215 ||
                collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) return;
            //获取相册内asset result
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (!result.count) return;
            
            NSString *title = [self getCollectionTitle:collection];
            
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                //所有照片
                ZLAlbumListModel *m = [self getAlbumModeWithTitle:title result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage];
                m.isCameraRoll = YES;
                [arrAlbum insertObject:m atIndex:0];
            } else {
                [arrAlbum addObject:[self getAlbumModeWithTitle:title result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage]];
            }
        }];
    }
    
    if (complete) complete(arrAlbum);
}

+ (NSString *)getCollectionTitle:(PHAssetCollection *)collection
{
    if (collection.assetCollectionType == PHAssetCollectionTypeAlbum) {
        //用户相册
        return collection.localizedTitle;
    }
    
    //系统相册
    ZLLanguageType type = [[[NSUserDefaults standardUserDefaults] valueForKey:ZLLanguageTypeKey] integerValue];
    
    NSString *title = nil;
    
    if (type == ZLLanguageSystem) {
        title = collection.localizedTitle;
    } else {
        switch (collection.assetCollectionSubtype) {
            case PHAssetCollectionSubtypeSmartAlbumUserLibrary:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserCameraRoll);
                break;
            case PHAssetCollectionSubtypeSmartAlbumPanoramas:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserPanoramas);
                break;
            case PHAssetCollectionSubtypeSmartAlbumVideos:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserVideos);
                break;
            case PHAssetCollectionSubtypeSmartAlbumFavorites:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserFavorites);
                break;
            case PHAssetCollectionSubtypeSmartAlbumTimelapses:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserTimelapses);
                break;
            case PHAssetCollectionSubtypeSmartAlbumRecentlyAdded:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserRecentlyAdded);
                break;
            case PHAssetCollectionSubtypeSmartAlbumBursts:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserBursts);
                break;
            case PHAssetCollectionSubtypeSmartAlbumSlomoVideos:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserSlomoVideos);
                break;
            case PHAssetCollectionSubtypeSmartAlbumSelfPortraits:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserSelfPortraits);
                break;
            case PHAssetCollectionSubtypeSmartAlbumScreenshots:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserScreenshots);
                break;
            case PHAssetCollectionSubtypeSmartAlbumDepthEffect:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserDepthEffect);
                break;
            case PHAssetCollectionSubtypeSmartAlbumLivePhotos:
                title = GetLocalLanguageTextValue(ZLPhotoBrowserLivePhotos);
                break;
                
            default:
                break;
        }
        
        if (@available(iOS 11, *)) {
            //            PHAssetCollectionSubtypeSmartAlbumAnimated 为动图，但是貌似苹果返回的结果有bug，动图的subtype值为 215，即PHAssetCollectionSubtypeSmartAlbumLongExposures
            if (collection.assetCollectionSubtype == 215) {
                title = GetLocalLanguageTextValue(ZLPhotoBrowserAnimated);
            }
        }
    }
    
    return title?:collection.localizedTitle;
}

//获取相册列表model
+ (ZLAlbumListModel *)getAlbumModeWithTitle:(NSString *)title result:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage
{
    ZLAlbumListModel *model = [[ZLAlbumListModel alloc] init];
    model.title = title;
    model.count = result.count;
    model.result = result;
    if (self.sortAscending) {
        model.headImageAsset = result.lastObject;
    } else {
        model.headImageAsset = result.firstObject;
    }
    //为了获取所有asset gif设置为yes
    model.models = [ZLPhotoManager getPhotoInResult:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage allowSelectGif:allowSelectImage allowSelectLivePhoto:allowSelectImage];
    
    return model;
}

#pragma mark - 根据照片数组对象获取对应photomodel数组
+ (NSArray<ZLPhotoModel *> *)getPhotoInResult:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto
{
    return [self getPhotoInResult:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage allowSelectGif:allowSelectGif allowSelectLivePhoto:allowSelectLivePhoto limitCount:NSIntegerMax];
}

+ (NSArray<ZLPhotoModel *> *)getPhotoInResult:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto limitCount:(NSInteger)limit
{
    NSMutableArray<ZLPhotoModel *> *arrModel = [NSMutableArray array];
    __block NSInteger count = 1;
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZLAssetMediaType type = [self transformAssetType:obj];
        
        if (type == ZLAssetMediaTypeImage && !allowSelectImage) return;
        if (type == ZLAssetMediaTypeGif && !allowSelectImage) return;
        if (type == ZLAssetMediaTypeLivePhoto && !allowSelectImage) return;
        if (type == ZLAssetMediaTypeVideo && !allowSelectVideo) return;
        
        if (count == limit) {
            *stop = YES;
        }
        
        NSString *duration = [self getDuration:obj];
        
        [arrModel addObject:[ZLPhotoModel modelWithAsset:obj type:type duration:duration]];
        count++;
    }];
    return arrModel;
}

//系统mediatype 转换为 自定义type
+ (ZLAssetMediaType)transformAssetType:(PHAsset *)asset
{
    switch (asset.mediaType) {
        case PHAssetMediaTypeAudio:
            return ZLAssetMediaTypeAudio;
        case PHAssetMediaTypeVideo:
            return ZLAssetMediaTypeVideo;
        case PHAssetMediaTypeImage:
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"])return ZLAssetMediaTypeGif;
            
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 10) return ZLAssetMediaTypeLivePhoto;
            
            return ZLAssetMediaTypeImage;
        default:
            return ZLAssetMediaTypeUnknown;
    }
}

+ (NSString *)getDuration:(PHAsset *)asset
{
    if (asset.mediaType != PHAssetMediaTypeVideo) return nil;
    
    NSInteger duration = (NSInteger)round(asset.duration);
    
    if (duration < 60) {
        return [NSString stringWithFormat:@"00:%02ld", duration];
    } else if (duration < 3600) {
        NSInteger m = duration / 60;
        NSInteger s = duration % 60;
        return [NSString stringWithFormat:@"%02ld:%02ld", m, s];
    } else {
        NSInteger h = duration / 3600;
        NSInteger m = (duration % 3600) / 60;
        NSInteger s = duration % 60;
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", h, m, s];
    }
}

+ (void)requestOriginalImageDataForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double, NSError *, BOOL *, NSDictionary *))progressHandler completion:(void (^)(NSData *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.progressHandler = progressHandler;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            if (completion) completion(imageData, info);
        }
    }];
}

+ (void)requestSelectedImageForAsset:(ZLPhotoModel *)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^)(UIImage *, NSDictionary *))completion
{
    if (model.type == ZLAssetMediaTypeGif && allowSelectGif) {
        [self requestOriginalImageDataForAsset:model.asset progressHandler:nil completion:^(NSData *data, NSDictionary *info) {
            if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                UIImage *image = [ZLPhotoManager transformToGifImageWithData:data];
                if (completion) {
                    completion(image, info);
                }
            }
        }];
    } else {
        if (isOriginal) {
            [self requestOriginalImageForAsset:model.asset progressHandler:nil completion:completion];
        } else {
            CGFloat scale = 2;
            CGFloat width = MIN(kViewWidth, kMaxImageWidth);
            CGSize size = CGSizeMake(width*scale, width*scale*model.asset.pixelHeight/model.asset.pixelWidth);
            [self requestImageForAsset:model.asset size:size progressHandler:nil completion:completion];
        }
    }
}

+ (void)requestOriginalImageForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion
{
    //    CGFloat scale = 4;
    //    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    //    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    //    [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
    [self requestImageForAsset:asset size:CGSizeMake(asset.pixelWidth, asset.pixelHeight) resizeMode:PHImageRequestOptionsResizeModeNone progressHandler:progressHandler completion:completion];
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    return [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast progressHandler:progressHandler completion:completion];
}

+ (void)requestLivePhotoForAsset:(PHAsset *)asset completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion
{
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.version = PHImageRequestOptionsVersionCurrent;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    option.networkAccessAllowed = YES;
    
    [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        if (completion) completion(livePhoto, info);
    }];
}

+ (void)requestVideoForAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *item, NSDictionary *info))completion
{
    [self requestVideoForAsset:asset progressHandler:nil completion:completion];
}

+ (void)requestVideoForAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *item, NSDictionary *info))completion
{
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) completion(playerItem, info);
    }];
}

+ (void)anialysisAssets:(NSArray<PHAsset *> *)assets original:(BOOL)original completion:(void (^)(NSArray<UIImage *> *))completion
{
    NSMutableArray *arr = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_queue_create(nil, 0);
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(1);
    
    for (int i = 0; i < assets.count; i++) {
        PHAsset *asset = assets[i];
        
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            zl_weakify(self);
            if (original) {
                [self requestOriginalImageForAsset:asset progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
                    if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
                    dispatch_semaphore_signal(sem);
                    zl_strongify(weakSelf);
                    
                    [arr addObject:[strongSelf scaleImage:image original:original]];
                    if (i == assets.count-1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(arr);
                        });
                    }
                }];
            } else {
                CGFloat scale = 2;
                CGFloat width = MIN(kViewWidth, kMaxImageWidth);
                CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
                [self requestImageForAsset:asset size:size progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
                    if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
                    dispatch_semaphore_signal(sem);
                    zl_strongify(weakSelf);
                    
                    [arr addObject:[strongSelf scaleImage:image original:original]];
                    if (i == assets.count-1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(arr);
                        });
                    }
                }];
            }
        });
    }
}

+ (UIImage *)scaleImage:(UIImage *)image original:(BOOL)original
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    
    if (data.length < 0.2*(1024*1024)) {
        //小于200k不缩放
        return image;
    }
    
    double scale = original ? (data.length>(1024*1024)?.7:.9) : (data.length>(1024*1024)?.5:.7);
    NSData *d = UIImageJPEGRepresentation(image, scale);
    
    return [UIImage imageWithData:d];
    
    //    CGSize size = CGSizeMake(ScalePhotoWidth, ScalePhotoWidth * image.size.height / image.size.width);
    //    if (image.size.width < size.width
    //        ) {
    //        return image;
    //    }
    //    UIGraphicsBeginImageContext(size);
    //    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //    return newImage;
}

#pragma mark - 获取asset对应的图片
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    
    option.resizeMode = resizeMode;//控制照片尺寸
    //    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.networkAccessAllowed = YES;
    
    option.progressHandler = progressHandler;
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    
    return [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}

+ (BOOL)judgeAssetisInLocalAblum:(PHAsset *)asset
{
    __block BOOL result = NO;
    if (@available(iOS 10.0, *)) {
        // https://stackoverflow.com/questions/31966571/check-given-phasset-is-icloud-asset
        // 这个api虽然是9.0出的，但是9.0会全部返回NO，未知原因，暂时先改为10.0
        NSArray *resourceArray = [PHAssetResource assetResourcesForAsset:asset];
        for (id obj in resourceArray) {
            result = [[obj valueForKey:@"locallyAvailable"] boolValue];
            if (result) break;
        }
    } else {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.networkAccessAllowed = NO;
        option.synchronous = YES;
        
        [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            result = imageData ? YES : NO;
        }];
    }
    return result;
}

+ (void)getPhotosBytesWithArray:(NSArray<ZLPhotoModel *> *)photos completion:(void (^)(NSString *photosBytes))completion
{
    __block NSInteger dataLength = 0;
    __block NSInteger count = photos.count;
    
    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < photos.count; i++) {
        ZLPhotoModel *model = photos[i];
        [[PHCachingImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dataLength += imageData.length;
            count--;
            if (count <= 0) {
                if (completion) {
                    completion([strongSelf transformDataLength:dataLength]);
                }
            }
        }];
    }
}

+ (NSString *)transformDataLength:(NSInteger)dataLength {
    NSString *bytes = @"";
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

+ (void)markSelectModelInArr:(NSArray<ZLPhotoModel *> *)dataArr selArr:(NSArray<ZLPhotoModel *> *)selArr
{
    NSMutableArray *selIdentifiers = [NSMutableArray array];
    for (ZLPhotoModel *m in selArr) {
        [selIdentifiers addObject:m.asset.localIdentifier];
    }
    for (ZLPhotoModel *m in dataArr) {
        if ([selIdentifiers containsObject:m.asset.localIdentifier]) {
            m.selected = YES;
        } else {
            m.selected = NO;
        }
    }
}

+ (UIImage *)transformToGifImageWithData:(NSData *)data
{
    return [self sd_animatedGIFWithData:data];
}

+ (UIImage *)sd_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            duration += [self sd_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)sd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (void)requestAssetFileUrl:(PHAsset *)asset complete:(void (^)(NSString *))complete
{
    ZLAssetMediaType type = [self transformAssetType:asset];
    if (type == ZLAssetMediaTypeVideo) {
        [self requestVideoForAsset:asset completion:^(AVPlayerItem *item, NSDictionary *info) {
            if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
            NSArray *arr = [info[@"PHImageFileSandboxExtensionTokenKey"] componentsSeparatedByString:@";"];
            if (complete) {
                complete(arr.lastObject);
            }
        }];
    } else {
        [self requestOriginalImageDataForAsset:asset progressHandler:nil completion:^(NSData *data, NSDictionary *info) {
            if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
            if (complete) {
                NSURL *url = info[@"PHImageFileURLKey"];
                complete(url.absoluteString);
            }
        }];
    }
}

#pragma mark - 编辑、导出视频相关
+ (void)analysisEverySecondsImageForAsset:(PHAsset *)asset interval:(NSTimeInterval)interval size:(CGSize)size complete:(void (^)(AVAsset *, NSArray<UIImage *> *))complete
{
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        [self analysisAVAsset:asset interval:interval size:size complete:complete];
    }];
}

+ (void)analysisAVAsset:(AVAsset *)asset interval:(NSTimeInterval)interval size:(CGSize)size complete:(void (^)(AVAsset *, NSArray<UIImage *> *))complete
{
    long duration = round(asset.duration.value) / asset.duration.timescale;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize = size;
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    //每秒的第一帧
    NSMutableArray *arr = [NSMutableArray array];
    for (float i = 0; i < duration; i += interval) {
        /*
         CMTimeMake(a,b) a当前第几帧, b每秒钟多少帧
         */
        //这里加上0.35 是为了避免解析0s图片必定失败的问题
        CMTime time = CMTimeMake((i+0.35) * asset.duration.timescale, asset.duration.timescale);
        NSValue *value = [NSValue valueWithCMTime:time];
        [arr addObject:value];
    }
    
    NSMutableArray *arrImages = [NSMutableArray array];
    
    __block long count = 0;
    [generator generateCGImagesAsynchronouslyForTimes:arr completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        switch (result) {
            case AVAssetImageGeneratorSucceeded:
                [arrImages addObject:[UIImage imageWithCGImage:image]];
                break;
            case AVAssetImageGeneratorFailed:
                ZLLoggerDebug(@"第%ld秒图片解析失败", count);
                break;
            case AVAssetImageGeneratorCancelled:
                ZLLoggerDebug(@"取消解析视频图片");
                break;
        }
        
        count++;
        
        if (count == arr.count && complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(asset, arrImages);
            });
        }
    }];
}

+ (void)exportEditVideoForAsset:(AVAsset *)asset range:(CMTimeRange)range type:(ZLExportVideoType)type complete:(void (^)(BOOL, PHAsset *))complete
{
    [self export:asset range:range type:type presetName:AVAssetExportPresetPassthrough renderSize:CGSizeZero watermarkImage:nil watermarkLocation:ZLWatermarkLocationCenter imageSize:CGSizeZero effectImage:nil birthRate:0 velocity:0 complete:^(NSString *exportFilePath, NSError *error) {
        if (!error) {
            [self saveVideoToAblum:[NSURL fileURLWithPath:exportFilePath] completion:^(BOOL isSuc, PHAsset *asset) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) complete(isSuc, asset);
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) complete(NO, nil);
            });
        }
    }];
}

+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type complete:(void (^)(NSString *, NSError *))complete
{
    [self exportVideoForAsset:asset type:type presetName:AVAssetExportPresetMediumQuality complete:complete];
}

+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type presetName:(NSString *)presetName complete:(void (^)(NSString *, NSError *))complete
{
    [self export:asset type:type presetName:presetName renderSize:CGSizeZero watermarkImage:nil watermarkLocation:ZLWatermarkLocationCenter imageSize:CGSizeZero effectImage:nil birthRate:0 velocity:0 complete:complete];
}

+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type renderSize:(CGSize)renderSize complete:(void (^)(NSString *, NSError *))complete
{
    [self exportVideoForAsset:asset type:type renderSize:renderSize watermarkImage:nil watermarkLocation:ZLWatermarkLocationCenter imageSize:CGSizeZero complete:complete];
}

#pragma mark - 视频加水印及粒子效果
+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type renderSize:(CGSize)renderSize watermarkImage:(UIImage *)watermarkImage watermarkLocation:(ZLWatermarkLocation)location imageSize:(CGSize)imageSize complete:(void (^)(NSString *, NSError *))complete
{
    [self export:asset type:type presetName:AVAssetExportPresetHighestQuality renderSize:renderSize watermarkImage:watermarkImage watermarkLocation:location imageSize:imageSize effectImage:nil birthRate:0 velocity:0 complete:complete];
}

+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type presetName:(NSString *)presetName watermarkImage:(UIImage *)watermarkImage watermarkLocation:(ZLWatermarkLocation)location imageSize:(CGSize)imageSize complete:(void (^)(NSString *, NSError *))complete
{
    [self export:asset type:type presetName:presetName renderSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) watermarkImage:watermarkImage watermarkLocation:location imageSize:imageSize effectImage:nil birthRate:0 velocity:0 complete:complete];
}

+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type presetName:(NSString *)presetName effectImage:(UIImage *)effectImage birthRate:(NSInteger)birthRate velocity:(CGFloat)velocity complete:(void (^)(NSString *, NSError *))complete
{
    [self export:asset type:type presetName:presetName renderSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) watermarkImage:nil watermarkLocation:ZLWatermarkLocationCenter imageSize:CGSizeZero effectImage:effectImage birthRate:birthRate velocity:velocity complete:complete];
}

//privite
+ (void)export:(PHAsset *)asset type:(ZLExportVideoType)type presetName:(NSString *)presetName renderSize:(CGSize)renderSize watermarkImage:(UIImage *)watermarkImage watermarkLocation:(ZLWatermarkLocation)location imageSize:(CGSize)imageSize effectImage:(UIImage *)effectImage birthRate:(NSInteger)birthRate velocity:(CGFloat)velocity complete:(void (^)(NSString *, NSError *))complete
{
    if (asset.mediaType != PHAssetMediaTypeVideo) {
        if (complete) complete(nil, [NSError errorWithDomain:@"导出失败" code:-1 userInfo:@{@"message": @"导出对象不是视频对象"}]);
        return;
    }
    
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        [self export:asset range:CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity) type:type presetName:presetName renderSize:renderSize watermarkImage:watermarkImage watermarkLocation:location imageSize:imageSize effectImage:effectImage birthRate:birthRate velocity:velocity complete:^(NSString *exportFilePath, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) complete(exportFilePath, error);
            });
        }];
    }];
}

+ (void)export:(AVAsset *)asset range:(CMTimeRange)range type:(ZLExportVideoType)type presetName:(NSString *)presetName renderSize:(CGSize)renderSize watermarkImage:(UIImage *)watermarkImage watermarkLocation:(ZLWatermarkLocation)location imageSize:(CGSize)imageSize effectImage:(UIImage *)effectImage birthRate:(NSInteger)birthRate velocity:(CGFloat)velocity complete:(void (^)(NSString *exportFilePath, NSError *error))complete
{
    NSString *exportFilePath = [self getVideoExportFilePath:type];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:presetName];
    
    NSURL *exportFileUrl = [NSURL fileURLWithPath:exportFilePath];
    
    exportSession.outputURL = exportFileUrl;
    exportSession.outputFileType = (type == ZLExportVideoTypeMov ? AVFileTypeQuickTimeMovie : AVFileTypeMPEG4);
    exportSession.timeRange = range;
//        exportSession.shouldOptimizeForNetworkUse = YES;
    if (!CGSizeEqualToSize(renderSize, CGSizeZero)) {
        AVMutableVideoComposition *com = [self getVideoComposition:asset renderSize:renderSize watermarkImage:watermarkImage watermarkLocation:location imageSize:imageSize effectImage:effectImage birthRate:birthRate velocity:velocity];
        if (!com) {
            if (complete) {
                complete(nil, [NSError errorWithDomain:@"视频裁剪导出失败" code:-1 userInfo:@{@"message": @"视频对象格式可能有错误，没有检测到视频通道"}]);
            }
            return;
        }
        exportSession.videoComposition = com;
    }
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        BOOL suc = NO;
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                ZLLoggerDebug(@"Export failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                ZLLoggerDebug(@"Export canceled");
                break;
                
            case AVAssetExportSessionStatusCompleted:{
                ZLLoggerDebug(@"Export completed");
                suc = YES;
            }
                break;
                
            default:
                ZLLoggerDebug(@"Export other");
                break;
        }
        
        if (complete) {
            complete(suc?exportFilePath:nil, suc?nil:exportSession.error);
            if (!suc) {
                [exportSession cancelExport];
            }
        }
    }];
}

+ (AVMutableVideoComposition *)getVideoComposition:(AVAsset *)asset renderSize:(CGSize)renderSize watermarkImage:(UIImage *)watermarkImage watermarkLocation:(ZLWatermarkLocation)location imageSize:(CGSize)imageSize effectImage:(UIImage *)effectImage birthRate:(NSInteger)birthRate velocity:(CGFloat)velocity
{
    AVMutableComposition *composition = [AVMutableComposition composition];
    //视频通道
    AVMutableCompositionTrack *assetVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //音频通道
    AVMutableCompositionTrack *assetAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error = nil;
    //裁剪时长
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    if (!videoTrack) {
        return nil;
    }
    [assetVideoTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    ZLLoggerDebug(@"%@", error);
    if (audioTrack) {
        [assetAudioTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:&error];
        ZLLoggerDebug(@"%@", error);
    }
    
    if (error) {
        return nil;
    }
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
    
    //处理视频旋转
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInstruction setOpacity:0.0 atTime:assetVideoTrack.timeRange.duration];
    //视频旋转，获取视频旋转角度，然后旋转对应角度，保持视频方向正确
    CGFloat degree = [self getVideoDegree:videoTrack];
    CGSize naturalSize = assetVideoTrack.naturalSize;
    
    CGAffineTransform mixedTransform =  CGAffineTransformIdentity;
    //处理renderSize，不能大于视频宽高
    CGFloat videoWidth = (degree==0 || degree==M_PI) ? naturalSize.width : naturalSize.height;
    CGFloat videoHeight = (degree==0 || degree==M_PI) ? naturalSize.height : naturalSize.width;
    CGSize cropSize = CGSizeMake(MIN(videoWidth, renderSize.width), MIN(videoHeight, renderSize.height));
    CGFloat x, y;
    if (degree == M_PI_2) {
        //顺时针 90°
        CGAffineTransform t = CGAffineTransformMakeTranslation(naturalSize.height,.0);
        CGAffineTransform t1 = CGAffineTransformRotate(t, M_PI_2);
        //x为正向下 y为正向左
        x = -(videoHeight-cropSize.height)/2;
        y = (videoWidth-cropSize.width)/2;
        mixedTransform = CGAffineTransformTranslate(t1, x, y);
    } else if (degree == M_PI) {
        //顺时针 180°
        CGAffineTransform t = CGAffineTransformMakeTranslation(naturalSize.width, naturalSize.height);
        CGAffineTransform t1 = CGAffineTransformRotate(t, M_PI);
        //x为正向左 y为正向上
        x = (videoWidth-cropSize.width)/2;
        y = (videoHeight-cropSize.height)/2;
        mixedTransform = CGAffineTransformTranslate(t1, x, y);
    } else if (degree == (M_PI_2 * 3)) {
        //顺时针 270°
        CGAffineTransform t = CGAffineTransformMakeTranslation(.0, naturalSize.width);
        CGAffineTransform t1 = CGAffineTransformRotate(t, M_PI_2*3);
        //x为正向上 y为正向右
        x = (videoHeight-cropSize.height)/2;
        y = -(videoWidth-cropSize.width)/2;
        mixedTransform = CGAffineTransformTranslate(t1, x, y);
    } else {
        //x为正向右 y为正向下
        x = -(videoWidth-cropSize.width)/2;
        y = -(videoHeight-cropSize.height)/2;
        mixedTransform = CGAffineTransformMakeTranslation(x, y);
    }
    
    [layerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    
    //管理所有需要处理的视频
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderScale = 1;
    videoComposition.renderSize = cropSize;
    
    instruction.layerInstructions = @[layerInstruction];
    videoComposition.instructions = @[instruction];
    
    //添加水印
    if (watermarkImage || effectImage) {
        [self addWatermark:videoComposition renderSize:cropSize watermarkImage:watermarkImage watermarkLocation:location imageSize:imageSize effectImage:effectImage birthRate:birthRate velocity:velocity];
    }
    
    return videoComposition;
}

+ (CGFloat)getVideoDegree:(AVAssetTrack *)videoTrack
{
    CGAffineTransform tf = videoTrack.preferredTransform;
    
    CGFloat degree = 0;
    if (tf.b == 1.0 && tf.c == -1.0) {
        degree = M_PI_2;
    } else if (tf.a == -1.0 && tf.d == -1.0) {
        degree = M_PI;
    } else if (tf.b == -1.0 && tf.c == 1.0) {
        degree = M_PI_2 * 3;
    }
    return degree;
}

+ (void)addWatermark:(AVMutableVideoComposition *)videoCom renderSize:(CGSize)renderSize watermarkImage:(UIImage *)watermarkImage watermarkLocation:(ZLWatermarkLocation)location imageSize:(CGSize)imageSize effectImage:(UIImage *)effectImage birthRate:(NSInteger)birthRate velocity:(CGFloat)velocity
{
//    CATextLayer *titleLayer = [CATextLayer layer];
//    [titleLayer setFont:(__bridge CFTypeRef)[UIFont systemFontOfSize:25].fontName];
//    titleLayer.contentsScale = 2;
//    [titleLayer setFont:@"HiraKakuProN-W3"];
//    titleLayer.fontSize = 70;
//    titleLayer.wrapped = YES;
//    titleLayer.string = @"just for test";
//    titleLayer.masksToBounds = YES;
//    titleLayer.foregroundColor = [[UIColor blueColor] CGColor];
//    titleLayer.alignmentMode = kCAAlignmentCenter;
//    titleLayer.frame = CGRectMake(20, 100, renderSize.width-40, 100);
//    titleLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = (CGRect){CGPointZero, renderSize};
    
//    [overlayLayer addSublayer:titleLayer];
    
    //水印图片
    if (watermarkImage) {
        CALayer *imageLayer = [CALayer layer];
        imageLayer.contents = (id)watermarkImage.CGImage;
        //坐标起点为左下角，向右为x正，向上为y正
        switch (location) {
            case ZLWatermarkLocationTopLeft:
                imageLayer.frame = CGRectMake(10, renderSize.height-imageSize.height-10, imageSize.width, imageSize.height);
                break;
            case ZLWatermarkLocationTopRight:
                imageLayer.frame = CGRectMake(renderSize.width-imageSize.width-10, renderSize.height-imageSize.height-10, imageSize.width, imageSize.height);
                break;
            case ZLWatermarkLocationBottomLeft:
                imageLayer.frame = CGRectMake(10, 10, imageSize.width, imageSize.height);
                break;
            case ZLWatermarkLocationBottomRight:
                imageLayer.frame = CGRectMake(renderSize.width-imageSize.width-10, 10, imageSize.width, imageSize.height);
                break;
            case ZLWatermarkLocationCenter:
                imageLayer.frame = CGRectMake((renderSize.width-imageSize.width)/2, (renderSize.height-imageSize.height)/2, imageSize.width, imageSize.height);
                break;
        }
        
        [overlayLayer addSublayer:imageLayer];
    }
    
    //粒子特效
    if (effectImage) {
        CAEmitterLayer *effectLayer = [self getEmitterLayerWithEffectImage:effectImage birthRate:birthRate velocity:velocity emitterSize:renderSize];
        [overlayLayer addSublayer:effectLayer];
    }
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.backgroundColor = [UIColor clearColor].CGColor;
    parentLayer.frame = (CGRect){CGPointZero, renderSize};
    videoLayer.frame = (CGRect){CGPointZero, renderSize};
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    videoCom.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

+ (CAEmitterLayer *)getEmitterLayerWithEffectImage:(UIImage *)effectImage birthRate:(NSInteger)birthRate velocity:(CGFloat)velocity emitterSize:(CGSize)emitterSize
{
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    
    //发射模式
    emitterLayer.renderMode = kCAEmitterLayerSurface;
    emitterLayer.emitterPosition = CGPointMake(emitterSize.width/2, emitterSize.height);
    //发射源的形状
    emitterLayer.emitterShape = kCAEmitterLayerLine;
    //发射源的尺寸大小
    emitterLayer.emitterSize = emitterSize;
    //    emitterLayer.emitterDepth = 0.5;
    
    //create a particle template
    CAEmitterCell *cell = [[CAEmitterCell alloc] init];
    cell.contents = (__bridge id)effectImage.CGImage;
    //每秒创建的粒子个数
    cell.birthRate = birthRate;
    //每个粒子的存在时间
    cell.lifetime = 30.0;
    
    //粒子透明度变化到0的速度，单位为秒
//    cell.alphaSpeed = -0.4;
    //粒子的扩散速度
    cell.velocity = velocity;
    //粒子向外扩散区域大小
    cell.velocityRange = emitterSize.height;
    //粒子y方向的加速度分量
    cell.yAcceleration = 10;
    //粒子的扩散角度，设置成2*M_PI则会从360°向外扩散
    cell.emissionRange = 0.5*M_PI;
    cell.spinRange = 0.25*M_PI;
    //粒子起始缩放比例
    cell.scale = 0.2;
    cell.scaleRange = 0.2f;
    //粒子缩放从0~0.5的速度
//    cell.scaleSpeed = 0.5;
    
    cell.color = [UIColor whiteColor].CGColor;
//    cell.redRange = 2.0f;
//    cell.blueRange = 2.0f;
//    cell.greenRange = 2.0f;
    
    emitterLayer.shadowOpacity = 1.0;
    emitterLayer.shadowRadius  = 0.0;
    emitterLayer.shadowOffset  = CGSizeMake(0.0, 0.0);
    //粒子边缘的颜色
    emitterLayer.shadowColor = [UIColor whiteColor].CGColor;
    
    // 形成遮罩
//    UIImage *image      = [UIImage imageNamed:@"alpha"];
//    CALayer *movedMask          = [CALayer layer];
//    movedMask.frame    = (CGRect){CGPointZero, image.size};
//    movedMask.contents = (__bridge id)(image.CGImage);
//    movedMask.position = self.containerView.center;
//    emitterLayer.mask    = movedMask;
    
    emitterLayer.emitterCells = @[cell];
    
    return emitterLayer;
}

+ (NSString *)getVideoExportFilePath:(ZLExportVideoType)type
{
    NSString *format = (type == ZLExportVideoTypeMov ? @"mov" : @"mp4");
    
    NSString *exportFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self getUniqueStrByUUID], format]];
    
    return exportFilePath;
}

+ (NSString *)getUniqueStrByUUID
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    
    //get the string representation of the UUID
    CFStringRef uuidString = CFUUIDCreateString(nil, uuidObj);
    
    NSString *str = [NSString stringWithString:(__bridge NSString *)uuidString];
    
    CFRelease(uuidObj);
    CFRelease(uuidString);
    
    return [str lowercaseString];
}

#pragma mark - 权限相关
+ (BOOL)havePhotoLibraryAuthority
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

+ (BOOL)haveCameraAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

+ (BOOL)haveMicrophoneAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

@end

