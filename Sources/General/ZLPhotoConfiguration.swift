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

public class ZLPhotoConfiguration: NSObject {

    private static var single = ZLPhotoConfiguration()
    
    @objc public class func `default`() -> ZLPhotoConfiguration {
        return ZLPhotoConfiguration.single
    }
    
    @objc public class func resetConfiguration() {
        ZLPhotoConfiguration.single = ZLPhotoConfiguration()
    }
    
    /// Framework style.
    @objc public var style: ZLPhotoBrowserStyle = .embedAlbumList
    
    @objc public var statusBarStyle: UIStatusBarStyle = .lightContent
    
    /// Photo sorting method, the preview interface is not affected by this parameter. Defaults to true.
    @objc public var sortAscending = true
    
    private var pri_maxSelectCount = 9
    /// Anything superior than 1 will enable the multiple selection feature. Defaults to 9.
    @objc public var maxSelectCount: Int {
        set {
            pri_maxSelectCount = max(1, newValue)
        }
        get {
            return pri_maxSelectCount
        }
    }
    
    private var pri_maxVideoSelectCount = 0
    /// A count for video max selection. Defaults to 0.
    /// - warning: Only valid in mix selection mode. (i.e. allowMixSelect = true)
    @objc public var maxVideoSelectCount: Int {
        set {
            pri_maxVideoSelectCount = newValue
        }
        get {
            if pri_maxVideoSelectCount <= 0 {
                return maxSelectCount
            } else {
                return max(minVideoSelectCount, min(pri_maxVideoSelectCount, maxSelectCount))
            }
        }
    }
    
    private var pri_minVideoSelectCount = 0
    /// A count for video min selection. Defaults to 0.
    /// - warning: Only valid in mix selection mode. (i.e. allowMixSelect = true)
    @objc public var minVideoSelectCount: Int {
        set {
            pri_minVideoSelectCount = newValue
        }
        get {
            return min(maxSelectCount, max(pri_minVideoSelectCount, 0))
        }
    }
    
    /// Whether photos and videos can be selected together. Default is true.
    /// If set to false, only one video can be selected. Defaults to true.
    @objc public var allowMixSelect = true
    
    /// Preview selection max preview count, if the value is zero, only show `Camera`, `Album`, `Cancel` buttons. Defaults to 20.
    @objc public var maxPreviewCount = 20
    
    @objc public var cellCornerRadio: CGFloat = 0
    
    /// If set to false, gif and livephoto cannot be selected either. Defaults to true.
    @objc public var allowSelectImage = true
    
    @objc public var allowSelectVideo = true
    
    /// Allow select Gif, it only controls whether it is displayed in Gif form.
    /// If value is false, the Gif logo is not displayed. Defaults to true.
    @objc public var allowSelectGif = true
    
    /// Allow select LivePhoto, it only controls whether it is displayed in LivePhoto form.
    /// If value is false, the LivePhoto logo is not displayed. Defaults to false.
    @objc public var allowSelectLivePhoto = false
    
    private var pri_allowTakePhotoInLibrary = true
    /// Allow take photos in the album. Defaults to true.
    /// - warning: If allowTakePhoto and allowRecordVideo are both false, it will not be displayed.
    @objc public var allowTakePhotoInLibrary: Bool {
        set {
            pri_allowTakePhotoInLibrary = newValue
        }
        get {
            return pri_allowTakePhotoInLibrary && (allowTakePhoto || allowRecordVideo)
        }
    }
    
    @objc public var allowEditImage = true
    
    /// - warning: The video can only be edited when no photos are selected, or only one video is selected, and the selection callback is executed immediately after editing is completed.
    @objc public var allowEditVideo = false
    
    /// Animation duration for select button
    @objc public var selectBtnAnimationDuration: CFTimeInterval = 0.4
    
    /// After selecting a image/video in the thumbnail interface, enter the editing interface directly. Defaults to false.
    /// - discussion: Editing image is only valid when allowEditImage is true and maxSelectCount is 1.
    /// Editing video is only valid when allowEditVideo is true and maxSelectCount is 1.
    @objc public var editAfterSelectThumbnailImage = false
    
