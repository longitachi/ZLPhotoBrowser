//
//  ZLThumbnailViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/19.
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

extension ZLThumbnailViewController {
    
    private enum SlideSelectType {
        case none
        case select
        case cancel
    }
    
    private enum AutoScrollDirection {
        case none
        case top
        case bottom
    }
    
}

class ZLThumbnailViewController: UIViewController {
    
    private var albumList: ZLAlbumListModel
    
    private var externalNavView: ZLExternalAlbumListNavView?
    
    private var embedNavView: ZLEmbedAlbumListNavView?
    
    private var embedAlbumListView: ZLEmbedAlbumListView?
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.bottomToolViewBgColor
        return view
    }()
    
    private var bottomBlurView: UIVisualEffectView?
    
    private var limitAuthTipsView: ZLLimitedAuthorityTipsView?
    
    private lazy var previewBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.preview), #selector(previewBtnClick))
        btn.titleLabel?.lineBreakMode = .byCharWrapping
        btn.titleLabel?.numberOfLines = 2
        btn.contentHorizontalAlignment = .left
        btn.isHidden = !ZLPhotoConfiguration.default().showPreviewButtonInAlbum
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
        btn.isHidden = !(ZLPhotoConfiguration.default().allowSelectOriginal && ZLPhotoConfiguration.default().allowSelectImage)
        btn.isSelected = (navigationController as? ZLImageNavController)?.isSelectedOriginal ?? false
        return btn
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.done), #selector(doneBtnClick), true)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    /// 所有滑动经过的indexPath
    private lazy var arrSlideIndexPaths: [IndexPath] = []
    
    /// 所有滑动经过的indexPath的初始选择状态
    private lazy var dicOriSelectStatus: [IndexPath: Bool] = [:]
    
    private var isLayoutOK = false
    
    /// 设备旋转前第一个可视indexPath
    private var firstVisibleIndexPathBeforeRotation: IndexPath?
    
    /// 是否触发了横竖屏切换
    private var isSwitchOrientation = false
    
    /// 是否开始出发滑动选择
    private var beginPanSelect = false
    
    /// 滑动选择 或 取消
    /// 当初始滑动的cell处于未选择状态，则开始选择，反之，则开始取消选择
    private var panSelectType: ZLThumbnailViewController.SlideSelectType = .none
    
    /// 开始滑动的indexPath
    private var beginSlideIndexPath: IndexPath?
    
    /// 最后滑动经过的index，开始的indexPath不计入
    /// 优化拖动手势计算，避免单个cell中冗余计算多次
    private var lastSlideIndex: Int?
    
    /// 预览所选择图片，手势返回时候不调用scrollToIndex
    private var isPreviewPush = false
    
    /// 拍照后置为true，需要刷新相册列表
    private var hasTakeANewAsset = false
    
    private var slideCalculateQueue = DispatchQueue(label: "com.ZLhotoBrowser.slide")
    
    private var autoScrollTimer: CADisplayLink?
    
    private var lastPanUpdateTime = CACurrentMediaTime()
    
    private let showLimitAuthTipsView: Bool = {
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited, ZLPhotoConfiguration.default().showEnterSettingTips {
            return true
        } else {
            return false
        }
    }()
    
    private var autoScrollInfo: (direction: AutoScrollDirection, speed: CGFloat) = (.none, 0)
    
    /// 照相按钮+添加图片按钮的数量
    /// the count of addPhotoButton & cameraButton
    private var offset: Int {
        if #available(iOS 14, *) {
            return showAddPhotoCell.zl.intValue + showCameraCell.zl.intValue
        } else {
            return showCameraCell.zl.intValue
        }
    }
    
    private lazy var panGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(slideSelectAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .zl.thumbnailBgColor
        view.dataSource = self
        view.delegate = self
        view.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .always
        }
        ZLCameraCell.zl.register(view)
        ZLThumbnailPhotoCell.zl.register(view)
        ZLAddPhotoCell.zl.register(view)
        
        return view
    }()
    
    var arrDataSources: [ZLPhotoModel] = []
    
    var showCameraCell: Bool {
        if ZLPhotoConfiguration.default().allowTakePhotoInLibrary, self.albumList.isCameraRoll {
            return true
        }
        return false
    }
    
    @available(iOS 14, *)
    var showAddPhotoCell: Bool {
        PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited && ZLPhotoConfiguration.default().showAddPhotoButton && albumList.isCameraRoll
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ZLPhotoUIConfiguration.default().statusBarStyle
    }
    
    deinit {
        zl_debugPrint("ZLThumbnailViewController deinit")
        cleanTimer()
    }
    
    init(albumList: ZLAlbumListModel) {
        self.albumList = albumList
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        if ZLPhotoConfiguration.default().allowSlideSelect {
            view.addGestureRecognizer(panGes)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
        
        loadPhotos()
        
        // Register for the album change notification when the status is limited, because the photoLibraryDidChange method will be repeated multiple times each time the album changes, causing the interface to refresh multiple times. So the album changes are not monitored in other authority.
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        resetBottomToolBtnStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isLayoutOK = true
        isPreviewPush = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let navViewNormalH: CGFloat = 44
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        var collectionViewInsetTop: CGFloat = 20
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
            collectionViewInsetTop = navViewNormalH
        } else {
            collectionViewInsetTop += navViewNormalH
        }
        
        let navViewFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: insets.top + navViewNormalH)
        externalNavView?.frame = navViewFrame
        embedNavView?.frame = navViewFrame
        
        embedAlbumListView?.frame = CGRect(x: 0, y: navViewFrame.maxY, width: view.bounds.width, height: view.bounds.height - navViewFrame.maxY)
        
        let showBottomToolBtns = showBottomToolBar()
        
        let bottomViewH: CGFloat
        if showLimitAuthTipsView, showBottomToolBtns {
            bottomViewH = ZLLayout.bottomToolViewH + ZLLimitedAuthorityTipsView.height
        } else if showLimitAuthTipsView {
            bottomViewH = ZLLimitedAuthorityTipsView.height
        } else if showBottomToolBtns {
            bottomViewH = ZLLayout.bottomToolViewH
        } else {
            bottomViewH = 0
        }
        
        let totalWidth = view.frame.width - insets.left - insets.right
        collectionView.frame = CGRect(x: insets.left, y: 0, width: totalWidth, height: view.frame.height)
        collectionView.contentInset = UIEdgeInsets(top: collectionViewInsetTop, left: 0, bottom: bottomViewH, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: 0, bottom: bottomViewH, right: 0)
        
        if !isLayoutOK {
            scrollToBottom()
        } else if isSwitchOrientation {
            isSwitchOrientation = false
            collectionView.performBatchUpdates(nil) { _ in
                if let firstVisibleIndexPathBeforeRotation = self.firstVisibleIndexPathBeforeRotation {
                    self.collectionView.scrollToItem(at: firstVisibleIndexPathBeforeRotation, at: .top, animated: false)
                }
            }
        }
        
        guard showBottomToolBtns || showLimitAuthTipsView else { return }
        
        let btnH = ZLLayout.bottomToolBtnH
        
        bottomView.frame = CGRect(x: 0, y: view.frame.height - insets.bottom - bottomViewH, width: view.bounds.width, height: bottomViewH + insets.bottom)
        bottomBlurView?.frame = bottomView.bounds
        
        if showLimitAuthTipsView {
            limitAuthTipsView?.frame = CGRect(x: 0, y: 0, width: bottomView.bounds.width, height: ZLLimitedAuthorityTipsView.height)
        }
        
        if showBottomToolBtns {
            let btnMaxWidth = (bottomView.bounds.width - 30) / 3
            
            let btnY = showLimitAuthTipsView ? ZLLimitedAuthorityTipsView.height + ZLLayout.bottomToolBtnY : ZLLayout.bottomToolBtnY
            let previewTitle = localLanguageTextValue(.preview)
            let previewBtnW = previewTitle.zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width
            previewBtn.frame = CGRect(x: 15, y: btnY, width: min(btnMaxWidth, previewBtnW), height: btnH)
            
            let originalTitle = localLanguageTextValue(.originalPhoto)
            let originBtnW = originalTitle.zl.boundingRect(
                font: ZLLayout.bottomToolTitleFont,
                limitSize: CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: 30
                )
            ).width + (originalBtn.currentImage?.size.width ?? 18) + 12
            let originBtnMaxW = min(btnMaxWidth, originBtnW)
            originalBtn.frame = CGRect(x: (bottomView.bounds.width - originBtnMaxW) / 2 - 5, y: btnY, width: originBtnMaxW, height: btnH)
            
            refreshDoneBtnFrame()
        }
    }
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = true
        edgesForExtendedLayout = .all
        view.backgroundColor = .zl.thumbnailBgColor
        
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        
        if let effect = ZLPhotoUIConfiguration.default().bottomViewBlurEffectOfAlbumList {
            bottomBlurView = UIVisualEffectView(effect: effect)
            bottomView.addSubview(bottomBlurView!)
        }
        
        if showLimitAuthTipsView {
            limitAuthTipsView = ZLLimitedAuthorityTipsView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: ZLLimitedAuthorityTipsView.height))
            bottomView.addSubview(limitAuthTipsView!)
        }
        
        bottomView.addSubview(previewBtn)
        bottomView.addSubview(originalBtn)
        bottomView.addSubview(doneBtn)
        
        setupNavView()
    }
    
    private func setupNavView() {
        if ZLPhotoUIConfiguration.default().style == .embedAlbumList {
            embedNavView = ZLEmbedAlbumListNavView(title: albumList.title)
            
            embedNavView?.selectAlbumBlock = { [weak self] in
                if self?.embedAlbumListView?.isHidden == true {
                    self?.embedAlbumListView?.show(reloadAlbumList: self?.hasTakeANewAsset ?? false)
                    self?.hasTakeANewAsset = false
                } else {
                    self?.embedAlbumListView?.hide()
                }
            }
            
            embedNavView?.cancelBlock = { [weak self] in
                let nav = self?.navigationController as? ZLImageNavController
                nav?.dismiss(animated: true, completion: {
                    nav?.cancelBlock?()
                })
            }
            
            view.addSubview(embedNavView!)
            
            embedAlbumListView = ZLEmbedAlbumListView(selectedAlbum: albumList)
            embedAlbumListView?.isHidden = true
            
            embedAlbumListView?.selectAlbumBlock = { [weak self] album in
                guard self?.albumList != album else {
                    return
                }
                self?.albumList = album
                self?.embedNavView?.title = album.title
                self?.loadPhotos()
                self?.embedNavView?.reset()
            }
            
            embedAlbumListView?.hideBlock = { [weak self] in
                self?.embedNavView?.reset()
            }
            
            view.addSubview(embedAlbumListView!)
        } else if ZLPhotoUIConfiguration.default().style == .externalAlbumList {
            externalNavView = ZLExternalAlbumListNavView(title: albumList.title)
            
            externalNavView?.backBlock = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            
            externalNavView?.cancelBlock = { [weak self] in
                let nav = self?.navigationController as? ZLImageNavController
                nav?.cancelBlock?()
                nav?.dismiss(animated: true, completion: nil)
            }
            
            view.addSubview(externalNavView!)
        }
    }
    
    private func createBtn(_ title: String, _ action: Selector, _ isDone: Bool = false) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(
            isDone ? .zl.bottomToolViewDoneBtnNormalTitleColor : .zl.bottomToolViewBtnNormalTitleColor,
            for: .normal
        )
        btn.setTitleColor(
            isDone ? .zl.bottomToolViewDoneBtnDisableTitleColor : .zl.bottomToolViewBtnDisableTitleColor,
            for: .disabled
        )
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    private func loadPhotos() {
        guard let nav = navigationController as? ZLImageNavController else {
            return
        }
        
        if albumList.models.isEmpty {
            let hud = ZLProgressHUD(style: ZLPhotoUIConfiguration.default().hudStyle)
            hud.show()
            DispatchQueue.global().async {
                self.albumList.refetchPhotos()
                ZLMainAsync {
                    self.arrDataSources.removeAll()
                    self.arrDataSources.append(contentsOf: self.albumList.models)
                    markSelected(source: &self.arrDataSources, selected: &nav.arrSelectedModels)
                    hud.hide()
                    self.collectionView.reloadData()
                    self.scrollToBottom()
                }
            }
        } else {
            arrDataSources.removeAll()
            arrDataSources.append(contentsOf: albumList.models)
            markSelected(source: &arrDataSources, selected: &nav.arrSelectedModels)
            collectionView.reloadData()
            scrollToBottom()
        }
    }
    
    private func showBottomToolBar() -> Bool {
        let config = ZLPhotoConfiguration.default()
        let condition1 = config.editAfterSelectThumbnailImage &&
            config.maxSelectCount == 1 &&
            (config.allowEditImage || config.allowEditVideo)
        let condition2 = config.allowPreviewPhotos && config.maxSelectCount == 1 && !config.showSelectBtnWhenSingleSelect
        if condition1 || condition2 {
            return false
        }
        return true
    }
    
    // MARK: btn actions
    
    @objc private func previewBtnClick() {
        guard let nav = navigationController as? ZLImageNavController else {
            zlLoggerInDebug("Navigation controller is null")
            return
        }
        let vc = ZLPhotoPreviewController(photos: nav.arrSelectedModels, index: 0)
        show(vc, sender: nil)
    }
    
    @objc private func originalPhotoClick() {
        originalBtn.isSelected.toggle()
        (navigationController as? ZLImageNavController)?.isSelectedOriginal = originalBtn.isSelected
    }
    
    @objc private func doneBtnClick() {
        let nav = navigationController as? ZLImageNavController
        if let block = ZLPhotoConfiguration.default().operateBeforeDoneAction {
            block(self) { [weak nav] in
                nav?.selectImageBlock?()
            }
        } else {
            nav?.selectImageBlock?()
        }
    }
    
    @objc private func deviceOrientationChanged(_ notify: Notification) {
        let pInView = collectionView.convert(CGPoint(x: 100, y: 100), from: view)
        firstVisibleIndexPathBeforeRotation = collectionView.indexPathForItem(at: pInView)
        isSwitchOrientation = true
    }
    
    @objc private func slideSelectAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return
        }
        let config = ZLPhotoConfiguration.default()
        let nav = navigationController as! ZLImageNavController
        
        let cell = collectionView.cellForItem(at: indexPath) as? ZLThumbnailPhotoCell
        let asc = config.sortAscending
        
        if pan.state == .began {
            beginPanSelect = (cell != nil)
            
            if beginPanSelect {
                let index = asc ? indexPath.row : indexPath.row - offset
                
                let m = arrDataSources[index]
                panSelectType = m.isSelected ? .cancel : .select
                beginSlideIndexPath = indexPath
                
                if !m.isSelected, nav.arrSelectedModels.count < config.maxSelectCount, canAddModel(m, currentSelectCount: nav.arrSelectedModels.count, sender: self) {
                    if shouldDirectEdit(m) {
                        panSelectType = .none
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
                refreshCellIndexAndMaskView()
                resetBottomToolBtnStatus()
                lastSlideIndex = indexPath.row
            }
        } else if pan.state == .changed {
            autoScrollWhenSlideSelect(pan)
            
            if !beginPanSelect || indexPath.row == lastSlideIndex || panSelectType == .none || cell == nil {
                return
            }
            guard let beginIndexPath = beginSlideIndexPath else {
                return
            }
            lastPanUpdateTime = CACurrentMediaTime()
            
            let visiblePaths = collectionView.indexPathsForVisibleItems
            slideCalculateQueue.async {
                self.lastSlideIndex = indexPath.row
                let minIndex = min(indexPath.row, beginIndexPath.row)
                let maxIndex = max(indexPath.row, beginIndexPath.row)
                let minIsBegin = minIndex == beginIndexPath.row
                
                var i = beginIndexPath.row
                while minIsBegin ? i <= maxIndex : i >= minIndex {
                    if i != beginIndexPath.row {
                        let p = IndexPath(row: i, section: 0)
                        if !self.arrSlideIndexPaths.contains(p) {
                            self.arrSlideIndexPaths.append(p)
                            let index = asc ? i : i - self.offset
                            let m = self.arrDataSources[index]
                            self.dicOriSelectStatus[p] = m.isSelected
                        }
                    }
                    i += (minIsBegin ? 1 : -1)
                }
                
                var selectedArrHasChange = false
                
                for path in self.arrSlideIndexPaths {
                    if !visiblePaths.contains(path) {
                        continue
                    }
                    let index = asc ? path.row : path.row - self.offset
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
                        if let index = nav.arrSelectedModels.firstIndex(where: { $0 == m }) {
                            nav.arrSelectedModels.remove(at: index)
                            selectedArrHasChange = true
                        }
                    } else {
                        if !nav.arrSelectedModels.contains(where: { $0 == m }) {
                            nav.arrSelectedModels.append(m)
                            selectedArrHasChange = true
                        }
                    }
                    
                    ZLMainAsync {
                        let c = self.collectionView.cellForItem(at: path) as? ZLThumbnailPhotoCell
                        c?.btnSelect.isSelected = m.isSelected
                    }
                }
                
                if selectedArrHasChange {
                    ZLMainAsync {
                        self.refreshCellIndexAndMaskView()
                        self.resetBottomToolBtnStatus()
                    }
                }
            }
        } else if pan.state == .ended || pan.state == .cancelled {
            cleanTimer()
            panSelectType = .none
            arrSlideIndexPaths.removeAll()
            dicOriSelectStatus.removeAll()
            resetBottomToolBtnStatus()
        }
    }
    
    private func autoScrollWhenSlideSelect(_ pan: UIPanGestureRecognizer) {
        guard ZLPhotoConfiguration.default().autoScrollWhenSlideSelectIsActive else {
            return
        }
        let arrSel = (navigationController as? ZLImageNavController)?.arrSelectedModels ?? []
        guard arrSel.count < ZLPhotoConfiguration.default().maxSelectCount else {
            // Stop auto scroll when reach the max select count.
            cleanTimer()
            return
        }
        
        let top = ((embedNavView?.frame.height ?? externalNavView?.frame.height) ?? 44) + 30
        let bottom = bottomView.frame.minY - 30
        
        let point = pan.location(in: view)
        
        var diff: CGFloat = 0
        var direction: AutoScrollDirection = .none
        if point.y < top {
            diff = top - point.y
            direction = .top
        } else if point.y > bottom {
            diff = point.y - bottom
            direction = .bottom
        } else {
            autoScrollInfo = (.none, 0)
            cleanTimer()
            return
        }
        
        guard diff > 0 else { return }
        
        let s = min(diff, 60) / 60 * ZLPhotoConfiguration.default().autoScrollMaxSpeed
        
        autoScrollInfo = (direction, s)
        
        if autoScrollTimer == nil {
            cleanTimer()
            autoScrollTimer = CADisplayLink(target: ZLWeakProxy(target: self), selector: #selector(autoScrollAction))
            autoScrollTimer?.add(to: RunLoop.current, forMode: .common)
        }
    }
    
    private func cleanTimer() {
        autoScrollTimer?.remove(from: RunLoop.current, forMode: .common)
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    @objc private func autoScrollAction() {
        guard autoScrollInfo.direction != .none else { return }
        let duration = CGFloat(autoScrollTimer?.duration ?? 1 / 60)
        if CACurrentMediaTime() - lastPanUpdateTime > 0.2 {
            // Finger may be not moved in slide selection mode
            slideSelectAction(panGes)
        }
        let distance = autoScrollInfo.speed * duration
        let offset = collectionView.contentOffset
        let inset = collectionView.contentInset
        if autoScrollInfo.direction == .top, offset.y + inset.top > distance {
            collectionView.contentOffset = CGPoint(x: 0, y: offset.y - distance)
        } else if autoScrollInfo.direction == .bottom, offset.y + collectionView.bounds.height + distance - inset.bottom < collectionView.contentSize.height {
            collectionView.contentOffset = CGPoint(x: 0, y: offset.y + distance)
        }
    }
    
    private func resetBottomToolBtnStatus() {
        guard showBottomToolBar() else { return }
        guard let nav = navigationController as? ZLImageNavController else {
            zlLoggerInDebug("Navigation controller is null")
            return
        }
        var doneTitle = localLanguageTextValue(.done)
        if ZLPhotoConfiguration.default().showSelectCountOnDoneBtn,
           nav.arrSelectedModels.count > 0
        {
            doneTitle += "(" + String(nav.arrSelectedModels.count) + ")"
        }
        if nav.arrSelectedModels.count > 0 {
            previewBtn.isEnabled = true
            doneBtn.isEnabled = true
            doneBtn.setTitle(doneTitle, for: .normal)
            doneBtn.backgroundColor = .zl.bottomToolViewBtnNormalBgColor
        } else {
            previewBtn.isEnabled = false
            doneBtn.isEnabled = false
            doneBtn.setTitle(doneTitle, for: .normal)
            doneBtn.backgroundColor = .zl.bottomToolViewBtnDisableBgColor
        }
        originalBtn.isSelected = nav.isSelectedOriginal
        refreshDoneBtnFrame()
    }
    
    private func refreshDoneBtnFrame() {
        let selCount = (navigationController as? ZLImageNavController)?.arrSelectedModels.count ?? 0
        var doneTitle = localLanguageTextValue(.done)
        if ZLPhotoConfiguration.default().showSelectCountOnDoneBtn, selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        let doneBtnW = doneTitle.zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 20
        
        let btnY = showLimitAuthTipsView ? ZLLimitedAuthorityTipsView.height + ZLLayout.bottomToolBtnY : ZLLayout.bottomToolBtnY
        doneBtn.frame = CGRect(x: bottomView.bounds.width - doneBtnW - 15, y: btnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
    }
    
    private func scrollToBottom() {
        guard ZLPhotoConfiguration.default().sortAscending, arrDataSources.count > 0 else {
            return
        }
        let index = arrDataSources.count - 1 + offset
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: false)
    }
    
    private func showCamera() {
        let config = ZLPhotoConfiguration.default()
        if config.useCustomCamera {
            let camera = ZLCustomCamera()
            camera.takeDoneBlock = { [weak self] image, videoUrl in
                self?.save(image: image, videoUrl: videoUrl)
            }
            showDetailViewController(camera, sender: nil)
        } else {
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                showAlertView(localLanguageTextValue(.cameraUnavailable), self)
            } else if ZLPhotoManager.hasCameraAuthority() {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.videoQuality = .typeHigh
                picker.sourceType = .camera
                picker.cameraFlashMode = config.cameraConfiguration.flashMode.imagePickerFlashMode
                var mediaTypes = [String]()
                if config.allowTakePhoto {
                    mediaTypes.append("public.image")
                }
                if config.allowRecordVideo {
                    mediaTypes.append("public.movie")
                }
                picker.mediaTypes = mediaTypes
                picker.videoMaximumDuration = TimeInterval(config.maxRecordDuration)
                showDetailViewController(picker, sender: nil)
            } else {
                showAlertView(String(format: localLanguageTextValue(.noCameraAuthority), getAppName()), self)
            }
        }
    }
    
    private func save(image: UIImage?, videoUrl: URL?) {
        let hud = ZLProgressHUD(style: ZLPhotoUIConfiguration.default().hudStyle)
        if let image = image {
            hud.show()
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] suc, asset in
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
            ZLPhotoManager.saveVideoToAlbum(url: videoUrl) { [weak self] suc, asset in
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
    
    private func handleDataArray(newModel: ZLPhotoModel) {
        hasTakeANewAsset = true
        albumList.refreshResult()
        
        let nav = navigationController as? ZLImageNavController
        let config = ZLPhotoConfiguration.default()
        var insertIndex = 0
        
        if config.sortAscending {
            insertIndex = arrDataSources.count
            arrDataSources.append(newModel)
        } else {
            // 保存拍照的照片或者视频，说明肯定有camera cell
            insertIndex = offset
            arrDataSources.insert(newModel, at: 0)
        }
        
        var canSelect = true
        // If mixed selection is not allowed, and the newModel type is video, it will not be selected.
        if !config.allowMixSelect, newModel.type == .video {
            canSelect = false
        }
        if canSelect, canAddModel(newModel, currentSelectCount: nav?.arrSelectedModels.count ?? 0, sender: self, showAlert: false) {
            if !shouldDirectEdit(newModel) {
                newModel.isSelected = true
                nav?.arrSelectedModels.append(newModel)
            }
        }
        
        let insertIndexPath = IndexPath(row: insertIndex, section: 0)
        collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: [insertIndexPath])
        }) { _ in
            self.collectionView.scrollToItem(at: insertIndexPath, at: .centeredVertically, animated: true)
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
        
        resetBottomToolBtnStatus()
    }
    
    private func showEditImageVC(model: ZLPhotoModel) {
        guard let nav = navigationController as? ZLImageNavController else {
            zlLoggerInDebug("Navigation controller is null")
            return
        }
        
        let hud = ZLProgressHUD(style: ZLPhotoUIConfiguration.default().hudStyle)
        hud.show()
        
        hud.show()
        ZLPhotoManager.fetchImage(for: model.asset, size: model.previewSize) { [weak self, weak nav] image, isDegraded in
            if !isDegraded {
                if let image = image {
                    ZLEditImageViewController.showEditImageVC(parentVC: self, image: image, editModel: model.editImageModel) { [weak nav] ei, editImageModel in
                        model.isSelected = true
                        model.editImage = ei
                        model.editImageModel = editImageModel
                        nav?.arrSelectedModels.append(model)
                        nav?.selectImageBlock?()
                    }
                } else {
                    showAlertView(localLanguageTextValue(.imageLoadFailed), self)
                }
                hud.hide()
            }
        }
    }
    
    private func showEditVideoVC(model: ZLPhotoModel) {
        let nav = navigationController as? ZLImageNavController
        let hud = ZLProgressHUD(style: ZLPhotoUIConfiguration.default().hudStyle)
        
        var requestAvAssetID: PHImageRequestID?
        
        hud.show(timeout: ZLPhotoConfiguration.default().timeout)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self)
            if let requestAvAssetID = requestAvAssetID {
                PHImageManager.default().cancelImageRequest(requestAvAssetID)
            }
        }
        
        func inner_showEditVideoVC(_ avAsset: AVAsset) {
            let vc = ZLEditVideoViewController(avAsset: avAsset)
            vc.editFinishBlock = { [weak self, weak nav] url in
                if let url = url {
                    ZLPhotoManager.saveVideoToAlbum(url: url) { [weak self, weak nav] suc, asset in
                        if suc, let asset = asset {
                            let m = ZLPhotoModel(asset: asset)
                            m.isSelected = true
                            nav?.arrSelectedModels.append(m)
                            nav?.selectImageBlock?()
                        } else {
                            showAlertView(localLanguageTextValue(.saveVideoError), self)
                        }
                    }
                } else {
                    nav?.arrSelectedModels.append(model)
                    nav?.selectImageBlock?()
                }
            }
            vc.modalPresentationStyle = .fullScreen
            showDetailViewController(vc, sender: nil)
        }
        
        // 提前fetch一下 avasset
        requestAvAssetID = ZLPhotoManager.fetchAVAsset(forVideo: model.asset) { [weak self] avAsset, _ in
            hud.hide()
            if let avAsset = avAsset {
                inner_showEditVideoVC(avAsset)
            } else {
                showAlertView(localLanguageTextValue(.timeout), self)
            }
        }
    }
}

