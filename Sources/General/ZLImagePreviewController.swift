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
    
    let datas: [Any]
    
    var selectStatus: [Bool]
    
    let urlType: ( (URL) -> ZLURLType )?
    
    let urlImageLoader: ( (URL, UIImageView, @escaping ( (CGFloat) -> Void ), @escaping ( () -> Void )) -> Void )?
    
    let showSelectBtn: Bool
    
    let showBottomView: Bool
    
    var currentIndex: Int
    
    var indexBeforOrientationChanged: Int
    
    var collectionView: UICollectionView!
    
    var navView: UIView!
    
    var navBlurView: UIVisualEffectView?
    
    var backBtn: UIButton!
    
    var indexLabel: UILabel!
    
    var selectBtn: UIButton!
    
    var bottomView: UIView!
    
    var bottomBlurView: UIVisualEffectView?
    
    var doneBtn: UIButton!
    
    var isFirstAppear = true
    
    var hideNavView = false
    
    @objc public var doneBlock: ( ([Any]) -> Void )?
    
    var orientation: UIInterfaceOrientation = .unknown
    
    public override var prefersStatusBarHidden: Bool {
        return !ZLPhotoConfiguration.default().showStatusBarInPreviewInterface
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return ZLPhotoConfiguration.default().statusBarStyle
    }
    
    /// - Parameters:
    ///   - datas: Must be one of PHAsset, UIImage and URL, will filter ohers in init function.
    ///   - showBottomView: If showSelectBtn is true, showBottomView is always true.
    ///   - index: Index for first display.
    ///   - urlType: Tell me the url is image or video.
    ///   - urlImageLoader: Called when cell will display, cell will layout after callback when image load finish. The first block is progress callback, second is load finish callback.
    @objc public init(datas: [Any], index: Int = 0, showSelectBtn: Bool = true, showBottomView: Bool = true, urlType: ( (URL) -> ZLURLType )? = nil, urlImageLoader: ( (URL, UIImageView, @escaping ( (CGFloat) -> Void ),  @escaping ( () -> Void )) -> Void )? = nil) {
        let filterDatas = datas.filter { (obj) -> Bool in
            return obj is PHAsset || obj is UIImage || obj is URL
        }
        self.datas = filterDatas
        self.selectStatus = Array(repeating: true, count: filterDatas.count)
        self.currentIndex = index >= filterDatas.count ? 0 : index
        self.indexBeforOrientationChanged = self.currentIndex
        self.showSelectBtn = showSelectBtn
        self.showBottomView = showSelectBtn ? true : showBottomView
        self.urlType = urlType
        self.urlImageLoader = urlImageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.resetSubViewStatus()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.isFirstAppear else { return }
        self.isFirstAppear = false
        
        self.reloadCurrentCell()
    }
    
    public override func viewDidLayoutSubviews() {
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
        self.indexLabel.frame = CGRect(x: (self.view.frame.width - 80)/2, y: insets.top, width: 80, height: 44)
        self.selectBtn.frame = CGRect(x: self.view.frame.width - 40 - insets.right, y: insets.top + (44 - 25) / 2, width: 25, height: 25)
        
        let bottomViewH = ZLLayout.bottomToolViewH
        
        self.bottomView.frame = CGRect(x: 0, y: self.view.frame.height-insets.bottom-bottomViewH, width: self.view.frame.width, height: bottomViewH+insets.bottom)
        self.bottomBlurView?.frame = self.bottomView.bounds
        
        self.resetBottomViewFrame()
        
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
    
    private func setupUI() {
        self.view.backgroundColor = .black
        self.automaticallyAdjustsScrollViewInsets = false
        
        // nav view
        self.navView = UIView()
        self.navView.backgroundColor = .navBarColor
        self.view.addSubview(self.navView)
        
        if let effect = ZLPhotoConfiguration.default().navViewBlurEffect {
            self.navBlurView = UIVisualEffectView(effect: effect)
            self.navView.addSubview(self.navBlurView!)
        }
        
        self.backBtn = UIButton(type: .custom)
        self.backBtn.setImage(getImage("zl_navBack"), for: .normal)
        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navView.addSubview(self.backBtn)
        
        self.indexLabel = UILabel()
        self.indexLabel.textColor = ZLPhotoConfiguration.default().themeColorDeploy.navTitleColor
        self.indexLabel.font = ZLLayout.navTitleFont
        self.indexLabel.textAlignment = .center
        self.navView.addSubview(self.indexLabel)
        
        self.selectBtn = UIButton(type: .custom)
        self.selectBtn.setImage(getImage("zl_btn_circle"), for: .normal)
        self.selectBtn.setImage(getImage("zl_btn_selected"), for: .selected)
        self.selectBtn.zl_enlargeValidTouchArea(inset: 10)
        self.selectBtn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
        self.navView.addSubview(self.selectBtn)
        
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
        ZLLocalImagePreviewCell.zl_register(self.collectionView)
        ZLNetImagePreviewCell.zl_register(self.collectionView)
        ZLNetVideoPreviewCell.zl_register(self.collectionView)
        
        // bottom view
        self.bottomView = UIView()
        self.bottomView.backgroundColor = .bottomToolViewBgColor
        self.view.addSubview(self.bottomView)
        
        if let effect = ZLPhotoConfiguration.default().bottomToolViewBlurEffect {
            self.bottomBlurView = UIVisualEffectView(effect: effect)
            self.bottomView.addSubview(self.bottomBlurView!)
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
        
        self.doneBtn = createBtn(localLanguageTextValue(.done), #selector(doneBtnClick))
        self.doneBtn.backgroundColor = .bottomToolViewBtnNormalBgColor
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        self.bottomView.addSubview(self.doneBtn)
        
        self.view.bringSubviewToFront(self.navView)
    }
    
    func resetSubViewStatus() {
        self.indexLabel.text = String(self.currentIndex + 1) + " / " + String(self.datas.count)
        
        if self.showSelectBtn {
            self.selectBtn.isSelected = self.selectStatus[self.currentIndex]
        } else {
            self.selectBtn.isHidden = true
        }
        
        self.resetBottomViewFrame()
    }
    
    func resetBottomViewFrame() {
        if self.showBottomView {
            let btnY: CGFloat = ZLLayout.bottomToolBtnY
            
            var doneTitle = localLanguageTextValue(.done)
            let selCount = self.selectStatus.filter{ $0 }.count
            if self.showSelectBtn, selCount > 0 {
                doneTitle += "(" + String(selCount) + ")"
            }
            let doneBtnW = doneTitle.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 20
            self.doneBtn.frame = CGRect(x: self.bottomView.bounds.width-doneBtnW-15, y: btnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
            self.doneBtn.setTitle(doneTitle, for: .normal)
        } else {
            self.bottomView.isHidden = true
        }
    }
    
    func dismiss() {
        if let nav = self.navigationController {
            let vc = nav.popViewController(animated: true)
            if vc == nil {
                nav.dismiss(animated: true, completion: nil)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: btn actions
    
    @objc func backBtnClick() {
        self.dismiss()
    }
    
    @objc func selectBtnClick() {
        var isSelected = self.selectStatus[self.currentIndex]
        self.selectBtn.layer.removeAllAnimations()
        if isSelected {
            isSelected = false
        } else {
            self.selectBtn.layer.add(getSpringAnimation(), forKey: nil)
            isSelected = true
        }
        
        self.selectStatus[self.currentIndex] = isSelected
        self.resetSubViewStatus()
    }
    
    @objc func doneBtnClick() {
        if self.showSelectBtn {
            let res = self.datas.enumerated().filter { (index, value) -> Bool in
                return self.selectStatus[index]
            }.map { (_, v) -> Any in
                return v
            }
            self.doneBlock?(res)
        } else {
            self.doneBlock?(self.datas)
        }
        
        self.dismiss()
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
        if self.showBottomView {
            self.bottomView.isHidden = self.hideNavView
        }
    }
    
}


// scroll view delegate
extension ZLImagePreviewController {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.collectionView else {
            return
        }
        NotificationCenter.default.post(name: ZLPhotoPreviewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (self.view.bounds.width + ZLPhotoPreviewController.colItemSpacing)))
        page = max(0, min(page, self.datas.count-1))
        if page == self.currentIndex {
            return
        }
        self.currentIndex = page
        self.resetSubViewStatus()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.indexBeforOrientationChanged = self.currentIndex
        let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0))
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
        return CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = ZLPhotoConfiguration.default()
        let obj = self.datas[indexPath.row]
        
        let baseCell: ZLPreviewBaseCell
        
        if let asset = obj as? PHAsset {
            let model = ZLPhotoModel(asset: asset)
            
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
            
            return baseCell
        } else if let image = obj as? UIImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLLocalImagePreviewCell.zl_identifier(), for: indexPath) as! ZLLocalImagePreviewCell
            
            cell.image = image
            
            baseCell = cell
        } else if let url = obj as? URL {
            let type = self.urlType?(url) ?? ZLURLType.image
            if type == .image {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLNetImagePreviewCell.zl_identifier(), for: indexPath) as! ZLNetImagePreviewCell
                cell.image = nil
                
                self.urlImageLoader?(url, cell.preview.imageView, { [weak cell] (progress) in
                    DispatchQueue.main.async {
                        cell?.progress = progress
                    }
                }, { [weak cell] in
                    DispatchQueue.main.async {
                        cell?.preview.resetSubViewSize()
                    }
                })
                
                baseCell = cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLNetVideoPreviewCell.zl_identifier(), for: indexPath) as! ZLNetVideoPreviewCell
                
                cell.videoUrl = url
                
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
        
        (baseCell as? ZLLocalImagePreviewCell)?.longPressBlock = { [weak self] in
            self?.showSaveImageAlert()
        }
        
        return baseCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let c = cell as? ZLPreviewBaseCell {
            c.resetSubViewStatusWhenCellEndDisplay()
        }
    }
    
    func showSaveImageAlert() {
        func saveImage() {
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? ZLLocalImagePreviewCell, let image = cell.currentImage else {
                return
            }
            let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
            hud.show()
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] (suc, _) in
                hud.hide()
                if !suc {
                    showAlertView(localLanguageTextValue(.saveImageError), self)
                }
            }
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let save = UIAlertAction(title: localLanguageTextValue(.save), style: .default) { (_) in
            saveImage()
        }
        let cancel = UIAlertAction(title: localLanguageTextValue(.cancel), style: .cancel, handler: nil)
        alert.addAction(save)
        alert.addAction(cancel)
        self.showDetailViewController(alert, sender: nil)
    }
    
}
