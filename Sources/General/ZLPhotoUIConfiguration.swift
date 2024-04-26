//
//  ZLPhotoUIConfiguration.swift
//  ZLPhotoBrowser
//
//  Created by long on 2022/4/18.
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

/// In an application, most of the UI configurations related to the album are uniform. Therefore, this class attempts to extract properties that are not affected by different album selection scenarios, avoiding redundant configurations for each different selection scenario.
/// Custom UI configuration (include colors, images, text, font)
@objcMembers
public class ZLPhotoUIConfiguration: NSObject {
    @objc public enum CancelButtonStyle: Int {
        case text
        case image
    }
    
    private static var single = ZLPhotoUIConfiguration()
    
    public class func `default`() -> ZLPhotoUIConfiguration {
        return ZLPhotoUIConfiguration.single
    }
    
    public class func resetConfiguration() {
        ZLPhotoUIConfiguration.single = ZLPhotoUIConfiguration()
    }
    
    // MARK: Framework style.
    
    /// Photo sorting method, the preview interface is not affected by this parameter. Defaults to true.
    public var sortAscending = true
    
    public var style: ZLPhotoBrowserStyle = .embedAlbumList
    
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    
    /// text: Cancel.  image: 'x'. Defaults to image.
    public var navCancelButtonStyle: ZLPhotoUIConfiguration.CancelButtonStyle = .image
    
    /// Whether to show the status bar when previewing photos. Defaults to false.
    public var showStatusBarInPreviewInterface = false
    
    /// HUD style. Defaults to dark.
    public var hudStyle: ZLProgressHUD.Style = .dark
    
    /// Adjust Slider Type
    public var adjustSliderType: ZLAdjustSliderType = .vertical
    
    public var cellCornerRadio: CGFloat = 0
    
    /// Custom alert class. Defaults to nil.
    public var customAlertClass: ZLCustomAlertProtocol.Type?
    
    private var pri_columnCount = 4
    /// The column count when iPhone is in portait mode. Minimum is 2, maximum is 6. Defaults to 4.
    /// ```
    /// iPhone landscape mode: columnCount += 2.
    /// iPad portait mode: columnCount += 2.
    /// iPad landscape mode: columnCount += 4.
    /// ```
    ///
    /// - Note: This property is ignored when using columnCountBlock.
    public var columnCount: Int {
        get {
            pri_columnCount
        }
        set {
            pri_columnCount = min(6, max(newValue, 2))
        }
    }
    
    /// Use this property to customize the column count for `ZLThumbnailViewController`.
    /// This property is recommended.
    public var columnCountBlock: ((_ collectionViewWidth: CGFloat) -> Int)?
    
    /// The minimum spacing to use between items in the same row for `ZLThumbnailViewController`.
    public var minimumInteritemSpacing: CGFloat = 2
    
    /// The minimum spacing to use between lines of items in the grid for `ZLThumbnailViewController`.
    public var minimumLineSpacing: CGFloat = 2
    
    /// In thumb image interface, control whether to display the selection button animation when selecting. Defaults to false.
    public var animateSelectBtnWhenSelectInThumbVC = false
    
    /// In preview interface, control whether to display the selection button animation when selecting. Defaults to true.
    public var animateSelectBtnWhenSelectInPreviewVC = true
    
    /// Animation duration for select button. Defaults to 0.5.
    public var selectBtnAnimationDuration: CFTimeInterval = 0.5
    
    /// Whether to display the serial number above the selected button. Defaults to false.
    public var showIndexOnSelectBtn = false
    
    /// Whether to display scroll to bottom button. Defaults to false.
    public var showScrollToBottomBtn = false
    
    /// Show the image captured by the camera is displayed on the camera button inside the album. Defaults to false.
    public var showCaptureImageOnTakePhotoBtn = false
    
    /// Overlay a mask layer on top of the selected photos. Defaults to true.
    public var showSelectedMask = true
    
    /// Display a border on the selected photos cell. Defaults to false.
    public var showSelectedBorder = false
    
