//
//  ZLThumbnailViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/19.
//
//  Copyright (c) 2020 Long Zhang <longitachi@163.com>
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

extension ZLThumbnailViewController {
    
    enum SlideSelectType {
        
        case none
        
        case select
        
        case cancel
        
    }
    
    struct Layout {
        
        static let bottomToolViewH: CGFloat = 55
        
        static let bottomToolBtnH: CGFloat = 34
        
        static let bottomToolTitleFont = getFont(17)
        
        static let collectionViewItemSpacing: CGFloat = 2
        
        static let collectionViewLineSpacing: CGFloat = 2
        
    }
    
}

class ZLThumbnailViewController: UIViewController {

    let albumList: ZLAlbumListModel
    
    var collectionView: UICollectionView!
    
    var bottomView: UIView!
    
    var bottomBlurView: UIVisualEffectView?
    
    var previewBtn: UIButton!
    
    var originalBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var arrDataSources: [ZLPhotoModel] = []
    
    var showCameraCell: Bool {
        if ZLPhotoConfiguration.default().allowTakePhotoInLibrary && (ZLPhotoConfiguration.default().allowSelectImage || ZLPhotoConfiguration.default().allowRecordVideo) {
            return true
        }
        return false
    }
    
    /// 所有滑动经过的indexPath
    lazy var arrSlideIndexPaths: [IndexPath] = []
    
    /// 所有滑动经过的indexPath的初始选择状态
    lazy var dicOriSelectStatus: [IndexPath: Bool] = [:]
    
    var isLayoutOK = false
    
    /// 设备旋转前第一个可视indexPath
    var firstVisibleIndexPathBeforeRotation: IndexPath?
    
    /// 是否触发了横竖屏切换
    var isSwitchOrientation = false
    
    /// 是否开始出发滑动选择
    var beginPanSelect = false
    
    /// 滑动选择 或 取消
    /// 当初始滑动的cell处于未选择状态，则开始选择，反之，则开始取消选择
    var panSelectType: ZLThumbnailViewController.SlideSelectType = .none
    
    /// 开始滑动的indexPath
    var beginSlideIndexPath: IndexPath?
    
    /// 最后滑动经过的index，开始的indexPath不计入
    /// 优化拖动手势计算，避免单个cell中冗余计算多次
    var lastSlideIndex: Int?
    
    /// 预览所选择图片，手势返回时候不调用scrollToIndex
    var isPreviewPush = false
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    deinit {
        debugPrint("ZLThumbnailViewController deinit")
    }
    
    init(albumList: ZLAlbumListModel) {
        self.albumList = albumList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        if ZLPhotoConfiguration.default().allowSlideSelect {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(slideSelectAction(_:)))
            self.view.addGestureRecognizer(pan)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
        
        self.loadPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        self.resetBottomToolBtnStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isLayoutOK = true
        self.isPreviewPush = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        var showBottomView = true
        
        let config = ZLPhotoConfiguration.default()
        let condition1 = config.editAfterSelectThumbnailImage &&
            config.maxSelectCount == 1 &&
            (config.allowEditImage || config.allowEditVideo)
        let condition2 = config.maxSelectCount == 1 && !config.showSelectBtnWhenSingleSelect
        if condition1 || condition2 {
            showBottomView = false
            insets.bottom = 0
        }
        let bottomViewH = showBottomView ? ZLThumbnailViewController.Layout.bottomToolViewH : 0
        
        let totalWidth = self.view.frame.width - insets.left - insets.right
        self.collectionView.frame = CGRect(x: insets.left, y: 0, width: totalWidth, height: self.view.frame.height)
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomViewH, right: 0)
        
        guard showBottomView else { return }
        
        let btnH = ZLThumbnailViewController.Layout.bottomToolBtnH
        
        self.bottomView.frame = CGRect(x: 0, y: self.view.frame.height-insets.bottom-bottomViewH, width: self.view.bounds.width, height: bottomViewH+insets.bottom)
        self.bottomBlurView?.frame = self.bottomView.bounds
        
