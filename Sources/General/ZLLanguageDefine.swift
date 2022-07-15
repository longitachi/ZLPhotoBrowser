//
//  ZLLanguageDefine.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/17.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
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
    case french
    case german
    case russian
    case vietnamese
    case korean
    case malay
    case italian
    case indonesian
    case portuguese
    case spanish
    case turkish
}

public struct ZLLocalLanguageKey: Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Camera (拍照)
    public static let previewCamera = ZLLocalLanguageKey(rawValue: "previewCamera")
    
    /// Record (拍摄)
    public static let previewCameraRecord = ZLLocalLanguageKey(rawValue: "previewCameraRecord")
    
    /// Album (相册)
    public static let previewAlbum = ZLLocalLanguageKey(rawValue: "previewAlbum")
    
    /// Cancel (取消)
    public static let cancel = ZLLocalLanguageKey(rawValue: "cancel")
    
    /// No Photo (无照片)
    public static let noPhotoTips = ZLLocalLanguageKey(rawValue: "noPhotoTips")
    
    /// waiting... (正在处理...)
    public static let hudLoading = ZLLocalLanguageKey(rawValue: "hudLoading")
    
    /// Done (确定)
    public static let done = ZLLocalLanguageKey(rawValue: "done")
    
    /// OK (确定)
    public static let ok = ZLLocalLanguageKey(rawValue: "ok")
    
    /// Request timed out (请求超时)
    public static let timeout = ZLLocalLanguageKey(rawValue: "timeout")
    
    /// Please Allow %@ to access your album in \"Settings\"->\"Privacy\"->\"Photos\"
    /// (请在iPhone的\"设置-隐私-照片\"选项中，允许%@访问你的照片)
    public static let noPhotoLibratyAuthority = ZLLocalLanguageKey(rawValue: "noPhotoLibratyAuthority")
    
    /// Please allow %@ to access your device's camera in \"Settings\"->\"Privacy\"->\"Camera\"
    /// (请在iPhone的\"设置-隐私-相机\"选项中，允许%@访问你的相机)
    public static let noCameraAuthority = ZLLocalLanguageKey(rawValue: "noCameraAuthority")
    
    /// Unable to record audio. Go to \"Settings\" > \"%@\" and enable microphone access.
    /// (无法录制声音，前往\"设置 > %@\"中打开麦克风权限)
    public static let noMicrophoneAuthority = ZLLocalLanguageKey(rawValue: "noMicrophoneAuthority")
    
    /// Camera is unavailable (相机不可用)
    public static let cameraUnavailable = ZLLocalLanguageKey(rawValue: "cameraUnavailable")
    
    /// Keep Recording (继续拍摄)
    public static let keepRecording = ZLLocalLanguageKey(rawValue: "keepRecording")
    
    /// Go to Settings (前往设置)
    public static let gotoSettings = ZLLocalLanguageKey(rawValue: "gotoSettings")
    
    /// Photos (照片)
    public static let photo = ZLLocalLanguageKey(rawValue: "photo")
    
    /// Full Image (原图)
    public static let originalPhoto = ZLLocalLanguageKey(rawValue: "originalPhoto")
    
    /// Back (返回)
    public static let back = ZLLocalLanguageKey(rawValue: "back")
    
    /// Edit (编辑)
    public static let edit = ZLLocalLanguageKey(rawValue: "edit")
    
    /// Done (完成)
    public static let editFinish = ZLLocalLanguageKey(rawValue: "editFinish")
    
    /// Undo (还原)
    public static let revert = ZLLocalLanguageKey(rawValue: "revert")
    
    /// Brightness (亮度)
    public static let brightness = ZLLocalLanguageKey(rawValue: "brightness")
    
    /// Contrast (对比度)
    public static let contrast = ZLLocalLanguageKey(rawValue: "contrast")
    
    /// Saturation (饱和度)
    public static let saturation = ZLLocalLanguageKey(rawValue: "saturation")
    
    /// Preview (预览)
    public static let preview = ZLLocalLanguageKey(rawValue: "preview")
    
    /// Save (保存)
    public static let save = ZLLocalLanguageKey(rawValue: "save")
    
    /// Failed to save the image (图片保存失败)
    public static let saveImageError = ZLLocalLanguageKey(rawValue: "saveImageError")
    
    /// Failed to save the video (视频保存失败)
    public static let saveVideoError = ZLLocalLanguageKey(rawValue: "saveVideoError")
    
    /// Max select count: %ld (最多只能选择%ld张图片)
    public static let exceededMaxSelectCount = ZLLocalLanguageKey(rawValue: "exceededMaxSelectCount")
    
    /// Max count for video selection: %ld (最多只能选择%ld个视频)
    public static let exceededMaxVideoSelectCount = ZLLocalLanguageKey(rawValue: "exceededMaxVideoSelectCount")
    
    /// Min count for video selection: %ld (最少选择%ld个视频)
    public static let lessThanMinVideoSelectCount = ZLLocalLanguageKey(rawValue: "lessThanMinVideoSelectCount")
    
    /// Unable to select video with a duration longer than %lds
    /// (不能选择超过%ld秒的视频)
    public static let longerThanMaxVideoDuration = ZLLocalLanguageKey(rawValue: "longerThanMaxVideoDuration")
    
    /// Unable to select video with a duration shorter than %lds
    /// (不能选择低于%ld秒的视频)
    public static let shorterThanMaxVideoDuration = ZLLocalLanguageKey(rawValue: "shorterThanMaxVideoDuration")
    
    /// Unable to sync from iCloud (iCloud无法同步)
    public static let iCloudVideoLoadFaild = ZLLocalLanguageKey(rawValue: "iCloudVideoLoadFaild")
    
    /// loading failed (图片加载失败)
    public static let imageLoadFailed = ZLLocalLanguageKey(rawValue: "imageLoadFailed")
    
    /// Tap to take photo and hold to record video (轻触拍照，按住摄像)
    public static let customCameraTips = ZLLocalLanguageKey(rawValue: "customCameraTips")
    
    /// Tap to take photo (轻触拍照)
    public static let customCameraTakePhotoTips = ZLLocalLanguageKey(rawValue: "customCameraTakePhotoTips")
    
    /// hold to record video (按住摄像)
    public static let customCameraRecordVideoTips = ZLLocalLanguageKey(rawValue: "customCameraRecordVideoTips")
    
    /// Record at least %lds (至少录制%ld秒)
    public static let minRecordTimeTips = ZLLocalLanguageKey(rawValue: "minRecordTimeTips")
    
    /// Recents (所有照片)
    public static let cameraRoll = ZLLocalLanguageKey(rawValue: "cameraRoll")
    
    /// Panoramas (全景照片)
    public static let panoramas = ZLLocalLanguageKey(rawValue: "panoramas")
    
    /// Videos (视频)
    public static let videos = ZLLocalLanguageKey(rawValue: "videos")
    
    /// Favorites (个人收藏)
    public static let favorites = ZLLocalLanguageKey(rawValue: "favorites")
    
    /// Time-Lapse (延时摄影)
    public static let timelapses = ZLLocalLanguageKey(rawValue: "timelapses")
    
    /// Recently Added (最近添加)
    public static let recentlyAdded = ZLLocalLanguageKey(rawValue: "recentlyAdded")
    
    /// Bursts (连拍快照)
    public static let bursts = ZLLocalLanguageKey(rawValue: "bursts")
    
    /// Slo-mo (慢动作)
    public static let slomoVideos = ZLLocalLanguageKey(rawValue: "slomoVideos")
    
    /// Selfies (自拍)
    public static let selfPortraits = ZLLocalLanguageKey(rawValue: "selfPortraits")
    
    /// Screenshots (屏幕快照)
    public static let screenshots = ZLLocalLanguageKey(rawValue: "screenshots")
    
    /// Portrait (人像)
    public static let depthEffect = ZLLocalLanguageKey(rawValue: "depthEffect")
    
    /// Live Photo
    public static let livePhotos = ZLLocalLanguageKey(rawValue: "livePhotos")
    
    /// Animated (动图)
    public static let animated = ZLLocalLanguageKey(rawValue: "animated")
    
    /// My Photo Stream (我的照片流)
    public static let myPhotoStream = ZLLocalLanguageKey(rawValue: "myPhotoStream")
    
    /// All Photos (所有照片)
    public static let noTitleAlbumListPlaceholder = ZLLocalLanguageKey(rawValue: "noTitleAlbumListPlaceholder")
    
    /// Unable to access all photos, go to settings (无法访问所有照片，前往设置)
    public static let unableToAccessAllPhotos = ZLLocalLanguageKey(rawValue: "unableToAccessAllPhotos")
    
    /// Drag here to remove (拖到此处删除)
    public static let textStickerRemoveTips = ZLLocalLanguageKey(rawValue: "textStickerRemoveTips")
}

func localLanguageTextValue(_ key: ZLLocalLanguageKey) -> String {
    if let value = ZLCustomLanguageDeploy.deploy[key] {
        return value
    }
    return Bundle.zlLocalizedString(key.rawValue)
}
