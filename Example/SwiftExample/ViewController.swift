//
//  ViewController.swift
//  SwiftExample
//
//  Created by long on 2019/9/4.
//  Copyright © 2019 long. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "ImageCell"

class ViewController: UIViewController {

    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    @IBOutlet weak var selImageSwitch: UISwitch!
    
    @IBOutlet weak var selGifSwitch: UISwitch!
    
    @IBOutlet weak var selVideoSwitch: UISwitch!
    
    @IBOutlet weak var selLivePhotoSwitch: UISwitch!
    
    @IBOutlet weak var takePhotoInLibratySwitch: UISwitch!
    
    @IBOutlet weak var rememberLastSelSwitch: UISwitch!
    
    @IBOutlet weak var showCaptureImageSwitch: UISwitch!
    
    @IBOutlet weak var forceTouchSwitch: UISwitch!
    
    @IBOutlet weak var editImageSwitch: UISwitch!
    
    @IBOutlet weak var mixSelectSwitch: UISwitch!
    
    @IBOutlet weak var editAfterSelectImageSwitch: UISwitch!
    
    @IBOutlet weak var maskSwitch: UISwitch!
    
    @IBOutlet weak var slideSelectSwitch: UISwitch!
    
    @IBOutlet weak var editVideoSwitch: UISwitch!
    
    @IBOutlet weak var dragSelectSwitch: UISwitch!
    
    @IBOutlet weak var anialysisAssetSwitch: UISwitch!
    
    @IBOutlet weak var previewTextField: UITextField!
    
    @IBOutlet weak var maxSelCountTextField: UITextField!
    
    @IBOutlet weak var cornerRadioTextField: UITextField!
    
    @IBOutlet weak var maxVideoDurationTextField: UITextField!
    
    @IBOutlet weak var languageSegment: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var lastSelectAssets: [PHAsset] = []
    
    var lastSelectImages: [UIImage] = []
    
    var images: [UIImage] = []
    
