//
//  ZLPhotoPreviewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/20.
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

class ZLPhotoPreviewController: UIViewController {
    
    static let colItemSpacing: CGFloat = 40
    
    static let selPhotoPreviewH: CGFloat = 100
    
    static let previewVCScrollNotification = Notification.Name("previewVCScrollNotification")
    
    let arrDataSources: [ZLPhotoModel]
    
    var currentIndex: Int
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        
        ZLPhotoPreviewCell.zl.register(view)
        ZLGifPreviewCell.zl.register(view)
        ZLLivePhotoPreviewCell.zl.register(view)
        ZLVideoPreviewCell.zl.register(view)
        
        return view
    }()
    
    private let showBottomViewAndSelectBtn: Bool
    
    private var indexBeforOrientationChanged: Int
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.navBarColorOfPreviewVC
        return view
    }()
    
    private var navBlurView: UIVisualEffectView?
    
    private lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.zl.getImage("zl_navBack"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var selectBtn: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setImage(.zl.getImage("zl_btn_circle"), for: .normal)
        btn.setImage(.zl.getImage("zl_btn_selected"), for: .selected)
        btn.enlargeInset = 10
        btn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .zl.indexLabelBgColor
        label.font = .zl.font(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 25.0 / 2
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.bottomToolViewBgColorOfPreviewVC
        return view
    }()
    
    private var bottomBlurView: UIVisualEffectView?
    
    private lazy var editBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.edit), #selector(editBtnClick))
        btn.titleLabel?.lineBreakMode = .byCharWrapping
        btn.titleLabel?.numberOfLines = 0
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    private lazy var originalBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.originalPhoto), #selector(originalPhotoClick))
        btn.titleLabel?.lineBreakMode = .byCharWrapping
        btn.titleLabel?.numberOfLines = 2
        btn.contentHorizontalAlignment = .left
        btn.setImage(.zl.getImage("zl_btn_original_circle"), for: .normal)
        btn.setImage(.zl.getImage("zl_btn_original_selected"), for: .selected)
        btn.setImage(.zl.getImage("zl_btn_original_selected"), for: [.selected, .highlighted])
        btn.adjustsImageWhenHighlighted = false
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return btn
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.done), #selector(doneBtnClick), true)
        btn.backgroundColor = .zl.bottomToolViewBtnNormalBgColorOfPreviewVC
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    private var selPhotoPreview: ZLPhotoPreviewSelectedView?
    
    private var isFirstAppear = true
    
    private var hideNavView = false
    
    private var popInteractiveTransition: ZLPhotoPreviewPopInteractiveTransition?
    
    private var orientation: UIInterfaceOrientation = .unknown
    
    /// 是否在点击确定时候，当未选择任何照片时候，自动选择当前index的照片
    var autoSelectCurrentIfNotSelectAnyone = true
    
    /// 界面消失时，通知上个界面刷新（针对预览视图）
    var backBlock: (() -> Void)?
    
    override var prefersStatusBarHidden: Bool {
        return !ZLPhotoUIConfiguration.default().showStatusBarInPreviewInterface
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ZLPhotoUIConfiguration.default().statusBarStyle
    }
    
    deinit {
        zl_debugPrint("ZLPhotoPreviewController deinit")
    }
    
    init(photos: [ZLPhotoModel], index: Int, showBottomViewAndSelectBtn: Bool = true) {
        arrDataSources = photos
        self.showBottomViewAndSelectBtn = showBottomViewAndSelectBtn
        currentIndex = index
        indexBeforOrientationChanged = index
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        addPopInteractiveTransition()
        resetSubViewStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        
        guard isFirstAppear else { return }
        isFirstAppear = false
        
        reloadCurrentCell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        insets.top = max(20, insets.top)
        
        collectionView.frame = CGRect(
            x: -ZLPhotoPreviewController.colItemSpacing / 2,
            y: 0,
            width: view.frame.width + ZLPhotoPreviewController.colItemSpacing,
            height: view.frame.height
        )
        
        let navH = insets.top + 44
        navView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: navH)
        navBlurView?.frame = navView.bounds
        
        backBtn.frame = CGRect(x: insets.left, y: insets.top, width: 60, height: 44)
        selectBtn.frame = CGRect(x: view.frame.width - 40 - insets.right, y: insets.top + (44 - 25) / 2, width: 25, height: 25)
        indexLabel.frame = selectBtn.bounds
        
        refreshBottomViewFrame()
        
        let ori = UIApplication.shared.statusBarOrientation
        if ori != orientation {
            orientation = ori
            collectionView.setContentOffset(
                CGPoint(x: (view.frame.width + ZLPhotoPreviewController.colItemSpacing) * CGFloat(indexBeforOrientationChanged), y: 0),
                animated: false
            )
            collectionView.performBatchUpdates({
                self.collectionView.setContentOffset(
                    CGPoint(x: (self.view.frame.width + ZLPhotoPreviewController.colItemSpacing) * CGFloat(self.indexBeforOrientationChanged), y: 0),
                    animated: false
                )
            })
        }
    }
    
    private func reloadCurrentCell() {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) else {
            return
        }
        if let cell = cell as? ZLGifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? ZLLivePhotoPreviewCell {
            cell.loadLivePhotoData()
        }
    }
    
    private func refreshBottomViewFrame() {
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        var bottomViewH = ZLLayout.bottomToolViewH
        var showSelPhotoPreview = false
        if ZLPhotoConfiguration.default().showSelectedPhotoPreview, let nav = navigationController as? ZLImageNavController {
            if !nav.arrSelectedModels.isEmpty {
                showSelPhotoPreview = true
                bottomViewH += ZLPhotoPreviewController.selPhotoPreviewH
                selPhotoPreview?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: ZLPhotoPreviewController.selPhotoPreviewH)
            }
        }
        let btnH = ZLLayout.bottomToolBtnH
        
        bottomView.frame = CGRect(x: 0, y: view.frame.height - insets.bottom - bottomViewH, width: view.frame.width, height: bottomViewH + insets.bottom)
        bottomBlurView?.frame = bottomView.bounds
        
        let btnY: CGFloat = showSelPhotoPreview ? ZLPhotoPreviewController.selPhotoPreviewH + ZLLayout.bottomToolBtnY : ZLLayout.bottomToolBtnY
        
        let btnMaxWidth = (bottomView.bounds.width - 30) / 3
        
        let editTitle = localLanguageTextValue(.edit)
        let editBtnW = editTitle.zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width
        editBtn.frame = CGRect(x: 15, y: btnY, width: min(btnMaxWidth, editBtnW), height: btnH)
        
        let originTitle = localLanguageTextValue(.originalPhoto)
        let originBtnW = originTitle.zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 30
        let originBtnMaxW = min(btnMaxWidth, originBtnW)
        originalBtn.frame = CGRect(x: (bottomView.bounds.width - originBtnMaxW) / 2 - 5, y: btnY, width: originBtnMaxW, height: btnH)
        
        let selCount = (navigationController as? ZLImageNavController)?.arrSelectedModels.count ?? 0
        var doneTitle = localLanguageTextValue(.done)
        if ZLPhotoConfiguration.default().showSelectCountOnDoneBtn, selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        let doneBtnW = doneTitle.zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 20
        doneBtn.frame = CGRect(x: bottomView.bounds.width - doneBtnW - 15, y: btnY, width: doneBtnW, height: btnH)
    }
    
    private func setupUI() {
        view.backgroundColor = .zl.previewVCBgColor
        automaticallyAdjustsScrollViewInsets = false
        
        let config = ZLPhotoConfiguration.default()
        
        view.addSubview(navView)
        
        if let effect = ZLPhotoUIConfiguration.default().navViewBlurEffectOfPreview {
            navBlurView = UIVisualEffectView(effect: effect)
            navView.addSubview(navBlurView!)
        }
        
        navView.addSubview(backBtn)
        navView.addSubview(selectBtn)
        selectBtn.addSubview(indexLabel)
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        
        if let effect = ZLPhotoUIConfiguration.default().bottomViewBlurEffectOfPreview {
            bottomBlurView = UIVisualEffectView(effect: effect)
            bottomView.addSubview(bottomBlurView!)
        }
        
        if config.showSelectedPhotoPreview {
            let selModels = (navigationController as? ZLImageNavController)?.arrSelectedModels ?? []
            selPhotoPreview = ZLPhotoPreviewSelectedView(selModels: selModels, currentShowModel: arrDataSources[currentIndex])
            selPhotoPreview?.selectBlock = { [weak self] model in
                self?.scrollToSelPreviewCell(model)
            }
            selPhotoPreview?.endSortBlock = { [weak self] models in
                self?.refreshCurrentCellIndex(models)
            }
            bottomView.addSubview(selPhotoPreview!)
        }
        
        editBtn.isHidden = (!config.allowEditImage && !config.allowEditVideo)
        bottomView.addSubview(editBtn)
        
        originalBtn.isHidden = !(config.allowSelectOriginal && config.allowSelectImage)
        originalBtn.isSelected = (navigationController as? ZLImageNavController)?.isSelectedOriginal ?? false
        bottomView.addSubview(originalBtn)
        
        bottomView.addSubview(doneBtn)
        
        view.bringSubviewToFront(navView)
    }
    
    private func createBtn(_ title: String, _ action: Selector, _ isDone: Bool = false) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(
            isDone ? .zl.bottomToolViewDoneBtnNormalTitleColorOfPreviewVC : .zl.bottomToolViewBtnNormalTitleColorOfPreviewVC,
            for: .normal
        )
        btn.setTitleColor(
            isDone ? .zl.bottomToolViewDoneBtnDisableTitleColorOfPreviewVC : .zl.bottomToolViewBtnDisableTitleColorOfPreviewVC,
            for: .disabled
        )
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    private func addPopInteractiveTransition() {
        guard (navigationController?.viewControllers.count ?? 0) > 1 else {
            // 仅有当前vc一个时候，说明不是从相册进入，不添加交互动画
            return
        }
        popInteractiveTransition = ZLPhotoPreviewPopInteractiveTransition(viewController: self)
        popInteractiveTransition?.shouldStartTransition = { [weak self] point -> Bool in
            guard let `self` = self else { return false }
            if !self.hideNavView, self.navView.frame.contains(point) || self.bottomView.frame.contains(point) {
                return false
            }
            
            guard self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) != nil else {
                return false
            }
            
            return true
        }
        popInteractiveTransition?.startTransition = { [weak self] in
            guard let `self` = self else { return }
            
            self.navView.alpha = 0
            self.bottomView.alpha = 0
            
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) else {
                return
            }
            if cell is ZLVideoPreviewCell {
                (cell as! ZLVideoPreviewCell).pauseWhileTransition()
            } else if cell is ZLLivePhotoPreviewCell {
                (cell as! ZLLivePhotoPreviewCell).livePhotoView.stopPlayback()
            } else if cell is ZLGifPreviewCell {
                (cell as! ZLGifPreviewCell).pauseGif()
            }
        }
        popInteractiveTransition?.cancelTransition = { [weak self] in
            guard let `self` = self else { return }
            
            self.hideNavView = false
            self.navView.isHidden = false
            self.bottomView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.navView.alpha = 1
                self.bottomView.alpha = 1
            }
            
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) else {
                return
            }
            if cell is ZLGifPreviewCell {
                (cell as! ZLGifPreviewCell).resumeGif()
            }
        }
    }
    
    private func resetSubViewStatus() {
        guard let nav = navigationController as? ZLImageNavController else {
            zlLoggerInDebug("Navigation controller is null")
            return
        }
        let config = ZLPhotoConfiguration.default()
        let currentModel = arrDataSources[currentIndex]
        
        if (!config.allowMixSelect && currentModel.type == .video) || (!config.showSelectBtnWhenSingleSelect && config.maxSelectCount == 1) {
            selectBtn.isHidden = true
        } else {
            selectBtn.isHidden = false
        }
        selectBtn.isSelected = arrDataSources[currentIndex].isSelected
        resetIndexLabelStatus()
        
        guard showBottomViewAndSelectBtn else {
            selectBtn.isHidden = true
            bottomView.isHidden = true
            return
        }
        let selCount = nav.arrSelectedModels.count
        var doneTitle = localLanguageTextValue(.done)
        if ZLPhotoConfiguration.default().showSelectCountOnDoneBtn, selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        doneBtn.setTitle(doneTitle, for: .normal)
        
        selPhotoPreview?.isHidden = selCount == 0
        refreshBottomViewFrame()
        
        var hideEditBtn = true
        if selCount < config.maxSelectCount || nav.arrSelectedModels.contains(where: { $0 == currentModel }) {
            if config.allowEditImage,
               currentModel.type == .image || (currentModel.type == .gif && !config.allowSelectGif) || (currentModel.type == .livePhoto && !config.allowSelectLivePhoto) {
                hideEditBtn = false
            }
            if config.allowEditVideo,
               currentModel.type == .video,
               selCount == 0 || (selCount == 1 && nav.arrSelectedModels.first == currentModel) {
                hideEditBtn = false
            }
        }
        editBtn.isHidden = hideEditBtn
        
        if ZLPhotoConfiguration.default().allowSelectOriginal,
           ZLPhotoConfiguration.default().allowSelectImage {
            originalBtn.isHidden = !((currentModel.type == .image) || (currentModel.type == .livePhoto && !config.allowSelectLivePhoto) || (currentModel.type == .gif && !config.allowSelectGif))
        }
    }
    
    private func resetIndexLabelStatus() {
        guard ZLPhotoConfiguration.default().showSelectedIndex else {
            indexLabel.isHidden = true
            return
        }
        guard let nav = navigationController as? ZLImageNavController else {
            zlLoggerInDebug("Navigation controller is null")
            return
        }
        if let index = nav.arrSelectedModels.firstIndex(where: { $0 == self.arrDataSources[self.currentIndex] }) {
            indexLabel.isHidden = false
            indexLabel.text = String(index + 1)
        } else {
            indexLabel.isHidden = true
        }
    }
    
    // MARK: btn actions
    
    @objc private func backBtnClick() {
        backBlock?()
        let vc = navigationController?.popViewController(animated: true)
        if vc == nil {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func selectBtnClick() {
        guard let nav = navigationController as? ZLImageNavController else {
            zlLoggerInDebug("Navigation controller is null")
            return
        }
        let currentModel = arrDataSources[currentIndex]
        selectBtn.layer.removeAllAnimations()
        if currentModel.isSelected {
            currentModel.isSelected = false
            nav.arrSelectedModels.removeAll { $0 == currentModel }
            selPhotoPreview?.removeSelModel(model: currentModel)
        } else {
            if ZLPhotoConfiguration.default().animateSelectBtnWhenSelect {
                selectBtn.layer.add(getSpringAnimation(), forKey: nil)
            }
            if !canAddModel(currentModel, currentSelectCount: nav.arrSelectedModels.count, sender: self) {
                return
            }
            currentModel.isSelected = true
            nav.arrSelectedModels.append(currentModel)
            selPhotoPreview?.addSelModel(model: currentModel)
        }
        resetSubViewStatus()
    }
    
    @objc private func editBtnClick() {
        let config = ZLPhotoConfiguration.default()
        let model = arrDataSources[currentIndex]
        
        var requestAvAssetID: PHImageRequestID?
        let hud = ZLProgressHUD(style: ZLPhotoUIConfiguration.default().hudStyle)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self)
            if let requestAvAssetID = requestAvAssetID {
                PHImageManager.default().cancelImageRequest(requestAvAssetID)
            }
        }
        
        if model.type == .image || (!config.allowSelectGif && model.type == .gif) || (!config.allowSelectLivePhoto && model.type == .livePhoto) {
            hud.show(timeout: ZLPhotoConfiguration.default().timeout)
            requestAvAssetID = ZLPhotoManager.fetchImage(for: model.asset, size: model.previewSize) { [weak self] image, isDegraded in
                if !isDegraded {
                    if let image = image {
                        self?.showEditImageVC(image: image)
                    } else {
                        showAlertView(localLanguageTextValue(.imageLoadFailed), self)
                    }
                    hud.hide()
                }
            }
        } else if model.type == .video || config.allowEditVideo {
            hud.show(timeout: ZLPhotoConfiguration.default().timeout)
            // fetch avasset
            requestAvAssetID = ZLPhotoManager.fetchAVAsset(forVideo: model.asset) { [weak self] avAsset, _ in
                hud.hide()
                if let avAsset = avAsset {
                    self?.showEditVideoVC(model: model, avAsset: avAsset)
                } else {
                    showAlertView(localLanguageTextValue(.timeout), self)
                }
            }
        }
    }
    
    @objc private func originalPhotoClick() {
        originalBtn.isSelected.toggle()
        
        let config = ZLPhotoConfiguration.default()
        
        let nav = (navigationController as? ZLImageNavController)
        nav?.isSelectedOriginal = originalBtn.isSelected
        if nav?.arrSelectedModels.count == 0 {
            selectBtnClick()
        } else if config.maxSelectCount == 1,
                  !config.showSelectBtnWhenSingleSelect,
                  !originalBtn.isSelected,
                  nav?.arrSelectedModels.count == 1,
                  let currentModel = nav?.arrSelectedModels.first
        {
            currentModel.isSelected = false
            currentModel.editImage = nil
            currentModel.editImageModel = nil
            nav?.arrSelectedModels.removeAll { $0 == currentModel }
            selPhotoPreview?.removeSelModel(model: currentModel)
            resetSubViewStatus()
            let index = config.sortAscending ? arrDataSources.lastIndex { $0 == currentModel } : arrDataSources.firstIndex { $0 == currentModel }
            if let index = index {
                collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
    
    @objc private func doneBtnClick() {
        guard let nav = navigationController as? ZLImageNavController else {
            zlLoggerInDebug("Navigation controller is null")
            return
        }
        
        func callBackBeforeDone() {
            if let block = ZLPhotoConfiguration.default().operateBeforeDoneAction {
                block(self) { [weak nav] in
                    nav?.selectImageBlock?()
                }
            } else {
                nav.selectImageBlock?()
            }
        }
        
        let currentModel = arrDataSources[currentIndex]
        if autoSelectCurrentIfNotSelectAnyone {
            if nav.arrSelectedModels.isEmpty, canAddModel(currentModel, currentSelectCount: nav.arrSelectedModels.count, sender: self) {
                nav.arrSelectedModels.append(currentModel)
            }
            
            if !nav.arrSelectedModels.isEmpty {
                callBackBeforeDone()
            }
        } else {
            callBackBeforeDone()
        }
    }
    
    private func scrollToSelPreviewCell(_ model: ZLPhotoModel) {
        guard let index = arrDataSources.lastIndex(of: model) else {
            return
        }
        collectionView.performBatchUpdates({
            self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }) { _ in
            self.indexBeforOrientationChanged = self.currentIndex
            self.reloadCurrentCell()
        }
    }
    
    private func refreshCurrentCellIndex(_ models: [ZLPhotoModel]) {
        let nav = navigationController as? ZLImageNavController
        nav?.arrSelectedModels.removeAll()
        nav?.arrSelectedModels.append(contentsOf: models)
        guard ZLPhotoConfiguration.default().showSelectedIndex else {
            return
        }
        resetIndexLabelStatus()
    }
    
    private func tapPreviewCell() {
        hideNavView.toggle()
        
        let currentCell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
        if let cell = currentCell as? ZLVideoPreviewCell {
            if cell.isPlaying {
                hideNavView = true
            }
        }
        navView.isHidden = hideNavView
        bottomView.isHidden = showBottomViewAndSelectBtn ? hideNavView : true
    }
    
    private func showEditImageVC(image: UIImage) {
        let model = arrDataSources[currentIndex]
        let nav = navigationController as? ZLImageNavController
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: image, editModel: model.editImageModel) { [weak self, weak nav] ei, editImageModel in
            guard let `self` = self else { return }
            model.editImage = ei
            model.editImageModel = editImageModel
            if nav?.arrSelectedModels.contains(where: { $0 == model }) == false {
                model.isSelected = true
                nav?.arrSelectedModels.append(model)
                self.resetSubViewStatus()
                self.selPhotoPreview?.addSelModel(model: model)
            } else {
                self.selPhotoPreview?.refreshCell(for: model)
            }
            self.collectionView.reloadItems(at: [IndexPath(row: self.currentIndex, section: 0)])
        }
    }
    
    private func showEditVideoVC(model: ZLPhotoModel, avAsset: AVAsset) {
        let nav = navigationController as? ZLImageNavController
        let vc = ZLEditVideoViewController(avAsset: avAsset)
        vc.modalPresentationStyle = .fullScreen
        
        vc.editFinishBlock = { [weak self, weak nav] url in
            if let u = url {
                ZLPhotoManager.saveVideoToAlbum(url: u) { [weak self, weak nav] suc, asset in
                    if suc, asset != nil {
                        let m = ZLPhotoModel(asset: asset!)
                        nav?.arrSelectedModels.removeAll()
                        nav?.arrSelectedModels.append(m)
                        nav?.selectImageBlock?()
                    } else {
                        showAlertView(localLanguageTextValue(.saveVideoError), self)
                    }
                }
            } else {
                nav?.arrSelectedModels.removeAll()
                nav?.arrSelectedModels.append(model)
                nav?.selectImageBlock?()
            }
        }
        
        present(vc, animated: false, completion: nil)
    }
    
}

extension ZLPhotoPreviewController: UINavigationControllerDelegate {
    
    func navigationController(_: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from _: UIViewController, to _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return nil
        }
        return popInteractiveTransition?.interactive == true ? ZLPhotoPreviewAnimatedTransition() : nil
    }
    
    func navigationController(_: UINavigationController, interactionControllerFor _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return popInteractiveTransition?.interactive == true ? popInteractiveTransition : nil
    }
    
}

