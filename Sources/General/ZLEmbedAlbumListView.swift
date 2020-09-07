//
//  ZLEmbedAlbumListView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/9/7.
//

import UIKit

class ZLEmbedAlbumListView: UIView {

    var selectedAlbum: ZLAlbumListModel
    
    var tableView: UITableView!
    
    var arrDataSource: [ZLAlbumListModel] = []
    
    var selectAlbumBlock: ( (ZLAlbumListModel) -> Void )?
    
    var hideBlock: ( () -> Void )?
    
    init(selectedAlbum: ZLAlbumListModel) {
        self.selectedAlbum = selectedAlbum
        super.init(frame: .zero)
        self.setupUI()
        self.loadAlbumList()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.clipsToBounds = true
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.tableView.backgroundColor = .albumListBgColor
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 60
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        self.tableView.separatorColor = .separatorColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addSubview(self.tableView)
        
        ZLAlbumListCell.zl_register(self.tableView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    func loadAlbumList() {
        DispatchQueue.global().async {
            ZLPhotoManager.getPhotoAlbumList(ascending: ZLPhotoConfiguration.default().sortAscending, allowSelectImage: ZLPhotoConfiguration.default().allowSelectImage, allowSelectVideo: ZLPhotoConfiguration.default().allowSelectVideo) { [weak self] (albumList) in
                self?.arrDataSource.removeAll()
                self?.arrDataSource.append(contentsOf: albumList)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func show() {
        let toFrame: CGRect
        
        if UIApplication.shared.statusBarOrientation.isPortrait {
            toFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height*0.7)
        } else {
            toFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height*0.8)
        }
        
        self.isHidden = false
        self.alpha = 0
        self.tableView.frame = CGRect(x: 0, y: -toFrame.height, width: self.frame.width, height: toFrame.height)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.tableView.frame = toFrame
        }
    }
    
    func hide() {
        var toFrame = self.tableView.frame
        toFrame.origin.y = -toFrame.height
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
            self.tableView.frame = toFrame
        } completion: { (_) in
            self.isHidden = true
            self.alpha = 1
        }
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        self.hide()
        self.hideBlock?()
    }
    
}


extension ZLEmbedAlbumListView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let p = gestureRecognizer.location(in: self)
        return !self.tableView.frame.contains(p)
    }
    
}


extension ZLEmbedAlbumListView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZLAlbumListCell.zl_identifier(), for: indexPath) as! ZLAlbumListCell
        
        let m = self.arrDataSource[indexPath.row]
        
        cell.configureCell(model: m, style: .embedAlbumList)
        
        cell.selectBtn.isSelected = m == self.selectedAlbum
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let m = self.arrDataSource[indexPath.row]
        self.selectedAlbum = m
        self.selectAlbumBlock?(m)
        self.hide()
        if let inx = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: inx, with: .none)
        }
    }
    
}