        let btnY: CGFloat = 7
        
        let previewTitle = localLanguageTextValue(.preview)
        let previewBtnW = previewTitle.boundingRect(font: ZLThumbnailViewController.Layout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width
        self.previewBtn.frame = CGRect(x: 15, y: btnY, width: previewBtnW, height: btnH)
        
        let originalTitle = localLanguageTextValue(.originalPhoto)
        let w = originalTitle.boundingRect(font: ZLThumbnailViewController.Layout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 30
        self.originalBtn.frame = CGRect(x: (self.bottomView.bounds.width-w)/2-5, y: btnY, width: w, height: btnH)
        
        self.refreshDoneBtnFrame()
        
        if !self.isLayoutOK {
            self.scrollToBottom()
        } else if self.isSwitchOrientation {
            self.isSwitchOrientation = false
            if let ip = self.firstVisibleIndexPathBeforeRotation {
                self.collectionView.scrollToItem(at: ip, at: .top, animated: false)
            }
        }
    }
    
    func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = true
        self.edgesForExtendedLayout = .all
        self.view.backgroundColor = .thumbnailBgColor
        self.title = self.albumList.title
        
        let backItem = UIBarButtonItem(image: getImage("zl_navBack"), style: .plain, target: self, action: #selector(navBackAction))
        self.navigationItem.leftBarButtonItem = backItem
        
        let cancelBtn = UIButton(type: .custom)
        let title = localLanguageTextValue(.previewCancel)
        let size = title.boundingRect(font: getFont(16), limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44))
        cancelBtn.frame = CGRect(x: 0, y: 0, width: size.width, height: 44)
        cancelBtn.titleLabel?.font = getFont(16)
        cancelBtn.setTitle(title, for: .normal)
        cancelBtn.setTitleColor(.navTitleColor, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .thumbnailBgColor
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .always
        }
        self.view.addSubview(self.collectionView)
        
        ZLCameraCell.zl_register(self.collectionView)
        ZLThumbnailPhotoCell.zl_register(self.collectionView)
        
        self.bottomView = UIView()
        self.bottomView.backgroundColor = .bottomToolViewBgColor
        self.view.addSubview(self.bottomView)
        
        if let effect = ZLPhotoConfiguration.default().bottomToolViewBlurEffect {
            self.bottomBlurView = UIVisualEffectView(effect: effect)
            self.bottomView.addSubview(self.bottomBlurView!)
        }
        
        func createBtn(_ title: String, _ action: Selector) -> UIButton {
            let btn = UIButton(type: .custom)
            btn.titleLabel?.font = ZLThumbnailViewController.Layout.bottomToolTitleFont
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.bottomToolViewBtnNormalTitleColor, for: .normal)
            btn.setTitleColor(.bottomToolViewBtnDisableTitleColor, for: .disabled)
            btn.addTarget(self, action: action, for: .touchUpInside)
            return btn
        }
        