    var isOriginal: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = (UIScreen.main.bounds.width - 9) / 4
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = 1.5
        layout.minimumInteritemSpacing = 1.5
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        self.collectionView.collectionViewLayout = layout
        self.collectionView.backgroundColor = .white
        self.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func getPas() -> ZLPhotoActionSheet {
        let ac = ZLPhotoActionSheet()
        
        // MARK: 参数配置 optional
        
        // 以下参数为自定义参数，均可不设置，有默认值
        ac.configuration.sortAscending = self.sortSegment.selectedSegmentIndex == 0
        ac.configuration.allowSelectImage = self.selImageSwitch.isOn
        ac.configuration.allowSelectGif = self.selGifSwitch.isOn
        ac.configuration.allowSelectVideo = self.selVideoSwitch.isOn
        ac.configuration.allowSelectLivePhoto = self.selLivePhotoSwitch.isOn
        ac.configuration.allowForceTouch = self.forceTouchSwitch.isOn
        ac.configuration.allowEditImage = self.editImageSwitch.isOn
        ac.configuration.allowEditVideo = self.editVideoSwitch.isOn
        ac.configuration.allowSlideSelect = self.slideSelectSwitch.isOn
        ac.configuration.allowMixSelect = self.mixSelectSwitch.isOn
        ac.configuration.allowDragSelect = self.dragSelectSwitch.isOn
        // 设置相册内部显示拍照按钮
        ac.configuration.allowTakePhotoInLibrary = self.takePhotoInLibratySwitch.isOn
        // 设置在内部拍照按钮上实时显示相机俘获画面
        ac.configuration.showCaptureImageOnTakePhotoBtn = self.showCaptureImageSwitch.isOn
        // 最大预览数
        ac.configuration.maxPreviewCount = Int(self.previewTextField.text ?? "20") ?? 20
        //最大选择数
        ac.configuration.maxSelectCount = Int(self.previewTextField.text ?? "9") ?? 9
        ac.configuration.maxVideoSelectCountInMix = 3
        ac.configuration.minVideoSelectCountInMix = 1
        // 允许选择视频的最大时长
        ac.configuration.maxVideoDuration = Int(self.maxVideoDurationTextField.text ?? "120") ?? 120
        // cell 弧度
        ac.configuration.cellCornerRadio = CGFloat(Float(self.cornerRadioTextField.text ?? "0") ?? 0.0)
        // 单选模式是否显示选择按钮
//        ac.configuration.showSelectBtn = true
        // 是否在选择图片后直接进入编辑界面
        ac.configuration.editAfterSelectThumbnailImage = self.editAfterSelectImageSwitch.isOn
        // 是否保存编辑后的图片
//        ac.configuration.saveNewImageAfterEdit = false
        // 设置编辑比例
//        ac.configuration.clipRatios = [GetClipRatio(7, 1)]
        // 是否在已选择照片上显示遮罩层
        ac.configuration.showSelectedMask = self.maskSwitch.isOn
//        ac.configuration.showSelectedIndex = false
        // 颜色，状态栏样式
//        ac.configuration.previewTextColor = .brown
//        ac.configuration.showSelectedMask = UIColor.purple.withAlphaComponent(0.2)
//        ac.configuration.navBarColor = .orange
//        ac.configuration.navTitleColor = .black
        ac.configuration.shouldAnialysisAsset = self.anialysisAssetSwitch.isOn
        ac.configuration.languageType = ZLLanguageType(rawValue: UInt(self.languageSegment?.selectedSegmentIndex ?? 0))!
        // 自定义多语言
//        ac.configuration.customLanguageKeyValue = ["ZLPhotoBrowserCameraText": "没错，我就是一个相机"]
        // 自定义图片
//        ac.configuration.customImageNames = ["zl_navBack"]
        // 是否使用系统相机
//        ac.configuration.useSystemCamera = true
//        ac.configuration.sessionPreset = .preset1920x1080
//        ac.configuration.exportVideoType = .mp4
//        ac.configuration.allowRecordVideo = false
//        ac.configuration.maxRecordDuration = 5
        
        // MARK: required
        let count = Int(self.maxSelCountTextField.text ?? "9") ?? 9
        if self.rememberLastSelSwitch.isOn && count > 1 {
            ac.arrSelectedAssets = self.lastSelectAssets as? NSMutableArray
        } else {
            ac.arrSelectedAssets = nil
        }
        
        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.images = images ?? []
            self?.isOriginal = isOriginal
            self?.lastSelectAssets = assets
            self?.lastSelectImages = images ?? []
            
            if let flag = self?.anialysisAssetSwitch.isOn, flag == false {
                self?.anialysis(assets: assets, isOriginal: isOriginal)
            } else {
                self?.collectionView.reloadData()
                debugPrint("images: \(String(describing: images))")
            }
        }
        
        ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexes) in
            debugPrint("图片解析出错索引为: \(errorIndexes), 对应assets为: \(errorAssets)")
        }
        
        ac.cancleBlock = {
            debugPrint("取消选择图片")
        }
        
        ac.sender = self
        return ac
    }
    
    func anialysis(assets: [PHAsset], isOriginal: Bool) {
        guard assets.count > 0 else { return }
        
        let hud = ZLProgressHUD()
        hud.show()
        
        ZLPhotoManager.anialysisAssets(assets, original: isOriginal) { [weak self] (images) in
            hud.hide()
            self?.images = images
            self?.lastSelectImages = images
            self?.collectionView.reloadData()
            debugPrint("images: \(String(describing: images))")
        }
    }
    
    @IBAction func selectPhotoPreview(_ sender: Any) {
        self.show(preview: true)
    }
    
    @IBAction func selectPhotoLibraty(_ sender: Any) {
        self.show(preview: false)
    }
    
    @IBAction func showCamera(_ sender: Any) {
        let camera = ZLCustomCamera()
        
        camera.doneBlock = { [weak self] (image, videoUrl) in
            self?.save(image: image, videoUrl: videoUrl)
        }
        
        self.showDetailViewController(camera, sender: nil)
    }
    
    func show(preview: Bool) {
        let ac = self.getPas()
        
        if preview {
            ac.showPreview(animate: true, sender: self)
        } else {
            ac.showPhotoLibrary(sender: self)
        }
    }
    
    func save(image: UIImage?, videoUrl: URL?) {
        guard image != nil || videoUrl != nil else {
            return
        }
        
        let hud = ZLProgressHUD()
        hud.show()
        
        if let _ = image {
            ZLPhotoManager.saveImage(toAblum: image!) { [weak self] (success, asset) in
                DispatchQueue.main.async {
                    if success {
                        self?.images = [image!]
                        self?.lastSelectImages = [image!]
                        self?.lastSelectAssets = [asset]
                        self?.collectionView.reloadData()
                    } else {
                        debugPrint("图片保存失败")
                    }
                    hud.hide()
                }
            }
        } else if let _ = videoUrl {
            ZLPhotoManager.saveVideo(toAblum: videoUrl!) { [weak self] (success, asset) in
                DispatchQueue.main.async {
                    if success {
                        ZLPhotoManager.requestImage(for: asset, size: CGSize(width: 300, height: 300), progressHandler: nil) { [weak self] (image, info) in
                            let flag = info[PHImageResultIsDegradedKey] as? Bool
                            if flag == true {
                                return
                            }
                            
                            self?.images = [image]
                            self?.lastSelectImages = [image]
                            self?.lastSelectAssets = [asset]
                            self?.collectionView.reloadData()
                            hud.hide()
                        }
                    } else {
                        debugPrint("视频保存失败")
                        hud.hide()
                    }
                }
            }
        }
    }
    
    @IBAction func previewNetImageAndVideo(_ sender: Any) {
        let arr = [
            GetDictForPreviewPhoto(URL(string: "http://i4.chuimg.com/e71fbe7ecebb11e9b33002420a001066_720w_1280h.mp4")!, .urlVideo)!,
            GetDictForPreviewPhoto(URL(string: "http://pic.962.net/up/2013-11/20131111660842025734.jpg")!, .urlImage)!,
            GetDictForPreviewPhoto(URL(string: "http://pic.962.net/up/2013-11/20131111660842034354.jpg")!, .urlImage)!,
            GetDictForPreviewPhoto(URL(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1514184259027&di=a2e54cf2d5affe17acdaf1fbf19ff0af&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201212%2F25%2F20121225173302_wTjN8.jpeg")!, .urlImage)!,
            GetDictForPreviewPhoto(URL(string: "http://i4.chuimg.com/956b3172a2e111e9b17402420a00105a_720w_1280h.mp4")!, .urlVideo)!,
            GetDictForPreviewPhoto(URL(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566386966005&di=adba0acdc81f732d75a1cc5a47f36c46&imgtype=0&src=http%3A%2F%2Fmsp.baidu.com%2Fv1%2Fmediaspot%2F968f19dc612b9e6d2f84a5149cd38b17.gif")!, .urlImage)!
        ]
        
        self.getPas().previewPhotos(arr, index: 0, hideToolBar: false) { (photos) in
            debugPrint("\(photos)")
        }
    }
    
    @IBAction func valueChanged(_ sender: UISwitch) {
        if sender == self.selImageSwitch {
            if !sender.isOn {
                self.selGifSwitch.setOn(false, animated: true)
                self.selLivePhotoSwitch.setOn(false, animated: true)
                self.editImageSwitch.setOn(false, animated: true)
                self.selVideoSwitch.setOn(true, animated: true)
            }
        } else if sender == self.selGifSwitch ||
                sender == self.selLivePhotoSwitch {
            if sender.isOn {
                self.selImageSwitch.setOn(true, animated: true)
            }
        } else if sender == self.selVideoSwitch {
            if !sender.isOn {
                self.selImageSwitch.setOn(true, animated: true)
            }
        } else if sender == self.editImageSwitch || sender == self.editVideoSwitch {
            if !self.editImageSwitch.isOn, !self.editVideoSwitch.isOn {
                self.editAfterSelectImageSwitch.setOn(false, animated: true)
            }
        }
    }
    
}


extension ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.previewTextField {
            guard let str = textField.text else {
                textField.text = "20"
                return
            }
            guard let value = Int(str) else {
                textField.text = "20"
                return
            }
            let v = min(max(0, value), 50)
            
            textField.text = String(v)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ImageCell
        
        cell.imageView.image = self.images[indexPath.row]
        cell.playImageView.isHidden = !(self.lastSelectAssets[indexPath.row].mediaType == .video)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.getPas().previewSelectedPhotos(self.lastSelectImages, assets: self.lastSelectAssets, index: indexPath.row, isOriginal: self.isOriginal)
    }
    
}
