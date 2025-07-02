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
    
    var selectedResults: [ZLResultModel] = []
    
    var isOriginal = false
    
    var takeSelectedAssetsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            FLEXManager.shared.showExplorer()
//        }
        
        ZLPhotoUIConfiguration.default()
            .customAlertClass(CustomAlertController.self)
    }
    
    func setupUI() {
        title = "Main"
        view.backgroundColor = .white
        
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
        view.addSubview(configBtn)
        configBtn.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.snp.topMargin).offset(20)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom).offset(20)
            }
            
            make.left.equalTo(view.snp.leftMargin).offset(30)
        }
        
        let configBtn_cn = createBtn("相册配置 (中文)", #selector(cn_configureClick))
        view.addSubview(configBtn_cn)
        configBtn_cn.snp.makeConstraints { make in
            make.top.equalTo(configBtn.snp.top)
            make.left.equalTo(configBtn.snp.right).offset(30)
        }
        
        let previewSelectBtn = createBtn("Preview selection", #selector(previewSelectPhoto))
        view.addSubview(previewSelectBtn)
        previewSelectBtn.snp.makeConstraints { make in
            make.top.equalTo(configBtn.snp.bottom).offset(20)
            make.left.equalTo(configBtn.snp.left)
        }
        
        let libratySelectBtn = createBtn("Library selection", #selector(librarySelectPhoto))
        view.addSubview(libratySelectBtn)
        libratySelectBtn.snp.makeConstraints { make in
            make.top.equalTo(previewSelectBtn.snp.top)
            make.left.equalTo(previewSelectBtn.snp.right).offset(20)
        }
        
        let cameraBtn = createBtn("Custom camera", #selector(showCamera))
        view.addSubview(cameraBtn)
        cameraBtn.snp.makeConstraints { make in
            make.left.equalTo(configBtn.snp.left)
            make.top.equalTo(previewSelectBtn.snp.bottom).offset(20)
        }
        
        let previewLocalAndNetImageBtn = createBtn("Preview local and net image", #selector(previewLocalAndNetImage))
        view.addSubview(previewLocalAndNetImageBtn)
        previewLocalAndNetImageBtn.snp.makeConstraints { make in
            make.left.equalTo(cameraBtn.snp.right).offset(20)
            make.centerY.equalTo(cameraBtn)
        }
        
        let wechatMomentDemoBtn = createBtn("Create WeChat moment Demo", #selector(createWeChatMomentDemo))
        view.addSubview(wechatMomentDemoBtn)
        wechatMomentDemoBtn.snp.makeConstraints { make in
            make.left.equalTo(configBtn.snp.left)
            make.top.equalTo(cameraBtn.snp.bottom).offset(20)
        }
        
        let takeLabel = UILabel()
        takeLabel.font = UIFont.systemFont(ofSize: 14)
        takeLabel.textColor = .black
        takeLabel.text = "Record selected photos："
        view.addSubview(takeLabel)
        takeLabel.snp.makeConstraints { make in
            make.left.equalTo(configBtn.snp.left)
            make.top.equalTo(wechatMomentDemoBtn.snp.bottom).offset(20)
        }
        
        takeSelectedAssetsSwitch = UISwitch()
        takeSelectedAssetsSwitch.isOn = false
        view.addSubview(takeSelectedAssetsSwitch)
        takeSelectedAssetsSwitch.snp.makeConstraints { make in
            make.left.equalTo(takeLabel.snp.right).offset(20)
            make.centerY.equalTo(takeLabel.snp.centerY)
        }
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(takeLabel.snp.bottom).offset(30)
            make.left.bottom.right.equalToSuperview()
        }
        
        collectionView.register(ImageCell.classForCoder(), forCellWithReuseIdentifier: "ImageCell")
    }
    
    @objc func configureClick() {
        let vc = PhotoConfigureViewController()
        showDetailViewController(vc, sender: nil)
    }
    
    @objc func cn_configureClick() {
        let vc = PhotoConfigureCNViewController()
        showDetailViewController(vc, sender: nil)
    }
    
    @objc func previewSelectPhoto() {
        showImagePicker(true)
    }
    
    @objc func librarySelectPhoto() {
        showImagePicker(false)
    }
    
    func showImagePicker(_ preview: Bool) {
        let minItemSpacing: CGFloat = 2
        let minLineSpacing: CGFloat = 2
        
        // Custom UI
        ZLPhotoUIConfiguration.default()
//            .navBarColor(.white)
//            .navViewBlurEffectOfAlbumList(nil)
//            .indexLabelBgColor(.black)
//            .indexLabelTextColor(.white)
            .minimumInteritemSpacing(minItemSpacing)
            .minimumLineSpacing(minLineSpacing)
            .columnCountBlock { Int(ceil($0 / (428.0 / 4))) }
            .showScrollToBottomBtn(true)
            
        if ZLPhotoUIConfiguration.default().languageType == .arabic {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .unspecified
        }
        
        // Custom image editor
        ZLPhotoConfiguration.default()
            .editImageConfiguration
            .imageStickerContainerView(ImageStickerContainerView())
//            .tools([.draw, .clip, .mosaic, .filter])
//            .adjustTools([.brightness, .contrast, .saturation])
            .clipRatios(ZLImageClipRatio.all)
//            .imageStickerContainerView(ImageStickerContainerView())
//            .filters([.normal, .process, ZLFilter(name: "custom", applier: ZLCustomFilter.hazeRemovalFilter)])
        
        /*
         ZLPhotoConfiguration.default()
             .cameraConfiguration
             .devicePosition(.front)
             .allowRecordVideo(false)
             .allowSwitchCamera(false)
             .showFlashSwitch(true)
          */
        ZLPhotoConfiguration.default()
            // You can first determine whether the asset is allowed to be selected.
            .canSelectAsset { _ in true }
            .didSelectAsset { _ in }
            .didDeselectAsset { _ in }
            .noAuthorityCallback { type in
                switch type {
                case .library:
                    debugPrint("No library authority")
                case .camera:
                    debugPrint("No camera authority")
                case .microphone:
                    debugPrint("No microphone authority")
                }
            }
            .gifPlayBlock { imageView, data, asset, _ in
                var animatedImageView: AnimatedImageView?
                for subView in imageView.subviews {
                    if let subView = subView as? AnimatedImageView {
                        animatedImageView = subView
                        break
                    }
                }

                if animatedImageView == nil {
                    animatedImageView = AnimatedImageView()
                    imageView.addSubview(animatedImageView!)
                }
                
                animatedImageView?.frame = imageView.bounds
                
                let provider = RawImageDataProvider(data: data, cacheKey: asset.localIdentifier)
                animatedImageView?.kf.setImage(
                    with: .provider(provider),
                    placeholder: imageView.image,
                    options: [.cacheOriginalImage]
                ) { result in
                    switch result {
                    case .success(_):
                        print("✅ GIF 加载并播放成功")
                    case .failure(_):
                        print("❌ GIF 加载失败")
                    }
                }
            }
            .pauseGIFBlock { $0.subviews.forEach { ($0 as? AnimatedImageView)?.stopAnimating() } }
            .resumeGIFBlock { $0.subviews.forEach { ($0 as? AnimatedImageView)?.startAnimating() } }
//            .operateBeforeDoneAction { currVC, block in
//                // Do something before select photo result callback, and then call block to continue done action.
//                block()
//            }
        
        /// Using this init method, you can continue editing the selected photo
        let picker = ZLPhotoPicker(results: takeSelectedAssetsSwitch.isOn ? selectedResults : nil)
        
        picker.selectImageBlock = { [weak self] results, isOriginal in
            guard let `self` = self else { return }
            self.selectedResults = results
            self.selectedImages = results.map { $0.image }
            self.selectedAssets = results.map { $0.asset }
            self.isOriginal = isOriginal
            self.collectionView.reloadData()
            debugPrint("images: \(self.selectedImages)")
            debugPrint("assets: \(self.selectedAssets)")
            debugPrint("isEdited: \(results.map { $0.isEdited })")
            debugPrint("isOriginal: \(isOriginal)")
            
//            guard !self.selectedAssets.isEmpty else { return }
//            self.saveAsset(self.selectedAssets[0])
        }
        picker.cancelBlock = {
            debugPrint("cancel select")
        }
        picker.selectImageRequestErrorBlock = { errorAssets, errorIndexs in
            debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
        }
        
        if preview {
            picker.showPreview(animate: true, sender: self)
        } else {
            picker.showPhotoLibrary(sender: self)
        }
    }
    
    func saveAsset(_ asset: PHAsset) {
        let filePath: String
        if asset.mediaType == .video {
            filePath = NSTemporaryDirectory().appendingFormat("%@.%@", UUID().uuidString, "mp4")
        } else {
            filePath = NSTemporaryDirectory().appendingFormat("%@.%@", UUID().uuidString, "jpg")
        }
        
        debugPrint("---- start saving \(filePath)")
        let url = URL(fileURLWithPath: filePath)
        ZLPhotoManager.saveAsset(asset, toFile: url) { error in
            do {
                if let error = error {
                     debugPrint("save error: \(error)")
                    return
                }
                
                debugPrint("save suc: \(url)")
                if asset.mediaType == .video {
                    _ = AVURLAsset(url: url)
                } else {
                    let data = try Data(contentsOf: url)
                    _ = UIImage(data: data)
                }
            } catch {}
        }
    }
    
    @objc func previewLocalAndNetImage() {
        var datas: [Any] = []
        // network image
        datas.append(URL(string: "https://cdn.pixabay.com/photo/2020/10/14/18/35/sign-post-5655110_1280.png")!)
        datas.append(URL(string: "https://images.pexels.com/photos/16144420/pexels-photo-16144420/free-photo-of-two-cats-sitting-under-a-tree-and-looking-up.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2")!)
        datas.append(URL(string: "http://5b0988e595225.cdn.sohucs.com/images/20190420/1d1070881fd540db817b2a3bdd967f37.gif")!)
        datas.append(URL(string: "https://cdn.pixabay.com/photo/2019/11/08/11/56/cat-4611189_1280.jpg")!)
        
        // network video
        let netVideoUrlString = "https://freevod.nf.migu.cn/mORsHmtum1AysKe3Ry%2FUb5rA1WelPRwa%2BS7ylo4qQCjcD5a2YuwiIC7rpFwwdGcgkgMxZVi%2FVZ%2Fnxf6NkQZ75HC0xnJ5rlB8UwiH8cZUuvErkVufDlxxLUBF%2FIgUEwjiq%2F%2FV%2FoxBQBVMUzAZaWTvOE5dxUFh4V3Oa489Ec%2BPw0IhEGuR64SuKk3MOszdFg0Q/600575Y9FGZ040325.mp4?msisdn=2a257d4c-1ee0-4ad8-8081-b1650c26390a&spid=600906&sid=50816168212200&timestamp=20201026155427&encrypt=70fe12c7473e6d68075e9478df40f207&k=dc156224f8d0835e&t=1603706067279&ec=2&flag=+&FN=%E5%B0%86%E6%95%85%E4%BA%8B%E5%86%99%E6%88%90%E6%88%91%E4%BB%AC"
        datas.append(URL(string: netVideoUrlString)!)
        
        // phasset
        if takeSelectedAssetsSwitch.isOn {
            datas.append(contentsOf: selectedAssets)
        }
        
        // local image
        datas.append(contentsOf:
            (1...3).compactMap { UIImage(named: "image" + String($0)) }
        )
        
        let videoSuffixs = ["mp4", "mov", "avi", "rmvb", "rm", "flv", "3gp", "wmv", "vob", "dat", "m4v", "f4v", "mkv"] // and more suffixs
        let vc = ZLImagePreviewController(datas: datas, index: 0, showSelectBtn: true) { url -> ZLURLType in
            // Just for demo.
            if url.absoluteString == netVideoUrlString {
                return .video
            }
            if let sf = url.absoluteString.split(separator: ".").last, videoSuffixs.contains(String(sf)) {
                return .video
            } else {
                return .image
            }
        } urlImageLoader: { url, imageView, progress, loadFinish in
            imageView.kf.setImage(with: url) { receivedSize, totalSize in
                let percentage = (CGFloat(receivedSize) / CGFloat(totalSize))
                debugPrint("\(percentage)")
                progress(percentage)
            } completionHandler: { _ in
                loadFinish()
            }
        }
        
        vc.delegate = self
        
        vc.netVideoCoverImageBlock = { url in
            debugPrint("Customize the cover image for the network video here. Index: \(String(describing: datas.firstIndex(where: { ($0 as? URL) == url })))")
            return nil
        }
        
        vc.doneBlock = { datas in
            debugPrint(datas)
        }
        
//        vc.longPressBlock = { (controller, image, index) in
//            debugPrint(String(describing: controller), String(describing: image), index)
//        }
        
        vc.modalPresentationStyle = .fullScreen
        showDetailViewController(vc, sender: nil)
    }
    
    @objc func showCamera() {
        // To enable tap-to-record you can also use tapToRecordVideo flag in camera config, for example:
        // ZLPhotoConfiguration.default().cameraConfiguration = ZLPhotoConfiguration.default().cameraConfiguration
        //  .tapToRecordVideo(true)
        
        let camera = ZLCustomCamera()
        camera.takeDoneBlock = { [weak self] image, videoUrl in
            self?.save(image: image, videoUrl: videoUrl)
        }
        showDetailViewController(camera, sender: nil)
    }
    
    func save(image: UIImage?, videoUrl: URL?) {
        if let image = image {
            let hud = ZLProgressHUD.show(toast: .processing)
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] error, asset in
                if error == nil, let asset {
                    let resultModel = ZLResultModel(asset: asset, image: image, isEdited: false, index: 0)
                    self?.selectedResults = [resultModel]
                    self?.selectedImages = [image]
                    self?.selectedAssets = [asset]
                    self?.collectionView.reloadData()
                } else {
                    debugPrint("保存图片到相册失败")
                }
                hud.hide()
            }
        } else if let videoUrl = videoUrl {
            let hud = ZLProgressHUD.show(toast: .processing)
            ZLPhotoManager.saveVideoToAlbum(url: videoUrl) { [weak self] error, asset in
                if error == nil, let asset {
                    self?.fetchImage(for: asset)
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
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: option) { image, info in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished, !isDegraded, let image = image {
                let resultModel = ZLResultModel(asset: asset, image: image, isEdited: false, index: 0)
                self.selectedResults = [resultModel]
                self.selectedImages = [image]
                self.selectedAssets = [asset]
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func createWeChatMomentDemo() {
        let vc = WeChatMomentDemoViewController()
        show(vc, sender: nil)
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
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        cell.imageView.image = selectedImages[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let picker = ZLPhotoPicker()
        picker.selectImageBlock = { [weak self] results, isOriginal in
            guard let `self` = self else { return }
            self.selectedResults = results
            self.selectedImages = results.map { $0.image }
            self.selectedAssets = results.map { $0.asset }
            self.isOriginal = isOriginal
            self.collectionView.reloadData()
            debugPrint("images: \(self.selectedImages)")
            debugPrint("assets: \(self.selectedAssets)")
            debugPrint("isEdited: \(results.map { $0.isEdited })")
            debugPrint("isOriginal: \(isOriginal)")
        }
        
        picker.previewAssets(sender: self, assets: selectedAssets, index: indexPath.row, isOriginal: isOriginal, showBottomViewAndSelectBtn: true)
    }
}

extension ViewController: ZLImagePreviewControllerDelegate {
    func imagePreviewController(_ controller: ZLImagePreviewController, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        debugPrint("---- willDisplay: \(cell) indexPath: \(indexPath)")
    }
    
    func imagePreviewController(_ controller: ZLImagePreviewController, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        debugPrint("---- didEndDisplaying: \(cell) indexPath: \(indexPath)")
    }
    
    func imagePreviewController(_ controller: ZLImagePreviewController, didScroll collectionView: UICollectionView) {
//        debugPrint("---- didScroll: \(collectionView)")
    }
}
