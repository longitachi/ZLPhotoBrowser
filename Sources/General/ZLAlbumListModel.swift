//
//  ZLAlbumListModel.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
//

import UIKit
import Photos

class ZLAlbumListModel: NSObject {

    let title: String
    
    var count: Int
    
    let result: PHFetchResult<PHAsset>
    
    let isCameraRoll: Bool
    
    var headImageAsset: PHAsset?
    
    var models: [ZLPhotoModel] = []
    
    // 暂未用到
    var selectedModels: [ZLPhotoModel] = []
    
    // 暂未用到
    var selectedCount: Int = 0
    
    init(title: String, result: PHFetchResult<PHAsset>, isCameraRoll: Bool, ascending: Bool) {
        self.title = title
        self.count = result.count
        self.result = result
        self.isCameraRoll = isCameraRoll
        if ascending {
            self.headImageAsset = result.lastObject
        } else {
            self.headImageAsset = result.firstObject
        }
    }
    
    func refetchPhotos() {
        let models = ZLPhotoManager.fetchPhoto(in: self.result, allowSelectImage: ZLPhotoConfiguration.default().allowSelectImage, allowSelectVideo:  ZLPhotoConfiguration.default().allowSelectVideo)
        self.models.removeAll()
        self.models.append(contentsOf: models)
    }
    
}
