//
//  PhotoConfigureCNViewController.swift
//  Example
//
//  Created by long on 2020/10/20.
//

import UIKit
import ZLPhotoBrowser

class PhotoConfigureCNViewController: UIViewController {

    let config = ZLPhotoConfiguration.default()
    
    var scrollView: UIScrollView!
    
    var previewCountTextField: UITextField!
    
    var selectCountTextField: UITextField!
    
    var minVideoSelectCountTextField: UITextField!
    
    var maxVideoSelectCountTextField: UITextField!
    
    var minVideoDurationTextField: UITextField!
    
    var maxVideoDurationTextField: UITextField!
    
    var cellRadiusTextField: UITextField!
    
    var styleSegment: UISegmentedControl!
    
    var languageButton: UIButton!
    
    var columnCountLabel: UILabel!
    
    var columnStepper: UIStepper!
    
    var sortAscendingSegment: UISegmentedControl!
    
    var allowSelectImageSwitch: UISwitch!
    
    var allowSelectGifSwitch: UISwitch!
    
    var allowSelectLivePhotoSwitch: UISwitch!
    
    var allowSelectOriginalSwitch: UISwitch!
    
    var allowSelectVideoSwitch: UISwitch!
    
    var allowMixSelectSwitch: UISwitch!
    
    var allowPreviewPhotosSwitch: UISwitch!
    
    var editImageLabel: UILabel!
    
    var allowEditImageSwitch: UISwitch!
    
    var editImageToolView: UIView!
    
    var editImageDrawToolSwitch: UISwitch!
    
    var editImageClipToolSwitch: UISwitch!
    
    var editImageImageStickerToolSwitch: UISwitch!
    
    var editImageTextStickerToolSwitch: UISwitch!
    
    var editImageMosaicToolSwitch: UISwitch!
    
    var editImageFilterToolSwitch: UISwitch!
    
    var editImageAdjustToolSwitch = UISwitch()
    
    var editImageAdjustToolView = UIView()
    
    var editImageBrightnessSwitch = UISwitch()
    
    var editImageContrastSwitch = UISwitch()
    
    var editImageSaturationSwitch = UISwitch()
    
    var saveEditImageSwitch: UISwitch!
    
    var editVideoLabel: UILabel!
    
    var allowEditVideoSwitch: UISwitch!
    
    var allowDragSelectSwitch: UISwitch!
    
    var allowSlideSelectSwitch: UISwitch!
    
    var autoScrollSwitch: UISwitch!
    
    var autoScrollMaxSpeedTextField: UITextField!
    
    var allowTakePhotoInLibrarySwitch: UISwitch!
    
    var showCaptureInCameraCellSwitch: UISwitch!
    
    var showSelectIndexSwitch: UISwitch!
    
    var showSelectMaskSwitch: UISwitch!
    
    var showSelectBorderSwitch: UISwitch!
    
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
        
