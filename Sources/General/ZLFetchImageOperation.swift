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

class ZLFetchImageOperation: Operation, @unchecked Sendable {
    private let model: ZLPhotoModel
    
    private let isOriginal: Bool
    
    private let progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)?
    
    private let completion: (UIImage?, PHAsset?) -> Void
    
    private var pri_isExecuting = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return pri_isExecuting
    }
    
    private var pri_isFinished = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return pri_isFinished
    }
    
    private var pri_isCancelled = false {
        willSet {
            willChangeValue(forKey: "isCancelled")
        }
        didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    private var requestImageID = PHInvalidImageRequestID
    
    override var isCancelled: Bool {
        return pri_isCancelled
    }
    
    init(
        model: ZLPhotoModel,
        isOriginal: Bool,
        progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil,
        completion: @escaping ((UIImage?, PHAsset?) -> Void)
    ) {
        self.model = model
        self.isOriginal = isOriginal
        self.progress = progress
        self.completion = completion
        super.init()
    }
    
    override func start() {
        if isCancelled {
            fetchFinish()
            return
        }
        zl_debugPrint("---- start fetch")
        pri_isExecuting = true
        
        // 存在编辑的图片
        if let editImage = model.editImage {
            if ZLPhotoConfiguration.default().saveNewImageAfterEdit {
                ZLPhotoManager.saveImageToAlbum(image: editImage) { [weak self] _, asset in
                    self?.completion(editImage, asset)
                    self?.fetchFinish()
                }
            } else {
                ZLMainAsync {
                    self.completion(editImage, nil)
                    self.fetchFinish()
                }
            }
            return
        }
        
        // 存在编辑的视频
        if let url = model.editVideoModel?.url {
            ZLPhotoManager.saveVideoToAlbum(url: url) { [weak self] error, asset in
                guard let asset else {
                    self?.completion(nil, nil)
                    self?.fetchFinish()
                    return
                }
                
                let newVideoModel = ZLPhotoModel(asset: asset)
                self?.fetchImage(for: newVideoModel) { image in
                    self?.completion(image, asset)
                    self?.fetchFinish()
                }
            }
            
            return
        }
        
        if ZLPhotoConfiguration.default().allowSelectGif, model.type == .gif {
            requestImageID = ZLPhotoManager.fetchOriginalImageData(for: model.asset) { [weak self] data, _, isDegraded in
                if !isDegraded {
                    let image = UIImage.zl.animateGifImage(data: data)
                    self?.completion(image, nil)
                    self?.fetchFinish()
                }
            }
            return
        }
        
        fetchImage(for: model) { [weak self] image in
            self?.completion(image, nil)
            self?.fetchFinish()
        }
    }
    
    private func fetchImage(for model: ZLPhotoModel, completion: @escaping ((UIImage?) -> Void)) {
        if isOriginal {
            requestImageID = ZLPhotoManager.fetchOriginalImage(for: model.asset, progress: progress) { [weak self] image, isDegraded in
                if !isDegraded {
                    zl_debugPrint("---- 原图加载完成 \(String(describing: self?.isCancelled))")
                    completion(image?.zl.fixOrientation())
                }
            }
        } else {
            requestImageID = ZLPhotoManager.fetchImage(for: model.asset, size: model.previewSize, progress: progress) { [weak self] image, isDegraded in
                if !isDegraded {
                    zl_debugPrint("---- 加载完成 isCancelled: \(String(describing: self?.isCancelled))")
                    completion(self?.scaleImage(image?.zl.fixOrientation()))
                }
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        zl_debugPrint("---- cancel \(isExecuting) \(requestImageID)")
        PHImageManager.default().cancelImageRequest(requestImageID)
        pri_isCancelled = true
        if isExecuting {
            fetchFinish()
        }
    }
    
    private func scaleImage(_ image: UIImage?) -> UIImage? {
        guard let image else { return nil }
        
        let mUnit: CGFloat = 1024 * 1024
        guard let data = image.jpegData(compressionQuality: 1), data.count >= Int(0.2 * mUnit) else {
            return image
        }
        
        if #available(iOS 11.0, *) {
            if let data = heifData(from: image, quality: 0.5) {
                return UIImage(data: data) ?? image
            }
            return image
        } else {
            let scale: CGFloat = (data.count > Int(mUnit) ? 0.6 : 0.8)
            return image.jpegData(compressionQuality: scale).flatMap { UIImage(data: $0) } ?? image
        }
    }
    
    @available(iOS 11.0, *)
    private func heifData(from image: UIImage, quality: CGFloat) -> Data? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil) else {
            return nil
        }
        
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        CGImageDestinationAddImage(dest, cgImage, options as CFDictionary)
        guard CGImageDestinationFinalize(dest) else {
            return nil
        }
        return data as Data
    }
    
    private func fetchFinish() {
        pri_isExecuting = false
        pri_isFinished = true
    }
}
