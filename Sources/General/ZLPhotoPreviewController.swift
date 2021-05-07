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
    
    let showBottomViewAndSelectBtn: Bool
    
    var currentIndex: Int
    
    var indexBeforOrientationChanged: Int
    
    var collectionView: UICollectionView!
    
    var navView: UIView!
    
    var navBlurView: UIVisualEffectView?
    
    var backBtn: UIButton!
    
    var selectBtn: UIButton!
    
    var indexLabel: UILabel!
    
    var bottomView: UIView!
    
    var bottomBlurView: UIVisualEffectView?
    
    var editBtn: UIButton!
    
    var originalBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var selPhotoPreview: ZLPhotoPreviewSelectedView?
    
    var isFirstAppear = true
    
    var hideNavView = false
    
    var popInteractiveTransition: ZLPhotoPreviewPopInteractiveTransition?
    
    /// 是否在点击确定时候，当未选择任何照片时候，自动选择当前index的照片
    var autoSelectCurrentIfNotSelectAnyone = true
    
    /// 界面消失时，通知上个界面刷新（针对预览视图）
    var backBlock: ( () -> Void )?
    
    var orientation: UIInterfaceOrientation = .unknown
    
    override var prefersStatusBarHidden: Bool {
        return !ZLPhotoConfiguration.default().showStatusBarInPreviewInterface
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ZLPhotoConfiguration.default().statusBarStyle
    }
    
    deinit {
        zl_debugPrint("ZLPhotoPreviewController deinit")
    }
    
    init(photos: [ZLPhotoModel], index: Int, showBottomViewAndSelectBtn: Bool = true) {
        self.arrDataSources = photos
        self.showBottomViewAndSelectBtn = showBottomViewAndSelectBtn
        self.currentIndex = index
        self.indexBeforOrientationChanged = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.addPopInteractiveTransition()
        self.resetSubViewStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
        
        guard self.isFirstAppear else { return }
        self.isFirstAppear = false
        
        self.reloadCurrentCell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        insets.top = max(20, insets.top)
        
        self.collectionView.frame = CGRect(x: -ZLPhotoPreviewController.colItemSpacing / 2, y: 0, width: self.view.frame.width + ZLPhotoPreviewController.colItemSpacing, height: self.view.frame.height)
        
        let navH = insets.top + 44
        self.navView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: navH)
        self.navBlurView?.frame = self.navView.bounds
        
        self.backBtn.frame = CGRect(x: insets.left, y: insets.top, width: 60, height: 44)
        self.selectBtn.frame = CGRect(x: self.view.frame.width - 40 - insets.right, y: insets.top + (44 - 25) / 2, width: 25, height: 25)
        self.indexLabel.frame = self.selectBtn.bounds
        
        self.refreshBottomViewFrame()
        
        let ori = UIApplication.shared.statusBarOrientation
        if ori != self.orientation {
            self.orientation = ori
            self.collectionView.setContentOffset(CGPoint(x: (self.view.frame.width + ZLPhotoPreviewController.colItemSpacing) * CGFloat(self.indexBeforOrientationChanged), y: 0), animated: false)
             self.collectionView.performBatchUpdates({
                self.collectionView.setContentOffset(CGPoint(x: (self.view.frame.width + ZLPhotoPreviewController.colItemSpacing) * CGFloat(self.indexBeforOrientationChanged), y: 0), animated: false)
             })
        }
    }
    
    func reloadCurrentCell() {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) else {
            return
        }
        if let cell = cell as? ZLGifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? ZLLivePhotoPreviewCell {
            cell.loadLivePhotoData()
        }
    }
    
    func refreshBottomViewFrame() {
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        var bottomViewH = ZLLayout.bottomToolViewH
        var showSelPhotoPreview = false
        if ZLPhotoConfiguration.default().showSelectedPhotoPreview {
            let nav = self.navigationController as! ZLImageNavController
            if !nav.arrSelectedModels.isEmpty {
                showSelPhotoPreview = true
                bottomViewH += ZLPhotoPreviewController.selPhotoPreviewH
                self.selPhotoPreview?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: ZLPhotoPreviewController.selPhotoPreviewH)
            }
        }
        let btnH = ZLLayout.bottomToolBtnH
        
        self.bottomView.frame = CGRect(x: 0, y: self.view.frame.height-insets.bottom-bottomViewH, width: self.view.frame.width, height: bottomViewH+insets.bottom)
        self.bottomBlurView?.frame = self.bottomView.bounds
        
        let btnY: CGFloat = showSelPhotoPreview ? ZLPhotoPreviewController.selPhotoPreviewH + ZLLayout.bottomToolBtnY : ZLLayout.bottomToolBtnY
        
        let editTitle = localLanguageTextValue(.edit)
        let editBtnW = editTitle.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width
        self.editBtn.frame = CGRect(x: 15, y: btnY, width: editBtnW, height: btnH)
        
        let originalTitle = localLanguageTextValue(.originalPhoto)
        let w = originalTitle.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 30
        self.originalBtn.frame = CGRect(x: (self.bottomView.bounds.width-w)/2-5, y: btnY, width: w, height: btnH)
        
        let selCount = (self.navigationController as? ZLImageNavController)?.arrSelectedModels.count ?? 0
        var doneTitle = localLanguageTextValue(.done)
        if selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        let doneBtnW = doneTitle.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 20
        self.doneBtn.frame = CGRect(x: self.bottomView.bounds.width-doneBtnW-15, y: btnY, width: doneBtnW, height: btnH)
    }
    
    func setupUI() {
        self.view.backgroundColor = .black
        self.automaticallyAdjustsScrollViewInsets = false
        
        let config = ZLPhotoConfiguration.default()
        // nav view
        self.navView = UIView()
        self.navView.backgroundColor = .navBarColor
        self.view.addSubview(self.navView)
        
        if let effect = config.navViewBlurEffect {
            self.navBlurView = UIVisualEffectView(effect: effect)
            self.navView.addSubview(self.navBlurView!)
        }
        
        self.backBtn = UIButton(type: .custom)
        self.backBtn.setImage(getImage("zl_navBack"), for: .normal)
        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navView.addSubview(self.backBtn)
        
        self.selectBtn = UIButton(type: .custom)
        self.selectBtn.setImage(getImage("zl_btn_circle"), for: .normal)
        self.selectBtn.setImage(getImage("zl_btn_selected"), for: .selected)
        self.selectBtn.zl_enlargeValidTouchArea(inset: 10)
        self.selectBtn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
        self.navView.addSubview(self.selectBtn)
        
        self.indexLabel = UILabel()
        self.indexLabel.backgroundColor = .indexLabelBgColor
        self.indexLabel.font = getFont(14)
        self.indexLabel.textColor = .white
        self.indexLabel.textAlignment = .center
        self.indexLabel.layer.cornerRadius = 25.0 / 2
        self.indexLabel.layer.masksToBounds = true
        self.indexLabel.isHidden = true
        self.selectBtn.addSubview(self.indexLabel)
        
        // collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.collectionView)
        
        ZLPhotoPreviewCell.zl_register(self.collectionView)
        ZLGifPreviewCell.zl_register(self.collectionView)
        ZLLivePhotoPreviewCell.zl_register(self.collectionView)
        ZLVideoPreviewCell.zl_register(self.collectionView)
        
        // bottom view
        self.bottomView = UIView()
        self.bottomView.backgroundColor = .bottomToolViewBgColor
        self.view.addSubview(self.bottomView)
        
        if let effect = config.bottomToolViewBlurEffect {
            self.bottomBlurView = UIVisualEffectView(effect: effect)
            self.bottomView.addSubview(self.bottomBlurView!)
        }
        
        if config.showSelectedPhotoPreview {
            let nav = self.navigationController as! ZLImageNavController
            self.selPhotoPreview = ZLPhotoPreviewSelectedView(selModels: nav.arrSelectedModels, currentShowModel: self.arrDataSources[self.currentIndex])
            self.selPhotoPreview?.selectBlock = { [weak self] (model) in
                self?.scrollToSelPreviewCell(model)
            }
            self.selPhotoPreview?.endSortBlock = { [weak self] (models) in
                self?.refreshCurrentCellIndex(models)
            }
            self.bottomView.addSubview(self.selPhotoPreview!)
        }
        
        func createBtn(_ title: String, _ action: Selector) -> UIButton {
            let btn = UIButton(type: .custom)
            btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.bottomToolViewBtnNormalTitleColor, for: .normal)
            btn.setTitleColor(.bottomToolViewBtnDisableTitleColor, for: .disabled)
            btn.addTarget(self, action: action, for: .touchUpInside)
            return btn
        }
        
        self.editBtn = createBtn(localLanguageTextValue(.edit), #selector(editBtnClick))
        self.editBtn.isHidden = (!config.allowEditImage && !config.allowEditVideo)
        self.bottomView.addSubview(self.editBtn)
        
        self.originalBtn = createBtn(localLanguageTextValue(.originalPhoto), #selector(originalPhotoClick))
        self.originalBtn.setImage(getImage("zl_btn_original_circle"), for: .normal)
        self.originalBtn.setImage(getImage("zl_btn_original_selected"), for: .selected)
        self.originalBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        self.originalBtn.isHidden = !(config.allowSelectOriginal && config.allowSelectImage)
        self.originalBtn.isSelected = (self.navigationController as! ZLImageNavController).isSelectedOriginal
        self.bottomView.addSubview(self.originalBtn)
        
        self.doneBtn = createBtn(localLanguageTextValue(.done), #selector(doneBtnClick))
        self.doneBtn.backgroundColor = .bottomToolViewBtnNormalBgColor
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        self.bottomView.addSubview(self.doneBtn)
        
        self.view.bringSubviewToFront(self.navView)
    }
    
    func addPopInteractiveTransition() {
        guard (self.navigationController?.viewControllers.count ?? 0 ) > 1 else {
            // 仅有当前vc一个时候，说明不是从相册进入，不添加交互动画
            return
        }
        self.popInteractiveTransition = ZLPhotoPreviewPopInteractiveTransition(viewController: self)
        self.popInteractiveTransition?.shouldStartTransition = { [weak self] (point) -> Bool in
            guard let `self` = self else { return false }
            if !self.hideNavView && (self.navView.frame.contains(point) || self.bottomView.frame.contains(point)) {
                return false
            }
            return true
        }
        self.popInteractiveTransition?.startTransition = { [weak self] in
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
        self.popInteractiveTransition?.cancelTransition = { [weak self] in
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
    
    func resetSubViewStatus() {
        let nav = self.navigationController as! ZLImageNavController
        let config = ZLPhotoConfiguration.default()
        let currentModel = self.arrDataSources[self.currentIndex]
        
        if (!config.allowMixSelect && currentModel.type == .video) || (!config.showSelectBtnWhenSingleSelect && config.maxSelectCount == 1) {
            self.selectBtn.isHidden = true
        } else {
            self.selectBtn.isHidden = false
        }
        self.selectBtn.isSelected = self.arrDataSources[self.currentIndex].isSelected
        self.resetIndexLabelStatus()
        
        guard self.showBottomViewAndSelectBtn else {
            self.selectBtn.isHidden = true
            self.bottomView.isHidden = true
            return
        }
        let selCount = nav.arrSelectedModels.count
        var doneTitle = localLanguageTextValue(.done)
        if selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        self.doneBtn.setTitle(doneTitle, for: .normal)
        
        self.selPhotoPreview?.isHidden = selCount == 0
        self.refreshBottomViewFrame()
        
        var hideEditBtn = true
        if selCount < config.maxSelectCount || nav.arrSelectedModels.contains(where: { $0 == currentModel }) {
            if config.allowEditImage && (currentModel.type == .image || (currentModel.type == .gif && !config.allowSelectGif) || (currentModel.type == .livePhoto && !config.allowSelectLivePhoto)) {
                hideEditBtn = false
            }
            if config.allowEditVideo && currentModel.type == .video && (selCount == 0 || (selCount == 1 && nav.arrSelectedModels.first == currentModel)) {
                hideEditBtn = false
            }
        }
        self.editBtn.isHidden = hideEditBtn
        
        if ZLPhotoConfiguration.default().allowSelectOriginal && ZLPhotoConfiguration.default().allowSelectImage {
            self.originalBtn.isHidden = !((currentModel.type == .image) || (currentModel.type == .livePhoto && !config.allowSelectLivePhoto) || (currentModel.type == .gif && !config.allowSelectGif))
        }
    }
    
    func resetIndexLabelStatus() {
        guard ZLPhotoConfiguration.default().showSelectedIndex else {
            self.indexLabel.isHidden = true
            return
        }
        let nav = self.navigationController as! ZLImageNavController
        if let index = nav.arrSelectedModels.firstIndex(where: { $0 == self.arrDataSources[self.currentIndex] }) {
            self.indexLabel.isHidden = false
            self.indexLabel.text = String(index + 1)
        } else {
            self.indexLabel.isHidden = true
        }
    }
    
    // MARK: btn actions
    
    @objc func backBtnClick() {
        self.backBlock?()
        let vc = self.navigationController?.popViewController(animated: true)
        if vc == nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func selectBtnClick() {
        let nav = self.navigationController as! ZLImageNavController
        let currentModel = self.arrDataSources[self.currentIndex]
        self.selectBtn.layer.removeAllAnimations()
        if currentModel.isSelected {
            currentModel.isSelected = false
            nav.arrSelectedModels.removeAll { $0 == currentModel }
            self.selPhotoPreview?.removeSelModel(model: currentModel)
        } else {
            self.selectBtn.layer.add(getSpringAnimation(), forKey: nil)
            if !canAddModel(currentModel, currentSelectCount: nav.arrSelectedModels.count, sender: self) {
                return
            }
            currentModel.isSelected = true
            nav.arrSelectedModels.append(currentModel)
            self.selPhotoPreview?.addSelModel(model: currentModel)
        }
        self.resetSubViewStatus()
    }
    
    @objc func editBtnClick() {
        let config = ZLPhotoConfiguration.default()
        let model = self.arrDataSources[self.currentIndex]
        let hud = ZLProgressHUD(style: config.hudStyle)
        
        if model.type == .image || (!config.allowSelectGif && model.type == .gif) || (!config.allowSelectLivePhoto && model.type == .livePhoto) {
            hud.show()
            ZLPhotoManager.fetchImage(for: model.asset, size: model.previewSize) { [weak self] (image, isDegraded) in
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
            var requestAvAssetID: PHImageRequestID?
            hud.show(timeout: 20)
            hud.timeoutBlock = { [weak self] in
                showAlertView(localLanguageTextValue(.timeout), self)
                if let _ = requestAvAssetID {
                    PHImageManager.default().cancelImageRequest(requestAvAssetID!)
                }
            }
            // fetch avasset
            requestAvAssetID = ZLPhotoManager.fetchAVAsset(forVideo: model.asset) { [weak self] (avAsset, _) in
                hud.hide()
                if let av = avAsset {
                    self?.showEditVideoVC(model: model, avAsset: av)
                } else {
                    showAlertView(localLanguageTextValue(.timeout), self)
                }
            }
        }
    }
    
    @objc func originalPhotoClick() {
        self.originalBtn.isSelected = !self.originalBtn.isSelected
        let nav = (self.navigationController as? ZLImageNavController)
        nav?.isSelectedOriginal = self.originalBtn.isSelected
        if nav?.arrSelectedModels.count == 0 {
            self.selectBtnClick()
        }
    }
    
    @objc func doneBtnClick() {
        let nav = self.navigationController as! ZLImageNavController
        let currentModel = self.arrDataSources[self.currentIndex]
        
        if self.autoSelectCurrentIfNotSelectAnyone {
            if nav.arrSelectedModels.isEmpty, canAddModel(currentModel, currentSelectCount: nav.arrSelectedModels.count, sender: self) {
                nav.arrSelectedModels.append(currentModel)
            }
            
            if !nav.arrSelectedModels.isEmpty {
                nav.selectImageBlock?()
            }
        } else {
            nav.selectImageBlock?()
        }
    }
    
    func scrollToSelPreviewCell(_ model: ZLPhotoModel) {
        guard let index = self.arrDataSources.lastIndex(of: model) else {
            return
        }
        self.collectionView.performBatchUpdates({
            self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }) { (_) in
            self.indexBeforOrientationChanged = self.currentIndex
            self.reloadCurrentCell()
        }
    }
    
    func refreshCurrentCellIndex(_ models: [ZLPhotoModel]) {
        let nav = self.navigationController as? ZLImageNavController
        nav?.arrSelectedModels.removeAll()
        nav?.arrSelectedModels.append(contentsOf: models)
        guard ZLPhotoConfiguration.default().showSelectedIndex else {
            return
        }
        self.resetIndexLabelStatus()
    }
    
    func tapPreviewCell() {
        self.hideNavView = !self.hideNavView
        let currentCell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0))
        if let cell = currentCell as? ZLVideoPreviewCell {
            if cell.isPlaying {
                self.hideNavView = true
            }
        }
        self.navView.isHidden = self.hideNavView
        self.bottomView.isHidden = self.showBottomViewAndSelectBtn ? self.hideNavView : true
    }
    
    func showEditImageVC(image: UIImage) {
        let model = self.arrDataSources[self.currentIndex]
        let nav = self.navigationController as! ZLImageNavController
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: image, editModel: model.editImageModel) { [weak self, weak nav] (ei, editImageModel) in
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
    
    func showEditVideoVC(model: ZLPhotoModel, avAsset: AVAsset) {
        let nav = self.navigationController as! ZLImageNavController
        let vc = ZLEditVideoViewController(avAsset: avAsset)
        vc.modalPresentationStyle = .fullScreen
        
        vc.editFinishBlock = { [weak self, weak nav] (url) in
            if let u = url {
                ZLPhotoManager.saveVideoToAlbum(url: u) { [weak self, weak nav] (suc, asset) in
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
        
        self.present(vc, animated: false, completion: nil)
    }
    
}


extension ZLPhotoPreviewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return nil
        }
        return self.popInteractiveTransition?.interactive == true ? ZLPhotoPreviewAnimatedTransition() : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.popInteractiveTransition?.interactive == true ? self.popInteractiveTransition : nil
    }
    
}


// scroll view delegate
extension ZLPhotoPreviewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.collectionView else {
            return
        }
        NotificationCenter.default.post(name: ZLPhotoPreviewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (self.view.bounds.width + ZLPhotoPreviewController.colItemSpacing)))
        page = max(0, min(page, self.arrDataSources.count-1))
        if page == self.currentIndex {
            return
        }
        self.currentIndex = page
        self.resetSubViewStatus()
        self.selPhotoPreview?.currentShowModelChanged(model: self.arrDataSources[self.currentIndex])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.indexBeforOrientationChanged = self.currentIndex
        let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0))
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
        return CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrDataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = ZLPhotoConfiguration.default()
        let model = self.arrDataSources[indexPath.row]
        
        let baseCell: ZLPreviewBaseCell
        
        if config.allowSelectGif, model.type == .gif {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLGifPreviewCell.zl_identifier(), for: indexPath) as! ZLGifPreviewCell
            
            cell.singleTapBlock = { [weak self] in
                self?.tapPreviewCell()
            }
            
            cell.model = model
            
            baseCell = cell
        } else if config.allowSelectLivePhoto, model.type == .livePhoto {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLLivePhotoPreviewCell.zl_identifier(), for: indexPath) as! ZLLivePhotoPreviewCell
            
            cell.model = model
            
            baseCell = cell
        } else if config.allowSelectVideo, model.type == .video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLVideoPreviewCell.zl_identifier(), for: indexPath) as! ZLVideoPreviewCell
            
            cell.model = model
            
            baseCell = cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLPhotoPreviewCell.zl_identifier(), for: indexPath) as! ZLPhotoPreviewCell

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
        if let c = cell as? ZLPreviewBaseCell {
            c.resetSubViewStatusWhenCellEndDisplay()
        }
    }
    
}