    /// Only valid when allowMixSelect is false and allowEditVideo is true. Defaults to true.
    /// Just like the Wechat-Timeline selection style. If you want to crop the video after select thumbnail under allowMixSelect = true, please use **editAfterSelectThumbnailImage**.
    @objc public var cropVideoAfterSelectThumbnail = true
    
    /// If image edit tools only has clip and this property is true. When you click edit, the cropping interface (i.e. ZLClipImageViewController) will be displayed. Defaults to false.
    @objc public var showClipDirectlyIfOnlyHasClipTool = false
    
    /// Save the edited image to the album after editing. Defaults to true.
    @objc public var saveNewImageAfterEdit = true
    
    /// If true, you can slide select photos in album. Defaults to true.
    @objc public var allowSlideSelect = true
    
    /// When slide select is active, will auto scroll to top or bottom when your finger at the top or bottom. Defaults to true.
    @objc public var autoScrollWhenSlideSelectIsActive = true
    
    /// The max speed (pt/s) of auto scroll. Defaults to 600.
    @objc public var autoScrollMaxSpeed: CGFloat = 600
    
    /// If true, you can drag select photo when preview selection style. Defaults to false.
    @objc public var allowDragSelect = false
    
    /// Allow select full image. Defaults to true.
    @objc public var allowSelectOriginal = true
    
    /// Allow access to the preview large image interface (That is, whether to allow access to the large image interface after clicking the thumbnail image). Defaults to true.
    @objc public var allowPreviewPhotos = true
    
    /// Whether to show the status bar when previewing photos. Defaults to false.
    @objc public var showStatusBarInPreviewInterface = false
    
    /// Whether to show the preview button (i.e. the preview button in the lower left corner of the thumbnail interface). Defaults to true.
    @objc public var showPreviewButtonInAlbum = true
    
    private var pri_columnCount: Int = 4
    /// The column count when iPhone is in portait mode. Minimum is 2, maximum is 6. Defaults to 4.
    /// ```
    /// iPhone landscape mode: columnCount += 2.
    /// iPad portait mode: columnCount += 2.
    /// iPad landscape mode: columnCount += 4.
    /// ```
    @objc public var columnCount: Int {
        set {
            pri_columnCount = min(6, max(newValue, 2))
        }
        get {
            return pri_columnCount
        }
    }
    
    /// Maximum cropping time when editing video, unit: second. Defaults to 10.
    @objc public var maxEditVideoTime: Second = 10
    
    /// Allow to choose the maximum duration of the video. Defaults to 120.
    @objc public var maxSelectVideoDuration: Second = 120
    
    /// Allow to choose the minimum duration of the video. Defaults to 0.
    @objc public var minSelectVideoDuration: Second = 0
    
    private var pri_editImageTools: [ZLEditImageViewController.EditImageTool] = [.draw, .clip, .imageSticker, .textSticker, .mosaic, .filter]
    /// Edit image tools. (Default order is draw, clip, imageSticker, textSticker, mosaic, filtter)
    /// Because Objective-C Array can't contain Enum styles, so this property is invalid in Objective-C.
    /// - warning: If you want to use the image sticker feature, you must provide a view that implements ZLImageStickerContainerDelegate.
    public var editImageTools: [ZLEditImageViewController.EditImageTool] {
        set {
            pri_editImageTools = newValue
        }
        get {
            if pri_editImageTools.isEmpty {
                return [.draw, .clip, .imageSticker, .textSticker, .mosaic, .filter]
            } else {
                return pri_editImageTools
            }
        }
    }
    
    private var pri_editImageDrawColors: [UIColor] = [.white, .black, zlRGB(241, 79, 79), zlRGB(243, 170, 78), zlRGB(80, 169, 56), zlRGB(30, 183, 243), zlRGB(139, 105, 234)]
    /// Draw colors for image editor.
    @objc public var editImageDrawColors: [UIColor] {
        set {
            pri_editImageDrawColors = newValue
        }
        get {
            if pri_editImageDrawColors.isEmpty {
                return [.white, .black, zlRGB(241, 79, 79), zlRGB(243, 170, 78), zlRGB(80, 169, 56), zlRGB(30, 183, 243), zlRGB(139, 105, 234)]
            } else {
                return pri_editImageDrawColors
            }
        }
    }
    
