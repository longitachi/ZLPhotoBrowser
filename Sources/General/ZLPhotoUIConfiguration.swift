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

/// Custom UI configuration (include colors, images, text, font)
public class ZLPhotoUIConfiguration: NSObject {
    @objc public enum CancelButtonStyle: Int {
        case text
        case image
    }
    
    private static var single = ZLPhotoUIConfiguration()
    
    @objc public class func `default`() -> ZLPhotoUIConfiguration {
        return ZLPhotoUIConfiguration.single
    }
    
    @objc public class func resetConfiguration() {
        ZLPhotoUIConfiguration.single = ZLPhotoUIConfiguration()
    }
    
    // MARK: Framework style.
    
    @objc public var style: ZLPhotoBrowserStyle = .embedAlbumList
    
    @objc public var statusBarStyle: UIStatusBarStyle = .lightContent
    
    /// text: Cancel.  image: 'x'. Defaults to image.
    @objc public var navCancelButtonStyle: ZLPhotoUIConfiguration.CancelButtonStyle = .image
    
    /// Whether to show the status bar when previewing photos. Defaults to false.
    @objc public var showStatusBarInPreviewInterface = false
    
    /// HUD style. Defaults to dark.
    @objc public var hudStyle: ZLProgressHUD.HUDStyle = .dark
    
    /// Custom alert class. Defaults to nil.
    public var customAlertClass: ZLCustomAlertProtocol.Type?
    
    // MARK: Navigation and bottom tool bar
    
    /// The blur effect of the navigation bar in the album list
    @objc public var navViewBlurEffectOfAlbumList: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the navigation bar in the preview interface
    @objc public var navViewBlurEffectOfPreview: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the bottom tool bar in the album list
    @objc public var bottomViewBlurEffectOfAlbumList: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    /// The blur effect of the bottom tool bar in the preview interface
    @objc public var bottomViewBlurEffectOfPreview: UIBlurEffect? = UIBlurEffect(style: .dark)
    
    // MARK: Image properties
    
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
    
    // MARK: Language properties
    