        // 视频最小选择个数
        let minVideoSelectCountLabel = createLabel("视频最小选择数")
        containerView.addSubview(minVideoSelectCountLabel)
        minVideoSelectCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(maxSelectCountLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.minVideoSelectCountTextField = createTextField(String(config.minVideoSelectCount), .numberPad)
        containerView.addSubview(self.minVideoSelectCountTextField)
        self.minVideoSelectCountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(minVideoSelectCountLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(minVideoSelectCountLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 视频最大选择个数
        let maxVideoSelectCountLabel = createLabel("视频最大选择数")
        containerView.addSubview(maxVideoSelectCountLabel)
        maxVideoSelectCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(minVideoSelectCountLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.maxVideoSelectCountTextField = createTextField(String(config.maxVideoSelectCount), .numberPad)
        containerView.addSubview(self.maxVideoSelectCountTextField)
        self.maxVideoSelectCountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(maxVideoSelectCountLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(maxVideoSelectCountLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 视频最小选择时长
        let minVideoDurationLabel = createLabel("视频选择最小时长")
        containerView.addSubview(minVideoDurationLabel)
        minVideoDurationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(maxVideoSelectCountLabel.snp.bottom).offset(velSpacing)
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
        
        // 相册样式
        let styleLabel = createLabel("相册样式")
        containerView.addSubview(styleLabel)
        styleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(cellRadiusLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.styleSegment = UISegmentedControl(items: ["样式一(仿微信)", "样式二(传统)"])
        self.styleSegment.selectedSegmentIndex = config.style.rawValue
        self.styleSegment.addTarget(self, action: #selector(styleSegmentChanged), for: .valueChanged)
        containerView.addSubview(self.styleSegment)
        self.styleSegment.snp.makeConstraints { (make) in
            make.left.equalTo(styleLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(styleLabel)
        }
        
        // 框架语言
        let languageLabel = createLabel("框架语言")
        containerView.addSubview(languageLabel)
        languageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(styleLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.languageButton = UIButton(type: .custom)
        self.languageButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.languageButton.setTitle(config.languageType.toString(), for: .normal)
        self.languageButton.addTarget(self, action: #selector(languageButtonClick), for: .touchUpInside)
        self.languageButton.setTitleColor(.white, for: .normal)
        self.languageButton.layer.cornerRadius = 5
        self.languageButton.layer.masksToBounds = true
        self.languageButton.backgroundColor = .black
        containerView.addSubview(self.languageButton)
        self.languageButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(languageLabel)
            make.left.equalTo(languageLabel.snp.right).offset(horSpacing)
        }
        
        // 每列个数
        let columnCountTitleLabel = createLabel("每行显示照片个数")
        containerView.addSubview(columnCountTitleLabel)
        columnCountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(languageLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.columnCountLabel = createLabel(String(config.columnCount))
        containerView.addSubview(self.columnCountLabel)
        self.columnCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(columnCountTitleLabel.snp.right).offset(10)
            make.centerY.equalTo(columnCountTitleLabel.snp.centerY)
        }
        
        self.columnStepper = UIStepper()
        self.columnStepper.minimumValue = 2
        self.columnStepper.maximumValue = 6
        self.columnStepper.stepValue = 1
        self.columnStepper.value = Double(config.columnCount)
        self.columnStepper.addTarget(self, action: #selector(columnStepperValueChanged), for: .valueChanged)
        containerView.addSubview(self.columnStepper)
        self.columnStepper.snp.makeConstraints { (make) in
            make.centerY.equalTo(columnCountTitleLabel.snp.centerY)
            make.left.equalTo(columnCountLabel.snp.right).offset(horSpacing)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        
        // 排序方式
        let sortLabel = createLabel("排序方式")
        containerView.addSubview(sortLabel)
        sortLabel.snp.makeConstraints { (make) in
            make.top.equalTo(columnCountTitleLabel.snp.bottom).offset(velSpacing)
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
        
        // 预览大图开关
        let previewPhotosLabel = createLabel("允许进入大图界面")
        containerView.addSubview(previewPhotosLabel)
        previewPhotosLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mixSelectLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.allowPreviewPhotosSwitch = UISwitch()
        self.allowPreviewPhotosSwitch.isOn = config.allowPreviewPhotos
        self.allowPreviewPhotosSwitch.addTarget(self, action: #selector(allowPreviewPhotoChanged), for: .valueChanged)
        containerView.addSubview(self.allowPreviewPhotosSwitch)
        self.allowPreviewPhotosSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(previewPhotosLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(previewPhotosLabel)
        }
        
        // 编辑图片开关
        editImageLabel = createLabel("允许编辑图片")
        containerView.addSubview(editImageLabel)
        editImageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(previewPhotosLabel.snp.bottom).offset(velSpacing)
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
        
        // 编辑图片工具
        self.editImageToolView = UIView()
        self.editImageToolView.alpha = config.allowEditImage ? 1 : 0
        containerView.addSubview(self.editImageToolView)
        self.editImageToolView.snp.makeConstraints { (make) in
            make.top.equalTo(self.allowEditImageSwitch.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
            make.right.equalTo(containerView)
        }
        
        // 涂鸦
        let drawToolLabel = createLabel("涂鸦")
        self.editImageToolView.addSubview(drawToolLabel)
        drawToolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.editImageToolView)
            make.left.equalTo(self.editImageToolView)
        }
        
        let editImageConfig = config.editImageConfiguration
        
        self.editImageDrawToolSwitch = UISwitch()
        self.editImageDrawToolSwitch.isOn = editImageConfig.tools.contains(.draw)
        self.editImageDrawToolSwitch.addTarget(self, action: #selector(drawToolChanged), for: .valueChanged)
        self.editImageToolView.addSubview(self.editImageDrawToolSwitch)
        self.editImageDrawToolSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(drawToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(drawToolLabel)
        }
        
        // 裁剪
        let clipToolLabel = createLabel("裁剪")
        self.editImageToolView.addSubview(clipToolLabel)
        clipToolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(drawToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        self.editImageClipToolSwitch = UISwitch()
        self.editImageClipToolSwitch.isOn = editImageConfig.tools.contains(.clip)
        self.editImageClipToolSwitch.addTarget(self, action: #selector(clipToolChanged), for: .valueChanged)
        self.editImageToolView.addSubview(self.editImageClipToolSwitch)
        self.editImageClipToolSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(clipToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(clipToolLabel)
        }
        
        // 贴图
        let imageStickerToolLabel = createLabel("贴图")
        self.editImageToolView.addSubview(imageStickerToolLabel)
        imageStickerToolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(clipToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        self.editImageImageStickerToolSwitch = UISwitch()
        self.editImageImageStickerToolSwitch.isOn = editImageConfig.tools.contains(.imageSticker)
        self.editImageImageStickerToolSwitch.addTarget(self, action: #selector(imageStickerToolChanged), for: .valueChanged)
        self.editImageToolView.addSubview(self.editImageImageStickerToolSwitch)
        self.editImageImageStickerToolSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(imageStickerToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(imageStickerToolLabel)
        }
        
        // 文本
        let textStickerToolLabel = createLabel("文本")
        self.editImageToolView.addSubview(textStickerToolLabel)
        textStickerToolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageStickerToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        self.editImageTextStickerToolSwitch = UISwitch()
        self.editImageTextStickerToolSwitch.isOn = editImageConfig.tools.contains(.textSticker)
        self.editImageTextStickerToolSwitch.addTarget(self, action: #selector(textStickerToolChanged), for: .valueChanged)
        self.editImageToolView.addSubview(self.editImageTextStickerToolSwitch)
        self.editImageTextStickerToolSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(textStickerToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(textStickerToolLabel)
        }
        
        // 马赛克
        let mosaicToolLabel = createLabel("马赛克")
        self.editImageToolView.addSubview(mosaicToolLabel)
        mosaicToolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textStickerToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        self.editImageMosaicToolSwitch = UISwitch()
        self.editImageMosaicToolSwitch.isOn = editImageConfig.tools.contains(.mosaic)
        self.editImageMosaicToolSwitch.addTarget(self, action: #selector(mosaicToolChanged), for: .valueChanged)
        self.editImageToolView.addSubview(self.editImageMosaicToolSwitch)
        self.editImageMosaicToolSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(mosaicToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(mosaicToolLabel)
        }
        
        // 滤镜
        let filterToolLabel = createLabel("滤镜")
        self.editImageToolView.addSubview(filterToolLabel)
        filterToolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mosaicToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        self.editImageFilterToolSwitch = UISwitch()
        self.editImageFilterToolSwitch.isOn = editImageConfig.tools.contains(.filter)
        self.editImageFilterToolSwitch.addTarget(self, action: #selector(filterToolChanged), for: .valueChanged)
        self.editImageToolView.addSubview(self.editImageFilterToolSwitch)
        self.editImageFilterToolSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(filterToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(filterToolLabel)
        }
        
        // 色值
        let adjustToolLabel = createLabel("色值调整")
        self.editImageToolView.addSubview(adjustToolLabel)
        adjustToolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(filterToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        self.editImageAdjustToolSwitch.isOn = editImageConfig.tools.contains(.adjust)
        self.editImageAdjustToolSwitch.addTarget(self, action: #selector(adjustToolChanged), for: .valueChanged)
        self.editImageToolView.addSubview(self.editImageAdjustToolSwitch)
        self.editImageAdjustToolSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(adjustToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(adjustToolLabel)
        }
        
        editImageToolView.addSubview(editImageAdjustToolView)
        editImageAdjustToolView.snp.makeConstraints { make in
            make.top.equalTo(adjustToolLabel.snp.bottom).offset(velSpacing)
            make.height.equalTo(editImageConfig.tools.contains(.adjust) ? 100 : 0)
            make.left.equalToSuperview().offset(horSpacing)
            make.right.bottom.equalToSuperview()
        }
        
        // 亮度
        let brightnessLabel = createLabel("亮度")
        editImageAdjustToolView.addSubview(brightnessLabel)
        brightnessLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
        }
        
        editImageBrightnessSwitch.isOn = editImageConfig.adjustTools.contains(.brightness)
        editImageBrightnessSwitch.addTarget(self, action: #selector(brightnessChanged), for: .valueChanged)
        editImageAdjustToolView.addSubview(editImageBrightnessSwitch)
        editImageBrightnessSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(brightnessLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(brightnessLabel)
        }
        
        // 对比度
        let contrastLabel = createLabel("对比度")
        editImageAdjustToolView.addSubview(contrastLabel)
        contrastLabel.snp.makeConstraints { (make) in
            make.top.equalTo(brightnessLabel.snp.bottom).offset(velSpacing)
            make.left.equalToSuperview()
        }
        
        editImageContrastSwitch.isOn = editImageConfig.adjustTools.contains(.contrast)
        editImageContrastSwitch.addTarget(self, action: #selector(contrastChanged), for: .valueChanged)
        editImageAdjustToolView.addSubview(editImageContrastSwitch)
        editImageContrastSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(contrastLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(contrastLabel)
        }
        
        // 饱和度
        let saturationLabel = createLabel("饱和度")
        editImageAdjustToolView.addSubview(saturationLabel)
        saturationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contrastLabel.snp.bottom).offset(velSpacing)
            make.left.equalToSuperview()
        }
        
        editImageSaturationSwitch.isOn = editImageConfig.adjustTools.contains(.saturation)
        editImageSaturationSwitch.addTarget(self, action: #selector(saturationChanged), for: .valueChanged)
        editImageAdjustToolView.addSubview(editImageSaturationSwitch)
        editImageSaturationSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(saturationLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(saturationLabel)
        }
        
        // 编辑视频开关
        editVideoLabel = createLabel("允许编辑视频")
        containerView.addSubview(editVideoLabel)
        editVideoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(editImageToolView.snp.bottom).offset(velSpacing)
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
        
        // 滑动拖拽时自动滚动
        let autoScrollLabel = createLabel("滑动选择时自动滚动")
        containerView.addSubview(autoScrollLabel)
        autoScrollLabel.snp.makeConstraints { (make) in
            make.top.equalTo(slideSelectLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.autoScrollSwitch = UISwitch()
        self.autoScrollSwitch.isOn = config.autoScrollWhenSlideSelectIsActive
        self.autoScrollSwitch.addTarget(self, action: #selector(autoScrollSwitchChanged), for: .valueChanged)
        containerView.addSubview(self.autoScrollSwitch)
        self.autoScrollSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(autoScrollLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(autoScrollLabel)
        }
        
        // 滑动拖拽时自动滚动最大速度
        let autoScrollMaxSpeedLabel = createLabel("自动滚动最大速度")
        containerView.addSubview(autoScrollMaxSpeedLabel)
        autoScrollMaxSpeedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(autoScrollLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.autoScrollMaxSpeedTextField = createTextField(String(format: "%.2f", config.autoScrollMaxSpeed), .decimalPad)
        containerView.addSubview(self.autoScrollMaxSpeedTextField)
        self.autoScrollMaxSpeedTextField.snp.makeConstraints { (make) in
            make.left.equalTo(autoScrollMaxSpeedLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(autoScrollMaxSpeedLabel)
        }
        
        // 相册内部拍照开关
        let takePhotoLabel = createLabel("允许相册内部拍照")
        containerView.addSubview(takePhotoLabel)
        takePhotoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(autoScrollMaxSpeedLabel.snp.bottom).offset(velSpacing)
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
        
        // 显示已选选择照片边框
        let showSelectBorderLabel = createLabel("显示已选择照片边框")
        containerView.addSubview(showSelectBorderLabel)
        showSelectBorderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(showSelectMaskLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        self.showSelectBorderSwitch = UISwitch()
        self.showSelectBorderSwitch.isOn = config.showSelectedBorder
        self.showSelectBorderSwitch.addTarget(self, action: #selector(showSelectBorderChanged), for: .valueChanged)
        containerView.addSubview(self.showSelectBorderSwitch)
        self.showSelectBorderSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(showSelectBorderLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showSelectBorderLabel)
        }
        
        // 显示不可选状态照片遮罩
        let showInvalidMaskLabel = createLabel("显示不可选状态照片遮罩")
        containerView.addSubview(showInvalidMaskLabel)
        showInvalidMaskLabel.snp.makeConstraints { (make) in
            make.top.equalTo(showSelectBorderLabel.snp.bottom).offset(velSpacing)
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
        cameraFlashSegment.selectedSegmentIndex = config.cameraConfiguration.flashMode.rawValue
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
    
    @objc func styleSegmentChanged() {
        config.style = styleSegment.selectedSegmentIndex == 0 ? .embedAlbumList : .externalAlbumList
    }
    
    @objc func languageButtonClick() {
        let languagePicker = LanguagePickerView(selectedLanguage: config.languageType)
        
        languagePicker.selectBlock = { [weak self] (language) in
            self?.languageButton.setTitle(language.toString(), for: .normal)
            self?.config.languageType = language
        }
        
        languagePicker.show(in: self.view)
        languagePicker.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    @objc func columnStepperValueChanged() {
        columnCountLabel.text = String(Int(columnStepper.value))
        config.columnCount = Int(columnStepper.value)
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
    
    @objc func allowPreviewPhotoChanged() {
        config.allowPreviewPhotos = allowPreviewPhotosSwitch.isOn
    }
    
    @objc func allowEditImageChanged() {
        config.allowEditImage = allowEditImageSwitch.isOn
        
        UIView.animate(withDuration: 0.25) {
            self.editImageToolView.alpha = self.config.allowEditImage ? 1 : 0
            self.editVideoLabel.snp.updateConstraints({ (make) in
                if self.config.allowEditImage {
                    make.top.equalTo(self.editImageToolView.snp.bottom).offset(20)
                } else {
                    make.top.equalTo(self.editImageToolView.snp.bottom).offset(-self.editImageToolView.bounds.height)
                }
            })
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func drawToolChanged() {
        if config.editImageConfiguration.tools.contains(.draw) {
            config.editImageConfiguration.tools.removeAll { $0 == .draw }
        } else {
            config.editImageConfiguration.tools.append(.draw)
        }
    }
    
    @objc func clipToolChanged() {
        if config.editImageConfiguration.tools.contains(.clip) {
            config.editImageConfiguration.tools.removeAll { $0 == .clip }
        } else {
            config.editImageConfiguration.tools.append(.clip)
        }
    }
    
    @objc func imageStickerToolChanged() {
        if config.editImageConfiguration.tools.contains(.imageSticker) {
            config.editImageConfiguration.tools.removeAll { $0 == .imageSticker }
        } else {
            config.editImageConfiguration.tools.append(.imageSticker)
        }
    }
    
    @objc func textStickerToolChanged() {
        if config.editImageConfiguration.tools.contains(.textSticker) {
            config.editImageConfiguration.tools.removeAll { $0 == .textSticker }
        } else {
            config.editImageConfiguration.tools.append(.textSticker)
        }
    }
    
    @objc func mosaicToolChanged() {
        if config.editImageConfiguration.tools.contains(.mosaic) {
            config.editImageConfiguration.tools.removeAll { $0 == .mosaic }
        } else {
            config.editImageConfiguration.tools.append(.mosaic)
        }
    }
    
    @objc func filterToolChanged() {
        if config.editImageConfiguration.tools.contains(.filter) {
            config.editImageConfiguration.tools.removeAll { $0 == .filter }
        } else {
            config.editImageConfiguration.tools.append(.filter)
        }
    }
    
    @objc func adjustToolChanged() {
        var isOn = false
        if config.editImageConfiguration.tools.contains(.adjust) {
            config.editImageConfiguration.tools.removeAll { $0 == .adjust }
        } else {
            isOn.toggle()
            config.editImageConfiguration.tools.append(.adjust)
        }
        UIView.animate(withDuration: 0.25) {
            self.editImageAdjustToolView.alpha = isOn ? 1 : 0
            self.editImageAdjustToolView.snp.updateConstraints { make in
                make.height.equalTo(isOn ? 100 : 0)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func brightnessChanged() {
        if config.editImageConfiguration.adjustTools.contains(.brightness) {
            config.editImageConfiguration.adjustTools.removeAll { $0 == .brightness }
        } else {
            config.editImageConfiguration.adjustTools.append(.brightness)
        }
    }
    
    @objc func contrastChanged() {
        if config.editImageConfiguration.adjustTools.contains(.contrast) {
            config.editImageConfiguration.adjustTools.removeAll { $0 == .contrast }
        } else {
            config.editImageConfiguration.adjustTools.append(.contrast)
        }
    }
    
    @objc func saturationChanged() {
        if config.editImageConfiguration.adjustTools.contains(.saturation) {
            config.editImageConfiguration.adjustTools.removeAll { $0 == .saturation }
        } else {
            config.editImageConfiguration.adjustTools.append(.saturation)
        }
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
    
    @objc func autoScrollSwitchChanged() {
        config.autoScrollWhenSlideSelectIsActive = autoScrollSwitch.isOn
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
    
    @objc func showSelectBorderChanged() {
        config.showSelectedBorder = showSelectBorderSwitch.isOn
    }
    
    @objc func showInvalidSelectMaskChanged() {
        config.showInvalidMask = showInvalidSelectMaskSwitch.isOn
    }
    
    @objc func useCustomCameraChanged() {
        config.useCustomCamera = useCustomCameraSwitch.isOn
    }
    
    @objc func cameraFlashSegmentChanged() {
        config.cameraConfiguration.flashMode = ZLCameraConfiguration.FlashMode(rawValue: cameraFlashSegment.selectedSegmentIndex)!
    }

}


extension PhotoConfigureCNViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.previewCountTextField {
            config.maxPreviewCount = Int(textField.text ?? "") ?? 20
        } else if textField == self.selectCountTextField {
            config.maxSelectCount = Int(textField.text ?? "") ?? 9
        } else if textField == self.minVideoSelectCountTextField {
            config.minVideoSelectCount = Int(textField.text ?? "") ?? 0
        } else if textField == self.maxVideoSelectCountTextField {
            config.maxVideoSelectCount = Int(textField.text ?? "") ?? 0
        } else if textField == self.minVideoDurationTextField {
            config.minSelectVideoDuration = Int(textField.text ?? "") ?? 0
        } else if textField == self.maxVideoDurationTextField {
            config.maxSelectVideoDuration = Int(textField.text ?? "") ?? 120
        } else if textField == self.cellRadiusTextField {
            config.cellCornerRadio = CGFloat(Double(textField.text ?? "") ?? 0)
        } else if textField == self.autoScrollMaxSpeedTextField {
            config.autoScrollMaxSpeed = CGFloat(Double(textField.text ?? "") ?? 0)
        }
    }
    
}
