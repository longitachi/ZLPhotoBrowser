//
//  ViewController.swift
//  Example
//
//  Created by long on 2020/8/11.
//

import UIKit
import ZLPhotoBrowser
import Photos

class ViewController: UIViewController {

    var collectionView: UICollectionView!
    
    var selectedImages: [UIImage] = []
    
    var selectedAssets: [PHAsset] = []
    
    var isOriginal = false
    
    var takeSelectedAssetsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "主界面"
        self.view.backgroundColor = .white
        
        func createBtn(_ title: String, _ action: Selector) -> UIButton {
            let btn = UIButton(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.addTarget(self, action: action, for: .touchUpInside)
            btn.backgroundColor = .black
            btn.layer.cornerRadius = 5
            btn.layer.masksToBounds = true
            return btn
        }
        
        let configBtn = createBtn("相册配置", #selector(configureClick))
        self.view.addSubview(configBtn)
        configBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.left.equalTo(self.view).offset(30)
        }
        
        let previewSelectBtn = createBtn("快速选择", #selector(previewSelectPhoto))
        self.view.addSubview(previewSelectBtn)
        previewSelectBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.left.equalTo(configBtn.snp.right).offset(20)
        }
        
        let libratySelectBtn = createBtn("进入相册选择", #selector(librarySelectPhoto))
        self.view.addSubview(libratySelectBtn)
        libratySelectBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.left.equalTo(previewSelectBtn.snp.right).offset(20)
        }
        
        let cameraBtn = createBtn("自定义相机", #selector(showCamera))
        self.view.addSubview(cameraBtn)
        cameraBtn.snp.makeConstraints { (make) in
            make.left.equalTo(configBtn.snp.left)
            make.top.equalTo(configBtn.snp.bottom).offset(20)
        }
        
        let takeLabel = UILabel()
        takeLabel.font = UIFont.systemFont(ofSize: 14)
        takeLabel.text = "记录已选择照片："
        self.view.addSubview(takeLabel)
        takeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(configBtn.snp.left)
            make.top.equalTo(cameraBtn.snp.bottom).offset(20)
        }
        
        self.takeSelectedAssetsSwitch = UISwitch()
        self.takeSelectedAssetsSwitch.isOn = false
        self.view.addSubview(self.takeSelectedAssetsSwitch)
        self.takeSelectedAssetsSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(takeLabel.snp.right).offset(20)
            make.centerY.equalTo(takeLabel.snp.centerY)
        }
        
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(takeLabel.snp.bottom).offset(30)
            make.left.bottom.right.equalTo(self.view)
        }
        
        self.collectionView.register(ImageCell.classForCoder(), forCellWithReuseIdentifier: "ImageCell")
    }
    
    @objc func configureClick() {
        let vc = PhotoConfigureViewController()
        self.showDetailViewController(vc, sender: nil)
    }
    
    @objc func previewSelectPhoto() {
        ZLPhotoConfiguration.default().editImageClipRatios = [.custom, .wh1x1, .wh3x4, .wh16x9, ZLImageClipRatio(title: "2 : 1", whRatio: 2 / 1)]
        let ac = ZLPhotoPreviewSheet(selectedAssets: self.takeSelectedAssetsSwitch.isOn ? self.selectedAssets : [])
        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.selectedImages = images
            self?.selectedAssets = assets
            self?.isOriginal = isOriginal
            self?.collectionView.reloadData()
            debugPrint("\(images)   \(assets)   \(isOriginal)")
        }
        ac.showPreview(animate: true, sender: self)
    }
    
    @objc func librarySelectPhoto() {
        ZLPhotoConfiguration.default().editImageClipRatios = [.custom, .wh1x1, .wh3x4, .wh16x9, ZLImageClipRatio(title: "2 : 1", whRatio: 2 / 1)]
        // 自定义滤镜
//        ZLPhotoConfiguration.default().filters = [.normal, .process, ZLFilter(name: "custom", applier: ZLCustomFilter.hazeRemovalFilter)]
        let ac = ZLPhotoPreviewSheet(selectedAssets: self.takeSelectedAssetsSwitch.isOn ? self.selectedAssets : [])
        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.selectedImages = images
            self?.selectedAssets = assets
            self?.collectionView.reloadData()
            debugPrint("\(images)   \(assets)   \(isOriginal)")
        }
        ac.showPhotoLibrary(sender: self)
    }
    
    @objc func showCamera() {
        let camera = ZLCustomCamera()
        camera.takeDoneBlock = { [weak self] (image, videoUrl) in
            self?.save(image: image, videoUrl: videoUrl)
        }
        self.showDetailViewController(camera, sender: nil)
    }
    
    func save(image: UIImage?, videoUrl: URL?) {
        let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
        if let image = image {
            hud.show()
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] (suc, asset) in
                if suc, let at = asset {
                    self?.selectedImages = [image]
                    self?.selectedAssets = [at]
                    self?.collectionView.reloadData()
                } else {
                    debugPrint("保存图片到相册失败")
                }
                hud.hide()
            }
        } else if let videoUrl = videoUrl {
            hud.show()
            ZLPhotoManager.saveVideoToAblum(url: videoUrl) { [weak self] (suc, asset) in
                if suc, let at = asset {
                    self?.fetchImage(for: at)
                } else {
                    debugPrint("保存视频到相册失败")
                }
                hud.hide()
            }
        }
    }
    
    func fetchImage(for asset: PHAsset) {
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        option.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: option) { (image, info) in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished, !isDegraded {
                self.selectedImages = [image!]
                self.selectedAssets = [asset]
                self.collectionView.reloadData()
            }
        }
    }
    
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var columnCount: CGFloat = (UI_USER_INTERFACE_IDIOM() == .pad) ? 6 : 4
        if UIApplication.shared.statusBarOrientation.isLandscape {
            columnCount += 2
        }
        let totalW = collectionView.bounds.width - (columnCount - 1) * 2
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        cell.imageView.image = self.selectedImages[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ac = ZLPhotoPreviewSheet()
        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.selectedImages = images
            self?.selectedAssets = assets
            self?.isOriginal = isOriginal
            self?.collectionView.reloadData()
            debugPrint("\(images)   \(assets)   \(isOriginal)")
        }
        ac.previewAssets(sender: self, assets: self.selectedAssets, index: indexPath.row, isOriginal: self.isOriginal)
    }
    
}