        self.previewBtn = createBtn(localLanguageTextValue(.preview), #selector(previewBtnClick))
        self.bottomView.addSubview(self.previewBtn)
        
        self.originalBtn = createBtn(localLanguageTextValue(.originalPhoto), #selector(originalPhotoClick))
        self.originalBtn.setImage(getImage("zl_btn_original_circle"), for: .normal)
        self.originalBtn.setImage(getImage("zl_btn_original_selected"), for: .selected)
        self.originalBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        self.originalBtn.isHidden = !(ZLPhotoConfiguration.default().allowSelectOriginal && ZLPhotoConfiguration.default().allowSelectImage)
        self.bottomView.addSubview(self.originalBtn)
        
        self.doneBtn = createBtn(localLanguageTextValue(.done), #selector(doneBtnClick))
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.layer.cornerRadius = 5
        self.bottomView.addSubview(self.doneBtn)
    }
    
    func loadPhotos() {
        let nav = self.navigationController as! ZLImageNavController
        if self.albumList.models.isEmpty {
            let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
            hud.show()
            DispatchQueue.global().async {
                self.albumList.refetchPhotos()
                DispatchQueue.main.async {
                    self.arrDataSources.append(contentsOf: self.albumList.models)
                    markSelected(source: &self.arrDataSources, selected: &nav.arrSelectedModels)
                    hud.hide()
                    self.collectionView.reloadData()
                    self.scrollToBottom()
                }
            }
        } else {
            self.arrDataSources.append(contentsOf: self.albumList.models)
            markSelected(source: &self.arrDataSources, selected: &nav.arrSelectedModels)
            self.collectionView.reloadData()
            self.scrollToBottom()
        }
    }
    
    /// MARK: btn actions
    
    @objc func navBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelBtnClick() {
        let nav = self.navigationController as? ZLImageNavController
        nav?.cancelBlock?()
        nav?.dismiss(animated: true, completion: nil)
    }
    
    @objc func previewBtnClick() {
        let nav = self.navigationController as! ZLImageNavController
        let vc = ZLPhotoPreviewViewController(photos: nav.arrSelectedModels, index: 0)
        self.show(vc, sender: nil)
    }
    
    @objc func originalPhotoClick() {
        self.originalBtn.isSelected = !self.originalBtn.isSelected
        (self.navigationController as? ZLImageNavController)?.isSelectedOriginal = self.originalBtn.isSelected
    }
    
    @objc func doneBtnClick() {
        let nav = self.navigationController as? ZLImageNavController
        nav?.selectImageBlock?()
    }
    
    @objc func deviceOrientationChanged(_ notify: Notification) {
        let pInView = self.collectionView.convert(CGPoint(x: 100, y: 100), from: self.view)
        self.firstVisibleIndexPathBeforeRotation = self.collectionView.indexPathForItem(at: pInView)
        self.isSwitchOrientation = true
    }
    
    @objc func slideSelectAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: point) else {
            return
        }
        let config = ZLPhotoConfiguration.default()
        let nav = self.navigationController as! ZLImageNavController
        
        let cell = self.collectionView.cellForItem(at: indexPath) as? ZLThumbnailPhotoCell
        let asc = !self.showCameraCell || config.sortAscending
        
        if pan.state == .began {
            self.beginPanSelect = (cell != nil)
            
            if self.beginPanSelect {
                let index = asc ? indexPath.row : indexPath.row - 1
                
                let m = self.arrDataSources[index]
                self.panSelectType = m.isSelected ? .cancel : .select
                self.beginSlideIndexPath = indexPath
                
                if !m.isSelected, canAddModel(m, currentSelectCount: nav.arrSelectedModels.count, sender: self) {
                    if self.shouldDirectEdit(m) {
                        self.panSelectType = .none
                        return
                    } else {
                        m.isSelected = true
                        nav.arrSelectedModels.append(m)
                    }
                } else if m.isSelected {
                    m.isSelected = false
                    nav.arrSelectedModels.removeAll { $0 == m }
                }
                
                cell?.btnSelect.isSelected = m.isSelected
                self.refreshCellIndex()
                self.refreshCellMaskView()
                self.resetBottomToolBtnStatus()
                self.lastSlideIndex = indexPath.row
            }
        } else if pan.state == .changed {
            if !self.beginPanSelect || indexPath.row == self.lastSlideIndex || self.panSelectType == .none || cell == nil {
                return
            }
            guard let beginIndexPath = self.beginSlideIndexPath else {
                return
            }
            self.lastSlideIndex = indexPath.row
            let minIndex = min(indexPath.row, beginIndexPath.row)
            let maxIndex = max(indexPath.row, beginIndexPath.row)
            let minIsBegin = minIndex == beginIndexPath.row
            
            var i = beginIndexPath.row
            while (minIsBegin ? i <= maxIndex : i >= minIndex) {
                if i != beginIndexPath.row {
                    let p = IndexPath(row: i, section: 0)
                    if !self.arrSlideIndexPaths.contains(p) {
                        self.arrSlideIndexPaths.append(p)
                        let index = asc ? i : i - 1
                        let m = self.arrDataSources[index]
                        self.dicOriSelectStatus[p] = m.isSelected
                    }
                }
                i += (minIsBegin ? 1 : -1)
            }
            
            for path in self.arrSlideIndexPaths {
                let index = asc ? path.row : path.row - 1
                // 是否在最初和现在的间隔区间内
                let inSection = path.row >= minIndex && path.row <= maxIndex
                let m = self.arrDataSources[index]
                
                if self.panSelectType == .select {
                    if inSection,
                       !m.isSelected,
                       canAddModel(m, currentSelectCount: nav.arrSelectedModels.count, sender: self, showAlert: false) {
                        m.isSelected = true
                    }
                } else if self.panSelectType == .cancel {
                    if inSection {
                        m.isSelected = false
                    }
                }
                
                if !inSection {
                    // 未在区间内的model还原为初始选择状态
                    m.isSelected = self.dicOriSelectStatus[path] ?? false
                }
                if !m.isSelected {
                    nav.arrSelectedModels.removeAll { $0 == m}
                } else {
                    if !nav.arrSelectedModels.contains(where: { $0 == m }) {
                        nav.arrSelectedModels.append(m)
                    }
                }
                
                let c = self.collectionView.cellForItem(at: path) as? ZLThumbnailPhotoCell
                c?.btnSelect.isSelected = m.isSelected
                self.refreshCellIndex()
                self.refreshCellMaskView()
                self.resetBottomToolBtnStatus()
            }
        } else if pan.state == .ended || pan.state == .cancelled {
            self.panSelectType = .none
            self.arrSlideIndexPaths.removeAll()
            self.dicOriSelectStatus.removeAll()
            self.resetBottomToolBtnStatus()
        }
    }
    
