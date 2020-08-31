//
//  ZLCameraCell.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/19.
//

import UIKit
import AVFoundation

class ZLCameraCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var session: AVCaptureSession?
    
    var videoInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    deinit {
        self.session?.stopRunning()
        self.session = nil
        debugPrint("ZLCameraCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width / 3, height: self.bounds.width / 3)
        self.imageView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        self.previewLayer?.frame = self.contentView.layer.bounds
    }
    
    func setupUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = ZLPhotoConfiguration.default().cellCornerRadio
        
        self.imageView = UIImageView(image: getImage("zl_takePhoto"))
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        self.backgroundColor = UIColor(white: 0.8, alpha: 1)
    }
    
    func startCapture() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) || status == .denied {
            return
        }
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            }
        } else {
            self.setupSession()
        }
    }
    
    func setupSession() {
        guard self.session == nil, (self.session?.isRunning ?? false) == false else {
            return
        }
        self.session?.stopRunning()
        if let input = self.videoInput {
            self.session?.removeInput(input)
        }
        if let output = self.photoOutput {
            self.session?.removeOutput(output)
        }
        self.session = nil
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = nil
        
        guard let camera = self.backCamera() else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        self.videoInput = input
        self.photoOutput = AVCapturePhotoOutput()
        
        self.session = AVCaptureSession()
        
        if self.session?.canAddInput(input) == true {
            self.session?.addInput(input)
        }
        if self.session?.canAddOutput(self.photoOutput!) == true {
            self.session?.addOutput(self.photoOutput!)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session!)
        self.contentView.layer.masksToBounds = true
        self.previewLayer?.frame = self.contentView.layer.bounds
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.contentView.layer.insertSublayer(self.previewLayer!, at: 0)
        
        self.session?.startRunning()
    }
    
    func backCamera() -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
        for device in devices {
            if device.position == .back {
                return device
            }
        }
        return nil
    }
    
}


extension ZLCameraCell: AVCapturePhotoCaptureDelegate {
    
}
