//
//  PhotoConfigureViewController.swift
//  Example
//
//  Created by long on 2020/8/24.
//

import UIKit
import ZLPhotoBrowser

class PhotoConfigureViewController: UIViewController {

    let config = ZLPhotoConfiguration.default()
    
    var scrollView: UIScrollView!
    
    var previewCountTextField: UITextField!
    
    var selectCountTextField: UITextField!
    
    var minVideoDurationTextField: UITextField!
    
    var maxVideoDurationTextField: UITextField!
    
    var cellRadiusTextField: UITextField!
    
    var languageSegment: UISegmentedControl!
    
    var sortAscendingSegment: UISegmentedControl!
    
    var allowSelectImageSwitch: UISwitch!
    
    var allowSelectGifSwitch: UISwitch!
    
    var allowSelectLivePhotoSwitch: UISwitch!
    
    var allowSelectOriginalSwitch: UISwitch!
    
    var allowSelectVideoSwitch: UISwitch!
    
    var allowMixSelectSwitch: UISwitch!
    
    var allowEditImageSwitch: UISwitch!
    
    var saveEditImageSwitch: UISwitch!
    
    var allowEditVideoSwitch: UISwitch!
    
    var allowDragSelectSwitch: UISwitch!
    
    var allowSlideSelectSwitch: UISwitch!
    
    var allowTakePhotoInLibrarySwitch: UISwitch!
    
    var showCaptureInCameraCellSwitch: UISwitch!
    
    var showSelectIndexSwitch: UISwitch!
    
    var showSelectMaskSwitch: UISwitch!
    
    var showInvalidSelectMaskSwitch: UISwitch!
    
    var useCustomCameraSwitch: UISwitch!
    
    var cameraFlashSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .white
        
