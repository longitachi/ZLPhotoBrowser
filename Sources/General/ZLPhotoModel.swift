//
//  ZLPhotoModel.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
//
//  Copyright (c) 2020 Long Zhang <longitachi@163.com>
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

extension ZLPhotoModel {
    
    enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
    
}


class ZLPhotoModel: NSObject {

    let ident: String
    
    let asset: PHAsset
    
    var type: ZLPhotoModel.MediaType = .unknown
    
    var duration: String = ""
    
    var isSelected: Bool = false
    
    var editImage: UIImage?
    
    var second: Second {
        guard type == .video else {
            return 0
        }
        return Int(round(asset.duration))
    }
    
    var whRatio: CGFloat {
        return CGFloat(self.asset.pixelWidth) / CGFloat(self.asset.pixelHeight)
    }
    
    var previewSize: CGSize {
        let scale: CGFloat = 2 //UIScreen.main.scale
        if self.whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, ZLMaxImageWidth) * scale
            let w = h * self.whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, ZLMaxImageWidth) * scale
            let h = w / self.whRatio
            return CGSize(width: w, height: h)
        }
    }
    
    // 保存上次编辑图片的一些内容，下次编辑时候可继续上次的编辑
    var editImageModel: ZLEditImageModel?
    
    init(asset: PHAsset) {
        self.ident = asset.localIdentifier
        self.asset = asset
        super.init()
        
        self.type = self.transformAssetType(for: asset)
        if self.type == .video {
            self.duration = self.transformDuration(for: asset)
        }
    }
    
    func transformAssetType(for asset: PHAsset) -> ZLPhotoModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
                return .gif
            }
            if #available(iOS 9.1, *) {
                if asset.mediaSubtypes == .photoLive || asset.mediaSubtypes.rawValue == 10 {
                    return .livePhoto
                }
            }
            return .image
        default:
            return .unknown
        }
    }
    
    func transformDuration(for asset: PHAsset) -> String {
        let dur = Int(round(asset.duration))
        
        switch dur {
        case 0..<60:
            return String(format: "00:%02d", dur)
        case 60..<3600:
            let m = dur / 60
            let s = dur % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = dur / 3600
            let m = (dur % 3600) / 60
            let s = dur % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
    
}


func ==(lhs: ZLPhotoModel, rhs: ZLPhotoModel) -> Bool {
    return lhs.ident == rhs.ident
}