// MARK: Gesture delegate

extension ZLThumbnailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let config = ZLPhotoConfiguration.default()
        if (config.maxSelectCount == 1 && !config.showSelectBtnWhenSingleSelect) || embedAlbumListView?.isHidden == false {
            return false
        }
        return true
    }
    
}

// MARK: CollectionView Delegate & DataSource

extension ZLThumbnailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ZLLayout.thumbCollectionViewItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ZLLayout.thumbCollectionViewLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let defaultCount = CGFloat(ZLPhotoConfiguration.default().columnCount)
        var columnCount: CGFloat = deviceIsiPad() ? (defaultCount + 2) : defaultCount
        if UIApplication.shared.statusBarOrientation.isLandscape {
            columnCount += 2
        }
        let totalW = collectionView.bounds.width - (columnCount - 1) * ZLLayout.thumbCollectionViewItemSpacing
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrDataSources.count + offset
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = ZLPhotoConfiguration.default()
        if showCameraCell, (config.sortAscending && indexPath.row == arrDataSources.count) || (!config.sortAscending && indexPath.row == 0) {
            // camera cell
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLCameraCell.zl.identifier, for: indexPath) as! ZLCameraCell
            
            if config.showCaptureImageOnTakePhotoBtn {
                cell.startCapture()
            }
            
            return cell
        }
        
        if #available(iOS 14, *) {
            if self.showAddPhotoCell, (config.sortAscending && indexPath.row == self.arrDataSources.count - 1 + self.offset) || (!config.sortAscending && indexPath.row == self.offset - 1) {
                return collectionView.dequeueReusableCell(withReuseIdentifier: ZLAddPhotoCell.zl.identifier, for: indexPath)
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLThumbnailPhotoCell.zl.identifier, for: indexPath) as! ZLThumbnailPhotoCell
        
        let model: ZLPhotoModel
        
        if !config.sortAscending {
            model = arrDataSources[indexPath.row - offset]
        } else {
            model = arrDataSources[indexPath.row]
        }
        
        let nav = navigationController as? ZLImageNavController
        cell.selectedBlock = { [weak self, weak nav, weak cell] isSelected in
            if !isSelected {
                let currentSelectCount = nav?.arrSelectedModels.count ?? 0
                guard canAddModel(model, currentSelectCount: currentSelectCount, sender: self) else {
                    return
                }
                if self?.shouldDirectEdit(model) == false {
                    model.isSelected = true
                    nav?.arrSelectedModels.append(model)
                    cell?.btnSelect.isSelected = true
                    self?.refreshCellIndexAndMaskView()
                }
            } else {
                cell?.btnSelect.isSelected = false
                model.isSelected = false
                nav?.arrSelectedModels.removeAll { $0 == model }
                self?.refreshCellIndexAndMaskView()
            }
            self?.resetBottomToolBtnStatus()
        }
        
        cell.indexLabel.isHidden = true
        if ZLPhotoConfiguration.default().showSelectedIndex {
            for (index, selM) in (nav?.arrSelectedModels ?? []).enumerated() {
                if model == selM {
                    setCellIndex(cell, showIndexLabel: true, index: index + 1)
                    break
                }
            }
        }
        
        setCellMaskView(cell, isSelected: model.isSelected, model: model)
        
        cell.model = model
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? ZLThumbnailPhotoCell else {
            return
        }
        var index = indexPath.row
        if !ZLPhotoConfiguration.default().sortAscending {
            index -= offset
        }
        let model = arrDataSources[index]
        setCellMaskView(c, isSelected: model.isSelected, model: model)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let c = collectionView.cellForItem(at: indexPath)
        if c is ZLCameraCell {
            showCamera()
            return
        }
        if #available(iOS 14, *) {
            if c is ZLAddPhotoCell {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
                return
            }
        }
        
        guard let cell = c as? ZLThumbnailPhotoCell else {
            return
        }
        
        if !ZLPhotoConfiguration.default().allowPreviewPhotos {
            cell.btnSelectClick()
            return
        }
        
        if !cell.enableSelect, ZLPhotoConfiguration.default().showInvalidMask {
            return
        }
        let config = ZLPhotoConfiguration.default()
        
        var index = indexPath.row
        if !config.sortAscending {
            index -= offset
        }
        let m = arrDataSources[index]
        if shouldDirectEdit(m) {
            return
        }
        
        let vc = ZLPhotoPreviewController(photos: arrDataSources, index: index)
        show(vc, sender: nil)
    }
    
    private func shouldDirectEdit(_ model: ZLPhotoModel) -> Bool {
        let config = ZLPhotoConfiguration.default()
        
        let canEditImage = config.editAfterSelectThumbnailImage &&
            config.allowEditImage &&
            config.maxSelectCount == 1 &&
            model.type.rawValue < ZLPhotoModel.MediaType.video.rawValue
        
        let canEditVideo = (config.editAfterSelectThumbnailImage &&
            config.allowEditVideo &&
            model.type == .video &&
            config.maxSelectCount == 1) ||
            (config.allowEditVideo &&
                model.type == .video &&
                !config.allowMixSelect &&
                config.cropVideoAfterSelectThumbnail)
        
        // 当前未选择图片 或已经选择了一张并且点击的是已选择的图片
        let nav = navigationController as? ZLImageNavController
        let arrSelectedModels = nav?.arrSelectedModels ?? []
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
    
    private func refreshCellIndexAndMaskView() {
        let showIndex = ZLPhotoConfiguration.default().showSelectedIndex
        let showMask = ZLPhotoConfiguration.default().showSelectedMask || ZLPhotoConfiguration.default().showInvalidMask
        
        guard showIndex || showMask else {
            return
        }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        visibleIndexPaths.forEach { indexPath in
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? ZLThumbnailPhotoCell else {
                return
            }
            var row = indexPath.row
            if !ZLPhotoConfiguration.default().sortAscending {
                row -= self.offset
            }
            let m = self.arrDataSources[row]
            
            let arrSel = (self.navigationController as? ZLImageNavController)?.arrSelectedModels ?? []
            var show = false
            var idx = 0
            var isSelected = false
            for (index, selM) in arrSel.enumerated() {
                if m == selM {
                    show = true
                    idx = index + 1
                    isSelected = true
                    break
                }
            }
            if showIndex {
                self.setCellIndex(cell, showIndexLabel: show, index: idx)
            }
            if showMask {
                self.setCellMaskView(cell, isSelected: isSelected, model: m)
            }
        }
    }
    
    private func setCellMaskView(_ cell: ZLThumbnailPhotoCell, isSelected: Bool, model: ZLPhotoModel) {
        cell.coverView.isHidden = true
        cell.enableSelect = true
        let arrSel = (navigationController as? ZLImageNavController)?.arrSelectedModels ?? []
        let config = ZLPhotoConfiguration.default()
        
        if isSelected {
            cell.coverView.backgroundColor = .zl.selectedMaskColor
            cell.coverView.isHidden = !config.showSelectedMask
            if config.showSelectedBorder {
                cell.layer.borderWidth = 4
            }
        } else {
            let selCount = arrSel.count
            if selCount < config.maxSelectCount {
                if config.allowMixSelect {
                    let videoCount = arrSel.filter { $0.type == .video }.count
                    if videoCount >= config.maxVideoSelectCount, model.type == .video {
                        cell.coverView.backgroundColor = .zl.invalidMaskColor
                        cell.coverView.isHidden = !config.showInvalidMask
                        cell.enableSelect = false
                    } else if (config.maxSelectCount - selCount) <= (config.minVideoSelectCount - videoCount), model.type != .video {
                        cell.coverView.backgroundColor = .zl.invalidMaskColor
                        cell.coverView.isHidden = !config.showInvalidMask
                        cell.enableSelect = false
                    }
                } else if selCount > 0 {
                    cell.coverView.backgroundColor = .zl.invalidMaskColor
                    cell.coverView.isHidden = (!config.showInvalidMask || model.type != .video)
                    cell.enableSelect = model.type != .video
                }
            } else if selCount >= config.maxSelectCount {
                cell.coverView.backgroundColor = .zl.invalidMaskColor
                cell.coverView.isHidden = !config.showInvalidMask
                cell.enableSelect = false
            }
            if config.showSelectedBorder {
                cell.layer.borderWidth = 0
            }
        }
    }
    
}

