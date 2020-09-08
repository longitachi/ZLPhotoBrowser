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
    
    public static let previewCamera = ZLLocalLanguageKey(rawValue: "previewCamera")
    
    public static let previewCameraRecord = ZLLocalLanguageKey(rawValue: "previewCameraRecord")
    
    public static let previewAlbum = ZLLocalLanguageKey(rawValue: "previewAlbum")
    
    public static let previewCancel = ZLLocalLanguageKey(rawValue: "previewCancel")
    
    public static let noPhotoTips = ZLLocalLanguageKey(rawValue: "noPhotoTips")
    
    public static let loading = ZLLocalLanguageKey(rawValue: "loading")
    
    public static let hudLoading = ZLLocalLanguageKey(rawValue: "hudLoading")
    
    public static let done = ZLLocalLanguageKey(rawValue: "done")
    
    public static let ok = ZLLocalLanguageKey(rawValue: "ok")
    
    public static let timeout = ZLLocalLanguageKey(rawValue: "timeout")
    
    public static let maxSelectCount = ZLLocalLanguageKey(rawValue: "exceededMaxSelectCount")
    
    public static let noPhotoLibratyAuthority = ZLLocalLanguageKey(rawValue: "noPhotoLibratyAuthority")
    
    public static let noCameraAuthority = ZLLocalLanguageKey(rawValue: "noCameraAuthority")
    
    public static let noMicrophoneAuthority = ZLLocalLanguageKey(rawValue: "noMicrophoneAuthority")
    
    public static let cameraUnavailable = ZLLocalLanguageKey(rawValue: "cameraUnavailable")
    
    public static let photo = ZLLocalLanguageKey(rawValue: "photo")
    
    public static let originalPhoto = ZLLocalLanguageKey(rawValue: "originalPhoto")
    
    public static let back = ZLLocalLanguageKey(rawValue: "back")
    
    public static let edit = ZLLocalLanguageKey(rawValue: "edit")
    
    public static let editFinish = ZLLocalLanguageKey(rawValue: "editFinish")
    
    public static let save = ZLLocalLanguageKey(rawValue: "save")
    
    public static let revert = ZLLocalLanguageKey(rawValue: "revert")
    
    public static let preview = ZLLocalLanguageKey(rawValue: "preview")
    
    public static let notAllowMixSelect = ZLLocalLanguageKey(rawValue: "notAllowMixSelect")
    
    public static let saveImageError = ZLLocalLanguageKey(rawValue: "saveImageError")
    
    public static let saveVideoError = ZLLocalLanguageKey(rawValue: "saveVideoError")
    
    public static let exceededMaxSelectCount = ZLLocalLanguageKey(rawValue: "exceededMaxSelectCount")
    
    public static let longerThanMaxVideoDuration = ZLLocalLanguageKey(rawValue: "longerThanMaxVideoDuration")
    
    public static let shorterThanMaxVideoDuration = ZLLocalLanguageKey(rawValue: "shorterThanMaxVideoDuration")
    
    public static let iCloudPhotoLoadFaild = ZLLocalLanguageKey(rawValue: "iCloudPhotoLoadFaild")
    
    public static let iCloudVideoLoadFaild = ZLLocalLanguageKey(rawValue: "iCloudVideoLoadFaild")
    
    public static let imageLoadFailed = ZLLocalLanguageKey(rawValue: "imageLoadFailed")
    
    public static let customCameraTips = ZLLocalLanguageKey(rawValue: "customCameraTips")
    
    public static let minRecordTimeTips = ZLLocalLanguageKey(rawValue: "minRecordTimeTips")
    
    public static let cameraRoll = ZLLocalLanguageKey(rawValue: "cameraRoll")
    
    public static let panoramas = ZLLocalLanguageKey(rawValue: "panoramas")
    
    public static let videos = ZLLocalLanguageKey(rawValue: "videos")
    
    public static let favorites = ZLLocalLanguageKey(rawValue: "favorites")
    
    public static let timelapses = ZLLocalLanguageKey(rawValue: "timelapses")
    
    public static let recentlyAdded = ZLLocalLanguageKey(rawValue: "recentlyAdded")
    
    public static let bursts = ZLLocalLanguageKey(rawValue: "bursts")
    
    public static let slomoVideos = ZLLocalLanguageKey(rawValue: "slomoVideos")
    
    public static let selfPortraits = ZLLocalLanguageKey(rawValue: "selfPortraits")
    
    public static let screenshots = ZLLocalLanguageKey(rawValue: "screenshots")
    
    public static let depthEffect = ZLLocalLanguageKey(rawValue: "depthEffect")
    
    public static let livePhotos = ZLLocalLanguageKey(rawValue: "livePhotos")
    
    public static let animated = ZLLocalLanguageKey(rawValue: "animated")
    
}

func localLanguageTextValue(_ key: ZLLocalLanguageKey) -> String {
    if let value = ZLCustomLanguageDeploy.deploy[key] {
        return value
    }
    return Bundle.zlLocalizedString(key.rawValue)
}
