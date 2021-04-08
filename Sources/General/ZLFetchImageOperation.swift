//
//  ZLFetchImageOperation.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
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
    
    var pri_isCancelled = false {
        willSet {
            self.willChangeValue(forKey: "isCancelled")
        }
        didSet {
            self.didChangeValue(forKey: "isCancelled")
        }
    }
    
    var requestImageID: PHImageRequestID = PHInvalidImageRequestID
    
    override var isCancelled: Bool {
        return self.pri_isCancelled
    }
    
    init(model: ZLPhotoModel, isOriginal: Bool, progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )? = nil, completion: @escaping ( (UIImage?, PHAsset?) -> Void )) {
        self.model = model
        self.isOriginal = isOriginal
        self.progress = progress
        self.completion = completion
        super.init()
    }
    
    override func start() {
        if self.isCancelled {
            self.fetchFinish()
            return
        }
        zl_debugPrint("---- start fetch")
        self.pri_isExecuting = true
        
        // 存在编辑的图片
        if let ei = self.model.editImage {
            if ZLPhotoConfiguration.default().saveNewImageAfterEdit {
                ZLPhotoManager.saveImageToAlbum(image: ei) { [weak self] (suc, asset) in
                    self?.completion(ei, asset)
                    self?.fetchFinish()
                }
            } else {
                DispatchQueue.main.async {
                    self.completion(ei, nil)
                    self.fetchFinish()
                }
            }
            return
        }
        
        if ZLPhotoConfiguration.default().allowSelectGif, self.model.type == .gif {
            self.requestImageID = ZLPhotoManager.fetchOriginalImageData(for: self.model.asset) { [weak self] (data, _, isDegraded) in
                if !isDegraded {
                    let image = UIImage.zl_animateGifImage(data: data)
                    self?.completion(image, nil)
                    self?.fetchFinish()
                }
            }
            return
        }
        
        if self.isOriginal {
            self.requestImageID = ZLPhotoManager.fetchOriginalImage(for: self.model.asset, progress: self.progress) { [weak self] (image, isDegraded) in
                if !isDegraded {
                    zl_debugPrint("---- 下载完成 \(String(describing: self?.isCancelled))")
                    self?.completion(image?.fixOrientation(), nil)
                    self?.fetchFinish()
                }
            }
        } else {
            self.requestImageID = ZLPhotoManager.fetchImage(for: self.model.asset, size: self.model.previewSize, progress: self.progress) { [weak self] (image, isDegraded) in
                if !isDegraded {
                    self?.completion(self?.scaleImage(image?.fixOrientation()), nil)
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
        let scale: CGFloat = (data.count > Int(mUnit) ? 0.5 : 0.7)
        
        guard let d = i.jpegData(compressionQuality: scale) else {
            return i
        }
        return UIImage(data: d)
    }
    
    func fetchFinish() {
        self.pri_isExecuting = false
        self.pri_isFinished = true
    }
    
    override func cancel() {
        super.cancel()
        zl_debugPrint("---- cancel \(self.isExecuting) \(self.requestImageID)")
        PHImageManager.default().cancelImageRequest(self.requestImageID)
        self.pri_isCancelled = true
        if self.isExecuting {
            self.fetchFinish()
        }
    }
    
}
