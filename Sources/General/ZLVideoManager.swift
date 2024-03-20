//
//  ZLVideoManager.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/9/23.
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
import AVFoundation
import Photos

public class ZLVideoManager: NSObject {
    class func getVideoExportFilePath(format: String? = nil) -> String {
        let format = format ?? ZLPhotoConfiguration.default().cameraConfiguration.videoExportType.format
        return NSTemporaryDirectory().appendingFormat("%@.%@", UUID().uuidString, format)
    }
    
    class func exportEditVideo(for asset: AVAsset, range: CMTimeRange, complete: @escaping ((URL?, Error?) -> Void)) {
        let type: ZLVideoManager.ExportType = ZLPhotoConfiguration.default().cameraConfiguration.videoExportType == .mov ? .mov : .mp4
        exportVideo(for: asset, range: range, exportType: type, presetName: AVAssetExportPresetPassthrough) { url, error in
            if url != nil {
                complete(url!, error)
            } else {
                complete(nil, error)
            }
        }
    }
    
    /// 没有针对不同分辨率视频做处理，仅用于处理相机拍照的视频
    @objc public class func mergeVideos(fileURLs: [URL], completion: @escaping ((URL?, Error?) -> Void)) {
        let composition = AVMutableComposition()
        let assets = fileURLs.map { AVURLAsset(url: $0) }
        
        var insertTime: CMTime = .zero
        var assetVideoTracks: [AVAssetTrack] = []
        
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())!
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())!
        
        for asset in assets {
            do {
                let timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
                if let videoTrack = asset.tracks(withMediaType: .video).first {
                    try compositionVideoTrack.insertTimeRange(
                        timeRange,
                        of: videoTrack,
                        at: insertTime
                    )
                    
                    assetVideoTracks.append(videoTrack)
                }
                
                if let audioTrack = asset.tracks(withMediaType: .audio).first {
                    try compositionAudioTrack.insertTimeRange(
                        timeRange,
                        of: audioTrack,
                        at: insertTime
                    )
                }
                
                insertTime = CMTimeAdd(insertTime, asset.duration)
            } catch {
                completion(nil, NSError.videoMergeError)
                return
            }
        }
        
        guard assetVideoTracks.count == assets.count else {
            completion(nil, NSError.videoMergeError)
            return
        }
        
        let renderSize = getNaturalSize(videoTrack: assetVideoTracks[0])
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = getInstructions(compositionTrack: compositionVideoTrack, assetVideoTracks: assetVideoTracks, assets: assets)
        videoComposition.frameDuration = assetVideoTracks[0].minFrameDuration
        videoComposition.renderSize = renderSize
        videoComposition.renderScale = 1
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720) else {
            completion(nil, NSError.videoMergeError)
            return
        }
        
        let outputURL = URL(fileURLWithPath: ZLVideoManager.getVideoExportFilePath())
        exportSession.outputURL = outputURL
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = ZLPhotoConfiguration.default().cameraConfiguration.videoExportType.avFileType
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously(completionHandler: {
            let suc = exportSession.status == .completed
            if exportSession.status == .failed {
                zl_debugPrint("ZLPhotoBrowser: video merge failed:  \(exportSession.error?.localizedDescription ?? "")")
            }
            ZLMainAsync {
                completion(suc ? outputURL : nil, exportSession.error)
            }
        })
    }
    
    private static func getNaturalSize(videoTrack: AVAssetTrack) -> CGSize {
        var size = videoTrack.naturalSize
        if isPortraitVideoTrack(videoTrack) {
            swap(&size.width, &size.height)
        }
        return size
    }
    
    private static func getInstructions(
        compositionTrack: AVMutableCompositionTrack,
        assetVideoTracks: [AVAssetTrack],
        assets: [AVURLAsset]
    ) -> [AVMutableVideoCompositionInstruction] {
        var instructions: [AVMutableVideoCompositionInstruction] = []
        
        var start: CMTime = .zero
        for (index, videoTrack) in assetVideoTracks.enumerated() {
            let asset = assets[index]
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
            layerInstruction.setTransform(videoTrack.preferredTransform, at: .zero)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: start, duration: asset.duration)
            instruction.layerInstructions = [layerInstruction]
            instructions.append(instruction)
            
            start = CMTimeAdd(start, asset.duration)
        }
        
        return instructions
    }
    
    private static func isPortraitVideoTrack(_ track: AVAssetTrack) -> Bool {
        let transform = track.preferredTransform
        let tfA = transform.a
        let tfB = transform.b
        let tfC = transform.c
        let tfD = transform.d
        
        if (tfA == 0 && tfB == 1 && tfC == -1 && tfD == 0) ||
            (tfA == 0 && tfB == 1 && tfC == 1 && tfD == 0) ||
            (tfA == 0 && tfB == -1 && tfC == 1 && tfD == 0) {
            return true
        } else {
            return false
        }
    }
}

// MARK: export methods

public extension ZLVideoManager {
    @objc class func exportVideo(for asset: PHAsset, exportType: ZLVideoManager.ExportType = .mov, presetName: String = AVAssetExportPresetMediumQuality, complete: @escaping ((URL?, Error?) -> Void)) {
        guard asset.mediaType == .video else {
            complete(nil, NSError.videoExportTypeError)
            return
        }
        
        _ = ZLPhotoManager.fetchAVAsset(forVideo: asset) { avAsset, _ in
            if let set = avAsset {
                self.exportVideo(for: set, exportType: exportType, presetName: presetName, complete: complete)
            } else {
                complete(nil, NSError.videoExportError)
            }
        }
    }
    
    @objc class func exportVideo(for asset: AVAsset, range: CMTimeRange = CMTimeRange(start: .zero, duration: .positiveInfinity), exportType: ZLVideoManager.ExportType = .mov, presetName: String = AVAssetExportPresetMediumQuality, complete: @escaping ((URL?, Error?) -> Void)) {
        let outputURL = URL(fileURLWithPath: getVideoExportFilePath(format: exportType.format))
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: presetName) else {
            complete(nil, NSError.videoExportError)
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = exportType.avFileType
        exportSession.timeRange = range
        
        exportSession.exportAsynchronously(completionHandler: {
            let suc = exportSession.status == .completed
            if exportSession.status == .failed {
                zl_debugPrint("ZLPhotoBrowser: video export failed: \(exportSession.error?.localizedDescription ?? "")")
            }
            ZLMainAsync {
                complete(suc ? outputURL : nil, exportSession.error)
            }
        })
    }
}

public extension ZLVideoManager {
    @objc enum ExportType: Int {
        var format: String {
            switch self {
            case .mov:
                return "mov"
            case .mp4:
                return "mp4"
            }
        }
        
        var avFileType: AVFileType {
            switch self {
            case .mov:
                return .mov
            case .mp4:
                return .mp4
            }
        }
        
        case mov
        case mp4
    }
}
