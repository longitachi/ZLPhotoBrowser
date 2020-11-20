//
//  ZLAlbumListCell.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/19.
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

class ZLAlbumListCell: UITableViewCell {

    var coverImageView: UIImageView!
    
    var titleLabel: UILabel!
    
    var countLabel: UILabel!
    
    var selectBtn: UIButton!
    
    var imageIdentifier: String?
    
    var model: ZLAlbumListModel!
    
    var style: ZLPhotoBrowserStyle = .embedAlbumList
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewX: CGFloat
        if self.style == .embedAlbumList {
            imageViewX = 0
        } else {
            imageViewX = 12
        }
        
        self.coverImageView.frame = CGRect(x: imageViewX, y: 2, width: self.bounds.height-4, height: self.bounds.height-4)
        if let m = self.model {
            let titleW = min(self.bounds.width / 3 * 2, m.title.boundingRect(font: getFont(17), limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width)
            self.titleLabel.frame = CGRect(x: self.coverImageView.frame.maxX + 10, y: (self.bounds.height - 30)/2, width: titleW, height: 30)
            
            let countSize = ("(" + String(self.model.count) + ")").boundingRect(font: getFont(16), limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30))
            self.countLabel.frame = CGRect(x: self.titleLabel.frame.maxX + 10, y: (self.bounds.height - 30)/2, width: countSize.width, height: 30)
        }
        self.selectBtn.frame = CGRect(x: self.bounds.width - 20 - 20, y: (self.bounds.height - 20) / 2, width: 20, height: 20)
    }
    
    func setupUI() {
        self.backgroundColor = .albumListBgColor
        self.selectionStyle = .none
        
        self.coverImageView = UIImageView()
        self.coverImageView.contentMode = .scaleAspectFill
        self.coverImageView.clipsToBounds = true
        if ZLPhotoConfiguration.default().cellCornerRadio > 0 {
            self.coverImageView.layer.masksToBounds = true
            self.coverImageView.layer.cornerRadius = ZLPhotoConfiguration.default().cellCornerRadio
        }
        self.contentView.addSubview(self.coverImageView)
        
        self.titleLabel = UILabel()
        self.titleLabel.font = getFont(17)
        self.titleLabel.textColor = .albumListTitleColor
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.contentView.addSubview(self.titleLabel)
        
        self.countLabel = UILabel()
        self.countLabel.font = getFont(16)
        self.countLabel.textColor = .albumListCountColor
        self.contentView.addSubview(self.countLabel)
        
        self.selectBtn = UIButton(type: .custom)
        self.selectBtn.isUserInteractionEnabled = false
        self.selectBtn.isHidden = true
        self.selectBtn.setImage(getImage("zl_albumSelect"), for: .selected)
        self.contentView.addSubview(self.selectBtn)
    }
    
    func configureCell(model: ZLAlbumListModel, style: ZLPhotoBrowserStyle) {
        self.model = model
        self.style = style
        
        self.titleLabel.text = self.model.title
        self.countLabel.text = "(" + String(self.model.count) + ")"
        
        if style == .embedAlbumList {
            self.accessoryType = .none
            self.selectBtn.isHidden = false
        } else {
            self.accessoryType = .disclosureIndicator
            self.selectBtn.isHidden = true
        }
        
        self.imageIdentifier = self.model.headImageAsset?.localIdentifier
        if let asset = self.model.headImageAsset {
            let w = self.bounds.height * 2.5
            ZLPhotoManager.fetchImage(for: asset, size: CGSize(width: w, height: w)) { [weak self] (image, _) in
                if self?.imageIdentifier == self?.model.headImageAsset?.localIdentifier {
                    self?.coverImageView.image = image ?? getImage("zl_defaultphoto")
                }
            }
        }
    }

}
