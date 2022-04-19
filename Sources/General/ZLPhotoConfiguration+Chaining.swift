//
//  ZLPhotoConfiguration+Chaining.swift
//  ZLPhotoBrowser
//
//  Created by long on 2021/11/1.
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

extension ZLPhotoConfiguration {
    
    @discardableResult
    public func style(_ style: ZLPhotoBrowserStyle) -> ZLPhotoConfiguration {
        self.style = style
        return self
    }
    
    @discardableResult
    public func statusBarStyle(_ statusBarStyle: UIStatusBarStyle) -> ZLPhotoConfiguration {
        self.statusBarStyle = statusBarStyle
        return self
    }
    
    
    @discardableResult
    public func navCancelButtonStyle(_ style: ZLPhotoConfiguration.CancelButtonStyle) -> ZLPhotoConfiguration {
        navCancelButtonStyle = style
        return self
    }
    
    @discardableResult
    public func sortAscending(_ ascending: Bool) -> ZLPhotoConfiguration {
        sortAscending = ascending
        return self
    }
    
    @discardableResult
    public func maxSelectCount(_ count: Int) -> ZLPhotoConfiguration {
        maxSelectCount = count
        return self
    }
    
    @discardableResult
    public func maxVideoSelectCount(_ count: Int) -> ZLPhotoConfiguration {
        maxVideoSelectCount = count
        return self
    }
    
    @discardableResult
    public func minVideoSelectCount(_ count: Int) -> ZLPhotoConfiguration {
        minVideoSelectCount = count
        return self
    }
    
    @discardableResult
    public func allowMixSelect(_ value: Bool) -> ZLPhotoConfiguration {
        allowMixSelect = value
        return self
    }
    
    @discardableResult
    public func maxPreviewCount(_ count: Int) -> ZLPhotoConfiguration {
        maxPreviewCount = count
        return self
    }
    
    @discardableResult
    public func cellCornerRadio(_ cornerRadio: CGFloat) -> ZLPhotoConfiguration {
        cellCornerRadio = cornerRadio
        return self
    }
    
    @discardableResult
    public func allowSelectImage(_ value: Bool) -> ZLPhotoConfiguration {
        allowSelectImage = value
        return self
    }
    
    @discardableResult
    @objc public func allowSelectVideo(_ value: Bool) -> ZLPhotoConfiguration {
        allowSelectVideo = value
        return self
    }
    
    @discardableResult
    public func allowSelectGif(_ value: Bool) -> ZLPhotoConfiguration {
        allowSelectGif = value
        return self
    }
    
    @discardableResult
    public func allowSelectLivePhoto(_ value: Bool) -> ZLPhotoConfiguration {
        allowSelectLivePhoto = value
        return self
    }
    
    @discardableResult
    public func allowTakePhotoInLibrary(_ value: Bool) -> ZLPhotoConfiguration {
        allowTakePhotoInLibrary = value
        return self
    }
    
    @discardableResult
    public func allowEditImage(_ value: Bool) -> ZLPhotoConfiguration {
        allowEditImage = value
        return self
    }
    
    @discardableResult
    public func allowEditVideo(_ value: Bool) -> ZLPhotoConfiguration {
        allowEditVideo = value
        return self
    }
    
    @discardableResult
    public func animateSelectBtnWhenSelect(_ animate: Bool) -> ZLPhotoConfiguration {
        animateSelectBtnWhenSelect = animate
        return self
    }
    
    @discardableResult
    public func selectBtnAnimationDuration(_ duration: CFTimeInterval) -> ZLPhotoConfiguration {
        selectBtnAnimationDuration = duration
        return self
    }
    
    @discardableResult
    public func editAfterSelectThumbnailImage(_ value: Bool) -> ZLPhotoConfiguration {
        editAfterSelectThumbnailImage = value
        return self
    }
    
    @discardableResult
    public func cropVideoAfterSelectThumbnail(_ value: Bool) -> ZLPhotoConfiguration {
        cropVideoAfterSelectThumbnail = value
        return self
    }
    