extension ZLThumbnailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            let image = info[.originalImage] as? UIImage
            let url = info[.mediaURL] as? URL
            self.save(image: image, videoUrl: url)
        }
    }
    
}

extension ZLThumbnailViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: albumList.result) else {
            return
        }
        
        ZLMainAsync {
            guard let nav = self.navigationController as? ZLImageNavController else {
                zlLoggerInDebug("Navigation controller is null")
                return
            }
            // 变化后再次显示相册列表需要刷新
            self.hasTakeANewAsset = true
            self.albumList.result = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                for sm in nav.arrSelectedModels {
                    let isDelete = changeInstance.changeDetails(for: sm.asset)?.objectWasDeleted ?? false
                    if isDelete {
                        nav.arrSelectedModels.removeAll { $0 == sm }
                    }
                }
                if !changes.removedObjects.isEmpty || !changes.insertedObjects.isEmpty {
                    self.albumList.models.removeAll()
                }
                
                self.loadPhotos()
            } else {
                for sm in nav.arrSelectedModels {
                    let isDelete = changeInstance.changeDetails(for: sm.asset)?.objectWasDeleted ?? false
                    if isDelete {
                        nav.arrSelectedModels.removeAll { $0 == sm }
                    }
                }
                self.albumList.models.removeAll()
                self.loadPhotos()
            }
            self.resetBottomToolBtnStatus()
        }
    }
    
}

