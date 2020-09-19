//
//  ZLAlbumListModel.swift
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

class ZLAlbumListModel: NSObject {

    let title: String
    
    var count: Int
    
    var result: PHFetchResult<PHAsset>
    
    let collection: PHAssetCollection
    
    let option: PHFetchOptions
    
    let isCameraRoll: Bool
    
    var headImageAsset: PHAsset?
    
    var models: [ZLPhotoModel] = []
    
    // 暂未用到
    var selectedModels: [ZLPhotoModel] = []
    
    // 暂未用到
    var selectedCount: Int = 0
    
    init(title: String, result: PHFetchResult<PHAsset>, collection: PHAssetCollection, option: PHFetchOptions, isCameraRoll: Bool) {
        self.title = title
        self.count = result.count
        self.result = result
        self.collection = collection
        self.option = option
        self.isCameraRoll = isCameraRoll
        
        self.headImageAsset = result.lastObject
    }
    
    func refetchPhotos() {
        let models = ZLPhotoManager.fetchPhoto(in: self.result, ascending: ZLPhotoConfiguration.default().sortAscending, allowSelectImage: ZLPhotoConfiguration.default().allowSelectImage, allowSelectVideo:  ZLPhotoConfiguration.default().allowSelectVideo)
        self.models.removeAll()
        self.models.append(contentsOf: models)
    }
    
    func refreshResult() {
        self.result = PHAsset.fetchAssets(in: self.collection, options: self.option)
        self.count = self.result.count
        self.models.removeAll()
    }
    
}


func ==(lhs: ZLAlbumListModel, rhs: ZLAlbumListModel) -> Bool {
    return lhs.title == rhs.title && lhs.count == rhs.count && lhs.headImageAsset?.localIdentifier == rhs.headImageAsset?.localIdentifier
}