    /// The default draw color. If this color not in editImageDrawColors, will pick the first color in editImageDrawColors as the default.
    @objc public var editImageDefaultDrawColor = zlRGB(241, 79, 79)
    
    private var pri_editImageClipRatios: [ZLImageClipRatio] = [.custom]
    /// Edit ratios for image editor.
    @objc public var editImageClipRatios: [ZLImageClipRatio] {
        set {
            pri_editImageClipRatios = newValue
        }
        get {
            if pri_editImageClipRatios.isEmpty {
                return [.custom]
            } else {
                return pri_editImageClipRatios
            }
        }
    }
    
    private var pri_textStickerTextColors: [UIColor] = [.white, .black, zlRGB(241, 79, 79), zlRGB(243, 170, 78), zlRGB(80, 169, 56), zlRGB(30, 183, 243), zlRGB(139, 105, 234)]
    /// Text sticker colors for image editor.
    @objc public var textStickerTextColors: [UIColor] {
        set {
            pri_textStickerTextColors = newValue
        }
        get {
            if pri_textStickerTextColors.isEmpty {
                return [.white, .black, zlRGB(241, 79, 79), zlRGB(243, 170, 78), zlRGB(80, 169, 56), zlRGB(30, 183, 243), zlRGB(139, 105, 234)]
            } else {
                return pri_textStickerTextColors
            }
        }
    }
    
    /// The default text sticker color. If this color not in textStickerTextColors, will pick the first color in textStickerTextColors as the default.
    @objc public var textStickerDefaultTextColor = UIColor.white
    
    private var pri_filters: [ZLFilter] = ZLFilter.all
    /// Filters for image editor.
    @objc public var filters: [ZLFilter] {
        set {
            pri_filters = newValue
        }
        get {
            if pri_filters.isEmpty {
                return ZLFilter.all
            } else {
                return pri_filters
            }
        }
    }
    
    @objc public var imageStickerContainerView: (UIView & ZLImageStickerContainerDelegate)? = nil
    
    /// Show the image captured by the camera is displayed on the camera button inside the album. Defaults to false.
    @objc public var showCaptureImageOnTakePhotoBtn = false
    
    /// In single selection mode, whether to display the selection button. Defaults to false.
    @objc public var showSelectBtnWhenSingleSelect = false
    
    /// Overlay a mask layer on top of the selected photos. Defaults to true.
    @objc public var showSelectedMask = true
    
    /// Display a border on the selected photos cell. Defaults to false.
    @objc public var showSelectedBorder = false
    
    /// Overlay a mask layer above the cells that cannot be selected. Defaults to true.
    @objc public var showInvalidMask = true
    
    /// Display the index of the selected photos. Defaults to true.
    @objc public var showSelectedIndex = true
    
    /// Display the selected photos at the bottom of the preview large photos interface. Defaults to true.
    @objc public var showSelectedPhotoPreview = true
    
    /// Developers can customize images, but the name of the custom image resource must be consistent with the image name in the replaced bundle.
    /// - example: Developers need to replace the selected and unselected image resources, and the array that needs to be passed in is
    /// ["zl_btn_selected", "zl_btn_unselected"].
    @objc public var customImageNames: [String] = [] {
        didSet {
            ZLCustomImageDeploy.deploy = self.customImageNames
        }
    }
    
    /// Allow framework fetch photos when callback. Defaults to true.
    @objc public var shouldAnialysisAsset = true
    
    /// Timeout for image parsing. Defaults to 20.
    @objc public var timeout: TimeInterval = 20
    
    /// Language for framework.
    @objc public var languageType: ZLLanguageType = .system {
        didSet {
            ZLCustomLanguageDeploy.language = self.languageType
            Bundle.resetLanguage()
        }
    }
    