    /// Language for framework.
    @objc public var languageType: ZLLanguageType = .system {
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
    @objc public var customLanguageKeyValue_objc: [String: String] = [:] {
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
    @objc public var themeFontName: String? {
        didSet {
            ZLCustomFontDeploy.fontName = themeFontName
        }
    }
    
    // MARK: Color properties
    
    /// Preview selection mode, translucent background color above.
    /// 预览快速选择模式下，上方透明区域背景色
    @objc public var sheetTranslucentColor: UIColor = .black.withAlphaComponent(0.1)
    
    /// Preview selection mode, a background color for `Camera`, `Album`, `Cancel` buttons.
    /// 预览快速选择模式下，按钮背景颜色
    @objc public var sheetBtnBgColor: UIColor = .white
    
    /// Preview selection mode, a text color for `Camera`, `Album`, `Cancel` buttons.
    /// 预览快速选择模式下，按钮标题颜色
    @objc public var sheetBtnTitleColor: UIColor = .black
    
    /// Preview selection mode, cancel button title color when the selection amount is superior than 0.
    /// 预览快速选择模式下，按钮标题高亮颜色
    @objc public var sheetBtnTitleTintColor: UIColor = .zl.rgba(80, 169, 56)
    
    /// A color for navigation bar.
    /// 相册列表及小图界面导航条背景色
    @objc public var navBarColor: UIColor = .zl.rgba(160, 160, 160, 0.65)
    
    /// A color for navigation bar in preview interface.
    /// 预览大图界面的导航条背景色
    @objc public var navBarColorOfPreviewVC: UIColor = .zl.rgba(160, 160, 160, 0.65)
    
    /// A color for Navigation bar text.
    /// 相册列表及小图界面导航栏标题颜色
    @objc public var navTitleColor: UIColor = .white
    
    /// A color for Navigation bar text of preview vc.
    /// 预览大图界面导航栏标题颜色
    @objc public var navTitleColorOfPreviewVC: UIColor = .white
    
    /// The background color of the title view when the frame style is embedAlbumList.
    /// 下拉选择相册列表模式下，选择区域的背景色
    @objc public var navEmbedTitleViewBgColor: UIColor = .zl.rgba(80, 80, 80)
    
    /// A color for background in album list.
    /// 相册列表背景色
    @objc public var albumListBgColor: UIColor = .zl.rgba(45, 45, 45)
    
    /// A color of the translucent area below the embed album list.
    /// 嵌入式相册列表下方透明区域颜色
    @objc public var embedAlbumListTranslucentColor: UIColor = .black.withAlphaComponent(0.8)
    
    /// A color for album list title label.
    /// 相册列表标题颜色
    @objc public var albumListTitleColor: UIColor = .white
    
    /// A color for album list count label.
    /// 相册列表数量label的颜色
    @objc public var albumListCountColor: UIColor = .zl.rgba(180, 180, 180)
    
    /// A color for album list separator.
    /// 相册列表分割线颜色
    @objc public var separatorColor: UIColor = .zl.rgba(60, 60, 60)
    
    /// A color for background in thumbnail interface.
    /// 相册小图界面背景色
    @objc public var thumbnailBgColor: UIColor = .zl.rgba(50, 50, 50)
    
    /// A color for background in preview interface..
    /// 预览大图界面背景色
    @objc public var previewVCBgColor: UIColor = .black
    
    /// A color for background in bottom tool view.
    /// 相册小图界面底部工具条背景色
    @objc public var bottomToolViewBgColor: UIColor = .zl.rgba(35, 35, 35, 0.3)
    
    /// A color for background in bottom tool view in preview interface.
    /// 预览大图界面底部工具条背景色
    @objc public var bottomToolViewBgColorOfPreviewVC: UIColor = .zl.rgba(35, 35, 35, 0.3)
    
    /// The normal state title color of bottom tool view buttons. Without done button.
    /// 相册小图界面底部按钮可交互状态下标题颜色，不包括 `完成` 按钮
    @objc public var bottomToolViewBtnNormalTitleColor: UIColor = .white
    
    /// The normal state title color of bottom tool view done button.
    /// 相册小图界面底部 `完成` 按钮可交互状态下标题颜色
    @objc public var bottomToolViewDoneBtnNormalTitleColor: UIColor = .white
    
    /// The normal state title color of bottom tool view buttons in preview interface.  Without done button.
    /// 预览大图界面底部按钮可交互状态下标题颜色，不包括 `完成` 按钮
    @objc public var bottomToolViewBtnNormalTitleColorOfPreviewVC: UIColor = .white
    
    /// The normal state title color of bottom tool view done button.
    /// 预览大图界面底部 `完成` 按钮可交互状态下标题颜色
    @objc public var bottomToolViewDoneBtnNormalTitleColorOfPreviewVC: UIColor = .white
    
    /// The disable state title color of bottom tool view buttons.  Without done button.
    /// 相册小图界面底部按钮不可交互状态下标题颜色，不包括 `完成` 按钮
    @objc public var bottomToolViewBtnDisableTitleColor: UIColor = .zl.rgba(168, 168, 168)
    
    /// The disable state title color of bottom tool view done button.
    /// 相册小图界面底部 `完成` 按钮不可交互状态下标题颜色
    @objc public var bottomToolViewDoneBtnDisableTitleColor: UIColor = .zl.rgba(168, 168, 168)
    
    /// The disable state title color of bottom tool view buttons in preview interface.  Without done button.
    /// 预览大图界面底部按钮不可交互状态下标题颜色，不包括 `完成` 按钮
    @objc public var bottomToolViewBtnDisableTitleColorOfPreviewVC: UIColor = .zl.rgba(168, 168, 168)
    
    /// The disable state title color of bottom tool view done button  in preview interface.
    /// 预览大图界面底部 `完成` 按钮不可交互状态下标题颜色
    @objc public var bottomToolViewDoneBtnDisableTitleColorOfPreviewVC: UIColor = .zl.rgba(168, 168, 168)
    
    /// The normal state background color of bottom tool view buttons.
    /// 相册小图界面底部按钮可交互状态下背景色
    @objc public var bottomToolViewBtnNormalBgColor: UIColor = .zl.rgba(80, 169, 56)
    
    /// The normal state background color of bottom tool view buttons in preview interface.
    /// 预览大图界面底部按钮可交互状态下背景色
    @objc public var bottomToolViewBtnNormalBgColorOfPreviewVC: UIColor = .zl.rgba(80, 169, 56)
    
    /// The disable state background color of bottom tool view buttons.
    /// 相册小图界面底部按钮不可交互状态下背景色
    @objc public var bottomToolViewBtnDisableBgColor: UIColor = .zl.rgba(50, 50, 50)
    
    /// The disable state background color of bottom tool view buttons in preview interface.
    /// 预览大图界面底部按钮不可交互状态下背景色
    @objc public var bottomToolViewBtnDisableBgColorOfPreviewVC: UIColor = .zl.rgba(50, 50, 50)
    
    /// With iOS14 limited authority, a color for select more photos at the bottom of the thumbnail interface.
    /// iOS14 limited权限下，下方提示选择更多图片信息文字的颜色
    @objc public var limitedAuthorityTipsColor: UIColor = .white
    
    /// The record progress color of custom camera.
    /// 自定义相机录制视频时进度条颜色
    @objc public var cameraRecodeProgressColor: UIColor = .zl.rgba(80, 169, 56)
    
    /// Mask layer color of selected cell.
    /// 已选择照片上方遮罩阴影颜色
    @objc public var selectedMaskColor: UIColor = .black.withAlphaComponent(0.2)
    
    /// Border color of selected cell.
    /// 已选择照片border颜色
    @objc public var selectedBorderColor: UIColor = .zl.rgba(80, 169, 56)
    
    /// Mask layer color of the cell that cannot be selected.
    /// 不可选的照片上方遮罩阴影颜色
    @objc public var invalidMaskColor: UIColor = .white.withAlphaComponent(0.5)
    
    /// The text color of selected cell index label.
    /// 已选照片右上角序号label背景色
    @objc public var indexLabelTextColor: UIColor = .white
    
    /// The background color of selected cell index label.
    /// 已选照片右上角序号label背景色
    @objc public var indexLabelBgColor: UIColor = .zl.rgba(80, 169, 56)
    
    /// The background color of camera cell inside album.
    /// 相册小图界面拍照按钮背景色
    @objc public var cameraCellBgColor: UIColor = .zl.rgba(76, 76, 76)
    
    /// The normal color of adjust slider.
    /// 编辑图片，调整饱和度、对比度、亮度时，右侧slider背景色
    @objc public var adjustSliderNormalColor: UIColor = .white
    
    /// The tint color of adjust slider.
    /// 编辑图片，调整饱和度、对比度、亮度时，右侧slider背景高亮色
    @objc public var adjustSliderTintColor: UIColor = .zl.rgba(80, 169, 56)
    
    /// The normal color of the title below the various tools in the image editor.
    /// 图片编辑器中各种工具下方标题普通状态下的颜色
    @objc public var imageEditorToolTitleNormalColor: UIColor = .zl.rgba(160, 160, 160)
    
    /// The tint color of the title below the various tools in the image editor.
    /// 图片编辑器中各种工具下方标题高亮状态下的颜色
    @objc public var imageEditorToolTitleTintColor: UIColor = .white
    
    /// Background color of trash can in image editor.
    /// 编辑器中垃圾箱普通状态下的颜色
    @objc public var trashCanBackgroundNormalColor: UIColor = .zl.rgba(40, 40, 40, 0.8)
    
    /// Background tint color of trash can in image editor.
    /// 编辑器中垃圾箱高亮状态下的颜色
    @objc public var trashCanBackgroundTintColor: UIColor = .zl.rgba(241, 79, 79, 0.98)
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
