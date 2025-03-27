//
//  ZLPhotoPicker.swift
//  ZLPhotoBrowser
//
//  Created by long on 2025/3/12.
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

public class ZLPhotoPicker: NSObject {
    private var arrSelectedModels: [ZLPhotoModel] = []
    
    private weak var sender: UIViewController?
    
    private weak var previewSheet: ZLPhotoPreviewSheet?
    
    private var isSelectOriginal = false
    
    private lazy var fetchImageQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    /// Success callback
    /// block params
    ///  - params1: result models
    ///  - params2: is full image
    @objc public var selectImageBlock: (([ZLResultModel], Bool) -> Void)?
    
    /// Callback for photos that failed to parse
    /// block params
    ///  - params1: failed assets.
    ///  - params2: index for asset
    @objc public var selectImageRequestErrorBlock: (([PHAsset], [Int]) -> Void)?
    
    @objc public var cancelBlock: (() -> Void)?
    
    deinit {
        zlLoggerInDebug("ZLPhotoPicker deinit")
    }
    
    @objc override public init() {
        let config = ZLPhotoConfiguration.default()
        if !config.allowSelectImage, !config.allowSelectVideo {
            assertionFailure("ZLPhotoBrowser: error configuration. The values of allowSelectImage and allowSelectVideo are both false")
            config.allowSelectImage = true
        }
    }
    
    /// - Parameter selectedAssets: preselected assets
    @objc public convenience init(selectedAssets: [PHAsset]? = nil) {
        self.init()
        
        let config = ZLPhotoConfiguration.default()
        selectedAssets?.zl.removeDuplicate().forEach { asset in
            if !config.allowMixSelect, asset.mediaType == .video {
                return
            }
            
            let m = ZLPhotoModel(asset: asset)
            m.isSelected = true
            self.arrSelectedModels.append(m)
        }
    }
    
    /// Using this init method, you can continue editing the selected photo.
    /// - Note:
    ///     If you want to continue the last edit, you need to satisfy the value of `saveNewImageAfterEdit` is `false` at the time of the last selection.
    /// - Parameters:
    ///    - results : preselected results
    @objc public convenience init(results: [ZLResultModel]? = nil) {
        self.init()
        
        let config = ZLPhotoConfiguration.default()
        results?.zl.removeDuplicate().forEach { result in
            if !config.allowMixSelect, result.asset.mediaType == .video {
                return
            }
            
            let m = ZLPhotoModel(asset: result.asset)
            if result.isEdited {
                m.editImage = result.image
                m.editImageModel = result.editModel
            }
            m.isSelected = true
            self.arrSelectedModels.append(m)
        }
    }
    
    /// - Warning: When calling this method in OC language, make sure that the `sender` is not zero
    @discardableResult
    @objc public func showPreview(animate: Bool = true, sender: UIViewController) -> ZLPhotoPreviewSheet {
        self.sender = sender
        
        let ps = ZLPhotoPreviewSheet(models: arrSelectedModels)
        ps.selectPhotosBlock = { models, isOriginal in
            self.requestSelectPhoto(models: models, isSelectOriginal: isOriginal)
        }
        
        ps.showLibraryBlock = { models, isOriginal in
            self.arrSelectedModels.removeAll()
            self.arrSelectedModels.append(contentsOf: models)
            self.isSelectOriginal = isOriginal
            self.showPhotoLibrary(sender: sender)
        }
        
        ps.cancelBlock = {
            self.cancel()
        }
        
        ps.showPreview(sender: sender)
        previewSheet = ps
        
        return ps
    }
    
    /// - Warning: When calling this method in OC language, make sure that the `sender` is not zero
    @discardableResult
    @objc public func showPhotoLibrary(sender: UIViewController) -> ZLImageNavController {
        self.sender = sender
        
        let nav: ZLImageNavController
        if ZLPhotoUIConfiguration.default().style == .embedAlbumList {
            let tvc = ZLThumbnailViewController(albumList: nil)
            nav = getImageNav(rootViewController: tvc)
        } else {
            nav = getImageNav(rootViewController: ZLAlbumListController())
            let tvc = ZLThumbnailViewController(albumList: nil)
            nav.pushViewController(tvc, animated: true)
        }
        
        sender.present(nav, animated: true) {
            self.previewSheet?.hide()
        }
        
        return nav
    }
    
    /// 传入已选择的assets，并预览
    @objc public func previewAssets(
        sender: UIViewController,
        assets: [PHAsset],
        index: Int,
        isOriginal: Bool,
        showBottomViewAndSelectBtn: Bool = true
    ) {
        assert(!assets.isEmpty, "Assets cannot be empty")
        
        let models = assets.zl.removeDuplicate().map { asset -> ZLPhotoModel in
            let m = ZLPhotoModel(asset: asset)
            m.isSelected = true
            return m
        }
        
        guard !models.isEmpty else {
            return
        }
        
        arrSelectedModels.removeAll()
        arrSelectedModels.append(contentsOf: models)
        self.sender = sender
        
        isSelectOriginal = isOriginal
        
        let vc = ZLPhotoPreviewController(photos: models, index: index, showBottomViewAndSelectBtn: showBottomViewAndSelectBtn)
        vc.autoSelectCurrentIfNotSelectAnyone = false
        let nav = getImageNav(rootViewController: vc)
        vc.backBlock = {
            self.cancel()
        }
        
        sender.showDetailViewController(nav, sender: nil)
    }
    
