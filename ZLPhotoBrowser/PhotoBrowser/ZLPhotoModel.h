//
//  ZLPhotoModel.h
//  ZLPhotoBrowser
//
//  Created by long on 17/4/12.
//  Copyright © 2017年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, ZLAssetMediaType) {
    ZLAssetMediaTypeUnknown,
    ZLAssetMediaTypeImage,
    ZLAssetMediaTypeGif,
    ZLAssetMediaTypeLivePhoto,
    ZLAssetMediaTypeVideo,
    ZLAssetMediaTypeAudio,
    ZLAssetMediaTypeNetImage,
    ZLAssetMediaTypeNetVideo,
};

@interface ZLPhotoModel : NSObject

//asset对象
@property (nonatomic, strong) PHAsset *asset;
//asset类型
@property (nonatomic, assign) ZLAssetMediaType type;
//视频时长
@property (nonatomic, copy) NSString *duration;
//是否被选择
@property (nonatomic, assign, getter=isSelected) BOOL selected;

//网络/本地 图片url
@property (nonatomic, strong) NSURL *url ;
//图片
@property (nonatomic, strong) UIImage *image;

/**初始化model对象*/
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(ZLAssetMediaType)type duration:(NSString *)duration;

@end

@interface ZLAlbumListModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isCameraRoll;
@property (nonatomic, strong) PHFetchResult *result;
//相册第一张图asset对象
@property (nonatomic, strong) PHAsset *headImageAsset;

@property (nonatomic, strong) NSArray<ZLPhotoModel *> *models;
@property (nonatomic, strong) NSArray *selectedModels;
//待用
@property (nonatomic, assign) NSUInteger selectedCount;

@end
