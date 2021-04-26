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
        
        self.title = "Main"
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
        
        let configBtn = createBtn("Configuration", #selector(configureClick))
        self.view.addSubview(configBtn)
        configBtn.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.snp.topMargin).offset(20)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(20)
            }
            
            make.left.equalTo(self.view).offset(30)
        }
        
        let configBtn_cn = createBtn("相册配置 (中文)", #selector(cn_configureClick))
        self.view.addSubview(configBtn_cn)
        configBtn_cn.snp.makeConstraints { (make) in
            make.top.equalTo(configBtn.snp.top)
            make.left.equalTo(configBtn.snp.right).offset(30)
        }
        
        let previewSelectBtn = createBtn("Preview selection", #selector(previewSelectPhoto))
        self.view.addSubview(previewSelectBtn)
        previewSelectBtn.snp.makeConstraints { (make) in
            make.top.equalTo(configBtn.snp.bottom).offset(20)
            make.left.equalTo(configBtn.snp.left)
        }
        
        let libratySelectBtn = createBtn("Library selection", #selector(librarySelectPhoto))
        self.view.addSubview(libratySelectBtn)
        libratySelectBtn.snp.makeConstraints { (make) in
            make.top.equalTo(previewSelectBtn.snp.top)
            make.left.equalTo(previewSelectBtn.snp.right).offset(20)
        }
        
        let cameraBtn = createBtn("Custom camera", #selector(showCamera))
        self.view.addSubview(cameraBtn)
        cameraBtn.snp.makeConstraints { (make) in
            make.left.equalTo(configBtn.snp.left)
            make.top.equalTo(previewSelectBtn.snp.bottom).offset(20)
        }
        
        let previewLocalAndNetImageBtn = createBtn("Preview local and net image", #selector(previewLocalAndNetImage))
        self.view.addSubview(previewLocalAndNetImageBtn)
        previewLocalAndNetImageBtn.snp.makeConstraints { (make) in
            make.left.equalTo(cameraBtn.snp.right).offset(20)
            make.centerY.equalTo(cameraBtn)
        }
        
        let wechatMomentDemoBtn = createBtn("Create WeChat moment Demo", #selector(createWeChatMomentDemo))
        self.view.addSubview(wechatMomentDemoBtn)
        wechatMomentDemoBtn.snp.makeConstraints { (make) in
            make.left.equalTo(configBtn.snp.left)
            make.top.equalTo(cameraBtn.snp.bottom).offset(20)
        }
        
        let takeLabel = UILabel()
        takeLabel.font = UIFont.systemFont(ofSize: 14)
        takeLabel.textColor = .black
        takeLabel.text = "Record selected photos："
        self.view.addSubview(takeLabel)
        takeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(configBtn.snp.left)
            make.top.equalTo(wechatMomentDemoBtn.snp.bottom).offset(20)
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
    
    @objc func cn_configureClick() {
        let vc = PhotoConfigureCNViewController()
        self.showDetailViewController(vc, sender: nil)
    }
    
    @objc func previewSelectPhoto() {
        self.showImagePicker(true)
    }
    
    @objc func librarySelectPhoto() {
        self.showImagePicker(false)
    }
    
    func showImagePicker(_ preview: Bool) {
        let config = ZLPhotoConfiguration.default()
//        config.editImageClipRatios = [.custom, .wh1x1, .wh3x4, .wh16x9, ZLImageClipRatio(title: "2 : 1", whRatio: 2 / 1)]
//        config.filters = [.normal, .process, ZLFilter(name: "custom", applier: ZLCustomFilter.hazeRemovalFilter)]
        
        config.imageStickerContainerView = ImageStickerContainerView()
        
        // You can first determine whether the asset is allowed to be selected.
        config.canSelectAsset = { (asset) -> Bool in
            return true
        }
        
        config.noAuthorityCallback = { (type) in
            switch type {
            case .library:
                debugPrint("No library authority")
            case .camera:
                debugPrint("No camera authority")
            case .microphone:
                debugPrint("No microphone authority")
            }
        }
        
        let ac = ZLPhotoPreviewSheet(selectedAssets: self.takeSelectedAssetsSwitch.isOn ? self.selectedAssets : [])
        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.selectedImages = images
            self?.selectedAssets = assets
            self?.isOriginal = isOriginal
            self?.collectionView.reloadData()
            debugPrint("\(images)   \(assets)   \(isOriginal)")
        }
        ac.cancelBlock = {
            debugPrint("cancel select")
        }
        ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
            debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
        }
        
        if preview {
            ac.showPreview(animate: true, sender: self)
        } else {
            ac.showPhotoLibrary(sender: self)
        }
    }
    
    @objc func previewLocalAndNetImage() {
        var datas: [Any] = []
        // network image
        datas.append(URL(string: "https://cdn.pixabay.com/photo/2020/10/14/18/35/sign-post-5655110_1280.png")!)
        datas.append(URL(string: "https://pic.netbian.com/uploads/allimg/190518/174718-1558172838db13.jpg")!)
        datas.append(URL(string: "http://5b0988e595225.cdn.sohucs.com/images/20190420/1d1070881fd540db817b2a3bdd967f37.gif")!)
        datas.append(URL(string: "https://cdn.pixabay.com/photo/2019/11/08/11/56/cat-4611189_1280.jpg")!)
        
        // network video
        let netVideoUrlString = "https://freevod.nf.migu.cn/mORsHmtum1AysKe3Ry%2FUb5rA1WelPRwa%2BS7ylo4qQCjcD5a2YuwiIC7rpFwwdGcgkgMxZVi%2FVZ%2Fnxf6NkQZ75HC0xnJ5rlB8UwiH8cZUuvErkVufDlxxLUBF%2FIgUEwjiq%2F%2FV%2FoxBQBVMUzAZaWTvOE5dxUFh4V3Oa489Ec%2BPw0IhEGuR64SuKk3MOszdFg0Q/600575Y9FGZ040325.mp4?msisdn=2a257d4c-1ee0-4ad8-8081-b1650c26390a&spid=600906&sid=50816168212200&timestamp=20201026155427&encrypt=70fe12c7473e6d68075e9478df40f207&k=dc156224f8d0835e&t=1603706067279&ec=2&flag=+&FN=%E5%B0%86%E6%95%85%E4%BA%8B%E5%86%99%E6%88%90%E6%88%91%E4%BB%AC"
        datas.append(URL(string: netVideoUrlString)!)
        
        // phasset
        if self.takeSelectedAssetsSwitch.isOn {
            datas.append(contentsOf: self.selectedAssets)
        }
        
        // local image
        datas.append(contentsOf:
            (1...3).compactMap { UIImage(named: "image" + String($0)) }
        )
        
        let videoSuffixs = ["mp4", "mov", "avi", "rmvb", "rm", "flv", "3gp", "wmv", "vob", "dat", "m4v", "f4v", "mkv"] // and more suffixs
        let vc = ZLImagePreviewController(datas: datas, index: 0, showSelectBtn: true) { (url) -> ZLURLType in
            // Just for demo.
            if url.absoluteString == netVideoUrlString {
                return .video
            }
            if let sf = url.absoluteString.split(separator: ".").last, videoSuffixs.contains(String(sf)) {
                return .video
            } else {
                return .image
            }
        } urlImageLoader: { (url, imageView, progress, loadFinish) in
            imageView.kf.setImage(with: url) { (receivedSize, totalSize) in
                let percentage = (CGFloat(receivedSize) / CGFloat(totalSize))
                debugPrint("\(percentage)")
                progress(percentage)
            } completionHandler: { (_) in
                loadFinish()
            }
        }
        
        vc.doneBlock = { (datas) in
            debugPrint(datas)
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.showDetailViewController(vc, sender: nil)
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
            ZLPhotoManager.saveVideoToAlbum(url: videoUrl) { [weak self] (suc, asset) in
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
    
    @objc func createWeChatMomentDemo() {
        let vc = WeChatMomentDemoViewController()
        self.show(vc, sender: nil)
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
        
        ac.previewAssets(sender: self, assets: self.selectedAssets, index: indexPath.row, isOriginal: self.isOriginal, showBottomViewAndSelectBtn: true)
    }
    
}