    @discardableResult
    public func showClipDirectlyIfOnlyHasClipTool(_ value: Bool) -> ZLPhotoConfiguration {
        showClipDirectlyIfOnlyHasClipTool = value
        return self
    }
    
    @discardableResult
    public func saveNewImageAfterEdit(_ value: Bool) -> ZLPhotoConfiguration {
        saveNewImageAfterEdit = value
        return self
    }
    
    @discardableResult
    public func allowSlideSelect(_ value: Bool) -> ZLPhotoConfiguration {
        allowSlideSelect = value
        return self
    }
    
    @discardableResult
    public func autoScrollWhenSlideSelectIsActive(_ value: Bool) -> ZLPhotoConfiguration {
        autoScrollWhenSlideSelectIsActive = value
        return self
    }
    
    @discardableResult
    public func autoScrollMaxSpeed(_ speed: CGFloat) -> ZLPhotoConfiguration {
        autoScrollMaxSpeed = speed
        return self
    }
    
    @discardableResult
    public func allowDragSelect(_ value: Bool) -> ZLPhotoConfiguration {
        allowDragSelect = value
        return self
    }
    
    @discardableResult
    public func allowSelectOriginal(_ value: Bool) -> ZLPhotoConfiguration {
        allowSelectOriginal = value
        return self
    }
    
    @discardableResult
    public func allowPreviewPhotos(_ value: Bool) -> ZLPhotoConfiguration {
        allowPreviewPhotos = value
        return self
    }
    
    @discardableResult
    public func showStatusBarInPreviewInterface(_ value: Bool) -> ZLPhotoConfiguration {
        showStatusBarInPreviewInterface = value
        return self
    }
    
    @discardableResult
    public func showPreviewButtonInAlbum(_ value: Bool) -> ZLPhotoConfiguration {
        showPreviewButtonInAlbum = value
        return self
    }
    
    @discardableResult
    public func showSelectCountOnDoneBtn(_ value: Bool) -> ZLPhotoConfiguration {
        showSelectCountOnDoneBtn = value
        return self
    }
    
    @discardableResult
    public func columnCount(_ count: Int) -> ZLPhotoConfiguration {
        columnCount = count
        return self
    }
    
    @discardableResult
    public func maxEditVideoTime(_ second: Second) -> ZLPhotoConfiguration {
        maxEditVideoTime = second
        return self
    }
    
    @discardableResult
    public func maxSelectVideoDuration(_ duration: Second) -> ZLPhotoConfiguration {
        maxSelectVideoDuration = duration
        return self
    }
    
    @discardableResult
    public func minSelectVideoDuration(_ duration: Second) -> ZLPhotoConfiguration {
        minSelectVideoDuration = duration
        return self
    }
    