    /// Overlay a mask layer above the cells that cannot be selected. Defaults to true.
    public var showInvalidMask = true
    
    /// Display the selected photos at the bottom of the preview large photos interface. Defaults to true.
    public var showSelectedPhotoPreview = true
    
    /// If user choose limited Photo mode, a button with '+' will be added to the ZLThumbnailViewController. It will call PHPhotoLibrary.shared().presentLimitedLibraryPicker(from:) to add photo. Defaults to true.
    public var showAddPhotoButton = true
    
    /// iOS14 limited Photo mode, will show collection footer view in ZLThumbnailViewController.
    /// Will go to system setting if clicked. Defaults to true.
    public var showEnterSettingTips = true

    /// Center tools in tools bar. Defaults to false.
    public var shouldCenterTools = false

    /// Timeout for image parsing. Defaults to 20.
    public var timeout: TimeInterval = 20
    
    // MARK: Navigation and bottom tool bar
    
    /// The blur effect of the navigation bar in the album list
    public var navViewBlurEffectOfAlbumList: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the navigation bar in the preview interface
    public var navViewBlurEffectOfPreview: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the bottom tool bar in the album list
    public var bottomViewBlurEffectOfAlbumList: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the bottom tool bar in the preview interface
    public var bottomViewBlurEffectOfPreview: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    // MARK: Image properties
    