// MARK: embed album list nav view

class ZLEmbedAlbumListNavView: UIView {
    
    private static let titleViewH: CGFloat = 32
    
    private static let arrowH: CGFloat = 20
    
    private var navBlurView: UIVisualEffectView?
    
    private lazy var titleBgControl: UIControl = {
        let control = UIControl()
        control.backgroundColor = .zl.navEmbedTitleViewBgColor
        control.layer.cornerRadius = ZLEmbedAlbumListNavView.titleViewH / 2
        control.layer.masksToBounds = true
        control.addTarget(self, action: #selector(titleBgControlClick), for: .touchUpInside)
        return control
    }()
    
    private lazy var albumTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zl.navTitleColor
        label.font = ZLLayout.navTitleFont
        label.text = title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var arrow: UIImageView = {
        let view = UIImageView(image: .zl.getImage("zl_downArrow"))
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        if ZLPhotoUIConfiguration.default().navCancelButtonStyle == .text {
            btn.titleLabel?.font = ZLLayout.navTitleFont
            btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
            btn.setTitleColor(.zl.navTitleColor, for: .normal)
        } else {
            btn.setImage(.zl.getImage("zl_navClose"), for: .normal)
        }
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    var title: String {
        didSet {
            albumTitleLabel.text = title
            refreshTitleViewFrame()
        }
    }
    
    var selectAlbumBlock: (() -> Void)?
    
    var cancelBlock: (() -> Void)?
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = safeAreaInsets
        }
        
        refreshTitleViewFrame()
        if ZLPhotoUIConfiguration.default().navCancelButtonStyle == .text {
            let cancelBtnW = localLanguageTextValue(.cancel).zl.boundingRect(font: ZLLayout.navTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)).width
            cancelBtn.frame = CGRect(x: insets.left + 20, y: insets.top, width: cancelBtnW, height: 44)
        } else {
            cancelBtn.frame = CGRect(x: insets.left + 10, y: insets.top, width: 44, height: 44)
        }
    }
    
    private func refreshTitleViewFrame() {
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = safeAreaInsets
        }
        
        navBlurView?.frame = bounds
        
        let albumTitleW = min(
            bounds.width / 2,
            title.zl.boundingRect(
                font: ZLLayout.navTitleFont,
                limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)
            ).width
        )
        let titleBgControlW = albumTitleW + ZLEmbedAlbumListNavView.arrowH + 20
        
        UIView.animate(withDuration: 0.25) {
            self.titleBgControl.frame = CGRect(
                x: (self.frame.width - titleBgControlW) / 2,
                y: insets.top + (44 - ZLEmbedAlbumListNavView.titleViewH) / 2,
                width: titleBgControlW,
                height: ZLEmbedAlbumListNavView.titleViewH
            )
            self.albumTitleLabel.frame = CGRect(x: 10, y: 0, width: albumTitleW, height: ZLEmbedAlbumListNavView.titleViewH)
            self.arrow.frame = CGRect(
                x: self.albumTitleLabel.frame.maxX + 5,
                y: (ZLEmbedAlbumListNavView.titleViewH - ZLEmbedAlbumListNavView.arrowH) / 2.0,
                width: ZLEmbedAlbumListNavView.arrowH,
                height: ZLEmbedAlbumListNavView.arrowH
            )
        }
    }
    
    private func setupUI() {
        backgroundColor = .zl.navBarColor
        
        if let effect = ZLPhotoUIConfiguration.default().navViewBlurEffectOfAlbumList {
            navBlurView = UIVisualEffectView(effect: effect)
            addSubview(navBlurView!)
        }
        
        addSubview(titleBgControl)
        titleBgControl.addSubview(albumTitleLabel)
        titleBgControl.addSubview(arrow)
        addSubview(cancelBtn)
    }
    
    @objc private func titleBgControlClick() {
        selectAlbumBlock?()
        if arrow.transform == .identity {
            UIView.animate(withDuration: 0.25) {
                self.arrow.transform = CGAffineTransform(rotationAngle: .pi)
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.arrow.transform = .identity
            }
        }
    }
    
    @objc private func cancelBtnClick() {
        cancelBlock?()
    }
    
    func reset() {
        UIView.animate(withDuration: 0.25) {
            self.arrow.transform = .identity
        }
    }
    
}

