//
//  ZLPhotoPreviewSheet.swift
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

class ZLPhotoPreviewSheet: UIView {
    private enum Layout {
        static let colH: CGFloat = 155
        
        static let btnH: CGFloat = 45
        
        static let spacing: CGFloat = 1 / UIScreen.main.scale
    }
    
    private lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.rgba(230, 230, 230)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = ZLCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .zl.previewBtnBgColor
        view.delegate = self
        view.dataSource = self
        view.isHidden = ZLPhotoConfiguration.default().maxPreviewCount == 0
        view.backgroundView = placeholderLabel
        ZLThumbnailPhotoCell.zl.register(view)
        
        return view
    }()
    
    private lazy var cameraBtn: UIButton = {
        let cameraTitle: String
        if !ZLPhotoConfiguration.default().cameraConfiguration.allowTakePhoto, ZLPhotoConfiguration.default().cameraConfiguration.allowRecordVideo {
            cameraTitle = localLanguageTextValue(.previewCameraRecord)
        } else {
            cameraTitle = localLanguageTextValue(.previewCamera)
        }
        let btn = createBtn(cameraTitle)
        btn.addTarget(self, action: #selector(cameraBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var photoLibraryBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.previewAlbum))
        btn.addTarget(self, action: #selector(photoLibraryBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.cancel))
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var flexibleView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.previewBtnBgColor
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .zl.font(ofSize: 15)
        label.text = localLanguageTextValue(.noPhotoTips)
        label.textAlignment = .center
        label.textColor = .zl.previewBtnTitleColor
        return label
    }()
    
    private var arrDataSources: [ZLPhotoModel] = []
    
    private var arrSelectedModels: [ZLPhotoModel] = []
    
    private var animate = true
    
    private var senderTabBarIsHidden: Bool?
    
    private var baseViewHeight: CGFloat = 0
    
    private var isSelectOriginal = false
    
    private var panBeginPoint: CGPoint = .zero
    
    private var panImageView: UIImageView?
    
    private var panModel: ZLPhotoModel?
    
    private var panCell: ZLThumbnailPhotoCell?
    
    private weak var sender: UIViewController?
    
    var cancelBlock: (() -> Void)?
    
    var selectPhotosBlock: ((_ models: [ZLPhotoModel], _ isOriginal: Bool) -> Void)?
    
    var showLibraryBlock: ((_ models: [ZLPhotoModel], _ isOriginal: Bool) -> Void)?
    
    deinit {
        zl_debugPrint("ZLPhotoPreviewSheet deinit")
    }
    
    convenience init(models: [ZLPhotoModel]? = nil) {
        self.init(frame: .zero)
        
        let config = ZLPhotoConfiguration.default()
        models?.forEach { item in
            if !config.allowMixSelect, item.asset.mediaType == .video {
                return
            }
            
            item.isSelected = true
            self.arrSelectedModels.append(item)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let config = ZLPhotoConfiguration.default()
        if !config.allowSelectImage, !config.allowSelectVideo {
            assertionFailure("ZLPhotoBrowser: error configuration. The values of allowSelectImage and allowSelectVideo are both false")
            config.allowSelectImage = true
        }
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        baseView.frame = CGRect(x: 0, y: bounds.height - baseViewHeight, width: bounds.width, height: baseViewHeight)
        
        var btnY: CGFloat = 0
        if ZLPhotoConfiguration.default().maxPreviewCount > 0 {
            collectionView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: ZLPhotoPreviewSheet.Layout.colH)
            btnY += (collectionView.frame.maxY + ZLPhotoPreviewSheet.Layout.spacing)
        }
        if canShowCameraBtn() {
            cameraBtn.frame = CGRect(x: 0, y: btnY, width: bounds.width, height: ZLPhotoPreviewSheet.Layout.btnH)
            btnY += (ZLPhotoPreviewSheet.Layout.btnH + ZLPhotoPreviewSheet.Layout.spacing)
        }
        photoLibraryBtn.frame = CGRect(x: 0, y: btnY, width: bounds.width, height: ZLPhotoPreviewSheet.Layout.btnH)
        btnY += (ZLPhotoPreviewSheet.Layout.btnH + ZLPhotoPreviewSheet.Layout.spacing)
        cancelBtn.frame = CGRect(x: 0, y: btnY, width: bounds.width, height: ZLPhotoPreviewSheet.Layout.btnH)
        btnY += ZLPhotoPreviewSheet.Layout.btnH
        flexibleView.frame = CGRect(x: 0, y: btnY, width: bounds.width, height: baseViewHeight - btnY)
    }
    
    func setupUI() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .zl.previewBgColor
        
        let showCameraBtn = canShowCameraBtn()
        var btnHeight: CGFloat = 0
        if ZLPhotoConfiguration.default().maxPreviewCount > 0 {
            btnHeight += ZLPhotoPreviewSheet.Layout.colH
        }
        btnHeight += (ZLPhotoPreviewSheet.Layout.spacing + ZLPhotoPreviewSheet.Layout.btnH) * (showCameraBtn ? 3 : 2)
        btnHeight += deviceSafeAreaInsets().bottom
        baseViewHeight = btnHeight
        
        addSubview(baseView)
        baseView.addSubview(collectionView)
        
        cameraBtn.isHidden = !showCameraBtn
        baseView.addSubview(cameraBtn)
        baseView.addSubview(photoLibraryBtn)
        baseView.addSubview(cancelBtn)
        baseView.addSubview(flexibleView)
        
        if ZLPhotoConfiguration.default().allowDragSelect {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panSelectAction(_:)))
            baseView.addGestureRecognizer(pan)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    private func createBtn(_ title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .zl.previewBtnBgColor
        btn.setTitleColor(.zl.previewBtnTitleColor, for: .normal)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .zl.font(ofSize: 17)
        return btn
    }
    
    private func canShowCameraBtn() -> Bool {
        if !ZLPhotoConfiguration.default().cameraConfiguration.allowTakePhoto, !ZLPhotoConfiguration.default().cameraConfiguration.allowRecordVideo {
            return false
        }
        return true
    }
    
    func show(animate: Bool, sender: UIViewController) {
        self.animate = animate
        self.sender = sender
        
        let status = PHPhotoLibrary.zl.authStatus(for: .readWrite)
        if status == .restricted || status == .denied {
            showNoAuthorityAlert()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                ZLMainAsync {
                    if status == .denied {
                        // 不符合苹果审核，这里注释掉 https://github.com/longitachi/ZLPhotoBrowser/issues/969#issuecomment-2601632232
//                        self.showNoAuthorityAlert()
                    } else if status == .authorized {
                        self.loadPhotos()
                        self.show()
                    }
                }
            }
            
            sender.view.addSubview(self)
        } else {
            loadPhotos()
            show()
        }
        
        // Register for the album change notification when the status is limited, because the photoLibraryDidChange method will be repeated multiple times each time the album changes, causing the interface to refresh multiple times. So the album changes are not monitored in other authority.
        if #available(iOS 14.0, *), PHPhotoLibrary.zl.authStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    private func loadPhotos() {
        let config = ZLPhotoConfiguration.default()
        ZLPhotoManager.getCameraRollAlbum(allowSelectImage: config.allowSelectImage, allowSelectVideo: config.allowSelectVideo) { [weak self] cameraRoll in
            guard let `self` = self else { return }
            var totalPhotos = ZLPhotoManager.fetchPhoto(in: cameraRoll.result, ascending: false, allowSelectImage: config.allowSelectImage, allowSelectVideo: config.allowSelectVideo, limitCount: config.maxPreviewCount)
            markSelected(source: &totalPhotos, selected: &self.arrSelectedModels)
            self.arrDataSources.removeAll()
            self.arrDataSources.append(contentsOf: totalPhotos)
            self.collectionView.reloadData()
        }
    }
    
    private func show() {
        frame = sender?.view.bounds ?? .zero
        
        collectionView.contentOffset = .zero
        
        if superview == nil {
            sender?.view.addSubview(self)
        }
        
        if let tabBar = sender?.tabBarController?.tabBar, !tabBar.isHidden {
            senderTabBarIsHidden = tabBar.isHidden
            tabBar.isHidden = true
        }
        
        if animate {
            backgroundColor = .zl.previewBgColor.withAlphaComponent(0)
            var frame = baseView.frame
            frame.origin.y = bounds.height
            baseView.frame = frame
            frame.origin.y -= baseViewHeight
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = .zl.previewBgColor
                self.baseView.frame = frame
            }
        }
    }
    
    func hide(completion: (() -> Void)? = nil) {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        
        if animate {
            var frame = baseView.frame
            frame.origin.y += baseViewHeight
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = .zl.previewBgColor.withAlphaComponent(0)
                self.baseView.frame = frame
            }) { _ in
                self.isHidden = true
                completion?()
                self.removeFromSuperview()
            }
        } else {
            isHidden = true
            completion?()
            removeFromSuperview()
        }
        
        if let senderTabBarIsHidden {
            sender?.tabBarController?.tabBar.isHidden = senderTabBarIsHidden
        }
    }
    
    private func showNoAuthorityAlert() {
        if let customAlertWhenNoAuthority = ZLPhotoConfiguration.default().customAlertWhenNoAuthority {
            customAlertWhenNoAuthority(.library)
            return
        }
        
        let action = ZLCustomAlertAction(title: localLanguageTextValue(.ok), style: .default) { _ in
            ZLPhotoConfiguration.default().noAuthorityCallback?(.library)
        }
        showAlertController(title: nil, message: String(format: localLanguageTextValue(.noPhotoLibraryAuthorityAlertMessage), getAppName()), style: .alert, actions: [action], sender: sender)
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        hide {
            self.cancelBlock?()
        }
    }
    
    @objc private func cameraBtnClick() {
        let config = ZLPhotoConfiguration.default()
        guard config.canEnterCamera?() ?? true else { return }
        
        if config.useCustomCamera {
            let camera = ZLCustomCamera()
            camera.takeDoneBlock = { [weak self] image, videoUrl in
                self?.save(image: image, videoURL: videoUrl)
            }
            sender?.showDetailViewController(camera, sender: nil)
        } else {
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                showAlertView(localLanguageTextValue(.cameraUnavailable), sender)
            } else if ZLPhotoManager.hasCameraAuthority() {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.videoQuality = .typeHigh
                picker.sourceType = .camera
                picker.cameraDevice = config.cameraConfiguration.devicePosition.cameraDevice
                if config.cameraConfiguration.showFlashSwitch {
                    picker.cameraFlashMode = .auto
                } else {
                    picker.cameraFlashMode = .off
                }
                var mediaTypes: [String] = []
                if config.cameraConfiguration.allowTakePhoto {
                    mediaTypes.append("public.image")
                }
                if config.cameraConfiguration.allowRecordVideo {
                    mediaTypes.append("public.movie")
                }
                picker.mediaTypes = mediaTypes
                picker.videoMaximumDuration = TimeInterval(config.cameraConfiguration.maxRecordDuration)
                sender?.showDetailViewController(picker, sender: nil)
            } else {
                showAlertView(String(format: localLanguageTextValue(.noCameraAuthorityAlertMessage), getAppName()), sender)
            }
        }
    }
    
    @objc private func photoLibraryBtnClick() {
        animate = false
        showLibraryBlock?(arrSelectedModels, isSelectOriginal)
    }
    
    @objc private func cancelBtnClick() {
        guard !arrSelectedModels.isEmpty else {
            hide { [weak self] in
                self?.cancelBlock?()
            }
            return
        }
        
        selectPhotosBlock?(arrSelectedModels, isSelectOriginal)
    }
    
    @objc private func panSelectAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: collectionView)
        if pan.state == .began {
            let cp = baseView.convert(point, from: collectionView)
            guard collectionView.frame.contains(cp) else {
                panBeginPoint = .zero
                return
            }
            panBeginPoint = point
        } else if pan.state == .changed {
            guard panBeginPoint != .zero else {
                return
            }
            
            guard let indexPath = collectionView.indexPathForItem(at: panBeginPoint) else {
                return
            }
            
            if panImageView == nil {
                guard point.y < panBeginPoint.y else {
                    return
                }
                guard let cell = collectionView.cellForItem(at: indexPath) as? ZLThumbnailPhotoCell else {
                    return
                }
                panModel = arrDataSources[indexPath.row]
                panCell = cell
                panImageView = UIImageView(frame: cell.bounds)
                panImageView?.contentMode = .scaleAspectFill
                panImageView?.clipsToBounds = true
                panImageView?.image = cell.imageView.image
                cell.imageView.image = nil
                addSubview(panImageView!)
            }
            panImageView?.center = convert(point, from: collectionView)
        } else if pan.state == .cancelled || pan.state == .ended {
            guard let pv = panImageView else {
                return
            }
            let pvRect = baseView.convert(pv.frame, from: self)
            var callBack = false
            if pvRect.midY < -10 {
                arrSelectedModels.removeAll()
                arrSelectedModels.append(panModel!)
                selectPhotosBlock?(arrSelectedModels, isSelectOriginal)
                callBack = true
            }
            
            panModel = nil
            if !callBack {
                let toRect = convert(panCell?.frame ?? .zero, from: collectionView)
                UIView.animate(withDuration: 0.25, animations: {
                    self.panImageView?.frame = toRect
                }) { _ in
                    self.panCell?.imageView.image = self.panImageView?.image
                    self.panCell = nil
                    self.panImageView?.removeFromSuperview()
                    self.panImageView = nil
                }
            } else {
                panCell?.imageView.image = panImageView?.image
                panImageView?.removeFromSuperview()
                panImageView = nil
                panCell = nil
            }
        }
    }
    
    private func showPreviewController(_ models: [ZLPhotoModel], index: Int) {
        let vc = ZLPhotoPreviewController(photos: models, index: index)
        let nav = getImageNav(rootViewController: vc)
        vc.backBlock = { [weak self, weak nav] in
            guard let `self` = self else { return }
            self.isSelectOriginal = nav?.isSelectedOriginal ?? false
            self.arrSelectedModels.removeAll()
            self.arrSelectedModels.append(contentsOf: nav?.arrSelectedModels ?? [])
            markSelected(source: &self.arrDataSources, selected: &self.arrSelectedModels)
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.changeCancelBtnTitle()
        }
        sender?.showDetailViewController(nav, sender: nil)
    }
    
    private func showEditImageVC(model: ZLPhotoModel) {
        var requestAssetID: PHImageRequestID?
        
        let hud = ZLProgressHUD.show(timeout: ZLPhotoUIConfiguration.default().timeout)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self?.sender)
            if let requestAssetID {
                PHImageManager.default().cancelImageRequest(requestAssetID)
            }
        }
        
        requestAssetID = ZLPhotoManager.fetchImage(for: model.asset, size: model.previewSize) { [weak self] image, isDegraded in
            if !isDegraded {
                if let image {
                    ZLEditImageViewController.showEditImageVC(parentVC: self?.sender, image: image, editModel: model.editImageModel) { [weak self] ei, editImageModel in
                        model.isSelected = true
                        model.editImage = ei
                        model.editImageModel = editImageModel
                        self?.arrSelectedModels.append(model)
                        ZLPhotoConfiguration.default().didSelectAsset?(model.asset)
                        
                        self?.selectPhotosBlock?(self?.arrSelectedModels ?? [], self?.isSelectOriginal ?? false)
                    }
                } else {
                    showAlertView(localLanguageTextValue(.imageLoadFailed), self?.sender)
                }
                hud.hide()
            }
        }
    }
    
    private func showEditVideoVC(model: ZLPhotoModel) {
        let config = ZLPhotoConfiguration.default()
        var requestAssetID: PHImageRequestID?
        
        let hud = ZLProgressHUD.show(timeout: ZLPhotoUIConfiguration.default().timeout)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self?.sender)
            if let requestAssetID {
                PHImageManager.default().cancelImageRequest(requestAssetID)
            }
        }
        
        func inner_showEditVideoVC(_ avAsset: AVAsset) {
            let vc = ZLEditVideoViewController(avAsset: avAsset)
            vc.editFinishBlock = { [weak self] editModel in
                model.isSelected = true
                model.editVideoModel = editModel
                self?.arrSelectedModels.removeAll()
                self?.arrSelectedModels.append(model)
                config.didSelectAsset?(model.asset)
                
                self?.selectPhotosBlock?(self?.arrSelectedModels ?? [], self?.isSelectOriginal ?? false)
            }
            vc.modalPresentationStyle = .fullScreen
            sender?.showDetailViewController(vc, sender: nil)
        }
        
        // 提前fetch一下 avasset
        requestAssetID = ZLPhotoManager.fetchAVAsset(forVideo: model.asset) { [weak self] avAsset, _ in
            hud.hide()
            if let avAsset {
                inner_showEditVideoVC(avAsset)
            } else {
                showAlertView(localLanguageTextValue(.timeout), self?.sender)
            }
        }
    }
    
    private func getImageNav(rootViewController: UIViewController) -> ZLImageNavController {
        let nav = ZLImageNavController(rootViewController: rootViewController)
        nav.modalPresentationStyle = .fullScreen
        nav.selectImageBlock = { [weak self, weak nav] in
            self?.isSelectOriginal = nav?.isSelectedOriginal ?? false
            self?.arrSelectedModels.removeAll()
            self?.arrSelectedModels.append(contentsOf: nav?.arrSelectedModels ?? [])
            
            nav?.dismiss(animated: true) {
                self?.selectPhotosBlock?(self?.arrSelectedModels ?? [], self?.isSelectOriginal ?? false)
            }
        }
        
        nav.cancelBlock = { [weak self] in
            self?.hide {
                self?.cancelBlock?()
            }
        }
        nav.isSelectedOriginal = isSelectOriginal
        nav.arrSelectedModels.removeAll()
        nav.arrSelectedModels.append(contentsOf: arrSelectedModels)
        
        return nav
    }
    
    private func save(image: UIImage?, videoURL: URL?) {
        if let image {
            let hud = ZLProgressHUD.show(toast: .processing)
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] error, asset in
                hud.hide()
                if error == nil, let asset {
                    let model = ZLPhotoModel(asset: asset)
                    self?.handleDataArray(newModel: model)
                } else {
                    showAlertView(localLanguageTextValue(.saveImageError), self?.sender)
                }
            }
        } else if let videoURL {
            let hud = ZLProgressHUD.show(toast: .processing)
            ZLPhotoManager.saveVideoToAlbum(url: videoURL) { [weak self] error, asset in
                hud.hide()
                if error == nil, let asset {
                    let model = ZLPhotoModel(asset: asset)
                    self?.handleDataArray(newModel: model)
                } else {
                    showAlertView(localLanguageTextValue(.saveVideoError), self?.sender)
                }
            }
        }
    }
    
    private func handleDataArray(newModel: ZLPhotoModel) {
        arrDataSources.insert(newModel, at: 0)
        let config = ZLPhotoConfiguration.default()
        
        var canSelect = true
        // If mixed selection is not allowed, and the newModel type is video, it will not be selected.
        if !config.allowMixSelect, newModel.type == .video {
            canSelect = false
        }
        // 单选模式，且不显示选择按钮时，不允许选择
        if config.maxSelectCount == 1, !config.showSelectBtnWhenSingleSelect {
            canSelect = false
        }
        if canSelect, canAddModel(newModel, currentSelectModels: arrSelectedModels, sender: sender, showAlert: false) {
            if !shouldDirectEdit(newModel) {
                newModel.isSelected = true
                arrSelectedModels.append(newModel)
                config.didSelectAsset?(newModel.asset)
                
                if config.callbackDirectlyAfterTakingPhoto {
                    selectPhotosBlock?(arrSelectedModels, isSelectOriginal)
                    return
                }
            }
        }
        
        let insertIndexPath = IndexPath(row: 0, section: 0)
        collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: [insertIndexPath])
        } completion: { _ in
            self.collectionView.scrollToItem(at: insertIndexPath, at: .centeredHorizontally, animated: true)
            
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
        
        changeCancelBtnTitle()
    }
}