    func resetBottomToolBtnStatus() {
        let nav = self.navigationController as! ZLImageNavController
        if nav.arrSelectedModels.count > 0 {
            self.previewBtn.isEnabled = true
            self.doneBtn.isEnabled = true
            let doneTitle = localLanguageTextValue(.done) + "(" + String(nav.arrSelectedModels.count) + ")"
            self.doneBtn.setTitle(doneTitle, for: .normal)
            self.doneBtn.backgroundColor = .bottomToolViewBtnNormalBgColor
        } else {
            self.previewBtn.isEnabled = false
            self.doneBtn.isEnabled = false
            self.doneBtn.setTitle(localLanguageTextValue(.done), for: .normal)
            self.doneBtn.backgroundColor = .bottomToolViewBtnDisableBgColor
        }
        self.originalBtn.isSelected = nav.isSelectedOriginal
        self.refreshDoneBtnFrame()
    }
    
    func refreshDoneBtnFrame() {
        let selCount = (self.navigationController as? ZLImageNavController)?.arrSelectedModels.count ?? 0
        var doneTitle = localLanguageTextValue(.done)
        if selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        let doneBtnW = doneTitle.boundingRect(font: ZLThumbnailViewController.Layout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 20
        self.doneBtn.frame = CGRect(x: self.bottomView.bounds.width-doneBtnW-15, y: 7, width: doneBtnW, height: ZLThumbnailViewController.Layout.bottomToolBtnH)
    }
    
    func scrollToBottom() {
        guard ZLPhotoConfiguration.default().sortAscending, self.arrDataSources.count > 0 else {
            return
        }
        let index = self.showCameraCell ? self.arrDataSources.count : self.arrDataSources.count - 1
        self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .bottom, animated: false)
    }
    
