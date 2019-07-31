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
    configuration.maxVideoSelectCountInMix = 9;
    configuration.minVideoSelectCountInMix = 0;
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
    configuration.navBarColor = kRGB(44, 45, 46);
    configuration.navTitleColor = [UIColor whiteColor];
    configuration.previewTextColor = [UIColor blackColor];
    configuration.bottomViewBgColor = kRGB(44, 45, 46);
    configuration.bottomBtnsNormalTitleColor = [UIColor whiteColor];
    configuration.bottomBtnsDisableTitleColor = kRGB(168, 168, 168);
    configuration.bottomBtnsNormalBgColor = kRGB(80, 169, 52);
    configuration.bottomBtnsDisableBgColor = kRGB(39, 80, 32);
    configuration.showSelectedMask = NO;
    configuration.selectedMaskColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    configuration.showSelectedIndex = YES;
    configuration.indexLabelBgColor = kRGB(80, 169, 52);
    configuration.cameraProgressColor = kRGB(80, 169, 52);
    configuration.customImageNames = nil;
    configuration.shouldAnialysisAsset = YES;
    configuration.timeout = 20;
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
    BOOL changeMaxVideoSelectCount = self.maxVideoSelectCountInMix == _maxSelectCount;
    
    _maxSelectCount = MAX(maxSelectCount, 1);
    
    if (changeMaxVideoSelectCount) {
        self.maxVideoSelectCountInMix = _maxSelectCount;
    } else if (_maxSelectCount < self.maxVideoSelectCountInMix) {
        self.maxVideoSelectCountInMix = _maxSelectCount;
    }
    
    if (self.minVideoSelectCountInMix > _maxSelectCount) {
        self.minVideoSelectCountInMix = _maxSelectCount;
    }
}

- (void)setMaxVideoSelectCountInMix:(NSInteger)maxVideoSelectCountInMix
{
    _maxVideoSelectCountInMix = MAX(MIN(self.maxSelectCount, maxVideoSelectCountInMix), 0);
    NSAssert(_maxVideoSelectCountInMix >= self.minVideoSelectCountInMix, @"混合选择中，最大视频选择数量不能小于最小视频选择数量");
}

- (void)setMinVideoSelectCountInMix:(NSInteger)minVideoSelectCountInMix
{
    _minVideoSelectCountInMix = MAX(MIN(self.maxSelectCount, minVideoSelectCountInMix), 0);
    NSAssert(_minVideoSelectCountInMix <= self.maxVideoSelectCountInMix, @"混合选择中，最小视频选择数量不能大于最大视频选择数量");
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
