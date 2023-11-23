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
    
    let uiConfig = ZLPhotoUIConfiguration.default()
    
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
    
    var customCameraSwitch: UISwitch!
    
    var cameraFlashSwitch: UISwitch!
    
    var customAlertSwitch: UISwitch!
    
    lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = true
        btn.setTitle("完成", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(dismissBtnClick), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
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
            field.backgroundColor = .white
            field.layer.cornerRadius = 3
            field.layer.masksToBounds = true
            field.layer.borderColor = UIColor.lightGray.cgColor
            field.layer.borderWidth = 1 / UIScreen.main.scale
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
            field.leftViewMode = .always
            field.delegate = self
            field.keyboardType = keyboardType
            field.text = text
            return field
        }
        
        let velSpacing: CGFloat = 20
        let horSpacing: CGFloat = 15
        let fieldSize = CGSize(width: 100, height: 30)
        
        let tipsLabel = createLabel("更多参数设置，请前往ZLPhotoConfiguration查看")
        tipsLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        tipsLabel.numberOfLines = 2
        tipsLabel.lineBreakMode = .byWordWrapping
        containerView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
        }
        
        // 预览张数
        let previewCountLabel = createLabel("最大预览张数")
        containerView.addSubview(previewCountLabel)
        previewCountLabel.snp.makeConstraints { make in
            make.top.equalTo(tipsLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(tipsLabel.snp.left)
        }
        
        previewCountTextField = createTextField(String(config.maxPreviewCount), .numberPad)
        containerView.addSubview(previewCountTextField)
        previewCountTextField.snp.makeConstraints { make in
            make.left.equalTo(previewCountLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(previewCountLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 最大选择张数
        let maxSelectCountLabel = createLabel("最大选择张数")
        containerView.addSubview(maxSelectCountLabel)
        maxSelectCountLabel.snp.makeConstraints { make in
            make.top.equalTo(previewCountLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        selectCountTextField = createTextField(String(config.maxSelectCount), .numberPad)
        containerView.addSubview(selectCountTextField)
        selectCountTextField.snp.makeConstraints { make in
            make.left.equalTo(maxSelectCountLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(maxSelectCountLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 视频最小选择个数
        let minVideoSelectCountLabel = createLabel("视频最小选择数")
        containerView.addSubview(minVideoSelectCountLabel)
        minVideoSelectCountLabel.snp.makeConstraints { make in
            make.top.equalTo(maxSelectCountLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        minVideoSelectCountTextField = createTextField(String(config.minVideoSelectCount), .numberPad)
        containerView.addSubview(minVideoSelectCountTextField)
        minVideoSelectCountTextField.snp.makeConstraints { make in
            make.left.equalTo(minVideoSelectCountLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(minVideoSelectCountLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 视频最大选择个数
        let maxVideoSelectCountLabel = createLabel("视频最大选择数")
        containerView.addSubview(maxVideoSelectCountLabel)
        maxVideoSelectCountLabel.snp.makeConstraints { make in
            make.top.equalTo(minVideoSelectCountLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        maxVideoSelectCountTextField = createTextField(String(config.maxVideoSelectCount), .numberPad)
        containerView.addSubview(maxVideoSelectCountTextField)
        maxVideoSelectCountTextField.snp.makeConstraints { make in
            make.left.equalTo(maxVideoSelectCountLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(maxVideoSelectCountLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 视频最小选择时长
        let minVideoDurationLabel = createLabel("视频选择最小时长")
        containerView.addSubview(minVideoDurationLabel)
        minVideoDurationLabel.snp.makeConstraints { make in
            make.top.equalTo(maxVideoSelectCountLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        minVideoDurationTextField = createTextField(String(config.minSelectVideoDuration), .numberPad)
        containerView.addSubview(minVideoDurationTextField)
        minVideoDurationTextField.snp.makeConstraints { make in
            make.left.equalTo(minVideoDurationLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(minVideoDurationLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 视频最大选择时长
        let maxVideoDurationLabel = createLabel("视频选择最大时长")
        containerView.addSubview(maxVideoDurationLabel)
        maxVideoDurationLabel.snp.makeConstraints { make in
            make.top.equalTo(minVideoDurationLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        maxVideoDurationTextField = createTextField(String(config.maxSelectVideoDuration), .numberPad)
        containerView.addSubview(maxVideoDurationTextField)
        maxVideoDurationTextField.snp.makeConstraints { make in
            make.left.equalTo(maxVideoDurationLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(maxVideoDurationLabel)
            make.size.equalTo(fieldSize)
        }
        
        // cell圆角
        let cellRadiusLabel = createLabel("cell圆角")
        containerView.addSubview(cellRadiusLabel)
        cellRadiusLabel.snp.makeConstraints { make in
            make.top.equalTo(maxVideoDurationLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        cellRadiusTextField = createTextField(String(format: "%.2f", uiConfig.cellCornerRadio), .decimalPad)
        containerView.addSubview(cellRadiusTextField)
        cellRadiusTextField.snp.makeConstraints { make in
            make.left.equalTo(cellRadiusLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(cellRadiusLabel)
            make.size.equalTo(fieldSize)
        }
        
        // 相册样式
        let styleLabel = createLabel("相册样式")
        containerView.addSubview(styleLabel)
        styleLabel.snp.makeConstraints { make in
            make.top.equalTo(cellRadiusLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        styleSegment = UISegmentedControl(items: ["样式一(仿微信)", "样式二(传统)"])
        styleSegment.selectedSegmentIndex = uiConfig.style.rawValue
        styleSegment.addTarget(self, action: #selector(styleSegmentChanged), for: .valueChanged)
        containerView.addSubview(styleSegment)
        styleSegment.snp.makeConstraints { make in
            make.left.equalTo(styleLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(styleLabel)
        }
        
        // 框架语言
        let languageLabel = createLabel("框架语言")
        containerView.addSubview(languageLabel)
        languageLabel.snp.makeConstraints { make in
            make.top.equalTo(styleLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        languageButton = UIButton(type: .custom)
        languageButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        languageButton.setTitle(uiConfig.languageType.toString(), for: .normal)
        languageButton.addTarget(self, action: #selector(languageButtonClick), for: .touchUpInside)
        languageButton.setTitleColor(.white, for: .normal)
        languageButton.layer.cornerRadius = 5
        languageButton.layer.masksToBounds = true
        languageButton.backgroundColor = .black
        containerView.addSubview(languageButton)
        languageButton.snp.makeConstraints { make in
            make.centerY.equalTo(languageLabel)
            make.left.equalTo(languageLabel.snp.right).offset(horSpacing)
        }
        
        // 每列个数
        let columnCountTitleLabel = createLabel("每行显示照片个数")
        containerView.addSubview(columnCountTitleLabel)
        columnCountTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(languageLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        columnCountLabel = createLabel(String(uiConfig.columnCount))
        containerView.addSubview(columnCountLabel)
        columnCountLabel.snp.makeConstraints { make in
            make.left.equalTo(columnCountTitleLabel.snp.right).offset(10)
            make.centerY.equalTo(columnCountTitleLabel.snp.centerY)
        }
        
        columnStepper = UIStepper()
        columnStepper.minimumValue = 2
        columnStepper.maximumValue = 6
        columnStepper.stepValue = 1
        columnStepper.value = Double(uiConfig.columnCount)
        columnStepper.addTarget(self, action: #selector(columnStepperValueChanged), for: .valueChanged)
        containerView.addSubview(columnStepper)
        columnStepper.snp.makeConstraints { make in
            make.centerY.equalTo(columnCountTitleLabel.snp.centerY)
            make.left.equalTo(columnCountLabel.snp.right).offset(horSpacing)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        
        // 排序方式
        let sortLabel = createLabel("排序方式")
        containerView.addSubview(sortLabel)
        sortLabel.snp.makeConstraints { make in
            make.top.equalTo(columnCountTitleLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        sortAscendingSegment = UISegmentedControl(items: ["升序", "降序"])
        sortAscendingSegment.selectedSegmentIndex = uiConfig.sortAscending ? 0 : 1
        sortAscendingSegment.addTarget(self, action: #selector(sortAscendingChanged), for: .valueChanged)
        containerView.addSubview(sortAscendingSegment)
        sortAscendingSegment.snp.makeConstraints { make in
            make.left.equalTo(sortLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(sortLabel)
        }
        
        // 选择图片开关
        let selImageLabel = createLabel("允许选择图片")
        containerView.addSubview(selImageLabel)
        selImageLabel.snp.makeConstraints { make in
            make.top.equalTo(sortLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowSelectImageSwitch = UISwitch()
        allowSelectImageSwitch.isOn = config.allowSelectImage
        allowSelectImageSwitch.addTarget(self, action: #selector(allowSelectImageChanged), for: .valueChanged)
        containerView.addSubview(allowSelectImageSwitch)
        allowSelectImageSwitch.snp.makeConstraints { make in
            make.left.equalTo(selImageLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selImageLabel)
        }
        
        // 选择gif开关
        let selGifLabel = createLabel("允许选择Gif")
        containerView.addSubview(selGifLabel)
        selGifLabel.snp.makeConstraints { make in
            make.top.equalTo(selImageLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowSelectGifSwitch = UISwitch()
        allowSelectGifSwitch.isOn = config.allowSelectGif
        allowSelectGifSwitch.addTarget(self, action: #selector(allowSelectGifChanged), for: .valueChanged)
        containerView.addSubview(allowSelectGifSwitch)
        allowSelectGifSwitch.snp.makeConstraints { make in
            make.left.equalTo(selGifLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selGifLabel)
        }
        
        // 选择livePhoto开关
        let selLivePhotoLabel = createLabel("允许选择LivePhoto")
        containerView.addSubview(selLivePhotoLabel)
        selLivePhotoLabel.snp.makeConstraints { make in
            make.top.equalTo(selGifLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowSelectLivePhotoSwitch = UISwitch()
        allowSelectLivePhotoSwitch.isOn = config.allowSelectLivePhoto
        allowSelectLivePhotoSwitch.addTarget(self, action: #selector(allowSelectLivePhotoChanged), for: .valueChanged)
        containerView.addSubview(allowSelectLivePhotoSwitch)
        allowSelectLivePhotoSwitch.snp.makeConstraints { make in
            make.left.equalTo(selLivePhotoLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selLivePhotoLabel)
        }
        
        // 选择livePhoto开关
        let selOriginalLabel = createLabel("允许选择原图")
        containerView.addSubview(selOriginalLabel)
        selOriginalLabel.snp.makeConstraints { make in
            make.top.equalTo(selLivePhotoLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowSelectOriginalSwitch = UISwitch()
        allowSelectOriginalSwitch.isOn = config.allowSelectOriginal
        allowSelectOriginalSwitch.addTarget(self, action: #selector(allowSelectOriginalChanged), for: .valueChanged)
        containerView.addSubview(allowSelectOriginalSwitch)
        allowSelectOriginalSwitch.snp.makeConstraints { make in
            make.left.equalTo(selOriginalLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selOriginalLabel)
        }
        
        // 选择视频开关
        let selVideoLabel = createLabel("允许选择视频")
        containerView.addSubview(selVideoLabel)
        selVideoLabel.snp.makeConstraints { make in
            make.top.equalTo(selOriginalLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowSelectVideoSwitch = UISwitch()
        allowSelectVideoSwitch.isOn = config.allowSelectVideo
        allowSelectVideoSwitch.addTarget(self, action: #selector(allowSelectVideoChanged), for: .valueChanged)
        containerView.addSubview(allowSelectVideoSwitch)
        allowSelectVideoSwitch.snp.makeConstraints { make in
            make.left.equalTo(selVideoLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(selVideoLabel)
        }
        
        // 混合选择开关
        let mixSelectLabel = createLabel("允许图片视频一起选择")
        containerView.addSubview(mixSelectLabel)
        mixSelectLabel.snp.makeConstraints { make in
            make.top.equalTo(selVideoLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowMixSelectSwitch = UISwitch()
        allowMixSelectSwitch.isOn = config.allowMixSelect
        allowMixSelectSwitch.addTarget(self, action: #selector(allowMixSelectChanged), for: .valueChanged)
        containerView.addSubview(allowMixSelectSwitch)
        allowMixSelectSwitch.snp.makeConstraints { make in
            make.left.equalTo(mixSelectLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(mixSelectLabel)
        }
        
        // 预览大图开关
        let previewPhotosLabel = createLabel("允许进入大图界面")
        containerView.addSubview(previewPhotosLabel)
        previewPhotosLabel.snp.makeConstraints { make in
            make.top.equalTo(mixSelectLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowPreviewPhotosSwitch = UISwitch()
        allowPreviewPhotosSwitch.isOn = config.allowPreviewPhotos
        allowPreviewPhotosSwitch.addTarget(self, action: #selector(allowPreviewPhotoChanged), for: .valueChanged)
        containerView.addSubview(allowPreviewPhotosSwitch)
        allowPreviewPhotosSwitch.snp.makeConstraints { make in
            make.left.equalTo(previewPhotosLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(previewPhotosLabel)
        }
        
        // 编辑图片开关
        editImageLabel = createLabel("允许编辑图片")
        containerView.addSubview(editImageLabel)
        editImageLabel.snp.makeConstraints { make in
            make.top.equalTo(previewPhotosLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowEditImageSwitch = UISwitch()
        allowEditImageSwitch.isOn = config.allowEditImage
        allowEditImageSwitch.addTarget(self, action: #selector(allowEditImageChanged), for: .valueChanged)
        containerView.addSubview(allowEditImageSwitch)
        allowEditImageSwitch.snp.makeConstraints { make in
            make.left.equalTo(editImageLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(editImageLabel)
        }
        
        // 编辑图片工具
        editImageToolView = UIView()
        editImageToolView.alpha = config.allowEditImage ? 1 : 0
        containerView.addSubview(editImageToolView)
        editImageToolView.snp.makeConstraints { make in
            make.top.equalTo(self.allowEditImageSwitch.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
            make.right.equalTo(containerView)
        }
        
        // 涂鸦
        let drawToolLabel = createLabel("涂鸦")
        editImageToolView.addSubview(drawToolLabel)
        drawToolLabel.snp.makeConstraints { make in
            make.top.equalTo(self.editImageToolView)
            make.left.equalTo(self.editImageToolView)
        }
        
        let editImageConfig = config.editImageConfiguration
        
        editImageDrawToolSwitch = UISwitch()
        editImageDrawToolSwitch.isOn = editImageConfig.tools.contains(.draw)
        editImageDrawToolSwitch.addTarget(self, action: #selector(drawToolChanged), for: .valueChanged)
        editImageToolView.addSubview(editImageDrawToolSwitch)
        editImageDrawToolSwitch.snp.makeConstraints { make in
            make.left.equalTo(drawToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(drawToolLabel)
        }
        
        // 裁剪
        let clipToolLabel = createLabel("裁剪")
        editImageToolView.addSubview(clipToolLabel)
        clipToolLabel.snp.makeConstraints { make in
            make.top.equalTo(drawToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        editImageClipToolSwitch = UISwitch()
        editImageClipToolSwitch.isOn = editImageConfig.tools.contains(.clip)
        editImageClipToolSwitch.addTarget(self, action: #selector(clipToolChanged), for: .valueChanged)
        editImageToolView.addSubview(editImageClipToolSwitch)
        editImageClipToolSwitch.snp.makeConstraints { make in
            make.left.equalTo(clipToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(clipToolLabel)
        }
        
        // 贴图
        let imageStickerToolLabel = createLabel("贴图")
        editImageToolView.addSubview(imageStickerToolLabel)
        imageStickerToolLabel.snp.makeConstraints { make in
            make.top.equalTo(clipToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        editImageImageStickerToolSwitch = UISwitch()
        editImageImageStickerToolSwitch.isOn = editImageConfig.tools.contains(.imageSticker)
        editImageImageStickerToolSwitch.addTarget(self, action: #selector(imageStickerToolChanged), for: .valueChanged)
        editImageToolView.addSubview(editImageImageStickerToolSwitch)
        editImageImageStickerToolSwitch.snp.makeConstraints { make in
            make.left.equalTo(imageStickerToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(imageStickerToolLabel)
        }
        
        // 文本
        let textStickerToolLabel = createLabel("文本")
        editImageToolView.addSubview(textStickerToolLabel)
        textStickerToolLabel.snp.makeConstraints { make in
            make.top.equalTo(imageStickerToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        editImageTextStickerToolSwitch = UISwitch()
        editImageTextStickerToolSwitch.isOn = editImageConfig.tools.contains(.textSticker)
        editImageTextStickerToolSwitch.addTarget(self, action: #selector(textStickerToolChanged), for: .valueChanged)
        editImageToolView.addSubview(editImageTextStickerToolSwitch)
        editImageTextStickerToolSwitch.snp.makeConstraints { make in
            make.left.equalTo(textStickerToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(textStickerToolLabel)
        }
        
        // 马赛克
        let mosaicToolLabel = createLabel("马赛克")
        editImageToolView.addSubview(mosaicToolLabel)
        mosaicToolLabel.snp.makeConstraints { make in
            make.top.equalTo(textStickerToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        editImageMosaicToolSwitch = UISwitch()
        editImageMosaicToolSwitch.isOn = editImageConfig.tools.contains(.mosaic)
        editImageMosaicToolSwitch.addTarget(self, action: #selector(mosaicToolChanged), for: .valueChanged)
        editImageToolView.addSubview(editImageMosaicToolSwitch)
        editImageMosaicToolSwitch.snp.makeConstraints { make in
            make.left.equalTo(mosaicToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(mosaicToolLabel)
        }
        
        // 滤镜
        let filterToolLabel = createLabel("滤镜")
        editImageToolView.addSubview(filterToolLabel)
        filterToolLabel.snp.makeConstraints { make in
            make.top.equalTo(mosaicToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        editImageFilterToolSwitch = UISwitch()
        editImageFilterToolSwitch.isOn = editImageConfig.tools.contains(.filter)
        editImageFilterToolSwitch.addTarget(self, action: #selector(filterToolChanged), for: .valueChanged)
        editImageToolView.addSubview(editImageFilterToolSwitch)
        editImageFilterToolSwitch.snp.makeConstraints { make in
            make.left.equalTo(filterToolLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(filterToolLabel)
        }
        
        // 色值
        let adjustToolLabel = createLabel("色值调整")
        editImageToolView.addSubview(adjustToolLabel)
        adjustToolLabel.snp.makeConstraints { make in
            make.top.equalTo(filterToolLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(self.editImageToolView)
        }
        
        editImageAdjustToolSwitch.isOn = editImageConfig.tools.contains(.adjust)
        editImageAdjustToolSwitch.addTarget(self, action: #selector(adjustToolChanged), for: .valueChanged)
        editImageToolView.addSubview(editImageAdjustToolSwitch)
        editImageAdjustToolSwitch.snp.makeConstraints { make in
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
        brightnessLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        editImageBrightnessSwitch.isOn = editImageConfig.adjustTools.contains(.brightness)
        editImageBrightnessSwitch.addTarget(self, action: #selector(brightnessChanged), for: .valueChanged)
        editImageAdjustToolView.addSubview(editImageBrightnessSwitch)
        editImageBrightnessSwitch.snp.makeConstraints { make in
            make.left.equalTo(brightnessLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(brightnessLabel)
        }
        
        // 对比度
        let contrastLabel = createLabel("对比度")
        editImageAdjustToolView.addSubview(contrastLabel)
        contrastLabel.snp.makeConstraints { make in
            make.top.equalTo(brightnessLabel.snp.bottom).offset(velSpacing)
            make.left.equalToSuperview()
        }
        
        editImageContrastSwitch.isOn = editImageConfig.adjustTools.contains(.contrast)
        editImageContrastSwitch.addTarget(self, action: #selector(contrastChanged), for: .valueChanged)
        editImageAdjustToolView.addSubview(editImageContrastSwitch)
        editImageContrastSwitch.snp.makeConstraints { make in
            make.left.equalTo(contrastLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(contrastLabel)
        }
        
        // 饱和度
        let saturationLabel = createLabel("饱和度")
        editImageAdjustToolView.addSubview(saturationLabel)
        saturationLabel.snp.makeConstraints { make in
            make.top.equalTo(contrastLabel.snp.bottom).offset(velSpacing)
            make.left.equalToSuperview()
        }
        
        editImageSaturationSwitch.isOn = editImageConfig.adjustTools.contains(.saturation)
        editImageSaturationSwitch.addTarget(self, action: #selector(saturationChanged), for: .valueChanged)
        editImageAdjustToolView.addSubview(editImageSaturationSwitch)
        editImageSaturationSwitch.snp.makeConstraints { make in
            make.left.equalTo(saturationLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(saturationLabel)
        }
        
        // 编辑视频开关
        editVideoLabel = createLabel("允许编辑视频")
        containerView.addSubview(editVideoLabel)
        editVideoLabel.snp.makeConstraints { make in
            if config.allowEditImage {
                make.top.equalTo(editImageToolView.snp.bottom).offset(velSpacing)
            } else {
                make.top.equalTo(editImageToolView.snp.top)
            }
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowEditVideoSwitch = UISwitch()
        allowEditVideoSwitch.isOn = config.allowEditVideo
        allowEditVideoSwitch.addTarget(self, action: #selector(allowEditVideoChanged), for: .valueChanged)
        containerView.addSubview(allowEditVideoSwitch)
        allowEditVideoSwitch.snp.makeConstraints { make in
            make.left.equalTo(editVideoLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(editVideoLabel)
        }
        
        // 保存编辑图片开关
        let saveEditImageLabel = createLabel("保存编辑的图片")
        containerView.addSubview(saveEditImageLabel)
        saveEditImageLabel.snp.makeConstraints { make in
            make.top.equalTo(editVideoLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        saveEditImageSwitch = UISwitch()
        saveEditImageSwitch.isOn = config.saveNewImageAfterEdit
        saveEditImageSwitch.addTarget(self, action: #selector(saveEditImageChanged), for: .valueChanged)
        containerView.addSubview(saveEditImageSwitch)
        saveEditImageSwitch.snp.makeConstraints { make in
            make.left.equalTo(saveEditImageLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(saveEditImageLabel)
        }
        
        // 拖拽选择开关
        let dragSelectLabel = createLabel("允许拖拽选择")
        containerView.addSubview(dragSelectLabel)
        dragSelectLabel.snp.makeConstraints { make in
            make.top.equalTo(saveEditImageLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowDragSelectSwitch = UISwitch()
        allowDragSelectSwitch.isOn = config.allowDragSelect
        allowDragSelectSwitch.addTarget(self, action: #selector(allowDragSelectChanged), for: .valueChanged)
        containerView.addSubview(allowDragSelectSwitch)
        allowDragSelectSwitch.snp.makeConstraints { make in
            make.left.equalTo(dragSelectLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(dragSelectLabel)
        }
        
        // 滑动拖拽开关
        let slideSelectLabel = createLabel("允许滑动选择")
        containerView.addSubview(slideSelectLabel)
        slideSelectLabel.snp.makeConstraints { make in
            make.top.equalTo(dragSelectLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowSlideSelectSwitch = UISwitch()
        allowSlideSelectSwitch.isOn = config.allowSlideSelect
        allowSlideSelectSwitch.addTarget(self, action: #selector(allowSlideSelectChanged), for: .valueChanged)
        containerView.addSubview(allowSlideSelectSwitch)
        allowSlideSelectSwitch.snp.makeConstraints { make in
            make.left.equalTo(slideSelectLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(slideSelectLabel)
        }
        
        // 滑动拖拽时自动滚动
        let autoScrollLabel = createLabel("滑动选择时自动滚动")
        containerView.addSubview(autoScrollLabel)
        autoScrollLabel.snp.makeConstraints { make in
            make.top.equalTo(slideSelectLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        autoScrollSwitch = UISwitch()
        autoScrollSwitch.isOn = config.autoScrollWhenSlideSelectIsActive
        autoScrollSwitch.addTarget(self, action: #selector(autoScrollSwitchChanged), for: .valueChanged)
        containerView.addSubview(autoScrollSwitch)
        autoScrollSwitch.snp.makeConstraints { make in
            make.left.equalTo(autoScrollLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(autoScrollLabel)
        }
        
        // 滑动拖拽时自动滚动最大速度
        let autoScrollMaxSpeedLabel = createLabel("自动滚动最大速度")
        containerView.addSubview(autoScrollMaxSpeedLabel)
        autoScrollMaxSpeedLabel.snp.makeConstraints { make in
            make.top.equalTo(autoScrollLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        autoScrollMaxSpeedTextField = createTextField(String(format: "%.2f", config.autoScrollMaxSpeed), .decimalPad)
        containerView.addSubview(autoScrollMaxSpeedTextField)
        autoScrollMaxSpeedTextField.snp.makeConstraints { make in
            make.left.equalTo(autoScrollMaxSpeedLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(autoScrollMaxSpeedLabel)
        }
        
        // 相册内部拍照开关
        let takePhotoLabel = createLabel("允许相册内部拍照")
        containerView.addSubview(takePhotoLabel)
        takePhotoLabel.snp.makeConstraints { make in
            make.top.equalTo(autoScrollMaxSpeedLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        allowTakePhotoInLibrarySwitch = UISwitch()
        allowTakePhotoInLibrarySwitch.isOn = config.allowTakePhotoInLibrary
        allowTakePhotoInLibrarySwitch.addTarget(self, action: #selector(allowTakePhotoInLibraryChanged), for: .valueChanged)
        containerView.addSubview(allowTakePhotoInLibrarySwitch)
        allowTakePhotoInLibrarySwitch.snp.makeConstraints { make in
            make.left.equalTo(takePhotoLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(takePhotoLabel)
        }
        
        // 相册内部拍照cell显示实时画面
        let showCaptureLabel = createLabel("拍照cell显示相机俘获画面")
        containerView.addSubview(showCaptureLabel)
        showCaptureLabel.snp.makeConstraints { make in
            make.top.equalTo(takePhotoLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        showCaptureInCameraCellSwitch = UISwitch()
        showCaptureInCameraCellSwitch.isOn = uiConfig.showCaptureImageOnTakePhotoBtn
        showCaptureInCameraCellSwitch.addTarget(self, action: #selector(showCaptureInCameraCellChanged), for: .valueChanged)
        containerView.addSubview(showCaptureInCameraCellSwitch)
        showCaptureInCameraCellSwitch.snp.makeConstraints { make in
            make.left.equalTo(showCaptureLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showCaptureLabel)
        }
        
        // 显示已选选择照片index
        let showSelectIndexLabel = createLabel("显示已选择照片index")
        containerView.addSubview(showSelectIndexLabel)
        showSelectIndexLabel.snp.makeConstraints { make in
            make.top.equalTo(showCaptureLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        showSelectIndexSwitch = UISwitch()
        showSelectIndexSwitch.isOn = config.showSelectedIndex
        showSelectIndexSwitch.addTarget(self, action: #selector(showSelectIndexChanged), for: .valueChanged)
        containerView.addSubview(showSelectIndexSwitch)
        showSelectIndexSwitch.snp.makeConstraints { make in
            make.left.equalTo(showSelectIndexLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showSelectIndexLabel)
        }
        
        // 显示已选选择照片遮罩
        let showSelectMaskLabel = createLabel("显示已选择照片遮罩")
        containerView.addSubview(showSelectMaskLabel)
        showSelectMaskLabel.snp.makeConstraints { make in
            make.top.equalTo(showSelectIndexLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        showSelectMaskSwitch = UISwitch()
        showSelectMaskSwitch.isOn = uiConfig.showSelectedMask
        showSelectMaskSwitch.addTarget(self, action: #selector(showSelectMaskChanged), for: .valueChanged)
        containerView.addSubview(showSelectMaskSwitch)
        showSelectMaskSwitch.snp.makeConstraints { make in
            make.left.equalTo(showSelectMaskLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showSelectMaskLabel)
        }
        
        // 显示已选选择照片边框
        let showSelectBorderLabel = createLabel("显示已选择照片边框")
        containerView.addSubview(showSelectBorderLabel)
        showSelectBorderLabel.snp.makeConstraints { make in
            make.top.equalTo(showSelectMaskLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        showSelectBorderSwitch = UISwitch()
        showSelectBorderSwitch.isOn = uiConfig.showSelectedBorder
        showSelectBorderSwitch.addTarget(self, action: #selector(showSelectBorderChanged), for: .valueChanged)
        containerView.addSubview(showSelectBorderSwitch)
        showSelectBorderSwitch.snp.makeConstraints { make in
            make.left.equalTo(showSelectBorderLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showSelectBorderLabel)
        }
        
        // 显示不可选状态照片遮罩
        let showInvalidMaskLabel = createLabel("显示不可选状态照片遮罩")
        containerView.addSubview(showInvalidMaskLabel)
        showInvalidMaskLabel.snp.makeConstraints { make in
            make.top.equalTo(showSelectBorderLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        showInvalidSelectMaskSwitch = UISwitch()
        showInvalidSelectMaskSwitch.isOn = uiConfig.showInvalidMask
        showInvalidSelectMaskSwitch.addTarget(self, action: #selector(showInvalidSelectMaskChanged), for: .valueChanged)
        containerView.addSubview(showInvalidSelectMaskSwitch)
        showInvalidSelectMaskSwitch.snp.makeConstraints { make in
            make.left.equalTo(showInvalidMaskLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(showInvalidMaskLabel)
        }
        
        // 使用自定义相机
        let customCameraLabel = createLabel("使用自定义相机")
        containerView.addSubview(customCameraLabel)
        customCameraLabel.snp.makeConstraints { make in
            make.top.equalTo(showInvalidMaskLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        customCameraSwitch = UISwitch()
        customCameraSwitch.isOn = config.useCustomCamera
        customCameraSwitch.addTarget(self, action: #selector(customCameraChanged), for: .valueChanged)
        containerView.addSubview(customCameraSwitch)
        customCameraSwitch.snp.makeConstraints { make in
            make.left.equalTo(customCameraLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(customCameraLabel)
        }
        
        // 闪光灯模式
        let cameraFlashLabel = createLabel("闪光灯开关")
        containerView.addSubview(cameraFlashLabel)
        cameraFlashLabel.snp.makeConstraints { make in
            make.top.equalTo(customCameraLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        cameraFlashSwitch = UISwitch()
        cameraFlashSwitch.isOn = config.cameraConfiguration.showFlashSwitch
        cameraFlashSwitch.addTarget(self, action: #selector(cameraFlashChanged), for: .valueChanged)
        containerView.addSubview(cameraFlashSwitch)
        cameraFlashSwitch.snp.makeConstraints { make in
            make.left.equalTo(cameraFlashLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(cameraFlashLabel)
        }
        
        // 使用自定义弹窗
        let customAlertLabel = createLabel("自定义alert样式")
        containerView.addSubview(customAlertLabel)
        customAlertLabel.snp.makeConstraints { make in
            make.top.equalTo(cameraFlashLabel.snp.bottom).offset(velSpacing)
            make.left.equalTo(previewCountLabel.snp.left)
        }
        
        customAlertSwitch = UISwitch()
        customAlertSwitch.isOn = uiConfig.customAlertClass != nil
        customAlertSwitch.addTarget(self, action: #selector(customAlertChanged), for: .valueChanged)
        containerView.addSubview(customAlertSwitch)
        customAlertSwitch.snp.makeConstraints { make in
            make.left.equalTo(customAlertLabel.snp.right).offset(horSpacing)
            make.centerY.equalTo(customAlertLabel)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
        }
        
        view.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-40)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
    }
    
    @objc func dismissBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func styleSegmentChanged() {
        uiConfig.style = styleSegment.selectedSegmentIndex == 0 ? .embedAlbumList : .externalAlbumList
    }
    
    @objc func languageButtonClick() {
        let languagePicker = LanguagePickerView(selectedLanguage: uiConfig.languageType)
        
        languagePicker.selectBlock = { [weak self] language in
            self?.languageButton.setTitle(language.toString(), for: .normal)
            self?.uiConfig.languageType = language
        }
        
        languagePicker.show(in: view)
        languagePicker.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    
    @objc func columnStepperValueChanged() {
        columnCountLabel.text = String(Int(columnStepper.value))
        uiConfig.columnCount = Int(columnStepper.value)
    }
    
    @objc func sortAscendingChanged() {
        let index = sortAscendingSegment.selectedSegmentIndex
        uiConfig.sortAscending = index == 0
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
            self.editVideoLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(20)
                if self.config.allowEditImage {
                    make.top.equalTo(self.editImageToolView.snp.bottom).offset(20)
                } else {
                    make.top.equalTo(self.editImageToolView.snp.top)
                }
            }
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
        uiConfig.showCaptureImageOnTakePhotoBtn = showCaptureInCameraCellSwitch.isOn
    }
    
    @objc func showSelectIndexChanged() {
        config.showSelectedIndex = showSelectIndexSwitch.isOn
    }
    
    @objc func showSelectMaskChanged() {
        uiConfig.showSelectedMask = showSelectMaskSwitch.isOn
    }
    
    @objc func showSelectBorderChanged() {
        uiConfig.showSelectedBorder = showSelectBorderSwitch.isOn
    }
    
    @objc func showInvalidSelectMaskChanged() {
        uiConfig.showInvalidMask = showInvalidSelectMaskSwitch.isOn
    }
    
    @objc func customCameraChanged() {
        config.useCustomCamera = customCameraSwitch.isOn
    }
    
    @objc func cameraFlashChanged() {
        config.cameraConfiguration.showFlashSwitch = cameraFlashSwitch.isOn
    }
    
    @objc func customAlertChanged() {
        if customAlertSwitch.isOn {
            uiConfig.customAlertClass = CustomAlertController.self
        } else {
            uiConfig.customAlertClass = nil
        }
    }
}

extension PhotoConfigureCNViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == previewCountTextField {
            config.maxPreviewCount = Int(textField.text ?? "") ?? 20
        } else if textField == selectCountTextField {
            config.maxSelectCount = Int(textField.text ?? "") ?? 9
        } else if textField == minVideoSelectCountTextField {
            config.minVideoSelectCount = Int(textField.text ?? "") ?? 0
        } else if textField == maxVideoSelectCountTextField {
            config.maxVideoSelectCount = Int(textField.text ?? "") ?? 0
        } else if textField == minVideoDurationTextField {
            config.minSelectVideoDuration = Int(textField.text ?? "") ?? 0
        } else if textField == maxVideoDurationTextField {
            config.maxSelectVideoDuration = Int(textField.text ?? "") ?? 120
        } else if textField == cellRadiusTextField {
            uiConfig.cellCornerRadio = CGFloat(Double(textField.text ?? "") ?? 0)
        } else if textField == autoScrollMaxSpeedTextField {
            config.autoScrollMaxSpeed = CGFloat(Double(textField.text ?? "") ?? 0)
        }
    }
}