    /// Developers can customize languages (This property is only for objc).
    /// - example: If you needs to replace
    /// key: @"loading", value: @"loading, waiting please" language,
    /// The dictionary that needs to be passed in is @[@"loading": @"text to be replaced"].
    /// - warning: Please pay attention to the placeholders contained in languages when changing, such as %ld, %@.
    @objc public var customLanguageKeyValue_objc: [String: String] = [:] {
        didSet {
            var swiftParams: [ZLLocalLanguageKey: String] = [:]
            customLanguageKeyValue_objc.forEach { (key, value) in
                swiftParams[ZLLocalLanguageKey(rawValue: key)] = value
            }
            self.customLanguageKeyValue = swiftParams
        }
    }
    
    /// Developers can customize languages.
    /// - example: If you needs to replace
    /// key: .loading, value: "loading, waiting please" language,
    /// The dictionary that needs to be passed in is [.loading: "text to be replaced"].
    /// - warning: Please pay attention to the placeholders contained in languages when changing, such as %ld, %@.
    public var customLanguageKeyValue: [ZLLocalLanguageKey: String] = [:] {
        didSet {
            ZLCustomLanguageDeploy.deploy = self.customLanguageKeyValue
        }
    }
    
    /// Whether to use custom camera. Defaults to true.
    @objc public var useCustomCamera = true
    
    private var pri_allowTakePhoto = true
    /// Allow taking photos in the camera (Need allowSelectImage to be true). Defaults to true.
    @objc public var allowTakePhoto: Bool {
        set {
            pri_allowTakePhoto = newValue
        }
        get {
            return pri_allowTakePhoto && allowSelectImage
        }
    }
    
    private var pri_allowRecordVideo = true
    /// Allow recording in the camera (Need allowSelectVideo to be true). Defaults to true.
    @objc public var allowRecordVideo: Bool {
        set {
            pri_allowRecordVideo = newValue
        }
        get {
            return pri_allowRecordVideo && allowSelectVideo
        }
    }
    
    private var pri_minRecordDuration: Second = 0
    /// Minimum recording duration. Defaults to 0.
    @objc public var minRecordDuration: Second {
        set {
            pri_minRecordDuration = max(0, newValue)
        }
        get {
            return pri_minRecordDuration
        }
    }
    
    private var pri_maxRecordDuration: Second = 10
    /// Maximum recording duration. Defaults to 10, minimum is 1.
    @objc public var maxRecordDuration: Second {
        set {
            pri_maxRecordDuration = max(1, newValue)
        }
        get {
            return pri_maxRecordDuration
        }
    }
    
    /// The configuration for camera.
    @objc public var cameraConfiguration = ZLCameraConfiguration()
    
    /// Hud style. Defaults to lightBlur.
    @objc public var hudStyle: ZLProgressHUD.HUDStyle = .lightBlur
    
    /// Navigation bar blur effect.
    @objc public var navViewBlurEffect: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// Bottom too bar blur effect.
    @objc public var bottomToolViewBlurEffect: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// Color configuration for framework.
    @objc public var themeColorDeploy: ZLPhotoThemeColorDeploy = .default()
    
    /// Font name.
    @objc public var themeFontName: String? = nil {
        didSet {
            ZLCustomFontDeploy.fontName = self.themeFontName
        }
    }
    
    /// This block will be called before selecting an image, the developer can first determine whether the asset is allowed to be selected.
    /// Only control whether it is allowed to be selected, and will not affect the selection logic in the framework.
    /// - Tips: If the choice is not allowed, the developer can toast prompt the user for relevant information.
    @objc public var canSelectAsset: ( (PHAsset) -> Bool )?
    
    /// If user choose limited Photo mode, a button with '+' will be added to the ZLThumbnailViewController. It will call PHPhotoLibrary.shared().presentLimitedLibraryPicker(from:) to add photo. Defaults to true.
    /// E.g., Sina Weibo's ImagePicker
    @objc public var showAddPhotoButton: Bool = true
    
    /// iOS14 limited Photo mode, will show collection footer view in ZLThumbnailViewController.
    /// Will go to system setting if clicked. Defaults to true.
    @objc public var showEnterSettingTips = true
    
    /// Callback after the no authority alert dismiss.
    @objc public var noAuthorityCallback: ( (ZLNoAuthorityType) -> Void )?
    
}


