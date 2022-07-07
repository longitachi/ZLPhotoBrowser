//
//  ZLThumbnailPhotoCell.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/12.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Photos

class ZLThumbnailPhotoCell: UICollectionViewCell {
    
    private lazy var bottomShadowView = UIImageView(image: .zl.getImage("zl_shadow"))
    
    private lazy var videoTag = UIImageView(image: .zl.getImage("zl_video"))
    
    private lazy var livePhotoTag = UIImageView(image: .zl.getImage("zl_livePhoto"))
    
    private lazy var editImageTag = UIImageView(image: .zl.getImage("zl_editImage_tag"))
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = .zl.font(ofSize: 13)
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    
    private lazy var progressView: ZLProgressView = {
        let view = ZLProgressView()
        view.isHidden = true
        return view
    }()
    
    private var imageIdentifier: String = ""
    
    private var smallImageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    private var bigImageReqeustID: PHImageRequestID = PHInvalidImageRequestID
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    lazy var btnSelect: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setBackgroundImage(.zl.getImage("zl_btn_unselected"), for: .normal)
        btn.setBackgroundImage(.zl.getImage("zl_btn_selected"), for: .selected)
        btn.addTarget(self, action: #selector(btnSelectClick), for: .touchUpInside)
        btn.enlargeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 5)
        return btn
    }()
    
    lazy var coverView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()
    
    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 23.0 / 2
        label.layer.masksToBounds = true
        label.textColor = .white
        label.font = .zl.font(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    var enableSelect: Bool = true
    
    var selectedBlock: ((Bool) -> Void)?
    
    var model: ZLPhotoModel! {
        didSet {
            configureCell()
        }
    }
    
    var index: Int = 0 {
        didSet {
            indexLabel.text = String(index)
        }
    }
    
    deinit {
        zl_debugPrint("ZLThumbnailPhotoCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(coverView)
        contentView.addSubview(btnSelect)
        btnSelect.addSubview(indexLabel)
        contentView.addSubview(bottomShadowView)
        bottomShadowView.addSubview(videoTag)
        bottomShadowView.addSubview(livePhotoTag)
        bottomShadowView.addSubview(editImageTag)
        bottomShadowView.addSubview(descLabel)
        contentView.addSubview(progressView)
        
        if ZLPhotoConfiguration.default().showSelectedBorder {
            layer.borderColor = UIColor.zl.selectedBorderColor.cgColor
        }
    }
    
    override func layoutSubviews() {
        imageView.frame = bounds
        coverView.frame = bounds
        btnSelect.frame = CGRect(x: bounds.width - 30, y: 8, width: 23, height: 23)
        indexLabel.frame = btnSelect.bounds
        bottomShadowView.frame = CGRect(x: 0, y: bounds.height - 25, width: bounds.width, height: 25)
        videoTag.frame = CGRect(x: 5, y: 1, width: 20, height: 15)
        livePhotoTag.frame = CGRect(x: 5, y: -1, width: 20, height: 20)
        editImageTag.frame = CGRect(x: 5, y: -1, width: 20, height: 20)
        descLabel.frame = CGRect(x: 30, y: 1, width: bounds.width - 35, height: 17)
        progressView.frame = CGRect(x: (bounds.width - 20) / 2, y: (bounds.height - 20) / 2, width: 20, height: 20)
        
        super.layoutSubviews()
    }
    
    @objc func btnSelectClick() {
        if !enableSelect, ZLPhotoConfiguration.default().showInvalidMask {
            return
        }
        
        btnSelect.layer.removeAllAnimations()
        if !btnSelect.isSelected, ZLPhotoConfiguration.default().animateSelectBtnWhenSelect {
            btnSelect.layer.add(getSpringAnimation(), forKey: nil)
        }
        
        selectedBlock?(btnSelect.isSelected)
        
        if btnSelect.isSelected {
            fetchBigImage()
        } else {
            progressView.isHidden = true
            cancelFetchBigImage()
        }
    }
    
    private func configureCell() {
        if ZLPhotoConfiguration.default().cellCornerRadio > 0 {
            layer.cornerRadius = ZLPhotoConfiguration.default().cellCornerRadio
            layer.masksToBounds = true
        }
        
        if model.type == .video {
            bottomShadowView.isHidden = false
            videoTag.isHidden = false
            livePhotoTag.isHidden = true
            editImageTag.isHidden = true
            descLabel.text = model.duration
        } else if model.type == .gif {
            bottomShadowView.isHidden = !ZLPhotoConfiguration.default().allowSelectGif
            videoTag.isHidden = true
            livePhotoTag.isHidden = true
            editImageTag.isHidden = true
            descLabel.text = "GIF"
        } else if model.type == .livePhoto {
            bottomShadowView.isHidden = !ZLPhotoConfiguration.default().allowSelectLivePhoto
            videoTag.isHidden = true
            livePhotoTag.isHidden = false
            editImageTag.isHidden = true
            descLabel.text = "Live"
        } else {
            if let _ = model.editImage {
                bottomShadowView.isHidden = false
                videoTag.isHidden = true
                livePhotoTag.isHidden = true
                editImageTag.isHidden = false
                descLabel.text = ""
            } else {
                bottomShadowView.isHidden = true
            }
        }
        
        let showSelBtn: Bool
        if ZLPhotoConfiguration.default().maxSelectCount > 1 {
            if !ZLPhotoConfiguration.default().allowMixSelect {
                showSelBtn = model.type.rawValue < ZLPhotoModel.MediaType.video.rawValue
            } else {
                showSelBtn = true
            }
        } else {
            showSelBtn = ZLPhotoConfiguration.default().showSelectBtnWhenSingleSelect
        }
        
        btnSelect.isHidden = !showSelBtn
        btnSelect.isUserInteractionEnabled = showSelBtn
        btnSelect.isSelected = model.isSelected
        
        indexLabel.backgroundColor = .zl.indexLabelBgColor
        
        if model.isSelected {
            fetchBigImage()
        } else {
            cancelFetchBigImage()
        }
        
        if let ei = model.editImage {
            imageView.image = ei
        } else {
            fetchSmallImage()
        }
    }
    
    private func fetchSmallImage() {
        let size: CGSize
        let maxSideLength = bounds.width * 1.2
        if model.whRatio > 1 {
            let w = maxSideLength * model.whRatio
            size = CGSize(width: w, height: maxSideLength)
        } else {
            let h = maxSideLength / model.whRatio
            size = CGSize(width: maxSideLength, height: h)
        }
        
        if smallImageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(smallImageRequestID)
        }
        
        imageIdentifier = model.ident
        imageView.image = nil
        smallImageRequestID = ZLPhotoManager.fetchImage(for: model.asset, size: size, completion: { [weak self] image, isDegraded in
            if self?.imageIdentifier == self?.model.ident {
                self?.imageView.image = image
            }
            if !isDegraded {
                self?.smallImageRequestID = PHInvalidImageRequestID
            }
        })
    }
    
    private func fetchBigImage() {
        cancelFetchBigImage()
        
        bigImageReqeustID = ZLPhotoManager.fetchOriginalImageData(for: model.asset, progress: { [weak self] progress, _, _, _ in
            if self?.model.isSelected == true {
                self?.progressView.isHidden = false
                self?.progressView.progress = max(0.1, progress)
                self?.imageView.alpha = 0.5
                if progress >= 1 {
                    self?.resetProgressViewStatus()
                }
            } else {
                self?.cancelFetchBigImage()
            }
        }, completion: { [weak self] _, _, _ in
            self?.resetProgressViewStatus()
        })
    }
    
    private func cancelFetchBigImage() {
        if bigImageReqeustID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(bigImageReqeustID)
        }
        resetProgressViewStatus()
    }
    
    private func resetProgressViewStatus() {
        progressView.isHidden = true
        imageView.alpha = 1
    }
    
}
