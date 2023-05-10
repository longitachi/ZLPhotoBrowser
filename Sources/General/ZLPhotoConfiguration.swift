//
//  ZLPhotoConfiguration.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
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

import UIKit
import Photos

public typealias Second = Int

@objcMembers
public class ZLPhotoConfiguration: NSObject {
    private static var single = ZLPhotoConfiguration()
    
    public class func `default`() -> ZLPhotoConfiguration {
        return ZLPhotoConfiguration.single
    }
    
    public class func resetConfiguration() {
        ZLPhotoConfiguration.single = ZLPhotoConfiguration()
    }
    
    /// Photo sorting method, the preview interface is not affected by this parameter. Defaults to true.
    public var sortAscending = true
    
    private var pri_maxSelectCount = 9
    /// Anything superior than 1 will enable the multiple selection feature. Defaults to 9.
    public var maxSelectCount: Int {
        get {
            return pri_maxSelectCount
        }
        set {
            pri_maxSelectCount = max(1, newValue)
        }
    }
    
    private var pri_maxVideoSelectCount = 0
    /// A count for video max selection. Defaults to 0.
    /// - warning: Only valid in mix selection mode. (i.e. allowMixSelect = true)
    public var maxVideoSelectCount: Int {
        get {
            if pri_maxVideoSelectCount <= 0 {
                return maxSelectCount
            } else {
                return max(minVideoSelectCount, min(pri_maxVideoSelectCount, maxSelectCount))
            }
        }
        set {
            pri_maxVideoSelectCount = newValue
        }
    }
    
    private var pri_minVideoSelectCount = 0
    /// A count for video min selection. Defaults to 0.
    /// - warning: Only valid in mix selection mode. (i.e. allowMixSelect = true)
    public var minVideoSelectCount: Int {
        get {
            return min(maxSelectCount, max(pri_minVideoSelectCount, 0))
        }
        set {
            pri_minVideoSelectCount = newValue
        }
    }
    
    /// Whether photos and videos can be selected together. Defaults to true.
    /// If set to false, only one video can be selected. Defaults to true.
    public var allowMixSelect = true
    
    /// Preview selection max preview count, if the value is zero, only show `Camera`, `Album`, `Cancel` buttons. Defaults to 20.
    public var maxPreviewCount = 20
    
    /// If set to false, gif and livephoto cannot be selected either. Defaults to true.
    public var allowSelectImage = true
    
    public var allowSelectVideo = true
    
    /// Allow select Gif, it only controls whether it is displayed in Gif form.
    /// If value is false, the Gif logo is not displayed. Defaults to true.
    public var allowSelectGif = true
    
    /// Allow select LivePhoto, it only controls whether it is displayed in LivePhoto form.
    /// If value is false, the LivePhoto logo is not displayed. Defaults to false.
    public var allowSelectLivePhoto = false
    
    private var pri_allowTakePhotoInLibrary = true
    /// Allow take photos in the album. Defaults to true.
    /// - warning: If allowTakePhoto and allowRecordVideo are both false, it will not be displayed.
    public var allowTakePhotoInLibrary: Bool {
        get {
            return pri_allowTakePhotoInLibrary && (cameraConfiguration.allowTakePhoto || cameraConfiguration.allowRecordVideo)
        }
        set {
            pri_allowTakePhotoInLibrary = newValue
        }
    }
    
    /// Whether to callback directly after taking a photo. Defaults to false.
    public var callbackDirectlyAfterTakingPhoto = false
    
    private var pri_allowEditImage = true
    public var allowEditImage: Bool {
        get {
            return pri_allowEditImage
        }
        set {
            pri_allowEditImage = newValue
        }
    }
    
    /// - warning: The video can only be edited when no photos are selected, or only one video is selected, and the selection callback is executed immediately after editing is completed.
    private var pri_allowEditVideo = false
    public var allowEditVideo: Bool {
        get {
            return pri_allowEditVideo
        }
        set {
            pri_allowEditVideo = newValue
        }
    }
    
    /// Control whether to display the selection button animation when selecting. Defaults to true.
    public var animateSelectBtnWhenSelect = true
    
    /// Animation duration for select button
    public var selectBtnAnimationDuration: CFTimeInterval = 0.4
    
    /// After selecting a image/video in the thumbnail interface, enter the editing interface directly. Defaults to false.
    /// - discussion: Editing image is only valid when allowEditImage is true and maxSelectCount is 1.
    /// Editing video is only valid when allowEditVideo is true and maxSelectCount is 1.
    public var editAfterSelectThumbnailImage = false
    
    /// Only valid when allowMixSelect is false and allowEditVideo is true. Defaults to true.
    /// Just like the Wechat-Timeline selection style. If you want to crop the video after select thumbnail under allowMixSelect = true, please use **editAfterSelectThumbnailImage**.
    public var cropVideoAfterSelectThumbnail = true
    
    /// If image edit tools only has clip and this property is true. When you click edit, the cropping interface (i.e. ZLClipImageViewController) will be displayed. Defaults to false.
    public var showClipDirectlyIfOnlyHasClipTool = false
    