    private func getImageNav(rootViewController: UIViewController) -> ZLImageNavController {
        let nav = ZLImageNavController(rootViewController: rootViewController)
        nav.modalPresentationStyle = .fullScreen
        nav.selectImageBlock = { [weak nav] in
            self.requestSelectPhoto(
                models: nav?.arrSelectedModels ?? [],
                isSelectOriginal: nav?.isSelectedOriginal ?? false,
                viewController: nav
            )
        }
        
        nav.cancelBlock = {
            self.cancel()
        }
        nav.isSelectedOriginal = isSelectOriginal
        nav.arrSelectedModels.removeAll()
        nav.arrSelectedModels.append(contentsOf: arrSelectedModels)
        
        return nav
    }
    
    private func cancel() {
        cancelBlock?()
    }
    
    /// 解析选择的图片
    private func requestSelectPhoto(
        models: [ZLPhotoModel],
        isSelectOriginal: Bool,
        viewController: UIViewController? = nil
    ) {
        arrSelectedModels.removeAll()
        arrSelectedModels.append(contentsOf: models)
        
        guard !arrSelectedModels.isEmpty else {
            selectImageBlock?([], isSelectOriginal)
            previewSheet?.hide()
            viewController?.dismiss(animated: true, completion: nil)
            return
        }
        
        let config = ZLPhotoConfiguration.default()
        
        if config.allowMixSelect {
            let videoCount = arrSelectedModels.filter { $0.type == .video }.count
            
            if videoCount > config.maxVideoSelectCount {
                showAlertView(String(format: localLanguageTextValue(.exceededMaxVideoSelectCount), ZLPhotoConfiguration.default().maxVideoSelectCount), viewController)
                return
            } else if videoCount < config.minVideoSelectCount {
                showAlertView(String(format: localLanguageTextValue(.lessThanMinVideoSelectCount), ZLPhotoConfiguration.default().minVideoSelectCount), viewController)
                return
            }
        }
        
        let hud = ZLProgressHUD.show(toast: .processing, timeout: ZLPhotoUIConfiguration.default().timeout)
        
        var timeout = false
        hud.timeoutBlock = { [weak self] in
            timeout = true
            showAlertView(localLanguageTextValue(.timeout), viewController ?? self?.sender)
            self?.fetchImageQueue.cancelAllOperations()
        }
        
        let isOriginal = config.allowSelectOriginal ? isSelectOriginal : config.alwaysRequestOriginal
        
        let callback = { [weak self] (sucModels: [ZLResultModel], errorAssets: [PHAsset], errorIndexs: [Int]) in
            hud.hide()
            
            func call() {
                self?.selectImageBlock?(sucModels, isOriginal)
                if !errorAssets.isEmpty {
                    self?.selectImageRequestErrorBlock?(errorAssets, errorIndexs)
                }
            }
            
            if let vc = viewController {
                vc.dismiss(animated: true) {
                    call()
                }
            } else {
                self?.previewSheet?.hide {
                    call()
                }
            }
            
            self?.arrSelectedModels.removeAll()
        }
        
        var results: [ZLResultModel?] = Array(repeating: nil, count: arrSelectedModels.count)
        var errorAssets: [PHAsset] = []
        var errorIndexs: [Int] = []
        
        var sucCount = 0
        let totalCount = arrSelectedModels.count
        
        for (i, m) in arrSelectedModels.enumerated() {
            let operation = ZLFetchImageOperation(model: m, isOriginal: isOriginal) { image, asset in
                guard !timeout else { return }
                
                sucCount += 1
                
                if let image = image {
                    let isEdited = m.editImage != nil && !config.saveNewImageAfterEdit
                    let model = ZLResultModel(
                        asset: asset ?? m.asset,
                        image: image,
                        isEdited: isEdited,
                        editModel: isEdited ? m.editImageModel : nil,
                        index: i
                    )
                    results[i] = model
                    zl_debugPrint("ZLPhotoBrowser: suc request \(i)")
                } else {
                    errorAssets.append(m.asset)
                    errorIndexs.append(i)
                    zl_debugPrint("ZLPhotoBrowser: failed request \(i)")
                }
                
                guard sucCount >= totalCount else { return }
                
                callback(
                    results.compactMap { $0 },
                    errorAssets,
                    errorIndexs
                )
            }
            fetchImageQueue.addOperation(operation)
        }
    }
}

// MARK: Methods for SwiftUI

public extension ZLPhotoPicker {
    @available(iOS, introduced: 13.0, message: "Only available for SwiftUI")
    func showPhotoLibraryForSwiftUI() -> ZLImageNavController {
        let nav: ZLImageNavController
        if ZLPhotoUIConfiguration.default().style == .embedAlbumList {
            let tvc = ZLThumbnailViewController(albumList: nil)
            nav = getImageNav(rootViewController: tvc)
        } else {
            nav = getImageNav(rootViewController: ZLAlbumListController())
            let tvc = ZLThumbnailViewController(albumList: nil)
            nav.pushViewController(tvc, animated: true)
        }
        
        return nav
    }
    
    /// 传入已选择的assets，并预览
    @objc func previewAssetsForSwiftUI(
        assets: [PHAsset],
        index: Int,
        isOriginal: Bool,
        showBottomViewAndSelectBtn: Bool = true
    ) -> ZLImageNavController {
        assert(!assets.isEmpty, "Assets cannot be empty")
        
        let models = assets.zl.removeDuplicate().map { asset -> ZLPhotoModel in
            let m = ZLPhotoModel(asset: asset)
            m.isSelected = true
            return m
        }
        
        arrSelectedModels.removeAll()
        arrSelectedModels.append(contentsOf: models)
        
        isSelectOriginal = isOriginal
        
        let vc = ZLPhotoPreviewController(photos: models, index: index, showBottomViewAndSelectBtn: showBottomViewAndSelectBtn)
        vc.autoSelectCurrentIfNotSelectAnyone = false
        let nav = getImageNav(rootViewController: vc)
        vc.backBlock = {
            self.cancel()
        }
        
        return nav
    }
}
