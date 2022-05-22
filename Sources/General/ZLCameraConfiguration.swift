//
//  ZLCameraConfiguration.swift
//  ZLPhotoBrowser
//
//  Created by long on 2021/11/10.
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

public class ZLCameraConfiguration: NSObject {
    
    @objc public enum CaptureSessionPreset: Int {
        var avSessionPreset: AVCaptureSession.Preset {
            switch self {
            case .cif352x288:
                return .cif352x288
            case .vga640x480:
                return .vga640x480
            case .hd1280x720:
                return .hd1280x720
            case .hd1920x1080:
                return .hd1920x1080
            case .hd4K3840x2160:
                return .hd4K3840x2160
            }
        }
        
        case cif352x288
        case vga640x480
        case hd1280x720
        case hd1920x1080
        case hd4K3840x2160
    }
    
    @objc public enum FocusMode: Int {
        var avFocusMode: AVCaptureDevice.FocusMode {
            switch self {
            case .autoFocus:
                return .autoFocus
            case .continuousAutoFocus:
                return .continuousAutoFocus
            }
        }
        
        case autoFocus
        case continuousAutoFocus
    }
    
    @objc public enum ExposureMode: Int {
        var avFocusMode: AVCaptureDevice.ExposureMode {
            switch self {
            case .autoExpose:
                return .autoExpose
            case .continuousAutoExposure:
                return .continuousAutoExposure
            }
        }
        
        case autoExpose
        case continuousAutoExposure
    }
    
    @objc public enum FlashMode: Int {
        var avFlashMode: AVCaptureDevice.FlashMode {
            switch self {
            case .auto:
                return .auto
            case .on:
                return .on
            case .off:
                return .off
            }
        }
        
        // 转系统相机
        var imagePickerFlashMode: UIImagePickerController.CameraFlashMode {
            switch self {
            case .auto:
                return .auto
            case .on:
                return .on
            case .off:
                return .off
            }
        }
        
        case auto
        case on
        case off
    }
    
    @objc public enum VideoExportType: Int {
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
    
    /// Video resolution. Defaults to hd1280x720.
    @objc public var sessionPreset: ZLCameraConfiguration.CaptureSessionPreset = .hd1280x720
    
    /// Camera focus mode. Defaults to continuousAutoFocus
    @objc public var focusMode: ZLCameraConfiguration.FocusMode = .continuousAutoFocus
    
    /// Camera exposure mode. Defaults to continuousAutoExposure
    @objc public var exposureMode: ZLCameraConfiguration.ExposureMode = .continuousAutoExposure
    
    /// Camera flahs mode. Default is off. Defaults to off.
    @objc public var flashMode: ZLCameraConfiguration.FlashMode = .off
    
    /// Video export format for recording video and editing video. Defaults to mov.
    @objc public var videoExportType: ZLCameraConfiguration.VideoExportType = .mov
}

// MARK: chaining

public extension ZLCameraConfiguration {
    @discardableResult
    func sessionPreset(_ sessionPreset: ZLCameraConfiguration.CaptureSessionPreset) -> ZLCameraConfiguration {
        self.sessionPreset = sessionPreset
        return self
    }
    
    @discardableResult
    func focusMode(_ mode: ZLCameraConfiguration.FocusMode) -> ZLCameraConfiguration {
        focusMode = mode
        return self
    }
    
    @discardableResult
    func exposureMode(_ mode: ZLCameraConfiguration.ExposureMode) -> ZLCameraConfiguration {
        exposureMode = mode
        return self
    }
    
    @discardableResult
    func flashMode(_ mode: ZLCameraConfiguration.FlashMode) -> ZLCameraConfiguration {
        flashMode = mode
        return self
    }
    
    @discardableResult
    func videoExportType(_ type: ZLCameraConfiguration.VideoExportType) -> ZLCameraConfiguration {
        videoExportType = type
        return self
    }
    
}
