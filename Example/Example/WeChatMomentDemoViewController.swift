//
//  WeChatMomentDemoViewController.swift
//  Example
//
//  Created by long on 2021/2/3.
//

import UIKit
import Photos
import ZLPhotoBrowser

class WeChatMomentDemoViewController: UIViewController {

    var collectionView: UICollectionView!
    
    var images: [UIImage] = []
    
    var assets: [PHAsset] = []
    
    var hasSelectVideo = false
    
    static let propertyLabel: Set<String> = ["allowSelectImage", "allowSelectVideo", "allowSelectGif", "allowSelectLivePhoto", "allowSelectOriginal", "cropVideoAfterSelectThumbnail", "allowEditVideo", "allowMixSelect", "maxSelectCount", "maxEditVideoTime"]
    
    let originalConfig: [String: Any] = {
        var dic = [String: Any]()
        for label in propertyLabel {
            dic[label] = ZLPhotoConfiguration.default().value(forKey: label)
        }
        return dic
    }()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        for label in WeChatMomentDemoViewController.propertyLabel {
            ZLPhotoConfiguration.default().setValue(originalConfig[label], forKey: label)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        collectionView.register(WeChatMomentImageCell.self, forCellWithReuseIdentifier: "WeChatMomentImageCell")
    }
    
    func selectPhotos() {
        let config = ZLPhotoConfiguration.default()
        config.allowSelectImage = true
        config.allowSelectVideo = images.count == 0
        config.allowSelectGif = false
        config.allowSelectLivePhoto = false
        config.allowSelectOriginal = false
        config.cropVideoAfterSelectThumbnail = true
        config.allowEditVideo = true
        config.allowMixSelect = false
        config.maxSelectCount = 9 - images.count
        config.maxEditVideoTime = 15
        
        // You can provide the selected assets so as not to repeat selection.
        // Like this 'let photoPicker = ZLPhotoPreviewSheet(selectedAssets: assets)'
        let photoPicker = ZLPhotoPreviewSheet()
        
        photoPicker.selectImageBlock = { [weak self] (results, _) in
            let images = results.map { $0.image }
            let assets = results.map { $0.asset }
            self?.hasSelectVideo = assets.first?.mediaType == .video
            self?.images.append(contentsOf: images)
            self?.assets.append(contentsOf: assets)
            self?.collectionView.reloadData()
        }
        
        photoPicker.showPhotoLibrary(sender: self)
    }
    
}


extension WeChatMomentDemoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hasSelectVideo ? 1 : min(9, images.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.frame.width - 40 - 10) / 3
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeChatMomentImageCell", for: indexPath) as! WeChatMomentImageCell
        
        if indexPath.row < images.count {
            cell.imageView.image = images[indexPath.row]
            cell.playImageView.isHidden = assets[indexPath.row].mediaType != .video
        } else {
            cell.imageView.image = UIImage(named: "addPhoto")
            cell.playImageView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == images.count {
            selectPhotos()
        } else {
            let previewVC = ZLImagePreviewController(datas: assets, index: indexPath.row, showSelectBtn: true)
            
            previewVC.doneBlock = { [weak self] (res) in
                guard let `self` = self else { return }
                if res.isEmpty {
                    self.assets.removeAll()
                    self.images.removeAll()
                    self.collectionView.reloadData()
                    return
                }
                
                if res.count != self.assets.count {
                    var p = 0, removeIndex: [Int] = []
                    for item in res {
                        var index = 0
                        for i in p..<self.assets.count {
                            if self.assets[i] == item as! PHAsset {
                                index = i
                                break
                            }
                        }
                        
                        if index > p {
                            removeIndex.append(contentsOf: p..<index)
                        }
                        if index < p {
                            removeIndex.append(index)
                        }
                        p = index + 1
                    }
                    removeIndex.append(contentsOf: p..<self.assets.count)
                    
                    removeIndex.reversed().forEach { (index) in
                        self.assets.remove(at: index)
                        self.images.remove(at: index)
                    }
                    self.collectionView.reloadData()
                }
            }
            
            previewVC.dismissTransitionFrame = { [weak self] index -> CGRect? in
                guard let `self` = self,
                      let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) else {
                    return nil
                }
                
                let rect = self.collectionView.convert(cell.frame, to: self.view)
                return rect
            }
            
            previewVC.modalPresentationStyle = .fullScreen
            showDetailViewController(previewVC, sender: nil)
        }
    }
    
}


class WeChatMomentImageCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var playImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        
        playImageView = UIImageView(image: UIImage(named: "playVideo"))
        playImageView.contentMode = .scaleAspectFit
        playImageView.isHidden = true
        contentView.addSubview(playImageView)
        playImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
