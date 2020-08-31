//
//  ZLFetchImageOperation.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
//

import UIKit
import Photos

class ZLFetchImageOperation: Operation {

    let model: ZLPhotoModel
    
    let isOriginal: Bool
    
    let progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )?
    
    let completion: ( (UIImage?, PHAsset?) -> Void )
    
    var pri_isExecuting = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return self.pri_isExecuting
    }
    
    var pri_isFinished = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return self.pri_isFinished
    }
    
    init(model: ZLPhotoModel, isOriginal: Bool, progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )? = nil, completion: @escaping ( (UIImage?, PHAsset?) -> Void )) {
        self.model = model
        self.isOriginal = isOriginal
        self.progress = progress
        self.completion = completion
        super.init()
    }
    
    override func start() {
        debugPrint("---- start fetch")
        self.pri_isExecuting = true
        
        // 存在编辑的图片
        if let ei = self.model.editImage {
            if ZLPhotoConfiguration.default().saveNewImageAfterEdit {
                ZLPhotoManager.saveImageToAlbum(image: ei) { [weak self] (suc, asset) in
                    self?.completion(ei, asset)
                    self?.fetchFinish()
                }
            } else {
                self.completion(ei, nil)
                self.fetchFinish()
            }
            return
        }
        
        if self.isOriginal {
            ZLPhotoManager.fetchOriginalImage(for: self.model.asset, progress: self.progress) { [weak self] (image, isDegraded) in
                if !isDegraded {
                    self?.completion(self?.scaleImage(image), nil)
                    self?.fetchFinish()
                }
            }
        } else {
            let w = min(UIScreen.main.bounds.width, ZLMaxImageWidth) * 2
            let aspectRatio = CGFloat(self.model.asset.pixelHeight) / CGFloat(self.model.asset.pixelWidth)
            ZLPhotoManager.fetchImage(for: self.model.asset, size: CGSize(width: w, height: w * aspectRatio), progress: self.progress) { [weak self] (image, isDegraded) in
                if !isDegraded {
                    self?.completion(self?.scaleImage(image), nil)
                    self?.fetchFinish()
                }
            }
        }
    }
    
    func scaleImage(_ image: UIImage?) -> UIImage? {
        guard let i = image else {
            return nil
        }
        guard let data = i.jpegData(compressionQuality: 1) else {
            return i
        }
        let mUnit: CGFloat = 1024 * 1024
        
        if data.count < Int(0.2 * mUnit) {
            return i
        }
        let scale: CGFloat = self.isOriginal ? (data.count > Int(mUnit) ? 0.7 : 0.9) : (data.count > Int(mUnit) ? 0.5 : 0.7)
        
        guard let d = i.jpegData(compressionQuality: scale) else {
            return i
        }
        return UIImage(data: d)
    }
    
    func fetchFinish() {
        self.pri_isExecuting = false
        self.pri_isFinished = true
    }
    
}