    func showCamera() {
        let config = ZLPhotoConfiguration.default()
        if config.useCustomCamera {
            let camera = ZLCustomCamera()
            camera.takeDoneBlock = { [weak self] (image, videoUrl) in
                self?.save(image: image, videoUrl: videoUrl)
            }
            self.showDetailViewController(camera, sender: nil)
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.videoQuality = .typeHigh
                picker.sourceType = .camera
                picker.cameraFlashMode = config.cameraFlashMode.imagePickerFlashMode
                var mediaTypes = [String]()
                if config.allowSelectImage {
                    mediaTypes.append("public.image")
                }
                if config.allowRecordVideo {
                    mediaTypes.append("public.movie")
                }
                picker.mediaTypes = mediaTypes
                picker.videoMaximumDuration = TimeInterval(config.maxRecordDuration)
                self.showDetailViewController(picker, sender: nil)
            } else {
                showAlertView(localLanguageTextValue(.cameraUnavailable), self)
            }
        }
    }
    
    func save(image: UIImage?, videoUrl: URL?) {
        let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
        if let image = image {
            hud.show()
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] (suc, asset) in
                if suc, let at = asset {
                    let model = ZLPhotoModel(asset: at)
                    self?.handleDataArray(newModel: model)
                } else {
                    showAlertView(localLanguageTextValue(.saveImageError), self)
                }
                hud.hide()
            }
        } else if let videoUrl = videoUrl {
            hud.show()
            ZLPhotoManager.saveVideoToAblum(url: videoUrl) { [weak self] (suc, asset) in
                if suc, let at = asset {
                    let model = ZLPhotoModel(asset: at)
                    self?.handleDataArray(newModel: model)
                } else {
                    showAlertView(localLanguageTextValue(.saveVideoError), self)
                }
                hud.hide()
            }
        }
    }
    
    func handleDataArray(newModel: ZLPhotoModel) {
        let nav = self.navigationController as? ZLImageNavController
        let config = ZLPhotoConfiguration.default()
        var insertIndex = 0
        
        if config.sortAscending {
            insertIndex = self.arrDataSources.count
            self.arrDataSources.append(newModel)
        } else {
            // 保存拍照的照片或者视频，说明肯定有camera cell
            insertIndex = 1
            self.arrDataSources.insert(newModel, at: 0)
        }
        
        if canAddModel(newModel, currentSelectCount: nav?.arrSelectedModels.count ?? 0, sender: self, showAlert: false) {
            if !self.shouldDirectEdit(newModel) {
                newModel.isSelected = true
                nav?.arrSelectedModels.append(newModel)
            }
        }
        
        let insertIndexPath = IndexPath(row: insertIndex, section: 0)
        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: [insertIndexPath])
        }) { (_) in
            self.collectionView.scrollToItem(at: insertIndexPath, at: .centeredVertically, animated: true)
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
        
        self.resetBottomToolBtnStatus()
    }
    
}


