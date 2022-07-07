//
//  ZLImagePreviewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/10/22.
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

@objc public enum ZLURLType: Int {
    case image
    case video
}

public class ZLImagePreviewController: UIViewController {
    
    static let colItemSpacing: CGFloat = 40
    
    static let selPhotoPreviewH: CGFloat = 100
    
    private let datas: [Any]
    
    private var selectStatus: [Bool]
    
    private let urlType: ((URL) -> ZLURLType)?
    
    private let urlImageLoader: ((URL, UIImageView, @escaping (CGFloat) -> Void, @escaping () -> Void) -> Void)?
    
    private let showSelectBtn: Bool
    
    private let showBottomView: Bool

    private var currentIndex: Int
    
    private var indexBeforOrientationChanged: Int
    
    private lazy var collectionView: UICollectionView = {
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
        ZLLocalImagePreviewCell.zl.register(view)
        ZLNetImagePreviewCell.zl.register(view)
        ZLNetVideoPreviewCell.zl.register(view)
        
        return view
    }()
    
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
    
    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zl.indexLabelTextColor
        label.font = ZLLayout.navTitleFont
        label.textAlignment = .center
        return label
    }()
    
    private lazy var selectBtn: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setImage(.zl.getImage("zl_btn_circle"), for: .normal)
        btn.setImage(.zl.getImage("zl_btn_selected"), for: .selected)
        btn.enlargeInset = 10
        btn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .zl.bottomToolViewBgColorOfPreviewVC
        return view
    }()
    
    private var bottomBlurView: UIVisualEffectView?
    
    private lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.zl.bottomToolViewDoneBtnNormalTitleColorOfPreviewVC, for: .normal)
        btn.setTitleColor(.zl.bottomToolViewDoneBtnDisableTitleColorOfPreviewVC, for: .disabled)
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.backgroundColor = .zl.bottomToolViewBtnNormalBgColorOfPreviewVC
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    private var isFirstAppear = true
    
    private var hideNavView = false
    
    private var orientation: UIInterfaceOrientation = .unknown
    
    @objc public var longPressBlock: ((ZLImagePreviewController?, UIImage?, Int) -> Void)?
    
    @objc public var doneBlock: (([Any]) -> Void)?
    
    @objc public var videoHttpHeader: [String: Any]?
    
    override public var prefersStatusBarHidden: Bool {
        return !ZLPhotoUIConfiguration.default().showStatusBarInPreviewInterface
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return ZLPhotoUIConfiguration.default().statusBarStyle
    }
    
    deinit {
        zl_debugPrint("ZLImagePreviewController deinit")
    }
    
    /// - Parameters:
    ///   - datas: Must be one of PHAsset, UIImage and URL, will filter others in init function.
    ///   - showBottomView: If showSelectBtn is true, showBottomView is always true.
    ///   - index: Index for first display.
    ///   - urlType: Tell me the url is image or video.
    ///   - urlImageLoader: Called when cell will display, cell will layout after callback when image load finish. The first block is progress callback, second is load finish callback.
    @objc public init(
        datas: [Any],
        index: Int = 0,
        showSelectBtn: Bool = true,
        showBottomView: Bool = true,
        urlType: ((URL) -> ZLURLType)? = nil,
        urlImageLoader: ((URL, UIImageView, @escaping (CGFloat) -> Void, @escaping () -> Void) -> Void)? = nil
    ) {
        let filterDatas = datas.filter { obj -> Bool in
            obj is PHAsset || obj is UIImage || obj is URL
        }
        self.datas = filterDatas
        selectStatus = Array(repeating: true, count: filterDatas.count)
        currentIndex = index >= filterDatas.count ? 0 : index
        indexBeforOrientationChanged = currentIndex
        self.showSelectBtn = showSelectBtn
        self.showBottomView = showSelectBtn ? true : showBottomView
        self.urlType = urlType
        self.urlImageLoader = urlImageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        resetSubViewStatus()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirstAppear else {
            return
        }
        isFirstAppear = false
        
        reloadCurrentCell()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        insets.top = max(20, insets.top)
        
        collectionView.frame = CGRect(x: -ZLPhotoPreviewController.colItemSpacing / 2, y: 0, width: view.frame.width + ZLPhotoPreviewController.colItemSpacing, height: view.frame.height)
        
        let navH = insets.top + 44
        navView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: navH)
        navBlurView?.frame = navView.bounds
        
        backBtn.frame = CGRect(x: insets.left, y: insets.top, width: 60, height: 44)
        indexLabel.frame = CGRect(x: (view.frame.width - 80) / 2, y: insets.top, width: 80, height: 44)
        selectBtn.frame = CGRect(x: view.frame.width - 40 - insets.right, y: insets.top + (44 - 25) / 2, width: 25, height: 25)
        
        let bottomViewH = ZLLayout.bottomToolViewH
        
        bottomView.frame = CGRect(x: 0, y: view.frame.height - insets.bottom - bottomViewH, width: view.frame.width, height: bottomViewH + insets.bottom)
        bottomBlurView?.frame = bottomView.bounds
        
        resetBottomViewFrame()
        
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
    
    private func setupUI() {
        view.backgroundColor = .zl.previewVCBgColor
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(navView)
        
        if let effect = ZLPhotoUIConfiguration.default().navViewBlurEffectOfPreview {
            navBlurView = UIVisualEffectView(effect: effect)
            navView.addSubview(navBlurView!)
        }
        
        navView.addSubview(backBtn)
        navView.addSubview(indexLabel)
        navView.addSubview(selectBtn)
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        
        if let effect = ZLPhotoUIConfiguration.default().bottomViewBlurEffectOfPreview {
            bottomBlurView = UIVisualEffectView(effect: effect)
            bottomView.addSubview(bottomBlurView!)
        }
        
        bottomView.addSubview(doneBtn)
        view.bringSubviewToFront(navView)
    }
    
    private func resetSubViewStatus() {
        indexLabel.text = String(currentIndex + 1) + " / " + String(datas.count)
        
        if showSelectBtn {
            selectBtn.isSelected = selectStatus[currentIndex]
        } else {
            selectBtn.isHidden = true
        }
        
        resetBottomViewFrame()
    }
    
    private func resetBottomViewFrame() {
        guard showBottomView else {
            bottomView.isHidden = true
            return
        }
        
        let btnY: CGFloat = ZLLayout.bottomToolBtnY
        
        var doneTitle = localLanguageTextValue(.done)
        let selCount = selectStatus.filter { $0 }.count
        if showSelectBtn,
           ZLPhotoConfiguration.default().showSelectCountOnDoneBtn,
           selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        let doneBtnW = doneTitle.zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 20
        doneBtn.frame = CGRect(x: bottomView.bounds.width - doneBtnW - 15, y: btnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
        doneBtn.setTitle(doneTitle, for: .normal)
    }
    
    private func dismiss() {
        if let nav = navigationController {
            let vc = nav.popViewController(animated: true)
            if vc == nil {
                nav.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: btn actions
    
    @objc private func backBtnClick() {
        dismiss()
    }
    
    @objc private func selectBtnClick() {
        var isSelected = selectStatus[currentIndex]
        selectBtn.layer.removeAllAnimations()
        if isSelected {
            isSelected = false
        } else {
            if ZLPhotoConfiguration.default().animateSelectBtnWhenSelect {
                selectBtn.layer.add(getSpringAnimation(), forKey: nil)
            }
            isSelected = true
        }
        
        selectStatus[currentIndex] = isSelected
        resetSubViewStatus()
    }
    
    @objc private func doneBtnClick() {
        if showSelectBtn {
            let res = datas.enumerated().filter { index, _ -> Bool in
                self.selectStatus[index]
            }.map { _, v -> Any in
                v
            }
            doneBlock?(res)
        } else {
            doneBlock?(datas)
        }
        
        dismiss()
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
        if showBottomView {
            bottomView.isHidden = hideNavView
        }
    }
    
}

// scroll view delegate
public extension ZLImagePreviewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else {
            return
        }
        NotificationCenter.default.post(name: ZLPhotoPreviewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (view.bounds.width + ZLPhotoPreviewController.colItemSpacing)))
        page = max(0, min(page, datas.count - 1))
        if page == currentIndex {
            return
        }
        currentIndex = page
        resetSubViewStatus()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        indexBeforOrientationChanged = currentIndex
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
        if let cell = cell as? ZLGifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? ZLLivePhotoPreviewCell {
            cell.loadLivePhotoData()
        }
    }
    
}

