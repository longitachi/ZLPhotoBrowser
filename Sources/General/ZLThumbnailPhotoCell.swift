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
    
    var imageView: UIImageView!
    
    var btnSelect: UIButton!
    
    var bottomShadowView: UIImageView!
    
    var videoTag: UIImageView!
    
    var livePhotoTag: UIImageView!
    
    var editImageTag: UIImageView!
    
    var descLabel: UILabel!
    
    var coverView: UIView!
    
    var indexLabel: UILabel!
    
    var enableSelect: Bool = true
    
    var progressView: ZLProgressView!
    
    var selectedBlock: ( (Bool) -> Void )?
    
    var model: ZLPhotoModel! {
        didSet {
            self.configureCell()
        }
    }
    
    var index: Int = 0 {
        didSet {
            self.indexLabel.text = String(index)
        }
    }
    
    var imageIdentifier: String = ""
    
    var smallImageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var bigImageReqeustID: PHImageRequestID = PHInvalidImageRequestID
    
    deinit {
        zl_debugPrint("ZLThumbnailPhotoCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        
        self.coverView = UIView()
        self.coverView.isUserInteractionEnabled = false
        self.coverView.isHidden = true
        self.contentView.addSubview(self.coverView)
        
        self.btnSelect = UIButton(type: .custom)
        self.btnSelect.setBackgroundImage(getImage("zl_btn_unselected"), for: .normal)
        self.btnSelect.setBackgroundImage(getImage("zl_btn_selected"), for: .selected)
        self.btnSelect.addTarget(self, action: #selector(btnSelectClick), for: .touchUpInside)
        self.btnSelect.zl_enlargeValidTouchArea(insets: UIEdgeInsets(top: 5, left: 20, bottom: 20, right: 5))
        self.contentView.addSubview(self.btnSelect)
        
        self.indexLabel = UILabel()
        self.indexLabel.layer.cornerRadius = 23.0 / 2
        self.indexLabel.layer.masksToBounds = true
        self.indexLabel.textColor = .white
        self.indexLabel.font = getFont(14)
        self.indexLabel.adjustsFontSizeToFitWidth = true
        self.indexLabel.minimumScaleFactor = 0.5
        self.indexLabel.textAlignment = .center
        self.btnSelect.addSubview(self.indexLabel)
        
        self.bottomShadowView = UIImageView(image: getImage("zl_shadow"))
        self.contentView.addSubview(self.bottomShadowView)
        
        self.videoTag = UIImageView(image: getImage("zl_video"))
        self.bottomShadowView.addSubview(self.videoTag)
        
        self.livePhotoTag = UIImageView(image: getImage("zl_livePhoto"))
        self.bottomShadowView.addSubview(self.livePhotoTag)
        
        self.editImageTag = UIImageView(image: getImage("zl_editImage_tag"))
        self.bottomShadowView.addSubview(self.editImageTag)
        
        self.descLabel = UILabel()
        self.descLabel.font = getFont(13)
        self.descLabel.textAlignment = .right
        self.descLabel.textColor = .white
        self.bottomShadowView.addSubview(self.descLabel)
        
        self.progressView = ZLProgressView()
        self.progressView.isHidden = true
        self.contentView.addSubview(self.progressView)
        
        if ZLPhotoConfiguration.default().showSelectedBorder {
            self.layer.borderColor = UIColor.selectedBorderColor.cgColor
        }
    }
    
    override func layoutSubviews() {
        self.imageView.frame = self.bounds
        self.coverView.frame = self.bounds
        self.btnSelect.frame = CGRect(x: self.bounds.width - 30, y: 8, width: 23, height: 23)
        self.indexLabel.frame = self.btnSelect.bounds
        self.bottomShadowView.frame = CGRect(x: 0, y: self.bounds.height - 25, width: self.bounds.width, height: 25)
        self.videoTag.frame = CGRect(x: 5, y: 1, width: 20, height: 15)
        self.livePhotoTag.frame = CGRect(x: 5, y: -1, width: 20, height: 20)
        self.editImageTag.frame = CGRect(x: 5, y: -1, width: 20, height: 20)
        self.descLabel.frame = CGRect(x: 30, y: 1, width: self.bounds.width - 35, height: 17)
        self.progressView.frame = CGRect(x: (self.bounds.width - 20)/2, y: (self.bounds.height - 20)/2, width: 20, height: 20)
        
        super.layoutSubviews()
    }
    
    @objc func btnSelectClick() {
        if !self.enableSelect, ZLPhotoConfiguration.default().showInvalidMask {
            return
        }
        
        self.btnSelect.layer.removeAllAnimations()
        if !self.btnSelect.isSelected {
            self.btnSelect.layer.add(getSpringAnimation(), forKey: nil)
        }
        
        self.selectedBlock?(self.btnSelect.isSelected)
        
        if self.btnSelect.isSelected {
            self.fetchBigImage()
        } else {
            self.progressView.isHidden = true
            self.cancelFetchBigImage()
        }
    }
    
    func configureCell() {
        if ZLPhotoConfiguration.default().cellCornerRadio > 0 {
            self.layer.cornerRadius = ZLPhotoConfiguration.default().cellCornerRadio
            self.layer.masksToBounds = true
        }
        
        if self.model.type == .video {
            self.bottomShadowView.isHidden = false
            self.videoTag.isHidden = false
            self.livePhotoTag.isHidden = true
            self.editImageTag.isHidden = true
            self.descLabel.text = self.model.duration
        } else if self.model.type == .gif {
            self.bottomShadowView.isHidden = !ZLPhotoConfiguration.default().allowSelectGif
            self.videoTag.isHidden = true
            self.livePhotoTag.isHidden = true
            self.editImageTag.isHidden = true
            self.descLabel.text = "GIF"
        } else if self.model.type == .livePhoto {
            self.bottomShadowView.isHidden = !ZLPhotoConfiguration.default().allowSelectLivePhoto
            self.videoTag.isHidden = true
            self.livePhotoTag.isHidden = false
            self.editImageTag.isHidden = true
            self.descLabel.text = "Live"
        } else {
            if let _ = self.model.editImage {
                self.bottomShadowView.isHidden = false
                self.videoTag.isHidden = true
                self.livePhotoTag.isHidden = true
                self.editImageTag.isHidden = false
                self.descLabel.text = ""
            } else {
                self.bottomShadowView.isHidden = true
            }
        }
        
        let showSelBtn: Bool
        if ZLPhotoConfiguration.default().maxSelectCount > 1 {
            if !ZLPhotoConfiguration.default().allowMixSelect {
                showSelBtn = self.model.type.rawValue < ZLPhotoModel.MediaType.video.rawValue
            } else {
                showSelBtn = true
            }
        } else {
            showSelBtn = ZLPhotoConfiguration.default().showSelectBtnWhenSingleSelect
        }
        
        self.btnSelect.isHidden = !showSelBtn
        self.btnSelect.isUserInteractionEnabled = showSelBtn
        self.btnSelect.isSelected = self.model.isSelected
        
        self.indexLabel.backgroundColor = .indexLabelBgColor
        
        if self.model.isSelected {
            self.fetchBigImage()
        } else {
            self.cancelFetchBigImage()
        }
        
        if let ei = self.model.editImage {
            self.imageView.image = ei
        } else {
            self.fetchSmallImage()
        }
    }
    
    func fetchSmallImage() {
        let size: CGSize
        let maxSideLength = self.bounds.width * 1.2
        if self.model.whRatio > 1 {
            let w = maxSideLength * self.model.whRatio
            size = CGSize(width: w, height: maxSideLength)
        } else {
            let h = maxSideLength / self.model.whRatio
            size = CGSize(width: maxSideLength, height: h)
        }
        
        if self.smallImageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.smallImageRequestID)
        }
        
        self.imageIdentifier = self.model.ident
        self.imageView.image = nil
        self.smallImageRequestID = ZLPhotoManager.fetchImage(for: self.model.asset, size: size, completion: { [weak self] (image, isDegraded) in
            if self?.imageIdentifier == self?.model.ident {
                self?.imageView.image = image
            }
            if !isDegraded {
                self?.smallImageRequestID = PHInvalidImageRequestID
            }
        })
    }
    
    func fetchBigImage() {
        self.cancelFetchBigImage()
        
        self.bigImageReqeustID = ZLPhotoManager.fetchOriginalImageData(for: self.model.asset, progress: { [weak self] (progress, error, _, _) in
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
        }, completion: { [weak self] (_, _, _) in
            self?.resetProgressViewStatus()
        })
    }
    
    func cancelFetchBigImage() {
        if self.bigImageReqeustID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.bigImageReqeustID)
        }
        self.resetProgressViewStatus()
    }
    
    func resetProgressViewStatus() {
        self.progressView.isHidden = true
        self.imageView.alpha = 1
    }
    
}