@objc public enum ZLNoAuthorityType: Int {
    case library
    case camera
    case microphone
}


@objc public enum ZLPhotoBrowserStyle: Int {
    
    /// The album list is embedded in the navigation of the thumbnail interface, click the drop-down display.
    case embedAlbumList
    
    /// The display relationship between the album list and the thumbnail interface is push.
    case externalAlbumList
    
}


public class ZLCameraConfiguration: NSObject {
    
    @objc public enum CaptureSessionPreset: Int {
        
        var avSessionPreset: AVCaptureSession.Preset {
            switch self {
            case .cif352x288:
                return .cif352x288
            case .vga640x480:
                return .vga640x480
            case .hd1280x720:
                return .hd1280x720
            case .hd1920x1080:
                return .hd1920x1080
            case .hd4K3840x2160:
                return .hd4K3840x2160
            }
        }
        
        case cif352x288
        case vga640x480
        case hd1280x720
        case hd1920x1080
        case hd4K3840x2160
    }
    
    @objc public enum FocusMode: Int  {
        
        var avFocusMode: AVCaptureDevice.FocusMode {
            switch self {
            case .autoFocus:
                return .autoFocus
            case .continuousAutoFocus:
                return .continuousAutoFocus
            }
        }
        
        case autoFocus
        case continuousAutoFocus
    }
    
    @objc public enum ExposureMode: Int  {
        
        var avFocusMode: AVCaptureDevice.ExposureMode {
            switch self {
            case .autoExpose:
                return .autoExpose
            case .continuousAutoExposure:
                return .continuousAutoExposure
            }
        }
        
        case autoExpose
        case continuousAutoExposure
    }
    
    @objc public enum FlashMode: Int  {
        
        var avFlashMode: AVCaptureDevice.FlashMode {
            switch self {
            case .auto:
                return .auto
            case .on:
                return .on
            case .off:
                return .off
            }
        }
        
        // 转系统相机
        var imagePickerFlashMode: UIImagePickerController.CameraFlashMode {
            switch self {
            case .auto:
                return .auto
            case .on:
                return .on
            case .off:
                return .off
            }
        }
        
        case auto
        case on
        case off
    }
    
    @objc public enum VideoExportType: Int {
        
        var format: String {
            switch self {
            case .mov:
                return "mov"
            case .mp4:
                return "mp4"
            }
        }
        
        var avFileType: AVFileType {
            switch self {
            case .mov:
                return .mov
            case .mp4:
                return .mp4
            }
        }
        
        case mov
        case mp4
    }
    
    /// Video resolution. Defaults to hd1280x720.
    @objc public var sessionPreset: ZLCameraConfiguration.CaptureSessionPreset
    /// Camera focus mode. Defaults to continuousAutoFocus
    @objc public var focusMode: ZLCameraConfiguration.FocusMode
    /// Camera exposure mode. Defaults to continuousAutoExposure
    @objc public var exposureMode: ZLCameraConfiguration.ExposureMode
    /// Camera flahs mode. Default is off. Defaults to off.
    @objc public var flashMode: ZLCameraConfiguration.FlashMode
    /// Video export format for recording video and editing video. Defaults to mov.
    @objc public var videoExportType: ZLCameraConfiguration.VideoExportType
    
    @objc public init(sessionPreset: ZLCameraConfiguration.CaptureSessionPreset = .hd1280x720,
         focusMode: ZLCameraConfiguration.FocusMode = .continuousAutoFocus,
         exposureMode: ZLCameraConfiguration.ExposureMode = .continuousAutoExposure,
         flashMode: ZLCameraConfiguration.FlashMode = .off,
         videoExportType: ZLCameraConfiguration.VideoExportType = .mov) {
        self.sessionPreset = sessionPreset
        self.focusMode = focusMode
        self.exposureMode = exposureMode
        self.flashMode = flashMode
        self.videoExportType = videoExportType
        super.init()
    }
}


/// Color deploy
public class ZLPhotoThemeColorDeploy: NSObject {
    
