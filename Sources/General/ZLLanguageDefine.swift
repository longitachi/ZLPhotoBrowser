//
//  ZLLanguageDefine.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/17.
//
//  Copyright (c) 2020 Long Zhang <longitachi@163.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

@objc public enum ZLLanguageType: Int {
    case system
    case chineseSimplified
    case chineseTraditional
    case english
    case japanese
}

public struct ZLLocalLanguageKey: Hashable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// 拍照
    public static let previewCamera = ZLLocalLanguageKey(rawValue: "previewCamera")
    
    /// 拍摄
    public static let previewCameraRecord = ZLLocalLanguageKey(rawValue: "previewCameraRecord")
    
    /// 相册
    public static let previewAlbum = ZLLocalLanguageKey(rawValue: "previewAlbum")
    
    /// 取消
    public static let previewCancel = ZLLocalLanguageKey(rawValue: "previewCancel")
    
    /// 无照片
    public static let noPhotoTips = ZLLocalLanguageKey(rawValue: "noPhotoTips")
    
    /// 加载中，请稍后
    public static let loading = ZLLocalLanguageKey(rawValue: "loading")
    
    /// 正在处理...
    public static let hudLoading = ZLLocalLanguageKey(rawValue: "hudLoading")
    
    /// 确定
    public static let done = ZLLocalLanguageKey(rawValue: "done")
    
    /// 确定
    public static let ok = ZLLocalLanguageKey(rawValue: "ok")
    
    /// 请求超时
    public static let timeout = ZLLocalLanguageKey(rawValue: "timeout")
    
    /// 请在iPhone的\"设置-隐私-照片\"选项中，允许%@访问你的照片
    public static let noPhotoLibratyAuthority = ZLLocalLanguageKey(rawValue: "noPhotoLibratyAuthority")
    
    /// 请在iPhone的\"设置-隐私-相机\"选项中，允许%@访问你的相机
    public static let noCameraAuthority = ZLLocalLanguageKey(rawValue: "noCameraAuthority")
    
    /// 请在iPhone的\"设置-隐私-麦克风\"选项中，允许%@访问你的麦克风
    public static let noMicrophoneAuthority = ZLLocalLanguageKey(rawValue: "noMicrophoneAuthority")
    
    /// 相机不可用
    public static let cameraUnavailable = ZLLocalLanguageKey(rawValue: "cameraUnavailable")
    
    /// 照片
    public static let photo = ZLLocalLanguageKey(rawValue: "photo")
    
    /// 原图
    public static let originalPhoto = ZLLocalLanguageKey(rawValue: "originalPhoto")
    
    /// 返回
    public static let back = ZLLocalLanguageKey(rawValue: "back")
    
    /// 编辑
    public static let edit = ZLLocalLanguageKey(rawValue: "edit")
    
    /// 完成
    public static let editFinish = ZLLocalLanguageKey(rawValue: "editFinish")
    
    /// 保存
    public static let save = ZLLocalLanguageKey(rawValue: "save")
    
    /// 还原
    public static let revert = ZLLocalLanguageKey(rawValue: "revert")
    
    /// 预览
    public static let preview = ZLLocalLanguageKey(rawValue: "preview")
    
    /// 不能同时选择照片和视频
    public static let notAllowMixSelect = ZLLocalLanguageKey(rawValue: "notAllowMixSelect")
    
    /// 图片保存失败
    public static let saveImageError = ZLLocalLanguageKey(rawValue: "saveImageError")
    
    /// 视频保存失败
    public static let saveVideoError = ZLLocalLanguageKey(rawValue: "saveVideoError")
    
    /// 最多只能选择%ld张图片
    public static let exceededMaxSelectCount = ZLLocalLanguageKey(rawValue: "exceededMaxSelectCount")
    
    /// 不能选择超过%ld秒的视频
    public static let longerThanMaxVideoDuration = ZLLocalLanguageKey(rawValue: "longerThanMaxVideoDuration")
    
    /// 不能选择低于%ld秒的视频
    public static let shorterThanMaxVideoDuration = ZLLocalLanguageKey(rawValue: "shorterThanMaxVideoDuration")
    
    /// 请在系统相册中下载到本地后重新尝试
    public static let iCloudPhotoLoadFaild = ZLLocalLanguageKey(rawValue: "iCloudPhotoLoadFaild")
    
    /// iCloud无法同步
    public static let iCloudVideoLoadFaild = ZLLocalLanguageKey(rawValue: "iCloudVideoLoadFaild")
    
    /// 图片加载失败
    public static let imageLoadFailed = ZLLocalLanguageKey(rawValue: "imageLoadFailed")
    
    /// 轻触拍照，按住摄像
    public static let customCameraTips = ZLLocalLanguageKey(rawValue: "customCameraTips")
    
    /// 轻触拍照
    public static let customCameraTakePhotoTips = ZLLocalLanguageKey(rawValue: "customCameraTakePhotoTips")
    
    /// 按住摄像
    public static let customCameraRecordVideoTips = ZLLocalLanguageKey(rawValue: "customCameraRecordVideoTips")
    
    /// 至少录制%ld秒
    public static let minRecordTimeTips = ZLLocalLanguageKey(rawValue: "minRecordTimeTips")
    
    /// 所有照片
    public static let cameraRoll = ZLLocalLanguageKey(rawValue: "cameraRoll")
    
    /// 全景照片
    public static let panoramas = ZLLocalLanguageKey(rawValue: "panoramas")
    
    /// 视频
    public static let videos = ZLLocalLanguageKey(rawValue: "videos")
    
    /// 个人收藏
    public static let favorites = ZLLocalLanguageKey(rawValue: "favorites")
    
    /// 延时摄影
    public static let timelapses = ZLLocalLanguageKey(rawValue: "timelapses")
    
    /// 最近添加
    public static let recentlyAdded = ZLLocalLanguageKey(rawValue: "recentlyAdded")
    
    /// 连拍快照
    public static let bursts = ZLLocalLanguageKey(rawValue: "bursts")
    
    /// 慢动作
    public static let slomoVideos = ZLLocalLanguageKey(rawValue: "slomoVideos")
    
    /// 自拍
    public static let selfPortraits = ZLLocalLanguageKey(rawValue: "selfPortraits")
    
    /// 屏幕快照
    public static let screenshots = ZLLocalLanguageKey(rawValue: "screenshots")
    
    /// 人像
    public static let depthEffect = ZLLocalLanguageKey(rawValue: "depthEffect")
    
    /// Live Photo
    public static let livePhotos = ZLLocalLanguageKey(rawValue: "livePhotos")
    
    /// 动图
    public static let animated = ZLLocalLanguageKey(rawValue: "animated")
    
    /// 我的照片流
    public static let myPhotoStream = ZLLocalLanguageKey(rawValue: "myPhotoStream")
    
    /// 所有照片
    public static let noTitleAlbumListPlaceholder = ZLLocalLanguageKey(rawValue: "noTitleAlbumListPlaceholder")
    
}

func localLanguageTextValue(_ key: ZLLocalLanguageKey) -> String {
    if let value = ZLCustomLanguageDeploy.deploy[key] {
        return value
    }
    return Bundle.zlLocalizedString(key.rawValue)
}
