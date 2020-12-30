//
//  ZLAlbumListController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
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

class ZLAlbumListController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var navView: UIView!
    
    var navBlurView: UIVisualEffectView?
    
    var albumTitleLabel: UILabel!
    
    var cancelBtn: UIButton!
    
    var tableView: UITableView!
    
    var arrDataSource: [ZLAlbumListModel] = []
    
    var shouldReloadAlbumList = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ZLPhotoConfiguration.default().statusBarStyle
    }
    
    deinit {
        zl_debugPrint("ZLAlbumListController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        guard self.shouldReloadAlbumList else {
            return
        }
        
        DispatchQueue.global().async {
            ZLPhotoManager.getPhotoAlbumList(ascending: ZLPhotoConfiguration.default().sortAscending, allowSelectImage: ZLPhotoConfiguration.default().allowSelectImage, allowSelectVideo: ZLPhotoConfiguration.default().allowSelectVideo) { [weak self] (albumList) in
                self?.arrDataSource.removeAll()
                self?.arrDataSource.append(contentsOf: albumList)
                
                self?.shouldReloadAlbumList = false
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let navViewNormalH: CGFloat = 44
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        var collectionViewInsetTop: CGFloat = 20
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
            collectionViewInsetTop = navViewNormalH
        } else {
            collectionViewInsetTop += navViewNormalH
        }
        
        self.navView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: insets.top + navViewNormalH)
        self.navBlurView?.frame = self.navView.bounds
        
        let albumTitleW = localLanguageTextValue(.photo).boundingRect(font: ZLLayout.navTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)).width
        self.albumTitleLabel.frame = CGRect(x: (self.view.frame.width-albumTitleW)/2, y: insets.top, width: albumTitleW, height: 44)
        let cancelBtnW = localLanguageTextValue(.cancel).boundingRect(font: ZLLayout.navTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)).width + 40
        self.cancelBtn.frame = CGRect(x: self.view.frame.width-insets.right-cancelBtnW, y: insets.top, width: cancelBtnW, height: 44)
        
        self.tableView.frame = CGRect(x: insets.left, y: 0, width: self.view.frame.width - insets.left - insets.right, height: self.view.frame.height)
        self.tableView.contentInset = UIEdgeInsets(top: collectionViewInsetTop, left: 0, bottom: 0, right: 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
    }
    
    func setupUI() {
        self.view.backgroundColor = .albumListBgColor
        
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.tableView.backgroundColor = .albumListBgColor
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 65
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        self.tableView.separatorColor = .separatorLineColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        ZLAlbumListCell.zl_register(self.tableView)
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .always
        }
        
        self.navView = UIView()
        self.navView.backgroundColor = .navBarColor
        self.view.addSubview(self.navView)
        
        if let effect = ZLPhotoConfiguration.default().navViewBlurEffect {
            self.navBlurView = UIVisualEffectView(effect: effect)
            self.navView.addSubview(self.navBlurView!)
        }
        
        self.albumTitleLabel = UILabel()
        self.albumTitleLabel.textColor = .navTitleColor
        self.albumTitleLabel.font = ZLLayout.navTitleFont
        self.albumTitleLabel.text = localLanguageTextValue(.photo)
        self.albumTitleLabel.textAlignment = .center
        self.navView.addSubview(self.albumTitleLabel)
        
        self.cancelBtn = UIButton(type: .custom)
        self.cancelBtn.titleLabel?.font = ZLLayout.navTitleFont
        self.cancelBtn.setTitle(localLanguageTextValue(.cancel), for: .normal)
        self.cancelBtn.setTitleColor(.navTitleColor, for: .normal)
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        self.navView.addSubview(self.cancelBtn)
    }
    
    @objc func cancelBtnClick() {
        let nav = self.navigationController as? ZLImageNavController
        nav?.cancelBlock?()
        nav?.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZLAlbumListCell.zl_identifier(), for: indexPath) as! ZLAlbumListCell
        
        cell.configureCell(model: self.arrDataSource[indexPath.row], style: .externalAlbumList)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ZLThumbnailViewController(albumList: self.arrDataSource[indexPath.row])
        self.show(vc, sender: nil)
    }

}


extension ZLAlbumListController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.shouldReloadAlbumList = true
    }
    
}