extension ZLImagePreviewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ZLImagePreviewController.colItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ZLImagePreviewController.colItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: ZLImagePreviewController.colItemSpacing / 2, bottom: 0, right: ZLImagePreviewController.colItemSpacing / 2)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = ZLPhotoConfiguration.default()
        let obj = datas[indexPath.row]
        
        let baseCell: ZLPreviewBaseCell
        
        if let asset = obj as? PHAsset {
            let model = ZLPhotoModel(asset: asset)
            
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
            
            return baseCell
        } else if let image = obj as? UIImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLLocalImagePreviewCell.zl.identifier, for: indexPath) as! ZLLocalImagePreviewCell
            
            cell.image = image
            
            baseCell = cell
        } else if let url = obj as? URL {
            let type = urlType?(url) ?? ZLURLType.image
            if type == .image {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLNetImagePreviewCell.zl.identifier, for: indexPath) as! ZLNetImagePreviewCell
                cell.image = nil
                
                urlImageLoader?(url, cell.preview.imageView, { [weak cell] progress in
                    ZLMainAsync {
                        cell?.progress = progress
                    }
                }, { [weak cell] in
                    ZLMainAsync {
                        cell?.preview.resetSubViewSize()
                    }
                })
                
                baseCell = cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLNetVideoPreviewCell.zl.identifier, for: indexPath) as! ZLNetVideoPreviewCell
                
                cell.configureCell(videoUrl: url, httpHeader: videoHttpHeader)
                
                baseCell = cell
            }
        } else {
            #if DEBUG
                fatalError("Preview obj must one of PHAsset, UIImage, URL")
            #else
                return UICollectionViewCell()
            #endif
        }
        
        baseCell.singleTapBlock = { [weak self] in
            self?.tapPreviewCell()
        }
        
        (baseCell as? ZLLocalImagePreviewCell)?.longPressBlock = { [weak self, weak baseCell] in
            if let callback = self?.longPressBlock {
                callback(self, baseCell?.currentImage, indexPath.row)
            } else {
                self?.showSaveImageAlert()
            }
        }
        
        return baseCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let c = cell as? ZLPreviewBaseCell {
            c.resetSubViewStatusWhenCellEndDisplay()
        }
    }
    
    private func showSaveImageAlert() {
        func saveImage() {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? ZLLocalImagePreviewCell, let image = cell.currentImage else {
                return
            }
            let hud = ZLProgressHUD(style: ZLPhotoUIConfiguration.default().hudStyle)
            hud.show()
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] suc, _ in
                hud.hide()
                if !suc {
                    showAlertView(localLanguageTextValue(.saveImageError), self)
                }
            }
        }
        
        let saveAction = ZLCustomAlertAction(title: localLanguageTextValue(.save), style: .default) { _ in
            saveImage()
        }
        let cancelAction = ZLCustomAlertAction(title: localLanguageTextValue(.cancel), style: .cancel, handler: nil)
        showAlertController(title: nil, message: "", style: .actionSheet, actions: [saveAction, cancelAction], sender: self)
    }
    
}