    @objc public class func `default`() -> ZLPhotoThemeColorDeploy {
        return ZLPhotoThemeColorDeploy()
    }
    
    /// Preview selection mode, transparent background color above.
    @objc public var previewBgColor = UIColor.black.withAlphaComponent(0.1)
    
    /// Preview selection mode, a background color for `Camera`, `Album`, `Cancel` buttons.
    @objc public var previewBtnBgColor = UIColor.white
    
    /// Preview selection mode, a text color for `Camera`, `Album`, `Cancel` buttons.
    @objc public var previewBtnTitleColor = UIColor.black
    
    /// Preview selection mode, cancel button title color when the selection amount is superior than 0.
    @objc public var previewBtnHighlightTitleColor = zlRGB(80, 169, 56)
    
    /// A color for navigation bar spinner.
    @objc public var navBarColor = zlRGB(160, 160, 160).withAlphaComponent(0.65)
    
    /// A color for Navigation bar text.
    @objc public var navTitleColor = UIColor.white
    
    /// The background color of the title view when the frame style is embedAlbumList.
    @objc public var navEmbedTitleViewBgColor = zlRGB(80, 80, 80)
    
    /// A color for background in album list.
    @objc public var albumListBgColor = zlRGB(45, 45, 45)
    
    /// A color for album list title label.
    @objc public var albumListTitleColor = UIColor.white
    
    /// A color for album list count label.
    @objc public var albumListCountColor = zlRGB(180, 180, 180)
    
    /// A color for album list separator.
    @objc public var separatorColor = zlRGB(60, 60, 60)
    
    /// A color for background in thumbnail interface.
    @objc public var thumbnailBgColor = zlRGB(50, 50, 50)
    
    /// A color for background in bottom tool view.
    @objc public var bottomToolViewBgColor = zlRGB(35, 35, 35).withAlphaComponent(0.3)
    
    /// The normal state title color of bottom tool view buttons.
    @objc public var bottomToolViewBtnNormalTitleColor = UIColor.white
    
    /// The disable state title color of bottom tool view buttons.
    @objc public var bottomToolViewBtnDisableTitleColor = zlRGB(168, 168, 168)
    
    /// The normal state background color of bottom tool view buttons.
    @objc public var bottomToolViewBtnNormalBgColor = zlRGB(80, 169, 56)
    
    /// The disable state background color of bottom tool view buttons.
    @objc public var bottomToolViewBtnDisableBgColor = zlRGB(50, 50, 50)
    
    /// With iOS14 limited authority, a color for select more photos at the bottom of the thumbnail interface.
    @objc public var selectMorePhotoWhenAuthIsLismitedTitleColor = UIColor.white
    
    /// The record progress color of custom camera.
    @objc public var cameraRecodeProgressColor = zlRGB(80, 169, 56)
    
    /// Mask layer color of selected cell.
    @objc public var selectedMaskColor = UIColor.black.withAlphaComponent(0.2)
    
    /// Border color of selected cell.
    @objc public var selectedBorderColor = zlRGB(80, 169, 56)
    
    /// Mask layer color of the cell that cannot be selected.
    @objc public var invalidMaskColor = UIColor.white.withAlphaComponent(0.5)
    
    /// The background color of selected cell index label.
    @objc public var indexLabelBgColor = zlRGB(80, 169, 56)
    
    /// The background color of camera cell inside album.
    @objc public var cameraCellBgColor = UIColor(white: 0.3, alpha: 1)
    
}


/// Font deply
public struct ZLCustomFontDeploy {
    
    static var fontName: String? = nil
    
}


/// Language deploy
struct ZLCustomLanguageDeploy {
    
    static var language: ZLLanguageType = .system
    
    static var deploy: [ZLLocalLanguageKey: String] = [:]
    
}


/// Image source deploy
struct ZLCustomImageDeploy {
    
    static var deploy: [String] = []
    
}


@objc public protocol ZLImageStickerContainerDelegate where Self: UIView {
    
    @objc var selectImageBlock: ( (UIImage) -> Void )? { get set }
    
    @objc var hideBlock: ( () -> Void )? { get set }
    
    @objc func show(in view: UIView)
    
}
