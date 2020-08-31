//
//  ZLAlbumListController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
//

import UIKit
import Photos

class ZLAlbumListController: UITableViewController {

    var arrDataSource: [ZLAlbumListModel] = []
    
    var shouldReloadAlbumList = true
    
    deinit {
        debugPrint("ZLAlbumListController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    func setupUI() {
        self.edgesForExtendedLayout = .top
        self.title = localLanguageTextValue(.photo)
        self.tableView.backgroundColor = .albumListBgColor
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 65
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        self.tableView.separatorColor = .separatorColor
        ZLAlbumListCell.zl_register(self.tableView)
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .always
        }
        
        let cancelBtn = UIButton(type: .custom)
        let title = localLanguageTextValue(.previewCancel)
        let size = title.boundingRect(font: getFont(16), limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44))
        cancelBtn.frame = CGRect(x: 0, y: 0, width: size.width, height: 44)
        cancelBtn.titleLabel?.font = getFont(16)
        cancelBtn.setTitle(title, for: .normal)
        cancelBtn.setTitleColor(.navTitleColor, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelBtn)
    }
    
    @objc func cancelBtnClick() {
        let nav = self.navigationController as? ZLImageNavController
        nav?.cancelBlock?()
        nav?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZLAlbumListCell.zl_identifier(), for: indexPath) as! ZLAlbumListCell
        
        cell.model = self.arrDataSource[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ZLThumbnailViewController(albumList: self.arrDataSource[indexPath.row])
        self.show(vc, sender: nil)
    }

}


extension ZLAlbumListController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.shouldReloadAlbumList = true
    }
    
}
