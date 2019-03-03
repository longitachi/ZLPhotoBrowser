//
//  ZLPhotoConfiguration.m
//  ZLPhotoBrowser
//
//  Created by long on 2017/11/16.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLPhotoConfiguration.h"

@implementation ZLPhotoConfiguration

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZLCustomImageNames];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZLLanguageTypeKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZLCustomLanguageKeyValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"---- %s", __FUNCTION__);
}

+ (instancetype)defaultPhotoConfiguration
{
    ZLPhotoConfiguration *configuration = [ZLPhotoConfiguration new];
    
    configuration.statusBarStyle = UIStatusBarStyleLightContent;
    configuration.maxSelectCount = 9;
    configuration.maxPreviewCount = 20;
    configuration.cellCornerRadio = .0;
    configuration.allowMixSelect = YES;
    configuration.allowSelectImage = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectGif = YES;
    configuration.allowSelectLivePhoto = NO;
    configuration.allowTakePhotoInLibrary = YES;
    configuration.allowForceTouch = YES;
    configuration.allowEditImage = YES;
    configuration.allowEditVideo = NO;
    configuration.allowSelectOriginal = YES;
    configuration.maxEditVideoTime = 10;
    configuration.maxVideoDuration = 120;
    configuration.allowSlideSelect = YES;
    configuration.allowDragSelect = NO;
//    configuration.editType = ZLImageEditTypeClip;
    configuration.clipRatios = @[GetCustomClipRatio(),
                                 GetClipRatio(1, 1),
                                 GetClipRatio(4, 3),
                                 GetClipRatio(3, 2),
                                 GetClipRatio(16, 9)];
    configuration.editAfterSelectThumbnailImage = NO;
    configuration.saveNewImageAfterEdit = YES;
    configuration.showCaptureImageOnTakePhotoBtn = YES;
    configuration.sortAscending = YES;
    configuration.showSelectBtn = NO;
    configuration.navBarColor = kRGB(19, 153, 231);
    configuration.navTitleColor = [UIColor whiteColor];
    configuration.bottomViewBgColor = [UIColor whiteColor];
    configuration.bottomBtnsNormalTitleColor = kRGB(80, 180, 234);
    configuration.bottomBtnsDisableBgColor = kRGB(200, 200, 200);
    configuration.showSelectedMask = NO;
    configuration.selectedMaskColor = [UIColor blackColor];
    configuration.customImageNames = nil;
    configuration.shouldAnialysisAsset = YES;
    configuration.languageType = ZLLanguageSystem;
    configuration.useSystemCamera = NO;
    configuration.allowRecordVideo = YES;
    configuration.maxRecordDuration = 10;
    configuration.sessionPreset = ZLCaptureSessionPreset1280x720;
    configuration.exportVideoType = ZLExportVideoTypeMov;
    
    return configuration;
}

- (void)setMaxSelectCount:(NSInteger)maxSelectCount
{
    _maxSelectCount = MAX(maxSelectCount, 1);
}

- (BOOL)showSelectBtn
{
    return _maxSelectCount > 1 ? YES : _showSelectBtn;
}

- (void)setAllowSelectLivePhoto:(BOOL)allowSelectLivePhoto
{
    if (@available(iOS 9.0, *)) {
        _allowSelectLivePhoto = allowSelectLivePhoto;
    } else {
        _allowSelectLivePhoto = NO;
    }
}

- (void)setMaxEditVideoTime:(NSInteger)maxEditVideoTime
{
    _maxEditVideoTime = MAX(maxEditVideoTime, 10);
}

- (void)setCustomImageNames:(NSArray<NSString *> *)customImageNames
{
    [[NSUserDefaults standardUserDefaults] setValue:customImageNames forKey:ZLCustomImageNames];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLanguageType:(ZLLanguageType)languageType
{
    [[NSUserDefaults standardUserDefaults] setValue:@(languageType) forKey:ZLLanguageTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSBundle resetLanguage];
}

- (void)setCustomLanguageKeyValue:(NSDictionary<NSString *,NSString *> *)customLanguageKeyValue
{
    [[NSUserDefaults standardUserDefaults] setValue:customLanguageKeyValue forKey:ZLCustomLanguageKeyValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setMaxRecordDuration:(NSInteger)maxRecordDuration
{
    _maxRecordDuration = MAX(maxRecordDuration, 1);
}

//- (void)setEditType:(ZLImageEditType)editType
//{
//    assert(editType != 0);
//
//    if (editType == 0) {
//        _editType = ZLImageEditTypeClip;
//    } else {
//        _editType = editType;
//    }
//}

@end
