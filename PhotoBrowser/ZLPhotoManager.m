//
//  ZLPhotoManager.m
//  ZLPhotoBrowser
//
//  Created by long on 17/4/12.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLPhotoManager.h"
#import "ZLDefine.h"
#import <AVFoundation/AVFoundation.h>
#define CollectionName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]

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
        NSLog(@"Cannot get asset from localID because it is nil");
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
        if ([collection.localizedTitle isEqualToString:CollectionName]) {
            return collection;
        }
    }
    //新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:CollectionName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"创建相册：%@失败", CollectionName);
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
            m = [self getAlbumModeWithTitle:collection.localizedTitle result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage];
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
     = 1000000201///最近删除知道值为（1000000201）但没找到对应的TypedefName
     // Used for fetching, if you don't care about the exact subtype
     PHAssetCollectionSubtypeAny = NSIntegerMax /////所有类型
     */
    NSMutableArray<ZLAlbumListModel *> *arrAlbum = [NSMutableArray array];
    for (PHFetchResult<PHAssetCollection *> *album in arrAllAlbums) {
        [album enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            //过滤PHCollectionList对象
            if (![collection isKindOfClass:PHAssetCollection.class]) return;
            //过滤最近删除
            if (collection.assetCollectionSubtype > 213) return;
            //获取相册内asset result
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (!result.count) return;
            
            if (collection.assetCollectionSubtype == 209) {
                ZLAlbumListModel *m = [self getAlbumModeWithTitle:collection.localizedTitle result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage];
                m.isCameraRoll = YES;
                [arrAlbum insertObject:m atIndex:0];
                
            } else {
                [arrAlbum addObject:[self getAlbumModeWithTitle:collection.localizedTitle result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage]];
            }
        }];
    }
    
    if (complete) complete(arrAlbum);
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

+ (void)requestOriginalImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
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
        [self requestOriginalImageDataForAsset:model.asset completion:^(NSData *data, NSDictionary *info) {
            if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                UIImage *image = [ZLPhotoManager transformToGifImageWithData:data];
                if (completion) {
                    completion(image, info);
                }
            }
        }];
    } else {
        if (isOriginal) {
            [self requestOriginalImageForAsset:model.asset completion:completion];
        } else {
            CGFloat scale = 2;
            CGFloat width = MIN(kViewWidth, kMaxImageWidth);
            CGSize size = CGSizeMake(width*scale, width*scale*model.asset.pixelHeight/model.asset.pixelWidth);
            [self requestImageForAsset:model.asset size:size completion:completion];
        }
    }
}

+ (void)requestOriginalImageForAsset:(PHAsset *)asset completion:(void (^)(UIImage *, NSDictionary *))completion
{
    [self requestImageForAsset:asset size:PHImageManagerMaximumSize resizeMode:PHImageRequestOptionsResizeModeExact completion:completion];
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *))completion
{
    return [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
}

+ (void)requestLivePhotoForAsset:(PHAsset *)asset completion:(void (^)(PHLivePhoto *, NSDictionary *))completion
{
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.version = PHImageRequestOptionsVersionCurrent;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    option.networkAccessAllowed = YES;
    
    [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        if (completion) completion(livePhoto, info);
    }];
}

+ (void)requestVideoForAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *, NSDictionary *))completion
{
    [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) completion(playerItem, info);
    }];
}

#pragma mark - 获取asset对应的图片
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion
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
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAblum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
    }];
    return isInLocalAblum;
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

+ (void)markSelcectModelInArr:(NSArray<ZLPhotoModel *> *)dataArr selArr:(NSArray<ZLPhotoModel *> *)selArr
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

#pragma mark - 编辑视频相关
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
    for (int i = 0; i < duration; i += interval) {
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
                NSLog(@"第%ld秒图片解析失败", count);
                break;
            case AVAssetImageGeneratorCancelled:
                NSLog(@"取消解析视频图片");
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

+ (void)exportEditVideoForAsset:(AVAsset *)asset range:(CMTimeRange)range complete:(void (^)(BOOL, PHAsset *))complete
{
    NSTimeInterval interval = [[[NSDate alloc] init] timeIntervalSince1970];
    
    NSString *exportFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.mov", interval]];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    
    NSURL *exportFileUrl = [NSURL fileURLWithPath:exportFilePath];
    
    exportSession.outputURL = exportFileUrl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
                
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"Export completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self saveVideoToAblum:exportFileUrl completion:^(BOOL isSuc, PHAsset *asset) {
                        if (complete) complete(isSuc, asset);
                        if (isSuc) {
                            NSLog(@"导出的的视频路径: %@", exportFilePath);
                        } else {
                            NSLog(@"导出视频失败");
                        }
                    }];
                });
            }
                break;
                
            default:
                NSLog(@"Export other");
                break;
        }
    }];
}

@end
