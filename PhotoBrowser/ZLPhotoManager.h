//
//  ZLPhotoManager.h
//  ZLPhotoBrowser
//
//  Created by long on 17/4/12.
//  Copyright © 2017年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "ZLPhotoModel.h"
#import "ZLDefine.h"

@class ZLAlbumListModel;

@interface ZLPhotoManager : NSObject

/**
 * @brief 设置排序模式
 */
+ (void)setSortAscending:(BOOL)ascending;


/**
 * @brief 保存图片到系统相册
 */
+ (void)saveImageToAblum:(UIImage *)image completion:(void (^)(BOOL suc, PHAsset *asset))completion;

/**
 * @brief 保存视频到系统相册
 */
+ (void)saveVideoToAblum:(NSURL *)url completion:(void (^)(BOOL suc, PHAsset *asset))completion;

/**
 * @brief 在全部照片中获取指定个数、排序方式的部分照片，在跳往预览大图界面时候video和gif均为no，不受参数影响
 */
+ (NSArray<ZLPhotoModel *> *)getAllAssetInPhotoAlbumWithAscending:(BOOL)ascending limitCount:(NSInteger)limit allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;


/**
 * @brief 获取相机胶卷相册列表对象
 */
+ (ZLAlbumListModel *)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage;


/**
 block 获取相机胶卷相册列表对象
 */
+ (void)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage complete:(void (^)(ZLAlbumListModel *album))complete;

/**
 * @brief 获取用户所有相册列表
 */
+ (void)getPhotoAblumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage complete:(void (^)(NSArray<ZLAlbumListModel *> *))complete;

/**
 * @brief 将result中对象转换成ZLPhotoModel
 */
+ (NSArray<ZLPhotoModel *> *)getPhotoInResult:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;

/**
 * @brief 获取选中的图片
 */
+ (void)requestSelectedImageForAsset:(ZLPhotoModel *)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^)(UIImage *, NSDictionary *))completion;


/**
 获取原图data，转换gif图
 */
+ (void)requestOriginalImageDataForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(NSData *, NSDictionary *))completion;

/**
 * @brief 获取原图
 */
+ (void)requestOriginalImageForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion;

/**
 * @brief 根据传入size获取图片
 */
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion;


/**
 * @brief 获取live photo
 */
+ (void)requestLivePhotoForAsset:(PHAsset *)asset completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion;

/**
 * @brief 获取视频
 */
+ (void)requestVideoForAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *item, NSDictionary *info))completion;
+ (void)requestVideoForAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *item, NSDictionary *info))completion;

#pragma mark - 逐个解析asset方法
/**
 自行解析图片方法
 
 使用顺序单个解析，缓解了框架同时解析大量图片造成的内存暴涨
 如果一下选择20张及以上照片(原图)建议使用自行解析
 
 请求到图片后做了一个大小的压缩（原图时并未压缩尺寸）来缓解内存的占用
 */
+ (void)anialysisAssets:(NSArray<PHAsset *> *)assets original:(BOOL)original completion:(void (^)(NSArray<UIImage *> *images))completion;

/**
 @brief 缩放图片
 */
+ (UIImage *)scaleImage:(UIImage *)image original:(BOOL)original;

/**
 * @brief 将系统mediatype转换为自定义mediatype
 */
+ (ZLAssetMediaType)transformAssetType:(PHAsset *)asset;

/**
 * @brief 转换视频时长
 */
+ (NSString *)getDuration:(PHAsset *)asset;

/**
 * @brief 判断图片是否存储在本地/或者已经从iCloud上下载到本地
 */
+ (BOOL)judgeAssetisInLocalAblum:(PHAsset *)asset;

/**
 * @brief 获取图片字节大小
 */
+ (void)getPhotosBytesWithArray:(NSArray<ZLPhotoModel *> *)photos completion:(void (^)(NSString *photosBytes))completion;

/**
 * @brief 标记源数组中已被选择的model
 */
+ (void)markSelectModelInArr:(NSArray<ZLPhotoModel *> *)dataArr selArr:(NSArray<ZLPhotoModel *> *)selArr;

/**
 * @brief 将image data转换为gif图片，sdwebimage
 */
+ (UIImage *)transformToGifImageWithData:(NSData *)data;


/**
 获取对应asset的路径
 */