// MARK: scroll view delegate

extension ZLPhotoPreviewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else {
            return
        }
        NotificationCenter.default.post(name: ZLPhotoPreviewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (view.bounds.width + ZLPhotoPreviewController.colItemSpacing)))
        page = max(0, min(page, arrDataSources.count - 1))
        if page == currentIndex {
            return
        }
        currentIndex = page
        resetSubViewStatus()
        selPhotoPreview?.currentShowModelChanged(model: arrDataSources[currentIndex])
    }
    
    func scrollViewDidEndDecelerating(_: UIScrollView) {
        indexBeforOrientationChanged = currentIndex
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
        if let cell = cell as? ZLGifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? ZLLivePhotoPreviewCell {
            cell.loadLivePhotoData()
        }
    }
    
}

extension ZLPhotoPreviewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ZLPhotoPreviewController.colItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ZLPhotoPreviewController.colItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: ZLPhotoPreviewController.colItemSpacing / 2, bottom: 0, right: ZLPhotoPreviewController.colItemSpacing / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrDataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = ZLPhotoConfiguration.default()
        let model = arrDataSources[indexPath.row]
        
        let baseCell: ZLPreviewBaseCell
        
        if config.allowSelectGif, model.type == .gif {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLGifPreviewCell.zl.identifier, for: indexPath) as! ZLGifPreviewCell
            
            cell.singleTapBlock = { [weak self] in
                self?.tapPreviewCell()
            }
            
            cell.model = model
            
            baseCell = cell
        } else if config.allowSelectLivePhoto, model.type == .livePhoto {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLLivePhotoPreviewCell.zl.identifier, for: indexPath) as! ZLLivePhotoPreviewCell
            
            cell.model = model
            
            baseCell = cell
        } else if config.allowSelectVideo, model.type == .video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLVideoPreviewCell.zl.identifier, for: indexPath) as! ZLVideoPreviewCell
            
            cell.model = model
            
            baseCell = cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLPhotoPreviewCell.zl.identifier, for: indexPath) as! ZLPhotoPreviewCell

            cell.singleTapBlock = { [weak self] in
                self?.tapPreviewCell()
            }

            cell.model = model

            baseCell = cell
        }
        
        baseCell.singleTapBlock = { [weak self] in
            self?.tapPreviewCell()
        }
        
        return baseCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ZLPreviewBaseCell)?.resetSubViewStatusWhenCellEndDisplay()
    }
    
}

