//
//  ZLPhotoManager.swift
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

public class ZLPhotoManager: NSObject {
    
    /// Save image to album.
    @objc public class func saveImageToAlbum(image: UIImage, completion: ((Bool, PHAsset?) -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .denied || status == .restricted {
            completion?(false, nil)
            return
        }
        
        var placeholderAsset: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset
        }) { suc, _ in
            ZLMainAsync {
                if suc {
                    let asset = self.getAsset(from: placeholderAsset?.localIdentifier)
                    completion?(suc, asset)
                } else {
                    completion?(false, nil)
                }
            }
        }
    }
    
    /// Save video to album.
    @objc public class func saveVideoToAlbum(url: URL, completion: ((Bool, PHAsset?) -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .denied || status == .restricted {
            completion?(false, nil)
            return
        }
        
        var placeholderAsset: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            placeholderAsset = newAssetRequest?.placeholderForCreatedAsset
        }) { suc, _ in
            ZLMainAsync {
                if suc {
                    let asset = self.getAsset(from: placeholderAsset?.localIdentifier)
                    completion?(suc, asset)
                } else {
                    completion?(false, nil)
                }
            }
        }
    }
    
    private class func getAsset(from localIdentifier: String?) -> PHAsset? {
        guard let id = localIdentifier else {
            return nil
        }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        if result.count > 0 {
            return result[0]
        }
        return nil
    }
    
    /// Fetch photos from result.
    @objc public class func fetchPhoto(in result: PHFetchResult<PHAsset>, ascending: Bool, allowSelectImage: Bool, allowSelectVideo: Bool, limitCount: Int = .max) -> [ZLPhotoModel] {
        var models: [ZLPhotoModel] = []
        let option: NSEnumerationOptions = ascending ? .init(rawValue: 0) : .reverse
        var count = 1
        
        result.enumerateObjects(options: option) { asset, _, stop in
            let m = ZLPhotoModel(asset: asset)
            
            if m.type == .image, !allowSelectImage {
                return
            }
            if m.type == .video, !allowSelectVideo {
                return
            }
            if count == limitCount {
                stop.pointee = true
            }
            
            models.append(m)
            count += 1
        }
        
        return models
    }
    
    /// Fetch all album list.
    @objc public class func getPhotoAlbumList(ascending: Bool, allowSelectImage: Bool, allowSelectVideo: Bool, completion: ([ZLAlbumListModel]) -> Void) {
        let option = PHFetchOptions()
        if !allowSelectImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !allowSelectVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil) as! PHFetchResult<PHCollection>
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil) as! PHFetchResult<PHCollection>
        let streamAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: nil) as! PHFetchResult<PHCollection>
        let syncedAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumSyncedAlbum, options: nil) as! PHFetchResult<PHCollection>
        let sharedAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: nil) as! PHFetchResult<PHCollection>
        let arr = [smartAlbums, albums, streamAlbums, syncedAlbums, sharedAlbums]
        
        var albumList: [ZLAlbumListModel] = []
        arr.forEach { album in
            album.enumerateObjects { collection, _, _ in
                guard let collection = collection as? PHAssetCollection else { return }
                if collection.assetCollectionSubtype == .smartAlbumAllHidden {
                    return
                }
                if #available(iOS 11.0, *), collection.assetCollectionSubtype.rawValue > PHAssetCollectionSubtype.smartAlbumLongExposures.rawValue {
                    return
                }
                let result = PHAsset.fetchAssets(in: collection, options: option)
                if result.count == 0 {
                    return
                }
                let title = self.getCollectionTitle(collection)
                
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    // Album of all photos.
                    let m = ZLAlbumListModel(title: title, result: result, collection: collection, option: option, isCameraRoll: true)
                    albumList.insert(m, at: 0)
                } else {
                    let m = ZLAlbumListModel(title: title, result: result, collection: collection, option: option, isCameraRoll: false)
                    albumList.append(m)
                }
            }
        }
        
        completion(albumList)
    }
    
    /// Fetch camera roll album.
    @objc public class func getCameraRollAlbum(allowSelectImage: Bool, allowSelectVideo: Bool, completion: @escaping (ZLAlbumListModel) -> Void) {
        let option = PHFetchOptions()
        if !allowSelectImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !allowSelectVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects { collection, _, stop in
            if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                let result = PHAsset.fetchAssets(in: collection, options: option)
                let albumModel = ZLAlbumListModel(title: self.getCollectionTitle(collection), result: result, collection: collection, option: option, isCameraRoll: true)
                completion(albumModel)
                stop.pointee = true
            }
        }
    }
    
    /// Conversion collection title.
    private class func getCollectionTitle(_ collection: PHAssetCollection) -> String {
        if collection.assetCollectionType == .album {
            // Albums created by user.
            var title: String?
            if ZLCustomLanguageDeploy.language == .system {
                title = collection.localizedTitle
            } else {
                switch collection.assetCollectionSubtype {
                case .albumMyPhotoStream:
                    title = localLanguageTextValue(.myPhotoStream)
                default:
                    title = collection.localizedTitle
                }
            }
            return title ?? localLanguageTextValue(.noTitleAlbumListPlaceholder)
        }
        
        var title: String?
        if ZLCustomLanguageDeploy.language == .system {
            title = collection.localizedTitle
        } else {
            switch collection.assetCollectionSubtype {
            case .smartAlbumUserLibrary:
                title = localLanguageTextValue(.cameraRoll)
            case .smartAlbumPanoramas:
                title = localLanguageTextValue(.panoramas)
            case .smartAlbumVideos:
                title = localLanguageTextValue(.videos)
            case .smartAlbumFavorites:
                title = localLanguageTextValue(.favorites)
            case .smartAlbumTimelapses:
                title = localLanguageTextValue(.timelapses)
            case .smartAlbumRecentlyAdded:
                title = localLanguageTextValue(.recentlyAdded)
            case .smartAlbumBursts:
                title = localLanguageTextValue(.bursts)
            case .smartAlbumSlomoVideos:
                title = localLanguageTextValue(.slomoVideos)
            case .smartAlbumSelfPortraits:
                title = localLanguageTextValue(.selfPortraits)
            case .smartAlbumScreenshots:
                title = localLanguageTextValue(.screenshots)
            case .smartAlbumDepthEffect:
                title = localLanguageTextValue(.depthEffect)
            case .smartAlbumLivePhotos:
                title = localLanguageTextValue(.livePhotos)
            default:
                title = collection.localizedTitle
            }
            
            if #available(iOS 11.0, *) {
                if collection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumAnimated {
                    title = localLanguageTextValue(.animated)
                }
            }
        }
        
        return title ?? localLanguageTextValue(.noTitleAlbumListPlaceholder)
    }
    
    @discardableResult
    @objc public class func fetchImage(for asset: PHAsset, size: CGSize, progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil, completion: @escaping (UIImage?, Bool) -> Void) -> PHImageRequestID {
        return fetchImage(for: asset, size: size, resizeMode: .fast, progress: progress, completion: completion)
    }
    
    @discardableResult
    @objc public class func fetchOriginalImage(for asset: PHAsset, progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil, completion: @escaping (UIImage?, Bool) -> Void) -> PHImageRequestID {
        return fetchImage(for: asset, size: PHImageManagerMaximumSize, resizeMode: .fast, progress: progress, completion: completion)
    }
    
    /// Fetch asset data.
    @discardableResult
    @objc public class func fetchOriginalImageData(for asset: PHAsset, progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil, completion: @escaping (Data, [AnyHashable: Any]?, Bool) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
            option.version = .original
        }
        option.isNetworkAccessAllowed = true
        option.resizeMode = .fast
        option.deliveryMode = .highQualityFormat
        option.progressHandler = { pro, error, stop, info in
            ZLMainAsync {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        return PHImageManager.default().requestImageData(for: asset, options: option) { data, _, _, info in
            let cancel = info?[PHImageCancelledKey] as? Bool ?? false
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if !cancel, let data = data {
                completion(data, info, isDegraded)
            }
        }
    }
    
    /// Fetch image for asset.
    private class func fetchImage(for asset: PHAsset, size: CGSize, resizeMode: PHImageRequestOptionsResizeMode, progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil, completion: @escaping (UIImage?, Bool) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        option.isNetworkAccessAllowed = true
        option.progressHandler = { pro, error, stop, info in
            ZLMainAsync {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        return PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { image, info in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished {
                completion(image, isDegraded)
            }
        }
    }
    
    @objc public class func fetchLivePhoto(for asset: PHAsset, completion: @escaping (PHLivePhoto?, [AnyHashable: Any]?, Bool) -> Void) -> PHImageRequestID {
        let option = PHLivePhotoRequestOptions()
        option.version = .current
        option.deliveryMode = .opportunistic
        option.isNetworkAccessAllowed = true
        
        return PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { livePhoto, info in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            completion(livePhoto, info, isDegraded)
        }
    }
    
    @objc public class func fetchVideo(for asset: PHAsset, progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil, completion: @escaping (AVPlayerItem?, [AnyHashable: Any]?, Bool) -> Void) -> PHImageRequestID {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.progressHandler = { pro, error, stop, info in
            ZLMainAsync {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        // https://github.com/longitachi/ZLPhotoBrowser/issues/369#issuecomment-728679135
        if asset.zl.isInCloud {
            return PHImageManager.default().requestExportSession(forVideo: asset, options: option, exportPreset: AVAssetExportPresetHighestQuality, resultHandler: { session, info in
                // iOS11 and earlier, callback is not on the main thread.
                ZLMainAsync {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    if let avAsset = session?.asset {
                        let item = AVPlayerItem(asset: avAsset)
                        completion(item, info, isDegraded)
                    } else {
                        completion(nil, nil, true)
                    }
                }
            })
        } else {
            return PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { item, info in
                // iOS11 and earlier, callback is not on the main thread.
                ZLMainAsync {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    completion(item, info, isDegraded)
                }
            }
        }
    }
    
    class func isFetchImageError(_ error: Error?) -> Bool {
        guard let e = error as NSError? else {
            return false
        }
        if e.domain == "CKErrorDomain" || e.domain == "CloudPhotoLibraryErrorDomain" {
            return true
        }
        return false
    }
    
    @objc public class func fetchAVAsset(forVideo asset: PHAsset, completion: @escaping (AVAsset?, [AnyHashable: Any]?) -> Void) -> PHImageRequestID {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        if asset.zl.isInCloud {
            return PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { session, info in
                // iOS11 and earlier, callback is not on the main thread.
                ZLMainAsync {
                    if let avAsset = session?.asset {
                        completion(avAsset, info)
                    } else {
                        completion(nil, info)
                    }
                }
            }
        } else {
            return PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, info in
                ZLMainAsync {
                    completion(avAsset, info)
                }
            }
        }
    }
    
    /// Fetch asset local file path.
    @objc public class func fetchAssetFilePath(asset: PHAsset, completion: @escaping (String?) -> Void) {
        asset.requestContentEditingInput(with: nil) { input, _ in
            var path = input?.fullSizeImageURL?.absoluteString
            if path == nil, let dir = asset.value(forKey: "directory") as? String, let name = asset.value(forKey: "filename") as? String {
                path = String(format: "file:///var/mobile/Media/%@/%@", dir, name)
            }
            completion(path)
        }
    }
    
    /// Save asset to file url. Support save image and video.
    @objc public class func saveAsset(_ asset: PHAsset, toFile fileUrl: URL, completion: @escaping ((Error?) -> Void)) {
        guard let resource = asset.zl.resource else {
            completion(NSError.assetSaveError)
            return
        }
        
        PHAssetResourceManager.default().writeData(for: resource, toFile: fileUrl, options: nil) { error in
            ZLMainAsync {
                completion(error)
            }
        }
    }
}

/// Authority related.
public extension ZLPhotoManager {
    @objc class func hasPhotoLibratyAuthority() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    @objc class func hasCameraAuthority() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            return false
        }
        return true
    }
    
    @objc class func hasMicrophoneAuthority() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .restricted || status == .denied {
            return false
        }
        return true
    }
    
}