    /// Developers can customize images, but the name of the custom image resource must be consistent with the image name in the replaced bundle.
    /// - example: Developers need to replace the selected and unselected image resources, and the array that needs to be passed in is
    /// ["zl_btn_selected", "zl_btn_unselected"].
    public var customImageNames: [String] = [] {
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
    public var customImageForKey_objc: [String: UIImage] = [:] {
        didSet {
            ZLCustomImageDeploy.imageForKey = customImageForKey_objc
        }
    }
    
    // MARK: Language properties
    
    /// Language for framework.
    public var languageType: ZLLanguageType = .system {
        didSet {
            ZLCustomLanguageDeploy.language = languageType
            Bundle.resetLanguage()
        }
    }
    
    /// Developers can customize languages.
    /// - example: If you needs to replace
    /// key: .hudLoading, value: "loading, waiting please" language,
    /// The dictionary that needs to be passed in is [.hudLoading: "text to be replaced"].
    /// - warning: Please pay attention to the placeholders contained in languages when changing, such as %ld, %@.
    public var customLanguageKeyValue: [ZLLocalLanguageKey: String] = [:] {
        didSet {
            ZLCustomLanguageDeploy.deploy = customLanguageKeyValue
        }
    }
    
    /// Developers can customize languages (This property is only for objc).
    /// - example: If you needs to replace
    /// key: @"loading", value: @"loading, waiting please" language,
    /// The dictionary that needs to be passed in is @[@"hudLoading": @"text to be replaced"].
    /// - warning: Please pay attention to the placeholders contained in languages when changing, such as %ld, %@.
    public var customLanguageKeyValue_objc: [String: String] = [:] {
        didSet {
            var swiftParams: [ZLLocalLanguageKey: String] = [:]
            customLanguageKeyValue_objc.forEach { key, value in
                swiftParams[ZLLocalLanguageKey(rawValue: key)] = value
            }
            customLanguageKeyValue = swiftParams
        }
    }
    
    // MARK: Font
    
    /// Font name.
    public var themeFontName: String? {
        didSet {
            ZLCustomFontDeploy.fontName = themeFontName
        }
    }
    
    // MARK: Color properties
    
    /// The theme color of framework.
    /// 框架主题色
    public var themeColor: UIColor = .zl.rgba(0, 193, 94)
    
    /// Preview selection mode, translucent background color above.
    /// 预览快速选择模式下，上方透明区域背景色
    public var sheetTranslucentColor: UIColor = .black.withAlphaComponent(0.1)
    
    /// Preview selection mode, a background color for `Camera`, `Album`, `Cancel` buttons.
    /// 预览快速选择模式下，按钮背景颜色
    public var sheetBtnBgColor: UIColor = .white
    
    /// Preview selection mode, a text color for `Camera`, `Album`, `Cancel` buttons.
    /// 预览快速选择模式下，按钮标题颜色
    public var sheetBtnTitleColor: UIColor = .black
    
    private var pri_sheetBtnTitleTintColor: UIColor?
    /// Preview selection mode, cancel button title color when the selection amount is superior than 0.
    /// 预览快速选择模式下，按钮标题高亮颜色
    public var sheetBtnTitleTintColor: UIColor {
        get {
            pri_sheetBtnTitleTintColor ?? themeColor
        }
        set {
            pri_sheetBtnTitleTintColor = newValue
        }
    }
    
    /// A color for navigation bar.
    /// 相册列表及小图界面导航条背景色
    public var navBarColor: UIColor = .zl.rgba(140, 140, 140, 0.75)
    
    /// A color for navigation bar in preview interface.
    /// 预览大图界面的导航条背景色
    public var navBarColorOfPreviewVC: UIColor = .zl.rgba(50, 50, 50)
    
    /// A color for Navigation bar text.
    /// 相册列表及小图界面导航栏标题颜色
    public var navTitleColor: UIColor = .white
    
    /// A color for Navigation bar text of preview vc.
    /// 预览大图界面导航栏标题颜色
    public var navTitleColorOfPreviewVC: UIColor = .white
    
    /// The background color of the title view when the frame style is embedAlbumList.
    /// 下拉选择相册列表模式下，选择区域的背景色
    public var navEmbedTitleViewBgColor: UIColor = .zl.rgba(80, 80, 80)
    
    /// A color for background in album list.
    /// 相册列表背景色
    public var albumListBgColor: UIColor = .zl.rgba(45, 45, 45)
    
    /// A color of the translucent area below the embed album list.
    /// 嵌入式相册列表下方透明区域颜色
    public var embedAlbumListTranslucentColor: UIColor = .black.withAlphaComponent(0.8)
    
    /// A color for album list title label.
    /// 相册列表标题颜色
    public var albumListTitleColor: UIColor = .white
    
    /// A color for album list count label.
    /// 相册列表数量label的颜色
    public var albumListCountColor: UIColor = .zl.rgba(180, 180, 180)
    
    /// A color for album list separator.
    /// 相册列表分割线颜色
    public var separatorColor: UIColor = .zl.rgba(60, 60, 60)
    
    /// A color for background in thumbnail interface.
    /// 相册小图界面背景色
    public var thumbnailBgColor: UIColor = .zl.rgba(25, 25, 25)
    
    /// A color for background in preview interface..
    /// 预览大图界面背景色
    public var previewVCBgColor: UIColor = .black
    
    /// A color for background in bottom tool view.
    /// 相册小图界面底部工具条背景色
    public var bottomToolViewBgColor: UIColor = .zl.rgba(35, 35, 35, 0.3)
    
    /// A color for background in bottom tool view in preview interface.
    /// 预览大图界面底部工具条背景色
    public var bottomToolViewBgColorOfPreviewVC: UIColor = .zl.rgba(35, 35, 35, 0.3)
    
    /// Title color of the original image size label in the album thumbnail interface.
    /// 相册小图界面原图大小label的text颜色
    public var originalSizeLabelTextColor: UIColor = .zl.rgba(130, 130, 130)
    
    /// Title color of the original image size label in the preview interface.
    /// 预览大图界面原图大小label的text颜色
    public var originalSizeLabelTextColorOfPreviewVC: UIColor = .zl.rgba(130, 130, 130)
    
    /// The normal state title color of bottom tool view buttons. Without done button.
    /// 相册小图界面底部按钮可交互状态下标题颜色，不包括 `完成` 按钮
    public var bottomToolViewBtnNormalTitleColor: UIColor = .white
    
    /// The normal state title color of bottom tool view done button.
    /// 相册小图界面底部 `完成` 按钮可交互状态下标题颜色
    public var bottomToolViewDoneBtnNormalTitleColor: UIColor = .white
    
    /// The normal state title color of bottom tool view buttons in preview interface.  Without done button.
    /// 预览大图界面底部按钮可交互状态下标题颜色，不包括 `完成` 按钮
    public var bottomToolViewBtnNormalTitleColorOfPreviewVC: UIColor = .white
    
    /// The normal state title color of bottom tool view done button.
    /// 预览大图界面底部 `完成` 按钮可交互状态下标题颜色
    public var bottomToolViewDoneBtnNormalTitleColorOfPreviewVC: UIColor = .white
    
    /// The disable state title color of bottom tool view buttons.  Without done button.
    /// 相册小图界面底部按钮不可交互状态下标题颜色，不包括 `完成` 按钮
    public var bottomToolViewBtnDisableTitleColor: UIColor = .zl.rgba(168, 168, 168)
    
    /// The disable state title color of bottom tool view done button.
    /// 相册小图界面底部 `完成` 按钮不可交互状态下标题颜色
    public var bottomToolViewDoneBtnDisableTitleColor: UIColor = .zl.rgba(168, 168, 168)
    
    /// The disable state title color of bottom tool view buttons in preview interface.  Without done button.
    /// 预览大图界面底部按钮不可交互状态下标题颜色，不包括 `完成` 按钮
    public var bottomToolViewBtnDisableTitleColorOfPreviewVC: UIColor = .zl.rgba(168, 168, 168)
    
    /// The disable state title color of bottom tool view done button  in preview interface.
    /// 预览大图界面底部 `完成` 按钮不可交互状态下标题颜色
    public var bottomToolViewDoneBtnDisableTitleColorOfPreviewVC: UIColor = .zl.rgba(168, 168, 168)
    
    private var pri_bottomToolViewBtnNormalBgColor: UIColor?
    /// The normal state background color of bottom tool view buttons.
    /// 相册小图界面底部按钮可交互状态下背景色
    public var bottomToolViewBtnNormalBgColor: UIColor {
        get {
            pri_bottomToolViewBtnNormalBgColor ?? themeColor
        }
        set {
            pri_bottomToolViewBtnNormalBgColor = newValue
        }
    }
    
    private var pri_bottomToolViewBtnNormalBgColorOfPreviewVC: UIColor?
    /// The normal state background color of bottom tool view buttons in preview interface.
    /// 预览大图界面底部按钮可交互状态下背景色
    public var bottomToolViewBtnNormalBgColorOfPreviewVC: UIColor {
        get {
            pri_bottomToolViewBtnNormalBgColorOfPreviewVC ?? themeColor
        }
        set {
            pri_bottomToolViewBtnNormalBgColorOfPreviewVC = newValue
        }
    }
    
    /// The disable state background color of bottom tool view buttons.
    /// 相册小图界面底部按钮不可交互状态下背景色
    public var bottomToolViewBtnDisableBgColor: UIColor = .zl.rgba(50, 50, 50)
    
    /// The disable state background color of bottom tool view buttons in preview interface.
    /// 预览大图界面底部按钮不可交互状态下背景色
    public var bottomToolViewBtnDisableBgColorOfPreviewVC: UIColor = .zl.rgba(50, 50, 50)
    
    /// With iOS14 limited authority, a color for select more photos at the bottom of the thumbnail interface.
    /// iOS14 limited权限下，下方提示选择更多图片信息文字的颜色
    public var limitedAuthorityTipsColor: UIColor = .white
    
    private var pri_cameraRecodeProgressColor: UIColor?
    /// The record progress color of custom camera.
    /// 自定义相机录制视频时进度条颜色
    public var cameraRecodeProgressColor: UIColor {
        get {
            pri_cameraRecodeProgressColor ?? themeColor
        }
        set {
            pri_cameraRecodeProgressColor = newValue
        }
    }
    
    /// Mask layer color of selected cell.
    /// 已选择照片上方遮罩阴影颜色
    public var selectedMaskColor: UIColor = .black.withAlphaComponent(0.45)
    
    private var pri_selectedBorderColor: UIColor?
    /// Border color of selected cell.
    /// 已选择照片border颜色
    public var selectedBorderColor: UIColor {
        get {
            pri_selectedBorderColor ?? themeColor
        }
        set {
            pri_selectedBorderColor = newValue
        }
    }
    
    /// Mask layer color of the cell that cannot be selected.
    /// 不可选的照片上方遮罩阴影颜色
    public var invalidMaskColor: UIColor = .zl.rgba(32, 32, 32, 0.85)
    
    /// The text color of selected cell index label.
    /// 已选照片右上角序号label背景色
    public var indexLabelTextColor: UIColor = .zl.rgba(220, 220, 220)
    
    private var pri_indexLabelBgColor: UIColor?
    /// The background color of selected cell index label.
    /// 已选照片右上角序号label背景色
    public var indexLabelBgColor: UIColor {
        get {
            pri_indexLabelBgColor ?? (showIndexOnSelectBtn ? themeColor : .clear)
        }
        set {
            pri_indexLabelBgColor = newValue
        }
    }
    
    /// The background color of camera cell inside album.
    /// 相册小图界面拍照按钮背景色
    public var cameraCellBgColor: UIColor = .zl.rgba(76, 76, 76)
    
    /// The normal color of adjust slider.
    /// 编辑图片，调整饱和度、对比度、亮度时，右侧slider背景色
    public var adjustSliderNormalColor: UIColor = .white
    
    private var pri_adjustSliderTintColor: UIColor?
    /// The tint color of adjust slider.
    /// 编辑图片，调整饱和度、对比度、亮度时，右侧slider背景高亮色
    public var adjustSliderTintColor: UIColor {
        get {
            pri_adjustSliderTintColor ?? themeColor
        }
        set {
            pri_adjustSliderTintColor = newValue
        }
    }
    
    /// The normal color of the title below the various tools in the image editor.
    /// 图片编辑器中各种工具下方标题普通状态下的颜色
    public var imageEditorToolTitleNormalColor: UIColor = .zl.rgba(160, 160, 160)
    
    /// The tint color of the title below the various tools in the image editor.
    /// 图片编辑器中各种工具下方标题高亮状态下的颜色
    public var imageEditorToolTitleTintColor: UIColor = .white
    
    /// The tint color of the image editor tool icons.
    /// 图片编辑器中各种工具图标高亮状态下的颜色
    public var imageEditorToolIconTintColor: UIColor?
    
    /// Background color of trash can in image editor.
    /// 编辑器中垃圾箱普通状态下的颜色
    public var trashCanBackgroundNormalColor: UIColor = .zl.rgba(40, 40, 40, 0.8)
    
    /// Background tint color of trash can in image editor.
    /// 编辑器中垃圾箱高亮状态下的颜色
    public var trashCanBackgroundTintColor: UIColor = .zl.rgba(241, 79, 79, 0.98)
}

/// Font deploy
enum ZLCustomFontDeploy {
    static var fontName: String?
}

/// Image source deploy
enum ZLCustomImageDeploy {
    static var imageNames: [String] = []
    
    static var imageForKey: [String: UIImage] = [:]
}

@objc public enum ZLPhotoBrowserStyle: Int {
    /// The album list is embedded in the navigation of the thumbnail interface, click the drop-down display.
    case embedAlbumList
    
    /// The display relationship between the album list and the thumbnail interface is push.
    case externalAlbumList
}

/// Language deploy
enum ZLCustomLanguageDeploy {
    static var language: ZLLanguageType = .system
    
    static var deploy: [ZLLocalLanguageKey: String] = [:]
}

/// Adjust slider type
@objc public enum ZLAdjustSliderType: Int {
    case vertical
    case horizontal
}