// MARK: 下方显示的已选择照片列表

class ZLPhotoPreviewSelectedView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        ZLPhotoPreviewSelectedViewCell.zl.register(view)
        
        if #available(iOS 11.0, *) {
            view.dragDelegate = self
            view.dropDelegate = self
            view.dragInteractionEnabled = true
            view.isSpringLoaded = true
        } else {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
            view.addGestureRecognizer(longPressGesture)
        }
        
        return view
    }()
    
    private var arrSelectedModels: [ZLPhotoModel]
    
    private var currentShowModel: ZLPhotoModel
    
    private var isDraging = false
    
    var selectBlock: ((ZLPhotoModel) -> Void)?
    
    var endSortBlock: (([ZLPhotoModel]) -> Void)?
    
    init(selModels: [ZLPhotoModel], currentShowModel: ZLPhotoModel) {
        arrSelectedModels = selModels
        self.currentShowModel = currentShowModel
        super.init(frame: .zero)
        
        setupUI()
    }
    
    private func setupUI() {
        addSubview(collectionView)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = CGRect(x: 0, y: 10, width: bounds.width, height: 80)
        if let index = arrSelectedModels.firstIndex(where: { $0 == self.currentShowModel }) {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func currentShowModelChanged(model: ZLPhotoModel) {
        guard currentShowModel != model else {
            return
        }
        currentShowModel = model
        
        if let index = arrSelectedModels.firstIndex(where: { $0 == self.currentShowModel }) {
            collectionView.performBatchUpdates({
                self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
            }) { _ in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        } else {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }
    
    func addSelModel(model: ZLPhotoModel) {
        arrSelectedModels.append(model)
        let indexPath = IndexPath(row: arrSelectedModels.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func removeSelModel(model: ZLPhotoModel) {
        guard let index = arrSelectedModels.firstIndex(where: { $0 == model }) else {
            return
        }
        arrSelectedModels.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    func refreshCell(for model: ZLPhotoModel) {
        guard let index = arrSelectedModels.firstIndex(where: { $0 == model }) else {
            return
        }
        collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    // MARK: iOS10 拖动
    
    @objc func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            isDraging = true
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        } else if gesture.state == .changed {
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        } else if gesture.state == .ended {
            isDraging = false
            collectionView.endInteractiveMovement()
            endSortBlock?(arrSelectedModels)
        } else {
            isDraging = false
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveModel = arrSelectedModels[sourceIndexPath.row]
        arrSelectedModels.remove(at: sourceIndexPath.row)
        arrSelectedModels.insert(moveModel, at: destinationIndexPath.row)
    }
    
    // MARK: iOS11 拖动
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        isDraging = true
        let itemProvider = NSItemProvider()
        let item = UIDragItem(itemProvider: itemProvider)
        return [item]
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        isDraging = false
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }
        guard let item = coordinator.items.first else {
            return
        }
        guard let sourceIndexPath = item.sourceIndexPath else {
            return
        }
        
        if coordinator.proposal.operation == .move {
            collectionView.performBatchUpdates({
                let moveModel = self.arrSelectedModels[sourceIndexPath.row]
                
                self.arrSelectedModels.remove(at: sourceIndexPath.row)
                
                self.arrSelectedModels.insert(moveModel, at: destinationIndexPath.row)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)
            
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            
            endSortBlock?(arrSelectedModels)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSelectedModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLPhotoPreviewSelectedViewCell.zl.identifier, for: indexPath) as! ZLPhotoPreviewSelectedViewCell
        
        let m = arrSelectedModels[indexPath.row]
        cell.model = m
        
        if m == currentShowModel {
            cell.layer.borderWidth = 4
        } else {
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isDraging else {
            return
        }
        let m = arrSelectedModels[indexPath.row]
        currentShowModel = m
        collectionView.performBatchUpdates({
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }) { _ in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
        selectBlock?(m)
    }
    
}

class ZLPhotoPreviewSelectedViewCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var tagImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.font = .zl.font(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    private var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    private var imageIdentifier: String = ""
    
    var model: ZLPhotoModel! {
        didSet {
            self.configureCell()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.zl.bottomToolViewBtnNormalBgColorOfPreviewVC.cgColor
        
        contentView.addSubview(imageView)
        contentView.addSubview(tagImageView)
        contentView.addSubview(tagLabel)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        tagImageView.frame = CGRect(x: 5, y: bounds.height - 25, width: 20, height: 20)
        tagLabel.frame = CGRect(x: 5, y: bounds.height - 25, width: bounds.width - 10, height: 20)
    }
    
    private func configureCell() {
        let size = CGSize(width: bounds.width * 1.5, height: bounds.height * 1.5)
        
        if imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        
        if model.type == .video {
            tagImageView.isHidden = false
            tagImageView.image = .zl.getImage("zl_video")
            tagLabel.isHidden = true
        } else if ZLPhotoConfiguration.default().allowSelectGif, model.type == .gif {
            tagImageView.isHidden = true
            tagLabel.isHidden = false
            tagLabel.text = "GIF"
        } else if ZLPhotoConfiguration.default().allowSelectLivePhoto, model.type == .livePhoto {
            tagImageView.isHidden = false
            tagImageView.image = .zl.getImage("zl_livePhoto")
            tagLabel.isHidden = true
        } else {
            if let _ = model.editImage {
                tagImageView.isHidden = false
                tagImageView.image = .zl.getImage("zl_editImage_tag")
            } else {
                tagImageView.isHidden = true
                tagLabel.isHidden = true
            }
        }
        
        imageIdentifier = model.ident
        imageView.image = nil
        
        if let ei = model.editImage {
            imageView.image = ei
        } else {
            imageRequestID = ZLPhotoManager.fetchImage(for: model.asset, size: size, completion: { [weak self] image, _ in
                if self?.imageIdentifier == self?.model.ident {
                    self?.imageView.image = image
                }
            })
        }
    }
    
}
