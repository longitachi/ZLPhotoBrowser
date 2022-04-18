//
//  ZLPhotoColorConfiguration.swift
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

/// Color deploy
public class ZLPhotoColorConfiguration: NSObject {
    
    @objc public class func `default`() -> ZLPhotoColorConfiguration {
        return ZLPhotoColorConfiguration()
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
    
    /// A color of the translucent area below the embed album list.
    /// 嵌入式相册列表下方透明区域颜色
    @objc public var embedAlbumListTranslucentColor = UIColor(white: 0, alpha: 0.8)
    
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
    
    /// The text color of selected cell index label.
    /// 已选照片右上角序号label背景色
    @objc public var indexLabelTextColor = UIColor.white
    
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

// MARK: chaining
extension ZLPhotoColorConfiguration {
    
    @discardableResult
    public func previewBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        previewBgColor = color
        return self
    }
    
    @discardableResult
    public func previewBtnBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        previewBtnBgColor = color
        return self
    }
    
    @discardableResult
    public func previewBtnTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        previewBtnTitleColor = color
        return self
    }
    
    @discardableResult
    public func previewBtnHighlightTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        previewBtnHighlightTitleColor = color
        return self
    }
    
    @discardableResult
    public func navBarColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        navBarColor = color
        return self
    }
    
    @discardableResult
    public func navBarColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        navBarColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func navTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        navTitleColor = color
        return self
    }
    
    @discardableResult
    public func navTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        navTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func navEmbedTitleViewBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        navEmbedTitleViewBgColor = color
        return self
    }
    
    @discardableResult
    public func albumListBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        albumListBgColor = color
        return self
    }
    
    @discardableResult
    public func albumListTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        albumListTitleColor = color
        return self
    }
    
    @discardableResult
    public func albumListCountColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        albumListCountColor = color
        return self
    }
    
    @discardableResult
    public func separatorColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        separatorColor = color
        return self
    }
    
    @discardableResult
    public func thumbnailBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        thumbnailBgColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBgColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBgColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnNormalTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBtnNormalTitleColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewDoneBtnNormalTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewDoneBtnNormalTitleColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnNormalTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBtnNormalTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewDoneBtnNormalTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewDoneBtnNormalTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnDisableTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBtnDisableTitleColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewDoneBtnDisableTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewDoneBtnDisableTitleColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnDisableTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBtnDisableTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewDoneBtnDisableTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewDoneBtnDisableTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnNormalBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBtnNormalBgColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnNormalBgColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBtnNormalBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnDisableBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBtnDisableBgColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnDisableBgColorOfPreviewVC(_ color: UIColor) -> ZLPhotoColorConfiguration {
        bottomToolViewBtnDisableBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func selectMorePhotoWhenAuthIsLismitedTitleColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        selectMorePhotoWhenAuthIsLismitedTitleColor = color
        return self
    }
    
    @discardableResult
    public func cameraRecodeProgressColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        cameraRecodeProgressColor = color
        return self
    }
    
    @discardableResult
    public func selectedMaskColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        selectedMaskColor = color
        return self
    }
    
    @discardableResult
    public func selectedBorderColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        selectedBorderColor = color
        return self
    }
    
    @discardableResult
    public func invalidMaskColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        invalidMaskColor = color
        return self
    }
    
    @discardableResult
    public func indexLabelBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        indexLabelBgColor = color
        return self
    }
    
    @discardableResult
    public func cameraCellBgColor(_ color: UIColor) -> ZLPhotoColorConfiguration {
        cameraCellBgColor = color
        return self
    }
    
}
