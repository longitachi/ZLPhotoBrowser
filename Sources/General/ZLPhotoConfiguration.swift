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

    @objc public enum CancelButtonStyle: Int {
        case text
        case image
    }
    
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
    
    /// text: Cancel.  image: 'x'. Default to text.
    @objc public var navCancelButtonStyle: ZLPhotoConfiguration.CancelButtonStyle = .image
    
    /// Photo sorting method, the preview interface is not affected by this parameter. Defaults to true.
    @objc public var sortAscending = true
    
    private var pri_maxSelectCount = 9
    /// Anything superior than 1 will enable the multiple selection feature. Defaults to 9.
    @objc public var maxSelectCount: Int {
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
    @objc public var maxVideoSelectCount: Int {
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
    @objc public var minVideoSelectCount: Int {
        get {
            return min(maxSelectCount, max(pri_minVideoSelectCount, 0))
        }
        set {
            pri_minVideoSelectCount = newValue
        }
    }
    
    /// Whether photos and videos can be selected together. Defaults to true.
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
        get {
            return pri_allowTakePhotoInLibrary && (allowTakePhoto || allowRecordVideo)
        }
        set {
            pri_allowTakePhotoInLibrary = newValue
        }
    }
    
    var pri_allowEditImage = true
    @objc public var allowEditImage: Bool {
        get {
            return pri_allowEditImage && shouldAnialysisAsset
        }
        set {
            pri_allowEditImage = newValue
        }
    }
    
    /// - warning: The video can only be edited when no photos are selected, or only one video is selected, and the selection callback is executed immediately after editing is completed.
    var pri_allowEditVideo = false
    @objc public var allowEditVideo: Bool {
        get {
            return pri_allowEditVideo && shouldAnialysisAsset
        }
        set {
            pri_allowEditVideo = newValue
        }
    }
    
    /// Control whether to display the selection button animation when selecting. Defaults to true.
    @objc public var animateSelectBtnWhenSelect = true
    
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
        get {
            return pri_columnCount
        }
        set {
            pri_columnCount = min(6, max(newValue, 2))
        }
    }
    
    /// Maximum cropping time when editing video, unit: second. Defaults to 10.
    @objc public var maxEditVideoTime: Second = 10
    
    /// Allow to choose the maximum duration of the video. Defaults to 120.
    @objc public var maxSelectVideoDuration: Second = 120
    
    /// Allow to choose the minimum duration of the video. Defaults to 0.
    @objc public var minSelectVideoDuration: Second = 0
    
    /// Image editor configuration.
    @objc public var editImageConfiguration = ZLEditImageConfiguration()
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    public var editImageTools: [ZLEditImageConfiguration.EditTool] {
        get {
            return editImageConfiguration.tools
        }
        set {
            editImageConfiguration.tools = newValue
        }
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @objc public var editImageDrawColors: [UIColor] {
        get {
            return editImageConfiguration.drawColors
        }
        set {
            editImageConfiguration.drawColors = newValue
        }
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @objc public var editImageDefaultDrawColor: UIColor {
        get {
            return editImageConfiguration.defaultDrawColor
        }
        set {
            editImageConfiguration.defaultDrawColor = newValue
        }
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @objc public var editImageClipRatios: [ZLImageClipRatio] {
        get {
            return editImageConfiguration.clipRatios
        }
        set {
            editImageConfiguration.clipRatios = newValue
        }
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @objc public var textStickerTextColors: [UIColor] {
        get {
            return editImageConfiguration.textStickerTextColors
        }
        set {
            editImageConfiguration.textStickerTextColors = newValue
        }
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @objc public var textStickerDefaultTextColor: UIColor {
        get {
            return editImageConfiguration.textStickerDefaultTextColor
        }
        set {
            editImageConfiguration.textStickerDefaultTextColor = newValue
        }
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @objc public var filters: [ZLFilter] {
        get {
            return editImageConfiguration.filters
        }
        set {
            editImageConfiguration.filters = newValue
        }
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
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
            ZLCustomImageDeploy.imageNames = customImageNames
        }
    }
    
    /// Developers can customize images, but the name of the custom image resource must be consistent with the image name in the replaced bundle.
    /// - example: Developers need to replace the selected and unselected image resources, and the array that needs to be passed in is
    /// ["zl_btn_selected": selectedImage, "zl_btn_unselected": unselectedImage].
    public var customImageForKey: [String: UIImage?] = [:] {
        didSet {
            customImageForKey.forEach { ZLCustomImageDeploy.imageForKey[$0.key] = $0.value }
        }
    }
    
    /// Developers can customize images, but the name of the custom image resource must be consistent with the image name in the replaced bundle.
    /// - example: Developers need to replace the selected and unselected image resources, and the array that needs to be passed in is
    /// ["zl_btn_selected": selectedImage, "zl_btn_unselected": unselectedImage].
    @objc public var customImageForKey_objc: [String: UIImage] = [:] {
        didSet {
            ZLCustomImageDeploy.imageForKey = customImageForKey_objc
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
        get {
            return pri_allowTakePhoto && allowSelectImage
        }
        set {
            pri_allowTakePhoto = newValue
        }
    }
    
    private var pri_allowRecordVideo = true
    /// Allow recording in the camera (Need allowSelectVideo to be true). Defaults to true.
    @objc public var allowRecordVideo: Bool {
        get {
            return pri_allowRecordVideo && allowSelectVideo
        }
        set {
            pri_allowRecordVideo = newValue
        }
    }
    
    private var pri_minRecordDuration: Second = 0
    /// Minimum recording duration. Defaults to 0.
    @objc public var minRecordDuration: Second {
        get {
            return pri_minRecordDuration
        }
        set {
            pri_minRecordDuration = max(0, newValue)
        }
    }
    
    private var pri_maxRecordDuration: Second = 10
    /// Maximum recording duration. Defaults to 10, minimum is 1.
    @objc public var maxRecordDuration: Second {
        get {
            return pri_maxRecordDuration
        }
        set {
            pri_maxRecordDuration = max(1, newValue)
        }
    }
    
    /// The configuration for camera.
    @objc public var cameraConfiguration = ZLCameraConfiguration()
    
    /// Hud style. Defaults to lightBlur.
    @objc public var hudStyle: ZLProgressHUD.HUDStyle = .lightBlur
    
    /// The blur effect of the navigation bar in the album list
    @objc public var navViewBlurEffectOfAlbumList: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the navigation bar in the preview interface
    @objc public var navViewBlurEffectOfPreview: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the bottom tool bar in the album list
    @objc public var bottomViewBlurEffectOfAlbumList: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the bottom tool bar in the preview interface
    @objc public var bottomViewBlurEffectOfPreview: UIBlurEffect? = UIBlurEffect(style: .dark)
    
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

/// Color deploy
public class ZLPhotoThemeColorDeploy: NSObject {
    
    @objc public class func `default`() -> ZLPhotoThemeColorDeploy {
        return ZLPhotoThemeColorDeploy()
    }
    
    /// Preview selection mode, transparent background color above.
    /// 预览快速选择模式下，上方透明区域背景色
    @objc public var previewBgColor = UIColor.black.withAlphaComponent(0.1)
    
    /// Preview selection mode, a background color for `Camera`, `Album`, `Cancel` buttons.
    /// 预览快速选择模式下，按钮背景颜色
    @objc public var previewBtnBgColor = UIColor.white
    
    /// Preview selection mode, a text color for `Camera`, `Album`, `Cancel` buttons.
    /// 预览快速选择模式下，按钮标题颜色
    @objc public var previewBtnTitleColor = UIColor.black
    
    /// Preview selection mode, cancel button title color when the selection amount is superior than 0.
    /// 预览快速选择模式下，按钮标题高亮颜色
    @objc public var previewBtnHighlightTitleColor = zlRGB(80, 169, 56)
    
    /// A color for navigation bar.
    /// 相册列表及小图界面导航条背景色
    @objc public var navBarColor = zlRGB(160, 160, 160).withAlphaComponent(0.65)
    
    /// A color for navigation bar in preview interface.
    /// 预览大图界面的导航条背景色
    @objc public var navBarColorOfPreviewVC = zlRGB(160, 160, 160).withAlphaComponent(0.65)
    
    /// A color for Navigation bar text.
    /// 相册列表及小图界面导航栏标题颜色
    @objc public var navTitleColor = UIColor.white
    
    /// A color for Navigation bar text of preview vc.
    /// 预览大图界面导航栏标题颜色
    @objc public var navTitleColorOfPreviewVC = UIColor.white
    
    /// The background color of the title view when the frame style is embedAlbumList.
    /// 下拉选择相册列表模式下，选择区域的背景色
    @objc public var navEmbedTitleViewBgColor = zlRGB(80, 80, 80)
    
    /// A color for background in album list.
    /// 相册列表背景色
    @objc public var albumListBgColor = zlRGB(45, 45, 45)
    
    /// A color for album list title label.
    /// 相册列表标题颜色
    @objc public var albumListTitleColor = UIColor.white
    
    /// A color for album list count label.
    /// 相册列表数量label的颜色
    @objc public var albumListCountColor = zlRGB(180, 180, 180)
    
    /// A color for album list separator.
    /// 相册列表分割线颜色
    @objc public var separatorColor = zlRGB(60, 60, 60)
    
    /// A color for background in thumbnail interface.
    /// 相册小图界面背景色
    @objc public var thumbnailBgColor = zlRGB(50, 50, 50)
    
    /// A color for background in bottom tool view.
    /// 相册小图界面底部工具条背景色
    @objc public var bottomToolViewBgColor = zlRGB(35, 35, 35).withAlphaComponent(0.3)
    
    /// A color for background in bottom tool view in preview interface.
    /// 预览大图界面底部工具条背景色
    @objc public var bottomToolViewBgColorOfPreviewVC = zlRGB(35, 35, 35).withAlphaComponent(0.3)
    
    /// The normal state title color of bottom tool view buttons. Without done button.
    /// 相册小图界面底部按钮可交互状态下标题颜色，不包括 `完成` 按钮
    @objc public var bottomToolViewBtnNormalTitleColor = UIColor.white
    
    /// The normal state title color of bottom tool view done button.
    /// 相册小图界面底部 `完成` 按钮可交互状态下标题颜色
    @objc public var bottomToolViewDoneBtnNormalTitleColor = UIColor.white
    
    /// The normal state title color of bottom tool view buttons in preview interface.  Without done button.
    /// 预览大图界面底部按钮可交互状态下标题颜色，不包括 `完成` 按钮
    @objc public var bottomToolViewBtnNormalTitleColorOfPreviewVC = UIColor.white
    
    /// The normal state title color of bottom tool view done button.
    /// 预览大图界面底部 `完成` 按钮可交互状态下标题颜色
    @objc public var bottomToolViewDoneBtnNormalTitleColorOfPreviewVC = UIColor.white
    
    /// The disable state title color of bottom tool view buttons.  Without done button.
    /// 相册小图界面底部按钮不可交互状态下标题颜色，不包括 `完成` 按钮
    @objc public var bottomToolViewBtnDisableTitleColor = zlRGB(168, 168, 168)
    
    /// The disable state title color of bottom tool view done button.
    /// 相册小图界面底部 `完成` 按钮不可交互状态下标题颜色
    @objc public var bottomToolViewDoneBtnDisableTitleColor = zlRGB(168, 168, 168)
    
    /// The disable state title color of bottom tool view buttons in preview interface.  Without done button.
    /// 预览大图界面底部按钮不可交互状态下标题颜色，不包括 `完成` 按钮
    @objc public var bottomToolViewBtnDisableTitleColorOfPreviewVC = zlRGB(168, 168, 168)
    
    /// The disable state title color of bottom tool view done button  in preview interface.
    /// 预览大图界面底部 `完成` 按钮不可交互状态下标题颜色
    @objc public var bottomToolViewDoneBtnDisableTitleColorOfPreviewVC = zlRGB(168, 168, 168)
    
    /// The normal state background color of bottom tool view buttons.
    /// 相册小图界面底部按钮可交互状态下背景色
    @objc public var bottomToolViewBtnNormalBgColor = zlRGB(80, 169, 56)
    
    /// The normal state background color of bottom tool view buttons in preview interface.
    /// 预览大图界面底部按钮可交互状态下背景色
    @objc public var bottomToolViewBtnNormalBgColorOfPreviewVC = zlRGB(80, 169, 56)
    
    /// The disable state background color of bottom tool view buttons.
    /// 相册小图界面底部按钮不可交互状态下背景色
    @objc public var bottomToolViewBtnDisableBgColor = zlRGB(50, 50, 50)
    
    /// The disable state background color of bottom tool view buttons in preview interface.
    /// 预览大图界面底部按钮不可交互状态下背景色
    @objc public var bottomToolViewBtnDisableBgColorOfPreviewVC = zlRGB(50, 50, 50)
    
    /// With iOS14 limited authority, a color for select more photos at the bottom of the thumbnail interface.
    /// iOS14 limited权限下，下方提示选择更多图片信息文字的颜色
    @objc public var selectMorePhotoWhenAuthIsLismitedTitleColor = UIColor.white
    
    /// The record progress color of custom camera.
    /// 自定义相机录制视频时进度条颜色
    @objc public var cameraRecodeProgressColor = zlRGB(80, 169, 56)
    
    /// Mask layer color of selected cell.
    /// 已选择照片上方遮罩阴影颜色
    @objc public var selectedMaskColor = UIColor.black.withAlphaComponent(0.2)
    
    /// Border color of selected cell.
    /// 已选择照片border颜色
    @objc public var selectedBorderColor = zlRGB(80, 169, 56)
    
    /// Mask layer color of the cell that cannot be selected.
    /// 不可选的照片上方遮罩阴影颜色
    @objc public var invalidMaskColor = UIColor.white.withAlphaComponent(0.5)
    
    /// The background color of selected cell index label.
    /// 已选照片右上角序号label背景色
    @objc public var indexLabelBgColor = zlRGB(80, 169, 56)
    
    /// The background color of camera cell inside album.
    /// 相册小图界面拍照按钮背景色
    @objc public var cameraCellBgColor = UIColor(white: 0.3, alpha: 1)
    
    /// The normal color of adjust slider.
    /// 编辑图片，调整饱和度、对比度、亮度时，右侧slider背景色
    @objc public var adjustSliderNormalColor = UIColor.white
    
    /// The tint color of adjust slider.
    /// 编辑图片，调整饱和度、对比度、亮度时，右侧slider背景高亮色
    @objc public var adjustSliderTintColor = zlRGB(80, 169, 56)
    
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
    
    static var imageNames: [String] = []
    
    static var imageForKey: [String: UIImage] = [:]
    
}
