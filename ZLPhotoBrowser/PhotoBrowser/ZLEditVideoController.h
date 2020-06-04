//
//  ZLEditVideoController.h
//  ZLPhotoBrowser
//
//  Created by long on 2017/9/15.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLDefine.h"

@class ZLPhotoModel, AVAsset, PHAsset;

NS_ASSUME_NONNULL_BEGIN

@interface ZLEditVideoController : UIViewController

@property (nonatomic, strong) ZLPhotoModel *model;

/// 通过该方法初始化，接收一个url，可直接调用编辑视频界面
/// @param url 这个url必须是fileUrl，网络url编辑视频可能失败
- (instancetype)initWithFileUrl:(NSURL *)url maxEditTime:(NSInteger)maxEditTime exportVideoType:(ZLExportVideoType)type completion:(void (^)(BOOL, PHAsset *))completion;

@end

NS_ASSUME_NONNULL_END
