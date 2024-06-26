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

@objcMembers
public class ZLCameraConfiguration: NSObject {
    private var pri_allowTakePhoto = true
    /// Allow taking photos in the camera (Need allowSelectImage to be true). Defaults to true.
    public var allowTakePhoto: Bool {
        get {
            pri_allowTakePhoto && ZLPhotoConfiguration.default().allowSelectImage
        }
        set {
            pri_allowTakePhoto = newValue
        }
    }
    
    private var pri_allowRecordVideo = true
    /// Allow recording in the camera (Need allowSelectVideo to be true). Defaults to true.
    public var allowRecordVideo: Bool {
        get {
            pri_allowRecordVideo && ZLPhotoConfiguration.default().allowSelectVideo
        }
        set {
            pri_allowRecordVideo = newValue
        }
    }
    
    private var pri_minRecordDuration: ZLPhotoConfiguration.Second = 0
    /// Minimum recording duration. Defaults to 0.
    public var minRecordDuration: ZLPhotoConfiguration.Second {
        get {
            pri_minRecordDuration
        }
        set {
            pri_minRecordDuration = max(0, newValue)
        }
    }
    
    private var pri_maxRecordDuration: ZLPhotoConfiguration.Second = 20
    /// Maximum recording duration. Defaults to 20, minimum is 1.
    public var maxRecordDuration: ZLPhotoConfiguration.Second {
        get {
            pri_maxRecordDuration
        }
        set {
            pri_maxRecordDuration = max(1, newValue)
        }
    }
    
    /// Indicates whether the video flowing through the connection should be mirrored about its vertical axis.
    public var isVideoMirrored = true
    
    /// Video resolution. Defaults to hd1920x1080.
    public var sessionPreset: ZLCameraConfiguration.CaptureSessionPreset = .hd1920x1080
    
    /// Camera focus mode. Defaults to continuousAutoFocus
    public var focusMode: ZLCameraConfiguration.FocusMode = .continuousAutoFocus
    
    /// Camera exposure mode. Defaults to continuousAutoExposure
    public var exposureMode: ZLCameraConfiguration.ExposureMode = .continuousAutoExposure
    
    /// Camera flahs switch. Defaults to true.
    public var showFlashSwitch = true
    
    /// Whether to support switch camera. Defaults to true.
    public var allowSwitchCamera = true
    
    /// Video export format for recording video and editing video. Defaults to mov.
    public var videoExportType: ZLCameraConfiguration.VideoExportType = .mov
    
    /// The default camera position after entering the camera. Defaults to back.
    public var devicePosition: ZLCameraConfiguration.DevicePosition = .back
    
    private var pri_videoCodecType: Any?
    /// The codecs for video capture. Defaults to .h264
    @available(iOS 11.0, *)
    public var videoCodecType: AVVideoCodecType {
        get {
            (pri_videoCodecType as? AVVideoCodecType) ?? .h264
        }
        set {
            pri_videoCodecType = newValue
        }
    }
}

public extension ZLCameraConfiguration {
    @objc enum CaptureSessionPreset: Int {
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
            case .photo:
                return .photo
            }
        }
        
        case cif352x288
        case vga640x480
        case hd1280x720
        case hd1920x1080
        case hd4K3840x2160
        case photo
    }
    
    @objc enum FocusMode: Int {
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
    
    @objc enum ExposureMode: Int {
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
    
    @objc enum VideoExportType: Int {
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
    
    @objc enum DevicePosition: Int {
        case back
        case front
        
        /// For custom camera
        var avDevicePosition: AVCaptureDevice.Position {
            switch self {
            case .back:
                return .back
            case .front:
                return .front
            }
        }
        
        /// For system camera
        var cameraDevice: UIImagePickerController.CameraDevice {
            switch self {
            case .back:
                return .rear
            case .front:
                return .front
            }
        }
    }
}

// MARK: chaining

public extension ZLCameraConfiguration {
    @discardableResult
    func allowTakePhoto(_ value: Bool) -> ZLCameraConfiguration {
        allowTakePhoto = value
        return self
    }
    
    @discardableResult
    func allowRecordVideo(_ value: Bool) -> ZLCameraConfiguration {
        allowRecordVideo = value
        return self
    }
    
    @discardableResult
    func minRecordDuration(_ duration: ZLPhotoConfiguration.Second) -> ZLCameraConfiguration {
        minRecordDuration = duration
        return self
    }
    
    @discardableResult
    func maxRecordDuration(_ duration: ZLPhotoConfiguration.Second) -> ZLCameraConfiguration {
        maxRecordDuration = duration
        return self
    }
    
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
    func showFlashSwitch(_ value: Bool) -> ZLCameraConfiguration {
        showFlashSwitch = value
        return self
    }
    
    @discardableResult
    func allowSwitchCamera(_ value: Bool) -> ZLCameraConfiguration {
        allowSwitchCamera = value
        return self
    }
    
    @discardableResult
    func videoExportType(_ type: ZLCameraConfiguration.VideoExportType) -> ZLCameraConfiguration {
        videoExportType = type
        return self
    }
    
    @discardableResult
    func devicePosition(_ position: ZLCameraConfiguration.DevicePosition) -> ZLCameraConfiguration {
        devicePosition = position
        return self
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func videoCodecType(_ type: AVVideoCodecType) -> ZLCameraConfiguration {
        videoCodecType = type
        return self
    }
}
