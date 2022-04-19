//
//  ZLPhotoUIConfiguration+Chaining.swift
//  ZLPhotoBrowser
//
//  Created by long on 2022/4/19.
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

// MARK: chaining
extension ZLPhotoUIConfiguration {
    
    @discardableResult
    public func navViewBlurEffectOfAlbumList(_ effect: UIBlurEffect?) -> ZLPhotoUIConfiguration {
        navViewBlurEffectOfAlbumList = effect
        return self
    }
    
    @discardableResult
    public func navViewBlurEffectOfPreview(_ effect: UIBlurEffect?) -> ZLPhotoUIConfiguration {
        navViewBlurEffectOfPreview = effect
        return self
    }
    
    @discardableResult
    public func bottomViewBlurEffectOfAlbumList(_ effect: UIBlurEffect?) -> ZLPhotoUIConfiguration {
        bottomViewBlurEffectOfAlbumList = effect
        return self
    }
    
    @discardableResult
    public func bottomViewBlurEffectOfPreview(_ effect: UIBlurEffect?) -> ZLPhotoUIConfiguration {
        bottomViewBlurEffectOfPreview = effect
        return self
    }
    
    @discardableResult
    public func customImageNames(_ names: [String]) -> ZLPhotoUIConfiguration {
        customImageNames = names
        return self
    }
    
    @discardableResult
    public func customImageForKey(_ map: [String: UIImage?]) -> ZLPhotoUIConfiguration {
        customImageForKey = map
        return self
    }
    
    @discardableResult
    public func customLanguageKeyValue(_ map: [ZLLocalLanguageKey: String]) -> ZLPhotoUIConfiguration {
        customLanguageKeyValue = map
        return self
    }
    
    @discardableResult
    public func themeFontName(_ name: String) -> ZLPhotoUIConfiguration {
        themeFontName = name
        return self
    }
    
    @discardableResult
    public func sheetTranslucentColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        sheetTranslucentColor = color
        return self
    }
    
    @discardableResult
    public func sheetBtnBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        sheetBtnBgColor = color
        return self
    }
    
    @discardableResult
    public func sheetBtnTitleColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        sheetBtnTitleColor = color
        return self
    }
    
    @discardableResult
    public func sheetBtnTitleTintColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        sheetBtnTitleTintColor = color
        return self
    }
    
    @discardableResult
    public func navBarColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        navBarColor = color
        return self
    }
    
    @discardableResult
    public func navBarColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        navBarColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func navTitleColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        navTitleColor = color
        return self
    }
    
    @discardableResult
    public func navTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        navTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func navEmbedTitleViewBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        navEmbedTitleViewBgColor = color
        return self
    }
    
    @discardableResult
    public func albumListBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        albumListBgColor = color
        return self
    }
    
    @discardableResult
    public func embedAlbumListTranslucentColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        embedAlbumListTranslucentColor = color
        return self
    }
    
    @discardableResult
    public func albumListTitleColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        albumListTitleColor = color
        return self
    }
    
    @discardableResult
    public func albumListCountColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        albumListCountColor = color
        return self
    }
    
    @discardableResult
    public func separatorColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        separatorColor = color
        return self
    }
    
    @discardableResult
    public func thumbnailBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        thumbnailBgColor = color
        return self
    }
    
    @discardableResult
    public func previewVCBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        previewVCBgColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBgColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBgColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnNormalTitleColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBtnNormalTitleColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewDoneBtnNormalTitleColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewDoneBtnNormalTitleColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnNormalTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBtnNormalTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewDoneBtnNormalTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewDoneBtnNormalTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnDisableTitleColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBtnDisableTitleColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewDoneBtnDisableTitleColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewDoneBtnDisableTitleColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnDisableTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBtnDisableTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewDoneBtnDisableTitleColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewDoneBtnDisableTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnNormalBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBtnNormalBgColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnNormalBgColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBtnNormalBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnDisableBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBtnDisableBgColor = color
        return self
    }
    
    @discardableResult
    public func bottomToolViewBtnDisableBgColorOfPreviewVC(_ color: UIColor) -> ZLPhotoUIConfiguration {
        bottomToolViewBtnDisableBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    public func selectMorePhotoWhenAuthIsLismitedTitleColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        selectMorePhotoWhenAuthIsLismitedTitleColor = color
        return self
    }
    
    @discardableResult
    public func cameraRecodeProgressColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        cameraRecodeProgressColor = color
        return self
    }
    
    @discardableResult
    public func selectedMaskColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        selectedMaskColor = color
        return self
    }
    
    @discardableResult
    public func selectedBorderColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        selectedBorderColor = color
        return self
    }
    
    @discardableResult
    public func invalidMaskColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        invalidMaskColor = color
        return self
    }
    
    @discardableResult
    public func indexLabelTextColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        indexLabelTextColor = color
        return self
    }
    
    @discardableResult
    public func indexLabelBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        indexLabelBgColor = color
        return self
    }
    
    @discardableResult
    public func cameraCellBgColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        cameraCellBgColor = color
        return self
    }
    
    @discardableResult
    public func adjustSliderNormalColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        adjustSliderNormalColor = color
        return self
    }
    
    @discardableResult
    public func adjustSliderTintColor(_ color: UIColor) -> ZLPhotoUIConfiguration {
        adjustSliderTintColor = color
        return self
    }
    
}
