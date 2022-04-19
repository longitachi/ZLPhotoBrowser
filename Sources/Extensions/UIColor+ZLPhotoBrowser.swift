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
        ZLPhotoUIConfiguration.default().navBarColor
    }
    
    class var navBarColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().navBarColorOfPreviewVC
    }
    
    /// 相册列表界面导航标题颜色
    class var navTitleColor: UIColor {
        ZLPhotoUIConfiguration.default().navTitleColor
    }
    
    /// 预览大图界面导航标题颜色
    class var navTitleColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().navTitleColorOfPreviewVC
    }
    
    /// 框架样式为 embedAlbumList 时，title view 背景色
    class var navEmbedTitleViewBgColor: UIColor {
        ZLPhotoUIConfiguration.default().navEmbedTitleViewBgColor
    }
    
    /// 预览选择模式下 上方透明背景色
    class var previewBgColor: UIColor {
        ZLPhotoUIConfiguration.default().sheetTranslucentColor
    }
    
    /// 预览选择模式下 拍照/相册/取消 的背景颜色
    class var previewBtnBgColor: UIColor {
        ZLPhotoUIConfiguration.default().sheetBtnBgColor
    }
    
    /// 预览选择模式下 拍照/相册/取消 的字体颜色
    class var previewBtnTitleColor: UIColor {
        ZLPhotoUIConfiguration.default().sheetBtnTitleColor
    }
    
    /// 预览选择模式下 选择照片大于0时，取消按钮title颜色
    class var previewBtnHighlightTitleColor: UIColor {
        ZLPhotoUIConfiguration.default().sheetBtnTitleTintColor
    }
    
    /// 相册列表界面背景色
    class var albumListBgColor: UIColor {
        ZLPhotoUIConfiguration.default().albumListBgColor
    }
    
    /// 嵌入式相册列表下方透明区域颜色
    class var embedAlbumListTranslucentColor: UIColor {
        ZLPhotoUIConfiguration.default().embedAlbumListTranslucentColor
    }
    
    /// 相册列表界面 相册title颜色
    class var albumListTitleColor: UIColor {
        ZLPhotoUIConfiguration.default().albumListTitleColor
    }
    
    /// 相册列表界面 数量label颜色
    class var albumListCountColor: UIColor {
        ZLPhotoUIConfiguration.default().albumListCountColor
    }
    
    /// 分割线颜色
    class var separatorLineColor: UIColor {
        ZLPhotoUIConfiguration.default().separatorColor
    }
    
    /// 小图界面背景色
    class var thumbnailBgColor: UIColor {
        ZLPhotoUIConfiguration.default().thumbnailBgColor
    }
    
    /// 预览大图界面背景色
    class var previewVCBgColor: UIColor {
        ZLPhotoUIConfiguration.default().previewVCBgColor
    }
    
    /// 相册列表界面底部工具条底色
    class var bottomToolViewBgColor: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBgColor
    }
    
    /// 预览大图界面底部工具条底色
    class var bottomToolViewBgColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBgColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 可交互 状态标题颜色
    class var bottomToolViewBtnNormalTitleColor: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBtnNormalTitleColor
    }
    
    /// 相册列表界面底部工具栏 `完成` 按钮 可交互 状态标题颜色
    class var bottomToolViewDoneBtnNormalTitleColor: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewDoneBtnNormalTitleColor
    }
    
    /// 预览大图界面底部工具栏按钮 可交互 状态标题颜色
    class var bottomToolViewBtnNormalTitleColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBtnNormalTitleColorOfPreviewVC
    }
    
    /// 预览大图界面底部工具栏 `完成` 按钮 可交互 状态标题颜色
    class var bottomToolViewDoneBtnNormalTitleColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewDoneBtnNormalTitleColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 不可交互 状态标题颜色
    class var bottomToolViewBtnDisableTitleColor: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBtnDisableTitleColor
    }
    
    /// 相册列表界面底部工具栏 `完成` 按钮 不可交互 状态标题颜色
    class var bottomToolViewDoneBtnDisableTitleColor: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewDoneBtnDisableTitleColor
    }
    
    /// 预览大图界面底部工具栏按钮 不可交互 状态标题颜色
    class var bottomToolViewBtnDisableTitleColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBtnDisableTitleColorOfPreviewVC
    }
    
    /// 预览大图界面底部工具栏 `完成` 按钮 不可交互 状态标题颜色
    class var bottomToolViewDoneBtnDisableTitleColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewDoneBtnDisableTitleColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 可交互 状态背景颜色
    class var bottomToolViewBtnNormalBgColor: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBtnNormalBgColor
    }
    
    /// 预览大图界面底部工具栏按钮 可交互 状态背景颜色
    class var bottomToolViewBtnNormalBgColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBtnNormalBgColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 不可交互 状态背景颜色
    class var bottomToolViewBtnDisableBgColor: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBtnDisableBgColor
    }
    
    /// 预览大图界面底部工具栏按钮 不可交互 状态背景颜色
    class var bottomToolViewBtnDisableBgColorOfPreviewVC: UIColor {
        ZLPhotoUIConfiguration.default().bottomToolViewBtnDisableBgColorOfPreviewVC
    }
    
    /// iOS14 limited 权限时候，小图界面下方显示 选择更多图片 标题颜色
    class var selectMorePhotoWhenAuthIsLismitedTitleColor: UIColor {
        return ZLPhotoUIConfiguration.default().selectMorePhotoWhenAuthIsLismitedTitleColor
    }
    
    /// 自定义相机录制视频时，进度条颜色
    class var cameraRecodeProgressColor: UIColor {
        ZLPhotoUIConfiguration.default().cameraRecodeProgressColor
    }
    
    /// 已选cell遮罩层颜色
    class var selectedMaskColor: UIColor {
        ZLPhotoUIConfiguration.default().selectedMaskColor
    }
    
    /// 已选cell border颜色
    class var selectedBorderColor: UIColor {
        ZLPhotoUIConfiguration.default().selectedBorderColor
    }
    
    /// 不能选择的cell上方遮罩层颜色
    class var invalidMaskColor: UIColor {
        ZLPhotoUIConfiguration.default().invalidMaskColor
    }
    
    /// 选中图片右上角index text color
    class var indexLabelTextColor: UIColor {
        ZLPhotoUIConfiguration.default().indexLabelTextColor
    }
    
    /// 选中图片右上角index background color
    class var indexLabelBgColor: UIColor {
        ZLPhotoUIConfiguration.default().indexLabelBgColor
    }
    
    /// 拍照cell 背景颜色
    class var cameraCellBgColor: UIColor {
        ZLPhotoUIConfiguration.default().cameraCellBgColor
    }
    
    /// 调整图片slider默认色
    class var adjustSliderNormalColor: UIColor {
        ZLPhotoUIConfiguration.default().adjustSliderNormalColor
    }
    
    /// 调整图片slider高亮色
    class var adjustSliderTintColor: UIColor {
        ZLPhotoUIConfiguration.default().adjustSliderTintColor
    }
    
}
