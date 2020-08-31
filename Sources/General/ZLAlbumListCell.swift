//
//  ZLAlbumListCell.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/19.
//

import UIKit

class ZLAlbumListCell: UITableViewCell {

    var coverImageView: UIImageView!
    
    var titleLabel: UILabel!
    
    var countLabel: UILabel!
    
    var imageIdentifier: String?
    
    var model: ZLAlbumListModel! {
        didSet {
            self.configureCell()
        }
    }
    
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
        self.coverImageView.frame = CGRect(x: 12, y: 2, width: self.bounds.height-4, height: self.bounds.height-4)
        if let m = self.model {
            let size = m.title.boundingRect(font: getFont(17), limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30))
            self.titleLabel.frame = CGRect(x: self.coverImageView.frame.maxX + 10, y: (self.bounds.height - 30)/2, width: size.width, height: 30)
            
            let countSize = ("(" + String(self.model.count) + ")").boundingRect(font: getFont(16), limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30))
            self.countLabel.frame = CGRect(x: self.titleLabel.frame.maxX + 10, y: (self.bounds.height - 30)/2, width: countSize.width, height: 30)
        }
    }
    
    func setupUI() {
        self.accessoryType = .disclosureIndicator
        self.backgroundColor = .albumListBgColor
        
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
    }
    
    func configureCell() {
        self.titleLabel.text = self.model.title
        self.countLabel.text = "(" + String(self.model.count) + ")"
            
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
