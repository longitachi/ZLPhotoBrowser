//
//  ZLCameraCell.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/19.
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

class ZLCameraCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: .zl.getImage("zl_takePhoto"))
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private var session: AVCaptureSession?
    
    private var videoInput: AVCaptureDeviceInput?
    
    private var photoOutput: AVCapturePhotoOutput?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    var isEnable = true {
        didSet {
            contentView.alpha = isEnable ? 1 : 0.3
        }
    }
    
    deinit {
        session?.stopRunning()
        session = nil
        zl_debugPrint("ZLCameraCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        previewLayer?.frame = contentView.layer.bounds
    }
    
    private func setupUI() {
        layer.masksToBounds = true
        layer.cornerRadius = ZLPhotoUIConfiguration.default().cellCornerRadio
        
        contentView.addSubview(imageView)
        backgroundColor = .zl.cameraCellBgColor
    }
    
    private func setupSession() {
        guard session == nil, (session?.isRunning ?? false) == false else {
            return
        }
        session?.stopRunning()
        if let input = videoInput {
            session?.removeInput(input)
        }
        if let output = photoOutput {
            session?.removeOutput(output)
        }
        session = nil
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        
        guard let camera = backCamera() else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        videoInput = input
        photoOutput = AVCapturePhotoOutput()
        
        session = AVCaptureSession()
        
        if session?.canAddInput(input) == true {
            session?.addInput(input)
        }
        if session?.canAddOutput(photoOutput!) == true {
            session?.addOutput(photoOutput!)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        contentView.layer.masksToBounds = true
        previewLayer?.frame = contentView.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        contentView.layer.insertSublayer(previewLayer!, at: 0)

        DispatchQueue.global(qos: .background).async {
            self.session?.startRunning()
        }
    }
    
    private func backCamera() -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
        for device in devices {
            if device.position == .back {
                return device
            }
        }
        return nil
    }
    
    func startCapture() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) || status == .denied {
            return
        }
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    ZLMainAsync {
                        self.setupSession()
                    }
                }
            }
        } else {
            setupSession()
        }
    }
}
