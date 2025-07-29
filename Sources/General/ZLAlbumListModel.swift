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
    
    private var currentLoadIndex: Int
    
    // 根据最小公倍数计算出一个接近pageSize的值
    private var onceLoadCount: Int { Int(ceil(Double(ZLPhotoUIConfiguration.default().pageSize) / Double(lcmColumns))) * lcmColumns }
    
    // 竖屏列数和横屏列数的最小公倍数
    private var lcmColumns = 12
    
    var columnCounts = (portrait: 4, landscape: 6) {
        didSet {
            lcmColumns = lcm(columnCounts.portrait, columnCounts.landscape)
        }
    }
    
    // 暂未用到
    private var selectedModels: [ZLPhotoModel] = []
    
    // 暂未用到
    private var selectedCount = 0
    
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
        currentLoadIndex = result.count
    }
    
    private func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a, b = b
        while b != 0 {
            (a, b) = (b, a % b)
        }
        return a
    }

    private func lcm(_ a: Int, _ b: Int) -> Int {
        return a * b / gcd(a, b)
    }
    
    @discardableResult
    public func preloadPhotos(loadAll: Bool = false) -> [ZLPhotoModel] {
        // 受限访问时，如果首次未选择任何照片，currentLoadIndex会为0，那么后续再添加照片的时候，需要重置该值来触发重新加载
        // bug: https://github.com/longitachi/ZLPhotoBrowser/issues/1016
        if currentLoadIndex == 0, models.count != result.count {
            currentLoadIndex = result.count
            models.removeAll()
        }
        
        guard currentLoadIndex > 0 else { return [] }
        
        var loadCount = onceLoadCount
        let isFirstLoad = currentLoadIndex == result.count
        if isFirstLoad {
            // mod横竖屏列数的最小公倍数，并在第一次加载时候把余数给加载了，从而使后续分页加载的数据均为整数行
            let mod = result.count % lcmColumns
            loadCount = onceLoadCount + mod
        }
        
        let minIndex = loadAll ? 0 : max(0, currentLoadIndex - loadCount)
        let indexSet = IndexSet(minIndex..<currentLoadIndex)
        currentLoadIndex = minIndex
        let models = ZLPhotoManager.fetchPhoto(
            in: result,
            ascending: ZLPhotoUIConfiguration.default().sortAscending,
            allowSelectImage: ZLPhotoConfiguration.default().allowSelectImage,
            allowSelectVideo: ZLPhotoConfiguration.default().allowSelectVideo,
            indexSet: indexSet
        )
        
        if ZLPhotoUIConfiguration.default().sortAscending {
            self.models.insert(contentsOf: models, at: 0)
        } else {
            self.models.append(contentsOf: models)
        }
        
        return models
    }
    
    func refreshResult() {
        result = PHAsset.fetchAssets(in: collection, options: option)
    }
}

public extension ZLAlbumListModel {
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ZLAlbumListModel else {
            return false
        }
        
        return title == object.title &&
            count == object.count &&
            headImageAsset?.localIdentifier == object.headImageAsset?.localIdentifier
    }
}