extension ZLPhotoPreviewSheet: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        return !baseView.frame.contains(location)
    }
}

extension ZLPhotoPreviewSheet: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let m = arrDataSources[indexPath.row]
        let w = CGFloat(m.asset.pixelWidth)
        let h = CGFloat(m.asset.pixelHeight)
        let scale = min(1.7, max(0.5, w / h))
        return CGSize(width: collectionView.frame.height * scale, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        placeholderLabel.isHidden = arrSelectedModels.isEmpty
        return arrDataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLThumbnailPhotoCell.zl.identifier, for: indexPath) as! ZLThumbnailPhotoCell
        
        let config = ZLPhotoConfiguration.default()
        
        let model = arrDataSources[indexPath.row]
        
        cell.selectedBlock = { [weak self] block in
            guard let `self` = self else { return }
            
            if !model.isSelected {
                guard canAddModel(model, currentSelectModels: self.arrSelectedModels, sender: self.sender) else {
                    return
                }
                
                downloadAssetIfNeed(model: model, sender: self.sender) {
                    if !self.shouldDirectEdit(model) {
                        model.isSelected = true
                        self.arrSelectedModels.append(model)
                        block(true)
                        
                        config.didSelectAsset?(model.asset)
                        self.refreshCellIndex()
                        self.changeCancelBtnTitle()
                    }
                }
            } else {
                model.isSelected = false
                self.arrSelectedModels.removeAll { $0 == model }
                block(false)
                
                config.didDeselectAsset?(model.asset)
                self.refreshCellIndex()
                
                self.changeCancelBtnTitle()
            }
        }
        
        if config.showSelectedIndex,
           let index = arrSelectedModels.firstIndex(where: { $0 == model }) {
            setCellIndex(cell, showIndexLabel: true, index: index + config.initialIndex)
        } else {
            cell.indexLabel.isHidden = true
        }
        
        setCellMaskView(cell, isSelected: model.isSelected, model: model)
        
        cell.model = model
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? ZLThumbnailPhotoCell else {
            return
        }
        let model = arrDataSources[indexPath.row]
        setCellMaskView(c, isSelected: model.isSelected, model: model)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ZLThumbnailPhotoCell else {
            return
        }
        
        if !ZLPhotoConfiguration.default().allowPreviewPhotos {
            cell.btnSelectClick()
            return
        }
        
        if !cell.enableSelect, ZLPhotoUIConfiguration.default().showInvalidMask {
            return
        }
        let model = arrDataSources[indexPath.row]
        
        if shouldDirectEdit(model) {
            return
        }
        
        let config = ZLPhotoConfiguration.default()
        let uiConfig = ZLPhotoUIConfiguration.default()
        let hud = ZLProgressHUD.show()
        
        ZLPhotoManager.getCameraRollAlbum(allowSelectImage: config.allowSelectImage, allowSelectVideo: config.allowSelectVideo) { [weak self] cameraRoll in
            defer {
                hud.hide()
            }
            
            guard let `self` = self else {
                return
            }
            
            var totalPhotos = ZLPhotoManager.fetchPhoto(
                in: cameraRoll.result,
                ascending: uiConfig.sortAscending,
                allowSelectImage: config.allowSelectImage,
                allowSelectVideo: config.allowSelectVideo
            )
            markSelected(source: &totalPhotos, selected: &self.arrSelectedModels)
            let defaultIndex = uiConfig.sortAscending ? totalPhotos.count - 1 : 0
            var index: Int?
            // last和first效果一样，只是排序方式不同时候分别从前后开始查找可以更快命中
            if uiConfig.sortAscending {
                index = totalPhotos.lastIndex { $0 == model }
            } else {
                index = totalPhotos.firstIndex { $0 == model }
            }
            
            self.showPreviewController(totalPhotos, index: index ?? defaultIndex)
        }
    }
    
    private func shouldDirectEdit(_ model: ZLPhotoModel) -> Bool {
        let config = ZLPhotoConfiguration.default()
        
        let canEditImage = config.editAfterSelectThumbnailImage &&
            config.allowEditImage &&
            config.maxSelectCount == 1 &&
            model.type.rawValue < ZLPhotoModel.MediaType.video.rawValue
        
        let canEditVideo = config.editAfterSelectThumbnailImage &&
            config.allowEditVideo &&
            model.type == .video &&
            config.maxSelectCount == 1
        
        // 当前未选择图片 或已经选择了一张并且点击的是已选择的图片
        let flag = arrSelectedModels.isEmpty || (arrSelectedModels.count == 1 && arrSelectedModels.first?.ident == model.ident)
        
        if canEditImage, flag {
            showEditImageVC(model: model)
        } else if canEditVideo, flag {
            showEditVideoVC(model: model)
        }
        
        return flag && (canEditImage || canEditVideo)
    }
    
    private func setCellIndex(_ cell: ZLThumbnailPhotoCell?, showIndexLabel: Bool, index: Int) {
        guard ZLPhotoConfiguration.default().showSelectedIndex else {
            return
        }
        
        cell?.index = index
        cell?.indexLabel.isHidden = !showIndexLabel
    }
    
    private func refreshCellIndex() {
        let config = ZLPhotoConfiguration.default()
        let uiConfig = ZLPhotoUIConfiguration.default()
        
        let cameraIsEnable = arrSelectedModels.count < config.maxSelectCount
        cameraBtn.alpha = cameraIsEnable ? 1 : 0.3
        cameraBtn.isEnabled = cameraIsEnable
        
        let showIndex = config.showSelectedIndex
        let showMask = uiConfig.showSelectedMask || uiConfig.showInvalidMask
        
        guard showIndex || showMask else {
            return
        }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        visibleIndexPaths.forEach { indexPath in
            guard let cell = collectionView.cellForItem(at: indexPath) as? ZLThumbnailPhotoCell else {
                return
            }
            let m = arrDataSources[indexPath.row]
            
            var show = false
            var idx = 0
            var isSelected = false
            for (index, selM) in arrSelectedModels.enumerated() {
                if m == selM {
                    show = true
                    idx = index + config.initialIndex
                    isSelected = true
                    break
                }
            }
            if showIndex {
                setCellIndex(cell, showIndexLabel: show, index: idx)
            }
            if showMask {
                setCellMaskView(cell, isSelected: isSelected, model: m)
            }
        }
    }
    
    private func setCellMaskView(_ cell: ZLThumbnailPhotoCell, isSelected: Bool, model: ZLPhotoModel) {
        cell.coverView.isHidden = true
        cell.enableSelect = true
        let config = ZLPhotoConfiguration.default()
        let uiConfig = ZLPhotoUIConfiguration.default()
        
        if isSelected {
            cell.coverView.backgroundColor = .zl.selectedMaskColor
            cell.coverView.isHidden = !uiConfig.showSelectedMask
            if uiConfig.showSelectedBorder {
                cell.layer.borderWidth = 4
            }
            return
        }
        
        let selCount = arrSelectedModels.count
        if selCount < config.maxSelectCount {
            if !config.allowMixSelect, selCount > 0 {
                let selectIsVideo = arrSelectedModels.first?.isVideo ?? false
                cell.coverView.backgroundColor = .zl.invalidMaskColor
                cell.coverView.isHidden = (!uiConfig.showInvalidMask || model.isVideo == selectIsVideo)
                cell.enableSelect = model.isVideo == selectIsVideo
            }
        } else if selCount >= config.maxSelectCount {
            cell.coverView.backgroundColor = .zl.invalidMaskColor
            cell.coverView.isHidden = !uiConfig.showInvalidMask
            cell.enableSelect = false
        }
        if uiConfig.showSelectedBorder {
            cell.layer.borderWidth = 0
        }
    }
    
    private func changeCancelBtnTitle() {
        if !arrSelectedModels.isEmpty {
            cancelBtn.setTitle(String(format: "%@(%ld)", localLanguageTextValue(.done), arrSelectedModels.count), for: .normal)
            cancelBtn.setTitleColor(.zl.previewBtnHighlightTitleColor, for: .normal)
        } else {
            cancelBtn.setTitle(localLanguageTextValue(.cancel), for: .normal)
            cancelBtn.setTitleColor(.zl.previewBtnTitleColor, for: .normal)
        }
    }
}

extension ZLPhotoPreviewSheet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            let image = info[.originalImage] as? UIImage
            let url = info[.mediaURL] as? URL
            self.save(image: image, videoURL: url)
        }
    }
}

extension ZLPhotoPreviewSheet: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        ZLMainAsync {
            self.loadPhotos()
        }
    }
}