/// 下方显示的已选择照片列表

class ZLPhotoPreviewSelectedView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    var bottomBlurView: UIVisualEffectView?
    
    var collectionView: UICollectionView!
    
    var arrSelectedModels: [ZLPhotoModel]
    
    var currentShowModel: ZLPhotoModel
    
    var selectBlock: ( (ZLPhotoModel) -> Void )?
    
    var endSortBlock: ( ([ZLPhotoModel]) -> Void )?
    
    var isDraging = false
    
    init(selModels: [ZLPhotoModel], currentShowModel: ZLPhotoModel) {
        self.arrSelectedModels = selModels
        self.currentShowModel = currentShowModel
        super.init(frame: .zero)
        self.setupUI()
    }
    
    func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
        self.addSubview(self.collectionView)
        
        ZLPhotoPreviewSelectedViewCell.zl_register(self.collectionView)
        
        if #available(iOS 11.0, *) {
            self.collectionView.dragDelegate = self
            self.collectionView.dropDelegate = self
            self.collectionView.dragInteractionEnabled = true
            self.collectionView.isSpringLoaded = true
        } else {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
            self.collectionView.addGestureRecognizer(longPressGesture)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bottomBlurView?.frame = self.bounds
        self.collectionView.frame = CGRect(x: 0, y: 10, width: self.bounds.width, height: 80)
        if let index = self.arrSelectedModels.firstIndex(where: { $0 == self.currentShowModel }) {
            self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func currentShowModelChanged(model: ZLPhotoModel) {
        guard self.currentShowModel != model else {
            return
        }
        self.currentShowModel = model
        
        if let index = self.arrSelectedModels.firstIndex(where: { $0 == self.currentShowModel }) {
            self.collectionView.performBatchUpdates({
                self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
            }) { (_) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        } else {
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
    }
    
    func addSelModel(model: ZLPhotoModel) {
        self.arrSelectedModels.append(model)
        let ip = IndexPath(row: self.arrSelectedModels.count-1, section: 0)
        self.collectionView.insertItems(at: [ip])
        self.collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: true)
    }
    
    func removeSelModel(model: ZLPhotoModel) {
        guard let index = self.arrSelectedModels.firstIndex(where: { $0 == model }) else {
            return
        }
        self.arrSelectedModels.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    func refreshCell(for model: ZLPhotoModel) {
        guard let index = self.arrSelectedModels.firstIndex(where: { $0 == model }) else {
            return
        }
        self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    // MARK: iOS10 拖动
    @objc func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                return
            }
            self.isDraging = true
            self.collectionView.beginInteractiveMovementForItem(at: indexPath)
        } else if gesture.state == .changed {
            self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: self.collectionView))
        } else if gesture.state == .ended {
            self.isDraging = false
            self.collectionView.endInteractiveMovement()
            self.endSortBlock?(self.arrSelectedModels)
        } else {
            self.isDraging = false
            self.collectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveModel = self.arrSelectedModels[sourceIndexPath.row]
        self.arrSelectedModels.remove(at: sourceIndexPath.row)
        self.arrSelectedModels.insert(moveModel, at: destinationIndexPath.row)
    }
    
    // MARK: iOS11 拖动
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        self.isDraging = true
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
        self.isDraging = false
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
            
            self.endSortBlock?(self.arrSelectedModels)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrSelectedModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLPhotoPreviewSelectedViewCell.zl_identifier(), for: indexPath) as! ZLPhotoPreviewSelectedViewCell
        
        let m = self.arrSelectedModels[indexPath.row]
        cell.model = m
        
        if m == self.currentShowModel {
            cell.layer.borderWidth = 4
        } else {
            cell.layer.borderWidth =  0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !self.isDraging else {
            return
        }
        let m = self.arrSelectedModels[indexPath.row]
        self.currentShowModel = m
        self.collectionView.performBatchUpdates({
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }) { (_) in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
        self.selectBlock?(m)
    }
    
}


class ZLPhotoPreviewSelectedViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var imageIdentifier: String = ""
    
    var tagImageView: UIImageView!
    
    var tagLabel: UILabel!
    
    var model: ZLPhotoModel! {
        didSet {
            self.configureCell()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.bottomToolViewBtnNormalBgColor.cgColor
        
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        
        self.tagImageView = UIImageView()
        self.tagImageView.contentMode = .scaleAspectFit
        self.tagImageView.clipsToBounds = true
        self.contentView.addSubview(self.tagImageView)
        
        self.tagLabel = UILabel()
        self.tagLabel.font = getFont(13)
        self.tagLabel.textColor = .white
        self.contentView.addSubview(self.tagLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.tagImageView.frame = CGRect(x: 5, y: self.bounds.height-25, width: 20, height: 20)
        self.tagLabel.frame = CGRect(x: 5, y: self.bounds.height - 25, width: self.bounds.width-10, height: 20)
    }
    
    func configureCell() {
        let size = CGSize(width: self.bounds.width * 1.5, height: self.bounds.height * 1.5)
        
        if self.imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.imageRequestID)
        }
        
        if self.model.type == .video {
            self.tagImageView.isHidden = false
            self.tagImageView.image = getImage("zl_video")
            self.tagLabel.isHidden = true
        } else if ZLPhotoConfiguration.default().allowSelectGif, self.model.type == .gif {
            self.tagImageView.isHidden = true
            self.tagLabel.isHidden = false
            self.tagLabel.text = "GIF"
        } else if ZLPhotoConfiguration.default().allowSelectLivePhoto, self.model.type == .livePhoto {
            self.tagImageView.isHidden = false
            self.tagImageView.image = getImage("zl_livePhoto")
            self.tagLabel.isHidden = true
        } else {
            if let _ =  self.model.editImage {
                self.tagImageView.isHidden = false
                self.tagImageView.image = getImage("zl_editImage_tag")
            } else {
                self.tagImageView.isHidden = true
                self.tagLabel.isHidden = true
            }
        }
        
        self.imageIdentifier = self.model.ident
        self.imageView.image = nil
        
        if let ei = self.model.editImage {
            self.imageView.image = ei
        } else {
            self.imageRequestID = ZLPhotoManager.fetchImage(for: self.model.asset, size: size, completion: { [weak self] (image, isDegraded) in
                if self?.imageIdentifier == self?.model.ident {
                    self?.imageView.image = image
                }
            })
        }
    }
    
}
