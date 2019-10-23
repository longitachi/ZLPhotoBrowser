//
//  ImageCell.swift
//  SwiftExample
//
//  Created by long on 2019/9/26.
//  Copyright © 2019 long. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var playImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView(frame: self.bounds)
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        
        self.playImageView = UIImageView(frame: CGRect(x: self.bounds.width/2-15, y: self.bounds.height/2-15, width: 30, height: 30))
        self.playImageView.contentMode = .scaleAspectFill
        self.playImageView.clipsToBounds = true
        self.playImageView.image = UIImage(named: "playVideo")
        self.contentView.addSubview(self.playImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
