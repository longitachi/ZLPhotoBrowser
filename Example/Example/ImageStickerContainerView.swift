//
//  ImageStickerContainerView.swift
//  Example
//
//  Created by long on 2020/11/20.
//

import UIKit
import ZLPhotoBrowser

class ImageStickerContainerView: UIView, ZLImageStickerContainerDelegate {
    
    static let baseViewH: CGFloat = 400
    
    var baseView: UIView!
    
    var collectionView: UICollectionView!
    
    var selectImageBlock: ((UIImage) -> Void)?
    
    var hideBlock: (() -> Void)?
    
    let datas = {
        (1...18).map { (v) -> String in
            "imageSticker" + String(v)
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: ImageStickerContainerView.baseViewH), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        self.baseView.layer.mask = nil
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.baseView.layer.mask = maskLayer
    }
    
    func setupUI() {
        self.baseView = UIView()
        self.addSubview(self.baseView)
        self.baseView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(ImageStickerContainerView.baseViewH)
            make.height.equalTo(ImageStickerContainerView.baseViewH)
        }
        
        let visualView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.baseView.addSubview(visualView)
        visualView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.baseView)
        }
        
        let toolView = UIView()
        toolView.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        self.baseView.addSubview(toolView)
        toolView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.baseView)
            make.height.equalTo(50)
        }
        
        let hideBtn = UIButton(type: .custom)
        hideBtn.setImage(UIImage(named: "close"), for: .normal)
        hideBtn.backgroundColor = .clear
        hideBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        hideBtn.addTarget(self, action: #selector(hideBtnClick), for: .touchUpInside)
        toolView.addSubview(hideBtn)
        hideBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(toolView)
            make.right.equalTo(toolView).offset(-20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.baseView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(toolView.snp.bottom)
            make.left.right.bottom.equalTo(self.baseView)
        }
        
        self.collectionView.register(ImageStickerCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImageStickerCell.classForCoder()))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideBtnClick))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    @objc func hideBtnClick() {
        self.hide()
    }
    
    func show(in view: UIView) {
        if self.superview !== view {
            self.removeFromSuperview()
            
            view.addSubview(self)
            self.snp.makeConstraints { (make) in
                make.edges.equalTo(view)
            }
            view.layoutIfNeeded()
        }
        
        self.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.baseView.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.snp.bottom)
            }
            view.layoutIfNeeded()
        }
    }
    
    func hide() {
        self.hideBlock?()
        
        UIView.animate(withDuration: 0.25) {
            self.baseView.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.snp.bottom).offset(ImageStickerContainerView.baseViewH)
            }
            self.superview?.layoutIfNeeded()
        } completion: { (_) in
            self.isHidden = true
        }

    }
    
}


extension ImageStickerContainerView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        return !self.baseView.frame.contains(location)
    }
    
}


extension ImageStickerContainerView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let column: CGFloat = 4
        let spacing: CGFloat = 20 + 5 * (column - 1)
        let w = (collectionView.frame.width - spacing) / column
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ImageStickerCell.classForCoder()), for: indexPath) as! ImageStickerCell
        
        cell.imageView.image = UIImage(named: self.datas[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = UIImage(named: self.datas[indexPath.row]) else {
            return
        }
        self.selectImageBlock?(image)
        self.hide()
    }
    
}


class ImageStickerCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
