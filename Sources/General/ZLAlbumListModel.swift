//
//  ZLAlbumListModel.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
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

public class ZLAlbumListModel: NSObject {
    
    public let title: String
    
    public var count: Int {
        return result.count
    }
    
    public var result: PHFetchResult<PHAsset>
    
    public let collection: PHAssetCollection
    
    public let option: PHFetchOptions
    
    public let isCameraRoll: Bool
    
    public var headImageAsset: PHAsset? {
        return result.lastObject
    }
    
    public var models: [ZLPhotoModel] = []
    
    // 暂未用到
    private var selectedModels: [ZLPhotoModel] = []
    
    // 暂未用到
    private var selectedCount: Int = 0
    
    public init(
        title: String,
        result: PHFetchResult<PHAsset>,
        collection: PHAssetCollection,
        option: PHFetchOptions,
        isCameraRoll: Bool
    ) {
        self.title = title
        self.result = result
        self.collection = collection
        self.option = option
        self.isCameraRoll = isCameraRoll
    }
    
    public func refetchPhotos() {
        let models = ZLPhotoManager.fetchPhoto(
            in: result,
            ascending: ZLPhotoConfiguration.default().sortAscending,
            allowSelectImage: ZLPhotoConfiguration.default().allowSelectImage,
            allowSelectVideo: ZLPhotoConfiguration.default().allowSelectVideo
        )
        self.models.removeAll()
        self.models.append(contentsOf: models)
    }
    
    func refreshResult() {
        result = PHAsset.fetchAssets(in: collection, options: option)
    }
}

extension ZLAlbumListModel {
    
    static func ==(lhs: ZLAlbumListModel, rhs: ZLAlbumListModel) -> Bool {
        return lhs.title == rhs.title &&
               lhs.count == rhs.count &&
               lhs.headImageAsset?.localIdentifier == rhs.headImageAsset?.localIdentifier
    }
    
}
