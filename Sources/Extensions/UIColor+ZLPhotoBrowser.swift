//
//  UIColor+ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
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
import UIKit

extension UIColor {
    
    class var navBarColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.navBarColor
    }
    
    class var navBarColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.navBarColorOfPreviewVC
    }
    
    /// 相册列表界面导航标题颜色
    class var navTitleColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.navTitleColor
    }
    
    /// 预览大图界面导航标题颜色
    class var navTitleColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.navTitleColorOfPreviewVC
    }
    
    /// 框架样式为 embedAlbumList 时，title view 背景色
    class var navEmbedTitleViewBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.navEmbedTitleViewBgColor
    }
    
    /// 预览选择模式下 上方透明背景色
    class var previewBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.previewBgColor
    }
    
    /// 预览选择模式下 拍照/相册/取消 的背景颜色
    class var previewBtnBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.previewBtnBgColor
    }
    
    /// 预览选择模式下 拍照/相册/取消 的字体颜色
    class var previewBtnTitleColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.previewBtnTitleColor
    }
    
    /// 预览选择模式下 选择照片大于0时，取消按钮title颜色
    class var previewBtnHighlightTitleColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.previewBtnHighlightTitleColor
    }
    
    /// 相册列表界面背景色
    class var albumListBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.albumListBgColor
    }
    
    /// 相册列表界面 相册title颜色
    class var albumListTitleColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.albumListTitleColor
    }
    
    /// 相册列表界面 数量label颜色
    class var albumListCountColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.albumListCountColor
    }
    
    /// 分割线颜色
    class var separatorLineColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.separatorColor
    }
    
    /// 小图界面背景色
    class var thumbnailBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.thumbnailBgColor
    }
    
    /// 相册列表界面底部工具条底色
    class var bottomToolViewBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBgColor
    }
    
    /// 预览大图界面底部工具条底色
    class var bottomToolViewBgColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBgColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 可交互 状态标题颜色
    class var bottomToolViewBtnNormalTitleColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBtnNormalTitleColor
    }
    
    /// 相册列表界面底部工具栏 `完成` 按钮 可交互 状态标题颜色
    class var bottomToolViewDoneBtnNormalTitleColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewDoneBtnNormalTitleColor
    }
    
    /// 预览大图界面底部工具栏按钮 可交互 状态标题颜色
    class var bottomToolViewBtnNormalTitleColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBtnNormalTitleColorOfPreviewVC
    }
    
    /// 预览大图界面底部工具栏 `完成` 按钮 可交互 状态标题颜色
    class var bottomToolViewDoneBtnNormalTitleColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewDoneBtnNormalTitleColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 不可交互 状态标题颜色
    class var bottomToolViewBtnDisableTitleColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBtnDisableTitleColor
    }
    
    /// 相册列表界面底部工具栏 `完成` 按钮 不可交互 状态标题颜色
    class var bottomToolViewDoneBtnDisableTitleColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewDoneBtnDisableTitleColor
    }
    
    /// 预览大图界面底部工具栏按钮 不可交互 状态标题颜色
    class var bottomToolViewBtnDisableTitleColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBtnDisableTitleColorOfPreviewVC
    }
    
    /// 预览大图界面底部工具栏 `完成` 按钮 不可交互 状态标题颜色
    class var bottomToolViewDoneBtnDisableTitleColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewDoneBtnDisableTitleColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 可交互 状态背景颜色
    class var bottomToolViewBtnNormalBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBtnNormalBgColor
    }
    
    /// 预览大图界面底部工具栏按钮 可交互 状态背景颜色
    class var bottomToolViewBtnNormalBgColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBtnNormalBgColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 不可交互 状态背景颜色
    class var bottomToolViewBtnDisableBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBtnDisableBgColor
    }
    
    /// 预览大图界面底部工具栏按钮 不可交互 状态背景颜色
    class var bottomToolViewBtnDisableBgColorOfPreviewVC: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.bottomToolViewBtnDisableBgColorOfPreviewVC
    }
    
    /// iOS14 limited 权限时候，小图界面下方显示 选择更多图片 标题颜色
    class var selectMorePhotoWhenAuthIsLismitedTitleColor: UIColor {
        return ZLPhotoConfiguration.default().themeColorDeploy.selectMorePhotoWhenAuthIsLismitedTitleColor
    }
    
    /// 自定义相机录制视频时，进度条颜色
    class var cameraRecodeProgressColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.cameraRecodeProgressColor
    }
    
    /// 已选cell遮罩层颜色
    class var selectedMaskColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.selectedMaskColor
    }
    
    /// 已选cell border颜色
    class var selectedBorderColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.selectedBorderColor
    }
    
    /// 不能选择的cell上方遮罩层颜色
    class var invalidMaskColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.invalidMaskColor
    }
    
    /// 选中图片右上角index background color
    class var indexLabelBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.indexLabelBgColor
    }
    
    /// 拍照cell 背景颜色
    class var cameraCellBgColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.cameraCellBgColor
    }
    
    /// 调整图片slider默认色
    class var adjustSliderNormalColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.adjustSliderNormalColor
    }
    
    /// 调整图片slider高亮色
    class var adjustSliderTintColor: UIColor {
        ZLPhotoConfiguration.default().themeColorDeploy.adjustSliderTintColor
    }
    
}