+ (void)requestAssetFileUrl:(PHAsset *)asset complete:(void (^)(NSString *filePath))complete;

#pragma mark - 编辑、导出视频相关

/**
 解析视频，获取每秒对应的一帧图片

 @param size 图片size
 */
+ (void)analysisEverySecondsImageForAsset:(PHAsset *)asset interval:(NSTimeInterval)interval size:(CGSize)size complete:(void (^)(AVAsset *avAsset, NSArray<UIImage *> *images))complete;

/**
 导出编辑的片段视频并保存到相册
 
 @param range 需要到处的视频间隔
 */
+ (void)exportEditVideoForAsset:(AVAsset *)asset range:(CMTimeRange)range type:(ZLExportVideoType)type complete:(void (^)(BOOL isSuc, PHAsset *asset))complete;


/**
 导出视频，视频压缩设置默认为 AVAssetExportPresetMediumQuality
 
 @param asset 需要导出视频的asset
 @param type 视频导出格式
 */
+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type complete:(void (^)(NSString *exportFilePath, NSError *error))complete;

/**
 导出视频

 @param asset 需要导出视频的asset
 @param type 视频导出格式
 @param presetName 视频压缩设置
 */
+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type presetName:(NSString *)presetName complete:(void (^)(NSString *exportFilePath, NSError *error))complete;


/**
 导出指定尺寸的视频，视频区域为以视频中心为中点（视频质量未压缩）

 @param asset 需要导出视频的asset
 @param type 视频导出格式
 @param renderSize 指定的尺寸大小
 */
+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type renderSize:(CGSize)renderSize complete:(void (^)(NSString *exportFilePath, NSError *error))complete;

#pragma mark - 导出视频加水印、粒子效果
/**
 导出指定尺寸视频，并添加水印，视频区域为以视频中心为中点（视频质量未压缩）
 
 @discussion（由于文字水印在开发过程中遇到对同一个视频导出时候，有的文字显示，有的不显示的文字，所以暂不支持文字水印）

 @param asset 需要导出视频的asset
 @param type 视频导出格式
 @param renderSize 指定的尺寸大小，如要导出全尺寸视频，可将该值设置的大些如:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
 @param watermarkImage 水印图片
 @param location 水印位置
 @param imageSize 水印大小
 */
+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type renderSize:(CGSize)renderSize watermarkImage:(UIImage *)watermarkImage watermarkLocation:(ZLWatermarkLocation)location imageSize:(CGSize)imageSize complete:(void (^)(NSString *exportFilePath, NSError *error))complete;


/**
 导出全尺寸视频，并添加水印（支持设置压缩系数）

 @param asset 需要导出视频的asset
 @param type 视频导出格式
 @param presetName 视频压缩设置
 @param watermarkImage 水印图片
 @param location 水印位置
 @param imageSize 水印大小
 */
+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type presetName:(NSString *)presetName watermarkImage:(UIImage *)watermarkImage watermarkLocation:(ZLWatermarkLocation)location imageSize:(CGSize)imageSize complete:(void (^)(NSString *exportFilePath, NSError *error))complete;


/**
 给视频加粒子特效，目前仅支持粒子从屏幕上方向下发射，e.g.:下雪特效，需传入一张雪花图片。
 
 @param asset 需要导出视频的asset
 @param type 视频导出格式
 @param presetName 视频压缩设置
 @param effectImage 粒子图片（建议一倍图尺寸不超过200*200）
 @param birthRate 粒子每秒创建数量（建议30~50）
 @param velocity 粒子扩散速度
 */
+ (void)exportVideoForAsset:(PHAsset *)asset type:(ZLExportVideoType)type presetName:(NSString *)presetName effectImage:(UIImage *)effectImage birthRate:(NSInteger)birthRate velocity:(CGFloat)velocity complete:(void (^)(NSString *exportFilePath, NSError *error))complete;


/**
 获取保存视频的路径
 */
+ (NSString *)getVideoExportFilePath:(ZLExportVideoType)type;


#pragma mark - 相册、相机、麦克风权限相关
/**
 是否有相册访问权限
 */
+ (BOOL)havePhotoLibraryAuthority;

/**
 是否有相机访问权限
 */
+ (BOOL)haveCameraAuthority;

/**
 是否有麦克风访问权限
 */
+ (BOOL)haveMicrophoneAuthority;

@end