extension ZLThumbnailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ZLThumbnailViewController.Layout.collectionViewItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ZLThumbnailViewController.Layout.collectionViewLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let defaultCount = CGFloat(ZLPhotoConfiguration.default().columnCount)
        var columnCount: CGFloat = deviceIsiPad() ? (defaultCount+2) : defaultCount
        if UIApplication.shared.statusBarOrientation.isLandscape {
            columnCount += 2
        }
        let totalW = collectionView.bounds.width - (columnCount - 1) * ZLThumbnailViewController.Layout.collectionViewItemSpacing
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showCameraCell ? (self.arrDataSources.count + 1) : self.arrDataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = ZLPhotoConfiguration.default()
        if self.showCameraCell && ((config.sortAscending && indexPath.row == self.arrDataSources.count) || (!config.sortAscending && indexPath.row == 0)) {
            // camera cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLCameraCell.zl_identifier(), for: indexPath) as! ZLCameraCell
            
            if config.showCaptureImageOnTakePhotoBtn {
                cell.startCapture()
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLThumbnailPhotoCell.zl_identifier(), for: indexPath) as! ZLThumbnailPhotoCell
        
        let model: ZLPhotoModel
        
        if self.showCameraCell, !config.sortAscending {
            model = self.arrDataSources[indexPath.row - 1]
        } else {
            model = self.arrDataSources[indexPath.row]
        }
        
        let nav = self.navigationController as? ZLImageNavController
        cell.selectedBlock = { [weak self, weak nav, weak cell] (isSelected) in
            if !isSelected {
                let currentSelectCount = nav?.arrSelectedModels.count ?? 0
                guard canAddModel(model, currentSelectCount: currentSelectCount, sender: self) else {
                    return
                }
                if self?.shouldDirectEdit(model) == false {
                    model.isSelected = true
                    nav?.arrSelectedModels.append(model)
                    cell?.btnSelect.isSelected = true
                    self?.setCellIndex(cell, showIndexLabel: true, index: currentSelectCount+1, animate: true)
                }
            } else {
                cell?.btnSelect.isSelected = false
                model.isSelected = false
                nav?.arrSelectedModels.removeAll { $0 == model }
                self?.refreshCellIndex()
            }
            self?.refreshCellMaskView()
            self?.resetBottomToolBtnStatus()
        }
        
        cell.indexLabel.isHidden = true
        if ZLPhotoConfiguration.default().showSelectedIndex {
            for (index, selM) in (nav?.arrSelectedModels ?? []).enumerated() {
                if model == selM {
                    self.setCellIndex(cell, showIndexLabel: true, index: index + 1, animate: false)
                    break
                }
            }
        }
        
        self.setCellMaskView(cell, isSelected: model.isSelected, model: model)
        
        cell.model = model
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? ZLThumbnailPhotoCell else {
            return
        }
        var index = indexPath.row
        if self.showCameraCell, !ZLPhotoConfiguration.default().sortAscending {
            index -= 1
        }
        let model = self.arrDataSources[index]
        self.setCellMaskView(c, isSelected: model.isSelected, model: model)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let c = collectionView.cellForItem(at: indexPath)
        if c is ZLCameraCell {
            self.showCamera()
            return
        }
        guard let cell = c as? ZLThumbnailPhotoCell else {
            return
        }
        if !cell.enableSelect {
            return
        }
        let config = ZLPhotoConfiguration.default()
        
        var index = indexPath.row
        if self.showCameraCell, !config.sortAscending {
            index -= 1
        }
        let m = self.arrDataSources[index]
        if self.shouldDirectEdit(m) {
            return
        }
        
        let vc = ZLPhotoPreviewViewController(photos: self.arrDataSources, index: index)
        self.show(vc, sender: nil)
    }
    
    func shouldDirectEdit(_ model: ZLPhotoModel) -> Bool {
        let canEditImage = ZLPhotoConfiguration.default().editAfterSelectThumbnailImage &&
            ZLPhotoConfiguration.default().allowEditImage &&
            ZLPhotoConfiguration.default().maxSelectCount == 1 &&
            model.type.rawValue < ZLPhotoModel.MediaType.video.rawValue
        
        let canEditVideo = ZLPhotoConfiguration.default().editAfterSelectThumbnailImage &&
            ZLPhotoConfiguration.default().allowEditVideo &&
            model.type == .video &&
            ZLPhotoConfiguration.default().maxSelectCount == 1 &&
            model.second >= ZLPhotoConfiguration.default().maxEditVideoTime &&
            model.second <= ZLPhotoConfiguration.default().maxSelectVideoDuration &&
            model.second >= ZLPhotoConfiguration.default().minSelectVideoDuration
        
        //当前未选择图片 或已经选择了一张并且点击的是已选择的图片
        let nav = self.navigationController as? ZLImageNavController
        let arrSelectedModels = nav?.arrSelectedModels ?? []
        let flag = arrSelectedModels.isEmpty || (arrSelectedModels.count == 1 && arrSelectedModels.first?.ident == model.ident)
        
        if canEditImage, flag {
            // TODO: 跳转编辑图片界面
            debugPrint("跳转编辑图片界面")
        } else if canEditVideo, flag {
            // TODO: 跳转编辑视频界面
            debugPrint("跳转编辑视频界面")
        }
        
        return ZLPhotoConfiguration.default().editAfterSelectThumbnailImage && ZLPhotoConfiguration.default().maxSelectCount == 1 && (ZLPhotoConfiguration.default().allowEditImage || ZLPhotoConfiguration.default().allowEditVideo)
    }
    
    func setCellIndex(_ cell: ZLThumbnailPhotoCell?, showIndexLabel: Bool, index: Int, animate: Bool) {
        guard ZLPhotoConfiguration.default().showSelectedIndex else {
            return
        }
        cell?.index = index
        cell?.indexLabel.isHidden = !showIndexLabel
        if animate {
            cell?.indexLabel.layer.add(getSpringAnimation(), forKey: nil)
        }
    }
    
    func refreshCellIndex() {
        guard ZLPhotoConfiguration.default().showSelectedIndex else {
            return
        }
        
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
        
        visibleIndexPaths.forEach { (indexPath) in
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? ZLThumbnailPhotoCell else {
                return
            }
            var row = indexPath.row
            if self.showCameraCell, !ZLPhotoConfiguration.default().sortAscending {
                row -= 1
            }
            let m = self.arrDataSources[row]
            
            let arrSel = (self.navigationController as? ZLImageNavController)?.arrSelectedModels ?? []
            var show = false
            var idx = 0
            for (index, selM) in arrSel.enumerated() {
                if m == selM {
                    show = true
                    idx = index + 1
                    break
                }
            }
            self.setCellIndex(cell, showIndexLabel: show, index: idx, animate: false)
        }
    }
    
    func refreshCellMaskView() {
        guard ZLPhotoConfiguration.default().showSelectedMask || ZLPhotoConfiguration.default().showInvalidMask else {
            return
        }
        
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
        
        visibleIndexPaths.forEach { (indexPath) in
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? ZLThumbnailPhotoCell else {
                return
            }
            var row = indexPath.row
            if self.showCameraCell, !ZLPhotoConfiguration.default().sortAscending {
                row -= 1
            }
            let m = self.arrDataSources[row]
            
            let arrSel = (self.navigationController as? ZLImageNavController)?.arrSelectedModels ?? []
            var isSelected = false
            for selM in arrSel {
                if m == selM {
                    isSelected = true
                    break
                }
            }
            self.setCellMaskView(cell, isSelected: isSelected, model: m)
        }
    }
    
    func setCellMaskView(_ cell: ZLThumbnailPhotoCell, isSelected: Bool, model: ZLPhotoModel) {
        cell.coverView.isHidden = true
        cell.enableSelect = true
        let arrSel = (self.navigationController as? ZLImageNavController)?.arrSelectedModels ?? []
        
        if isSelected {
            cell.coverView.backgroundColor = ZLPhotoConfiguration.default().selectedMaskColor
            cell.coverView.isHidden = !ZLPhotoConfiguration.default().showSelectedMask
        } else {
            let selCount = arrSel.count
            if selCount < ZLPhotoConfiguration.default().maxSelectCount, selCount > 0 {
                if !ZLPhotoConfiguration.default().allowMixSelect {
                    cell.coverView.backgroundColor = ZLPhotoConfiguration.default().invalidMaskColor
                    cell.coverView.isHidden = (!ZLPhotoConfiguration.default().showInvalidMask || model.type != .video)
                    cell.enableSelect = model.type != .video
                }
            } else if selCount >= ZLPhotoConfiguration.default().maxSelectCount {
                cell.coverView.backgroundColor = ZLPhotoConfiguration.default().invalidMaskColor
                cell.coverView.isHidden = ZLPhotoConfiguration.default().showInvalidMask
                cell.enableSelect = false
            }
        }
    }
    
}


extension ZLThumbnailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            let image = info[.originalImage] as? UIImage
            let url = info[.mediaURL] as? URL
            self.save(image: image, videoUrl: url)
        }
    }
    
}