    /// Save the edited image to the album after editing. Defaults to true.
    public var saveNewImageAfterEdit = true
    
    /// If true, you can slide select photos in album. Defaults to true.
    public var allowSlideSelect = true
    
    /// When slide select is active, will auto scroll to top or bottom when your finger at the top or bottom. Defaults to true.
    public var autoScrollWhenSlideSelectIsActive = true
    
    /// The max speed (pt/s) of auto scroll. Defaults to 600.
    public var autoScrollMaxSpeed: CGFloat = 600
    
    /// If true, you can drag select photo when preview selection style. Defaults to false.
    public var allowDragSelect = false
    
    /// Allow select full image. Defaults to true.
    public var allowSelectOriginal = true
    
    /// Always return the original photo.
    /// - warning: Only valid when `allowSelectOriginal = false`, Defaults to false.
    public var alwaysRequestOriginal = false
    
    /// Allow access to the preview large image interface (That is, whether to allow access to the large image interface after clicking the thumbnail image). Defaults to true.
    public var allowPreviewPhotos = true
    
    /// Whether to show the preview button (i.e. the preview button in the lower left corner of the thumbnail interface). Defaults to true.
    public var showPreviewButtonInAlbum = true
    
    /// Whether to display the selected count on the button. Defaults to true.
    public var showSelectCountOnDoneBtn = true
    
    /// Maximum cropping time when editing video, unit: second. Defaults to 10.
    public var maxEditVideoTime: Second = 10
    
    /// Allow to choose the maximum duration of the video. Defaults to 120.
    public var maxSelectVideoDuration: Second = 120
    
    /// Allow to choose the minimum duration of the video. Defaults to 0.
    public var minSelectVideoDuration: Second = 0
    
    /// Image editor configuration.
    public var editImageConfiguration = ZLEditImageConfiguration()
    
    /// Show the image captured by the camera is displayed on the camera button inside the album. Defaults to false.
    public var showCaptureImageOnTakePhotoBtn = false
    
    /// In single selection mode, whether to display the selection button. Defaults to false.
    public var showSelectBtnWhenSingleSelect = false
    
    /// Overlay a mask layer on top of the selected photos. Defaults to true.
    public var showSelectedMask = true
    
    /// Display a border on the selected photos cell. Defaults to false.
    public var showSelectedBorder = false
    
    /// Overlay a mask layer above the cells that cannot be selected. Defaults to true.
    public var showInvalidMask = true
    
    /// Display the index of the selected photos. Defaults to true.
    public var showSelectedIndex = true
    
    /// Display the selected photos at the bottom of the preview large photos interface. Defaults to true.
    public var showSelectedPhotoPreview = true
    
    /// Timeout for image parsing. Defaults to 20.
    public var timeout: TimeInterval = 20
    
    /// Whether to use custom camera. Defaults to true.
    public var useCustomCamera = true
    
    /// The configuration for camera.
    public var cameraConfiguration = ZLCameraConfiguration()
    
    /// This block will be called before selecting an image, the developer can first determine whether the asset is allowed to be selected.
    /// Only control whether it is allowed to be selected, and will not affect the selection logic in the framework.
    /// - Tips: If the choice is not allowed, the developer can toast prompt the user for relevant information.
    public var canSelectAsset: ((PHAsset) -> Bool)?
    
    /// If user choose limited Photo mode, a button with '+' will be added to the ZLThumbnailViewController. It will call PHPhotoLibrary.shared().presentLimitedLibraryPicker(from:) to add photo. Defaults to true.
    /// E.g., Sina Weibo's ImagePicker
    public var showAddPhotoButton = true
    
    /// iOS14 limited Photo mode, will show collection footer view in ZLThumbnailViewController.
    /// Will go to system setting if clicked. Defaults to true.
    public var showEnterSettingTips = true
    
    /// The maximum number of frames for GIF images. To avoid crashes due to memory spikes caused by loading GIF images with too many frames, it is recommended that this value is not too large. Defaults to 50.
    public var maxFrameCountForGIF = 50
    
    /// You can use this block to customize the playback of GIF images to achieve better results. For example, use FLAnimatedImage to play GIFs. Defaults to nil.
    public var gifPlayBlock: ((UIImageView, Data, [AnyHashable: Any]?) -> Void)?
    
    /// Pause GIF image playback, used together with gifPlayBlock. Defaults to nil.
    public var pauseGIFBlock: ((UIImageView) -> Void)?
    
    /// Resume GIF image playback, used together with gifPlayBlock. Defaults to nil.
    public var resumeGIFBlock: ((UIImageView) -> Void)?
    
    /// Callback after the no authority alert dismiss.
    public var noAuthorityCallback: ((ZLNoAuthorityType) -> Void)?
    
    /// Allow user to do something before select photo result callback.
    /// And you must call the second parameter of this block to continue the photos selection.
    /// The first parameter is the current controller.
    /// The second parameter is the block that needs to be called after the user completes the operation.
    public var operateBeforeDoneAction: ((UIViewController, @escaping () -> Void) -> Void)?
}

@objc public enum ZLNoAuthorityType: Int {
    case library
    case camera
    case microphone
}