        self.scrollView = UIScrollView()
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.keyboardDismissMode = .onDrag
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        let containerView = UIView()
        self.scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
        }
        
        func createLabel(_ title: String) -> UILabel {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .black
            label.text = title
            return label
        }
        
        func createTextField(_ text: String?, _ keyboardType: UIKeyboardType) -> UITextField {
            let field = UITextField()
            field.font = UIFont.systemFont(ofSize: 14)
            field.textColor = .black
            field.borderStyle = .roundedRect
            field.delegate = self
            field.keyboardType = keyboardType
            field.text = text
            return field
        }
        
        let velSpacing: CGFloat = 20
        let horSpacing: CGFloat = 20
        let fieldSize = CGSize(width: 100, height: 30)
        
        let tipsLabel = createLabel("更多参数设置，请前往ZLPhotoConfiguration查看")
        tipsLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        tipsLabel.numberOfLines = 2
        tipsLabel.lineBreakMode = .byWordWrapping
        containerView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
        }
        
        let dismissBtn = UIButton(type: .custom)
        dismissBtn.setTitle("完成", for: .normal)
        dismissBtn.addTarget(self, action: #selector(dismissBtnClick), for: .touchUpInside)
        dismissBtn.layer.cornerRadius = 5
        dismissBtn.layer.masksToBounds = true
        dismissBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        dismissBtn.backgroundColor = .black
        if #available(iOS 13.0, *) {
        } else {
            self.view.addSubview(dismissBtn)
            dismissBtn.snp.makeConstraints { (make) in
                make.top.equalTo(tipsLabel.snp.bottom).offset(velSpacing)
                make.left.equalTo(tipsLabel.snp.left)
                make.width.equalTo(60)
            }
        }
        
        // 预览张数
        let previewCountLabel = createLabel("最大预览张数")
        containerView.addSubview(previewCountLabel)
        if #available(iOS 13.0, *) {
            previewCountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tipsLabel.snp.bottom).offset(velSpacing)
                make.left.equalTo(tipsLabel.snp.left)
            }
        } else {
            previewCountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(dismissBtn.snp.bottom).offset(velSpacing)
                make.left.equalTo(tipsLabel.snp.left)
            }
        }
        
        self.previewCountTextField = createTextField(String(config.maxPreviewCount), .numberPad)
        containerView.addSubview(self.previewCountTextField)
        self.previewCountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(previewCountLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(previewCountLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 最大选择张数
        let maxSelectCountLabel = createLabel("最大选择张数")
        containerView.addSubview(maxSelectCountLabel)
        maxSelectCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(previewCountLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.selectCountTextField = createTextField(String(config.maxSelectCount), .numberPad)
        containerView.addSubview(self.selectCountTextField)
        self.selectCountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(maxSelectCountLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(maxSelectCountLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 视频最小选择时长
        let minVideoDurationLabel = createLabel("视频选择最小时长")
        containerView.addSubview(minVideoDurationLabel)
        minVideoDurationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(maxSelectCountLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.minVideoDurationTextField = createTextField(String(config.minSelectVideoDuration), .numberPad)
        containerView.addSubview(self.minVideoDurationTextField)
        self.minVideoDurationTextField.snp.makeConstraints { (make) in
            make.left.equalTo(minVideoDurationLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(minVideoDurationLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 视频最大选择时长
        let maxVideoDurationLabel = createLabel("视频选择最大时长")
        containerView.addSubview(maxVideoDurationLabel)
        maxVideoDurationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(minVideoDurationLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.maxVideoDurationTextField = createTextField(String(config.maxSelectVideoDuration), .numberPad)
        containerView.addSubview(self.maxVideoDurationTextField)
        self.maxVideoDurationTextField.snp.makeConstraints { (make) in
            make.left.equalTo(maxVideoDurationLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(maxVideoDurationLabel)
            make.size.equalTo(fieldSize)
        }
        
        // cell圆角
        let cellRadiusLabel = createLabel("cell圆角")
        containerView.addSubview(cellRadiusLabel)
        cellRadiusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(maxVideoDurationLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.cellRadiusTextField = createTextField(String(format: "%.2f", config.cellCornerRadio), .decimalPad)
        containerView.addSubview(self.cellRadiusTextField)
        self.cellRadiusTextField.snp.makeConstraints { (make) in
            make.left.equalTo(cellRadiusLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(cellRadiusLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 框架语言
        let languageLabel = createLabel("框架语言")
        containerView.addSubview(languageLabel)
        languageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(cellRadiusLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.languageSegment = UISegmentedControl(items: ["跟随系统", "中文简", "中文繁", "英文", "日文"])
        self.languageSegment.selectedSegmentIndex = config.languageType.rawValue
        self.languageSegment.addTarget(self, action: #selector(languageSegmentChanged), for: .valueChanged)
        containerView.addSubview(self.languageSegment)
        self.languageSegment.snp.makeConstraints { (make) in
            make.top.equalTo(languageLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
            make.right.equalTo(containerView).offset(-20)
        }
        
        // 排序方式
        let sortLabel = createLabel("排序方式")
        containerView.addSubview(sortLabel)
        sortLabel.snp.makeConstraints { (make) in
            make.top.equalTo(languageSegment.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.sortAscendingSegment = UISegmentedControl(items: ["升序", "降序"])
        self.sortAscendingSegment.selectedSegmentIndex = config.sortAscending ? 0 : 1
        self.sortAscendingSegment.addTarget(self, action: #selector(sortAscendingChanged), for: .valueChanged)
        containerView.addSubview(self.sortAscendingSegment)
        self.sortAscendingSegment.snp.makeConstraints { (make) in
            make.left.equalTo(sortLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(sortLabel)
        }
        
        // 选择图片开关
        let selImageLabel = createLabel("允许选择图片")
        containerView.addSubview(selImageLabel)
        selImageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(sortLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowSelectImageSwitch = UISwitch()
        self.allowSelectImageSwitch.isOn = config.allowSelectImage
        self.allowSelectImageSwitch.addTarget(self, action: #selector(allowSelectImageChanged), for: .valueChanged)
        containerView.addSubview(self.allowSelectImageSwitch)
        self.allowSelectImageSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(selImageLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selImageLabel)
        }
        
        // 选择gif开关
        let selGifLabel = createLabel("允许选择Gif")
        containerView.addSubview(selGifLabel)
        selGifLabel.snp.makeConstraints { (make) in
            make.top.equalTo(selImageLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowSelectGifSwitch = UISwitch()
        self.allowSelectGifSwitch.isOn = config.allowSelectGif
        self.allowSelectGifSwitch.addTarget(self, action: #selector(allowSelectGifChanged), for: .valueChanged)
        containerView.addSubview(self.allowSelectGifSwitch)
        self.allowSelectGifSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(selGifLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selGifLabel)
        }
        
        // 选择livePhoto开关
        let selLivePhotoLabel = createLabel("允许选择LivePhoto")
        containerView.addSubview(selLivePhotoLabel)
        selLivePhotoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(selGifLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowSelectLivePhotoSwitch = UISwitch()
        self.allowSelectLivePhotoSwitch.isOn = config.allowSelectLivePhoto
        self.allowSelectLivePhotoSwitch.addTarget(self, action: #selector(allowSelectLivePhotoChanged), for: .valueChanged)
        containerView.addSubview(self.allowSelectLivePhotoSwitch)
        self.allowSelectLivePhotoSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(selLivePhotoLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selLivePhotoLabel)
        }
        
        // 选择livePhoto开关
        let selOriginalLabel = createLabel("允许选择原图")
        containerView.addSubview(selOriginalLabel)
        selOriginalLabel.snp.makeConstraints { (make) in
            make.top.equalTo(selLivePhotoLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowSelectOriginalSwitch = UISwitch()
        self.allowSelectOriginalSwitch.isOn = config.allowSelectOriginal
        self.allowSelectOriginalSwitch.addTarget(self, action: #selector(allowSelectOriginalChanged), for: .valueChanged)
        containerView.addSubview(self.allowSelectOriginalSwitch)
        self.allowSelectOriginalSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(selOriginalLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selOriginalLabel)
        }
        
        // 选择视频开关
        let selVideoLabel = createLabel("允许选择视频")
        containerView.addSubview(selVideoLabel)
        selVideoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(selOriginalLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowSelectVideoSwitch = UISwitch()
        self.allowSelectVideoSwitch.isOn = config.allowSelectVideo
        self.allowSelectVideoSwitch.addTarget(self, action: #selector(allowSelectVideoChanged), for: .valueChanged)
        containerView.addSubview(self.allowSelectVideoSwitch)
        self.allowSelectVideoSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(selVideoLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selVideoLabel)
        }
        
        // 混合选择开关
        let mixSelectLabel = createLabel("允许图片视频一起选择")
        containerView.addSubview(mixSelectLabel)
        mixSelectLabel.snp.makeConstraints { (make) in
            make.top.equalTo(selVideoLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowMixSelectSwitch = UISwitch()
        self.allowMixSelectSwitch.isOn = config.allowMixSelect
        self.allowMixSelectSwitch.addTarget(self, action: #selector(allowMixSelectChanged), for: .valueChanged)
        containerView.addSubview(self.allowMixSelectSwitch)
        self.allowMixSelectSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(mixSelectLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(mixSelectLabel)
        }
        
        // 编辑图片开关
        let editImageLabel = createLabel("允许编辑图片")
        containerView.addSubview(editImageLabel)
        editImageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mixSelectLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowEditImageSwitch = UISwitch()
        self.allowEditImageSwitch.isOn = config.allowEditImage
        self.allowEditImageSwitch.addTarget(self, action: #selector(allowEditImageChanged), for: .valueChanged)
        containerView.addSubview(self.allowEditImageSwitch)
        self.allowEditImageSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(editImageLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(editImageLabel)
        }
        
        // 编辑视频开关
        let editVideoLabel = createLabel("允许编辑视频")
        containerView.addSubview(editVideoLabel)
        editVideoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(editImageLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowEditVideoSwitch = UISwitch()
        self.allowEditVideoSwitch.isOn = config.allowEditVideo
        self.allowEditVideoSwitch.addTarget(self, action: #selector(allowEditVideoChanged), for: .valueChanged)
        containerView.addSubview(self.allowEditVideoSwitch)
        self.allowEditVideoSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(editVideoLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(editVideoLabel)
        }
        
        // 保存编辑图片开关
        let saveEditImageLabel = createLabel("保存编辑的图片")
        containerView.addSubview(saveEditImageLabel)
        saveEditImageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(editVideoLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.saveEditImageSwitch = UISwitch()
        self.saveEditImageSwitch.isOn = config.saveNewImageAfterEdit
        self.saveEditImageSwitch.addTarget(self, action: #selector(saveEditImageChanged), for: .valueChanged)
        containerView.addSubview(self.saveEditImageSwitch)
        self.saveEditImageSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(saveEditImageLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(saveEditImageLabel)
        }
        
        // 拖拽选择开关
        let dragSelectLabel = createLabel("允许拖拽选择")
        containerView.addSubview(dragSelectLabel)
        dragSelectLabel.snp.makeConstraints { (make) in
            make.top.equalTo(saveEditImageLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowDragSelectSwitch = UISwitch()
        self.allowDragSelectSwitch.isOn = config.allowDragSelect
        self.allowDragSelectSwitch.addTarget(self, action: #selector(allowDragSelectChanged), for: .valueChanged)
        containerView.addSubview(self.allowDragSelectSwitch)
        self.allowDragSelectSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(dragSelectLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(dragSelectLabel)
        }
        
        // 滑动拖拽开关
        let slideSelectLabel = createLabel("允许滑动选择")
        containerView.addSubview(slideSelectLabel)
        slideSelectLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dragSelectLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowSlideSelectSwitch = UISwitch()
        self.allowSlideSelectSwitch.isOn = config.allowSlideSelect
        self.allowSlideSelectSwitch.addTarget(self, action: #selector(allowSlideSelectChanged), for: .valueChanged)
        containerView.addSubview(self.allowSlideSelectSwitch)
        self.allowSlideSelectSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(slideSelectLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(slideSelectLabel)
        }
        
        // 滑动拖拽开关
        let takePhotoLabel = createLabel("允许相册内部拍照")
        containerView.addSubview(takePhotoLabel)
        takePhotoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(slideSelectLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowTakePhotoInLibrarySwitch = UISwitch()
        self.allowTakePhotoInLibrarySwitch.isOn = config.allowTakePhotoInLibrary
        self.allowTakePhotoInLibrarySwitch.addTarget(self, action: #selector(allowTakePhotoInLibraryChanged), for: .valueChanged)
        containerView.addSubview(self.allowTakePhotoInLibrarySwitch)
        self.allowTakePhotoInLibrarySwitch.snp.makeConstraints { (make) in
            make.left.equalTo(takePhotoLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(takePhotoLabel)
        }
        
        // 相册内部拍照cell显示实时画面
        let showCaptureLabel = createLabel("拍照cell显示相机俘获画面")
        containerView.addSubview(showCaptureLabel)
        showCaptureLabel.snp.makeConstraints { (make) in
            make.top.equalTo(takePhotoLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.showCaptureInCameraCellSwitch = UISwitch()
        self.showCaptureInCameraCellSwitch.isOn = config.showCaptureImageOnTakePhotoBtn
        self.showCaptureInCameraCellSwitch.addTarget(self, action: #selector(showCaptureInCameraCellChanged), for: .valueChanged)
        containerView.addSubview(self.showCaptureInCameraCellSwitch)
        self.showCaptureInCameraCellSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(showCaptureLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showCaptureLabel)
        }
        
        // 显示已选选择照片index
        let showSelectIndexLabel = createLabel("显示已选择照片index")
        containerView.addSubview(showSelectIndexLabel)
        showSelectIndexLabel.snp.makeConstraints { (make) in
            make.top.equalTo(showCaptureLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.showSelectIndexSwitch = UISwitch()
        self.showSelectIndexSwitch.isOn = config.showSelectedIndex
        self.showSelectIndexSwitch.addTarget(self, action: #selector(showSelectIndexChanged), for: .valueChanged)
        containerView.addSubview(self.showSelectIndexSwitch)
        self.showSelectIndexSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(showSelectIndexLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showSelectIndexLabel)
        }
        
        // 显示已选选择照片遮罩
        let showSelectMaskLabel = createLabel("显示已选择照片遮罩")
        containerView.addSubview(showSelectMaskLabel)
        showSelectMaskLabel.snp.makeConstraints { (make) in
            make.top.equalTo(showSelectIndexLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.showSelectMaskSwitch = UISwitch()
        self.showSelectMaskSwitch.isOn = config.showSelectedMask
        self.showSelectMaskSwitch.addTarget(self, action: #selector(showSelectMaskChanged), for: .valueChanged)
        containerView.addSubview(self.showSelectMaskSwitch)
        self.showSelectMaskSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(showSelectMaskLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showSelectMaskLabel)
        }
        
        // 显示不可选状态照片遮罩
        let showInvalidMaskLabel = createLabel("显示不可选状态照片遮罩")
        containerView.addSubview(showInvalidMaskLabel)
        showInvalidMaskLabel.snp.makeConstraints { (make) in
            make.top.equalTo(showSelectMaskLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.showInvalidSelectMaskSwitch = UISwitch()
        self.showInvalidSelectMaskSwitch.isOn = config.showInvalidMask
        self.showInvalidSelectMaskSwitch.addTarget(self, action: #selector(showInvalidSelectMaskChanged), for: .valueChanged)
        containerView.addSubview(self.showInvalidSelectMaskSwitch)
        self.showInvalidSelectMaskSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(showInvalidMaskLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showInvalidMaskLabel)
        }
        
        // 使用自定义相机
        let useCustomCameraLabel = createLabel("使用自定义相机")
        containerView.addSubview(useCustomCameraLabel)
        useCustomCameraLabel.snp.makeConstraints { (make) in
            make.top.equalTo(showInvalidMaskLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.useCustomCameraSwitch = UISwitch()
        self.useCustomCameraSwitch.isOn = config.useCustomCamera
        self.useCustomCameraSwitch.addTarget(self, action: #selector(useCustomCameraChanged), for: .valueChanged)
        containerView.addSubview(self.useCustomCameraSwitch)
        self.useCustomCameraSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(useCustomCameraLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(useCustomCameraLabel)
        }
        
        // 闪光灯模式
        let cameraFlashLabel = createLabel("闪光灯模式")
        containerView.addSubview(cameraFlashLabel)
        cameraFlashLabel.snp.makeConstraints { (make) in
            make.top.equalTo(useCustomCameraLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.cameraFlashSegment = UISegmentedControl(items: ["自动", "打开", "关闭"])
        cameraFlashSegment.selectedSegmentIndex = config.cameraFlashMode.rawValue
        self.cameraFlashSegment.addTarget(self, action: #selector(cameraFlashSegmentChanged), for: .valueChanged)
        containerView.addSubview(self.cameraFlashSegment)
        self.cameraFlashSegment.snp.makeConstraints { (make) in
            make.left.equalTo(cameraFlashLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(cameraFlashLabel)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
        }
    }
    
    @objc func dismissBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func languageSegmentChanged() {
        config.languageType = ZLLanguageType(rawValue: languageSegment.selectedSegmentIndex)!
    }
    
    @objc func sortAscendingChanged() {
        let index = self.sortAscendingSegment.selectedSegmentIndex
        config.sortAscending = index == 0
    }
    
    @objc func allowSelectImageChanged() {
        let allow = allowSelectImageSwitch.isOn
        config.allowSelectImage = allow
        if !allow {
            config.allowSelectGif = allow
            config.allowSelectLivePhoto = allow
            config.allowSelectOriginal = allow
            config.allowSelectVideo = !allow
            
            allowSelectGifSwitch.setOn(allow, animated: true)
            allowSelectLivePhotoSwitch.setOn(allow, animated: true)
            allowSelectOriginalSwitch.setOn(allow, animated: true)
            allowSelectVideoSwitch.setOn(!allow, animated: true)
        }
    }
    
    @objc func allowSelectGifChanged() {
        config.allowSelectGif = allowSelectGifSwitch.isOn
    }
    
    @objc func allowSelectLivePhotoChanged() {
        config.allowSelectLivePhoto = allowSelectLivePhotoSwitch.isOn
    }
    
    @objc func allowSelectOriginalChanged() {
        config.allowSelectOriginal = allowSelectOriginalSwitch.isOn
    }
    
    @objc func allowSelectVideoChanged() {
        let allow = allowSelectVideoSwitch.isOn
        config.allowSelectVideo = allow
        if !allow {
            config.allowSelectImage = !allow
            allowSelectImageSwitch.setOn(!allow, animated: true)
        }
    }
    
    @objc func allowMixSelectChanged() {
        config.allowMixSelect = allowMixSelectSwitch.isOn
    }
    
    @objc func allowEditImageChanged() {
        config.allowEditImage = allowEditImageSwitch.isOn
    }
    
    @objc func saveEditImageChanged() {
        config.saveNewImageAfterEdit = saveEditImageSwitch.isOn
    }
    
    @objc func allowEditVideoChanged() {
        config.allowEditVideo = allowEditVideoSwitch.isOn
    }
    
    @objc func allowDragSelectChanged() {
        config.allowDragSelect = allowDragSelectSwitch.isOn
    }
    
    @objc func allowSlideSelectChanged() {
        config.allowSlideSelect = allowSlideSelectSwitch.isOn
    }
    
    @objc func allowTakePhotoInLibraryChanged() {
        config.allowTakePhotoInLibrary = allowTakePhotoInLibrarySwitch.isOn
    }
    
    @objc func showCaptureInCameraCellChanged() {
        config.showCaptureImageOnTakePhotoBtn = showCaptureInCameraCellSwitch.isOn
        
    }
    
    @objc func showSelectIndexChanged() {
        config.showSelectedIndex = showSelectIndexSwitch.isOn
    }
    
    @objc func showSelectMaskChanged() {
        config.showSelectedMask = showSelectMaskSwitch.isOn
    }
    
    @objc func showInvalidSelectMaskChanged() {
        config.showInvalidMask = showInvalidSelectMaskSwitch.isOn
    }
    
    @objc func useCustomCameraChanged() {
        config.useCustomCamera = useCustomCameraSwitch.isOn
    }
    
    @objc func cameraFlashSegmentChanged() {
        config.cameraFlashMode = ZLCustomCamera.CameraFlashMode(rawValue: cameraFlashSegment.selectedSegmentIndex)!
    }

    
}


extension PhotoConfigureViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.previewCountTextField {
            config.maxPreviewCount = Int(textField.text ?? "") ?? 20
        } else if textField == self.selectCountTextField {
            config.maxSelectCount = Int(textField.text ?? "") ?? 9
        } else if textField == self.minVideoDurationTextField {
            config.minSelectVideoDuration = Int(textField.text ?? "") ?? 0
        } else if textField == self.maxVideoDurationTextField {
            config.maxSelectVideoDuration = Int(textField.text ?? "") ?? 120
        } else if textField == self.cellRadiusTextField {
            config.cellCornerRadio = CGFloat(Double(textField.text ?? "") ?? 0)
        }
    }
    
}