    @discardableResult
    public func editImageConfiguration(_ configuration: ZLEditImageConfiguration) -> ZLPhotoConfiguration {
        editImageConfiguration = configuration
        return self
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @discardableResult
    public func editImageTools(_ tools: [ZLEditImageConfiguration.EditTool]) -> ZLPhotoConfiguration {
        editImageTools = tools
        return self
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @discardableResult
    public func editImageDrawColors(_ colors: [UIColor]) -> ZLPhotoConfiguration {
        editImageDrawColors = colors
        return self
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @discardableResult
    public func editImageDefaultDrawColor(_ color: UIColor) -> ZLPhotoConfiguration {
        editImageDefaultDrawColor = color
        return self
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @discardableResult
    public func editImageClipRatios(_ ratios: [ZLImageClipRatio]) -> ZLPhotoConfiguration {
        editImageClipRatios = ratios
        return self
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @discardableResult
    public func textStickerTextColors(_ colors: [UIColor]) -> ZLPhotoConfiguration {
        textStickerTextColors = colors
        return self
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @discardableResult
    public func textStickerDefaultTextColor(_ color: UIColor) -> ZLPhotoConfiguration {
        textStickerDefaultTextColor = color
        return self
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @discardableResult
    public func filters(_ filters: [ZLFilter]) -> ZLPhotoConfiguration {
        self.filters = filters
        return self
    }
    
    @available(*, deprecated, message: "Use editImageConfiguration, this property will be removed")
    @discardableResult
    public func imageStickerContainerView(_ view: (UIView & ZLImageStickerContainerDelegate)?) -> ZLPhotoConfiguration {
        imageStickerContainerView = view
        return self
    }
    
    @discardableResult
    public func showCaptureImageOnTakePhotoBtn(_ value: Bool) -> ZLPhotoConfiguration {
        showCaptureImageOnTakePhotoBtn = value
        return self
    }
    
    @discardableResult
    public func showSelectBtnWhenSingleSelect(_ value: Bool) -> ZLPhotoConfiguration {
        showSelectBtnWhenSingleSelect = value
        return self
    }
    
    @discardableResult
    public func showSelectedMask(_ value: Bool) -> ZLPhotoConfiguration {
        showSelectedMask = value
        return self
    }
    
    @discardableResult
    public func showSelectedBorder(_ value: Bool) -> ZLPhotoConfiguration {
        showSelectedBorder = value
        return self
    }
    
    @discardableResult
    public func showInvalidMask(_ value: Bool) -> ZLPhotoConfiguration {
        showInvalidMask = value
        return self
    }
    
    @discardableResult
    public func showSelectedIndex(_ value: Bool) -> ZLPhotoConfiguration {
        showSelectedIndex = value
        return self
    }
    
    @discardableResult
    public func showSelectedPhotoPreview(_ value: Bool) -> ZLPhotoConfiguration {
        showSelectedPhotoPreview = value
        return self
    }
    
    @discardableResult
    public func shouldAnialysisAsset(_ value: Bool) -> ZLPhotoConfiguration {
        shouldAnialysisAsset = value
        return self
    }
    
    @discardableResult
    public func timeout(_ timeout: TimeInterval) -> ZLPhotoConfiguration {
        self.timeout = timeout
        return self
    }
    
    @discardableResult
    public func languageType(_ type: ZLLanguageType) -> ZLPhotoConfiguration {
        languageType = type
        return self
    }
    
    @discardableResult
    public func useCustomCamera(_ value: Bool) -> ZLPhotoConfiguration {
        useCustomCamera = value
        return self
    }
    
    @discardableResult
    public func allowTakePhoto(_ value: Bool) -> ZLPhotoConfiguration {
        allowTakePhoto = value
        return self
    }
    
    @discardableResult
    public func allowRecordVideo(_ value: Bool) -> ZLPhotoConfiguration {
        allowRecordVideo = value
        return self
    }
    
    @discardableResult
    public func minRecordDuration(_ duration: Second) -> ZLPhotoConfiguration {
        minRecordDuration = duration
        return self
    }
    
    @discardableResult
    public func maxRecordDuration(_ duration: Second) -> ZLPhotoConfiguration {
        maxRecordDuration = duration
        return self
    }
    
    @discardableResult
    public func cameraConfiguration(_ configuration: ZLCameraConfiguration) -> ZLPhotoConfiguration {
        cameraConfiguration = configuration
        return self
    }
    
    @discardableResult
    public func hudStyle(_ style: ZLProgressHUD.HUDStyle) -> ZLPhotoConfiguration {
        hudStyle = style
        return self
    }
    
    @discardableResult
    @objc public func canSelectAsset(_ block: ((PHAsset) -> Bool)?) -> ZLPhotoConfiguration {
        canSelectAsset = block
        return self
    }
    
    @discardableResult
    @objc public func showAddPhotoButton(_ value: Bool) -> ZLPhotoConfiguration {
        showAddPhotoButton = value
        return self
    }
    
    @discardableResult
    @objc public func showEnterSettingTips(_ value: Bool) -> ZLPhotoConfiguration {
        showEnterSettingTips = value
        return self
    }
    
    @discardableResult
    @objc public func noAuthorityCallback(_ callback: ((ZLNoAuthorityType) -> Void)?) -> ZLPhotoConfiguration {
        noAuthorityCallback = callback
        return self
    }
    
    @discardableResult
    @objc public func operateBeforeDoneAction(_ block: ((UIViewController, @escaping () -> Void) -> Void)?) -> ZLPhotoConfiguration {
        operateBeforeDoneAction = block
        return self
    }
    
}