// MARK: external album list nav view

class ZLExternalAlbumListNavView: UIView {
    
    private let title: String
    
    private var navBlurView: UIVisualEffectView?
    
    private lazy var albumTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zl.navTitleColor
        label.font = ZLLayout.navTitleFont
        label.text = title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        if ZLPhotoUIConfiguration.default().navCancelButtonStyle == .text {
            btn.titleLabel?.font = ZLLayout.navTitleFont
            btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
            btn.setTitleColor(.zl.navTitleColor, for: .normal)
        } else {
            btn.setImage(.zl.getImage("zl_navClose"), for: .normal)
        }
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.zl.getImage("zl_navBack"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        return btn
    }()
    
    var backBlock: (() -> Void)?
    
    var cancelBlock: (() -> Void)?
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = safeAreaInsets
        }
        
        navBlurView?.frame = bounds
        
        backBtn.frame = CGRect(x: insets.left, y: insets.top, width: 60, height: 44)
        let albumTitleW = min(bounds.width / 2, title.zl.boundingRect(font: ZLLayout.navTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)).width)
        albumTitleLabel.frame = CGRect(x: (bounds.width - albumTitleW) / 2, y: insets.top, width: albumTitleW, height: 44)
        
        if ZLPhotoUIConfiguration.default().navCancelButtonStyle == .text {
            let cancelBtnW = localLanguageTextValue(.cancel).zl.boundingRect(font: ZLLayout.navTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)).width + 40
            cancelBtn.frame = CGRect(x: bounds.width - insets.right - cancelBtnW, y: insets.top, width: cancelBtnW, height: 44)
        } else {
            cancelBtn.frame = CGRect(x: bounds.width - insets.right - 44 - 10, y: insets.top, width: 44, height: 44)
        }
    }
    
    private func setupUI() {
        backgroundColor = .zl.navBarColor
        
        if let effect = ZLPhotoUIConfiguration.default().navViewBlurEffectOfAlbumList {
            navBlurView = UIVisualEffectView(effect: effect)
            addSubview(navBlurView!)
        }
        
        addSubview(backBtn)
        addSubview(albumTitleLabel)
        addSubview(cancelBtn)
    }
    
    @objc private func backBtnClick() {
        backBlock?()
    }
    
    @objc private func cancelBtnClick() {
        cancelBlock?()
    }
    
}

class ZLLimitedAuthorityTipsView: UIView {
    
    static let height: CGFloat = 70
    
    private lazy var icon = UIImageView(image: .zl.getImage("zl_warning"))
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.font = .zl.font(ofSize: 14)
        label.text = localLanguageTextValue(.unableToAccessAllPhotos)
        label.textColor = .zl.limitedAuthorityTipsColor
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var arrow = UIImageView(image: .zl.getImage("zl_right_arrow"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(icon)
        addSubview(tipsLabel)
        addSubview(arrow)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        icon.frame = CGRect(x: 18, y: (ZLLimitedAuthorityTipsView.height - 25) / 2, width: 25, height: 25)
        tipsLabel.frame = CGRect(x: 55, y: (ZLLimitedAuthorityTipsView.height - 40) / 2, width: frame.width - 55 - 30, height: 40)
        arrow.frame = CGRect(x: frame.width - 25, y: (ZLLimitedAuthorityTipsView.height - 12) / 2, width: 12, height: 12)
    }
    
    @objc private func tapAction() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
