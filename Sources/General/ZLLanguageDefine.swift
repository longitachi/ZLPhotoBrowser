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
    
    public static let previewCamera = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserCameraText")
    
    public static let previewCameraRecord = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserCameraRecordText")
    
    public static let previewAlbum = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserAblumText")
    
    public static let previewCancel = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserCancelText")
    
    public static let noPhotoTips = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserNoPhotoText")
    
    public static let loading = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserLoadingText")
    
    public static let hudLoading = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserHandleText")
    
    public static let done = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserDoneText")
    
    public static let ok = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserOKText")
    
    public static let timeout = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserRequestTimeout")
    
    public static let maxSelectCount = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserExceededMaxSelectCountText")
    
    public static let noPhotoLibratyAuthority = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserNoAblumAuthorityText")
    
    public static let noCameraAuthority = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserNoCameraAuthorityText")
    
    public static let noMicrophoneAuthority = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserNoMicrophoneAuthorityText")
    
    public static let cameraUnavailable = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserCameraUnavailableText")
    
    public static let photo = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserPhotoText")
    
    public static let originalPhoto = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserOriginalText")
    
    public static let back = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserBackText")
    
    public static let edit = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserEditText")
    
    public static let editFinish = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserEditFinishText")
    
    public static let save = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserSaveText")
    
    public static let revert = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserRevertText")
    
    public static let preview = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserPreviewText")
    
    public static let notAllowMixSelect = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserNotAllowMixSelect")
    
    public static let saveImageError = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserSaveImageErrorText")
    
    public static let saveVideoError = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserSaveVideoFailed")
    
    public static let exceededMaxSelectCount = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserExceededMaxSelectCountText")
    
    public static let longerThanMaxVideoDuration = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserLongerThanMaxVideoDurationText")
    
    public static let shorterThanMaxVideoDuration = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserShorterThanMinVideoDurationText")
    
    public static let iCloudPhotoLoadFaild = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowseriCloudPhotoLoadFailedText")
    
    public static let iCloudVideoLoadFaild = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowseriCloudVideoLoadFailedText")
    
    public static let imageLoadFailed = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserLoadImageFailed")
    
    public static let customCameraTips = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserCustomCameraTips")
    
    public static let cameraRoll = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserCameraRoll")
    
    public static let panoramas = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserPanoramas")
    
    public static let videos = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserVideos")
    
    public static let favorites = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserFavorites")
    
    public static let timelapses = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserTimelapses")
    
    public static let recentlyAdded = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserRecentlyAdded")
    
    public static let bursts = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserBursts")
    
    public static let slomoVideos = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserSlomoVideos")
    
    public static let selfPortraits = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserSelfPortraits")
    
    public static let screenshots = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserScreenshots")
    
    public static let depthEffect = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserDepthEffect")
    
    public static let livePhotos = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserLivePhotos")
    
    public static let animated = ZLLocalLanguageKey(rawValue: "ZLPhotoBrowserAnimated")
    
}

func localLanguageTextValue(_ key: ZLLocalLanguageKey) -> String {
    if let value = ZLCustomLanguageDeploy.deploy[key] {
        return value
    }
    return Bundle.zlLocalizedString(key.rawValue)
}
