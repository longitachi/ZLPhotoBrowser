//
//  ZLCustomCamera.swift
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
import AVFoundation
import CoreMotion

open class ZLCustomCamera: UIViewController, CAAnimationDelegate {
    enum Layout {
        static let bottomViewH: CGFloat = 150
        
        static let largeCircleRadius: CGFloat = 85
        
        static let smallCircleRadius: CGFloat = 62
        
        static let largeCircleRecordScale: CGFloat = 1.2
        
        static let smallCircleRecordScale: CGFloat = 0.7
    }
    
    @objc public var takeDoneBlock: ((UIImage?, URL?) -> Void)?
    
    @objc public var cancelBlock: (() -> Void)?
    
    public lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.font = .zl.font(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.alpha = 0
        if ZLPhotoConfiguration.default().allowTakePhoto, ZLPhotoConfiguration.default().allowRecordVideo {
            label.text = localLanguageTextValue(.customCameraTips)
        } else if ZLPhotoConfiguration.default().allowTakePhoto {
            label.text = localLanguageTextValue(.customCameraTakePhotoTips)
        } else if ZLPhotoConfiguration.default().allowRecordVideo {
            label.text = localLanguageTextValue(.customCameraRecordVideoTips)
        }
        
        return label
    }()
    
    public lazy var bottomView = UIView()
    
    public lazy var largeCircleView: UIVisualEffectView = {
        let view: UIVisualEffectView
        if #available(iOS 13.0, *) {
            view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
        } else {
            view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        }
        view.layer.masksToBounds = true
        view.layer.cornerRadius = ZLCustomCamera.Layout.largeCircleRadius / 2
        return view
    }()
    
    public lazy var smallCircleView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = ZLCustomCamera.Layout.smallCircleRadius / 2
        view.isUserInteractionEnabled = false
        view.backgroundColor = .white
        return view
    }()
    
    public lazy var animateLayer: CAShapeLayer = {
        let animateLayerRadius = ZLCustomCamera.Layout.largeCircleRadius
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: animateLayerRadius, height: animateLayerRadius), cornerRadius: animateLayerRadius / 2)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.zl.cameraRecodeProgressColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 8
        return layer
    }()
    
    public lazy var retakeBtn: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setImage(.zl.getImage("zl_retake"), for: .normal)
        btn.addTarget(self, action: #selector(retakeBtnClick), for: .touchUpInside)
        btn.isHidden = true
        btn.adjustsImageWhenHighlighted = false
        btn.enlargeInset = 30
        return btn
    }()
    
    public lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.setTitle(localLanguageTextValue(.done), for: .normal)
        btn.setTitleColor(.zl.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        btn.backgroundColor = .zl.bottomToolViewBtnNormalBgColor
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.isHidden = true
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    public lazy var dismissBtn: ZLEnlargeButton = {
        let btn = ZLEnlargeButton(type: .custom)
        btn.setImage(.zl.getImage("zl_arrow_down"), for: .normal)
        btn.addTarget(self, action: #selector(dismissBtnClick), for: .touchUpInside)
        btn.adjustsImageWhenHighlighted = false
        btn.enlargeInset = 30
        return btn
    }()
    
    public lazy var switchCameraBtn: ZLEnlargeButton = {
        let cameraCount = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices.count
        
        let btn = ZLEnlargeButton(type: .custom)
        btn.setImage(.zl.getImage("zl_toggle_camera"), for: .normal)
        btn.addTarget(self, action: #selector(switchCameraBtnClick), for: .touchUpInside)
        btn.adjustsImageWhenHighlighted = false
        btn.enlargeInset = 30
        btn.isHidden = cameraCount <= 1
        return btn
    }()
    
    public lazy var focusCursorView: UIImageView = {
        let view = UIImageView(image: .zl.getImage("zl_focus"))
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        view.alpha = 0
        return view
    }()
    
    public lazy var takedImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.isHidden = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var hideTipsTimer: Timer?
    
    private var takedImage: UIImage?
    
    private var videoUrl: URL?
    
    private var motionManager: CMMotionManager?
    
    private var orientation: AVCaptureVideoOrientation = .portrait
    
    private let sessionQueue = DispatchQueue(label: "com.zl.camera.sessionQueue")
    
    private let session = AVCaptureSession()
    
    private var videoInput: AVCaptureDeviceInput?
    
    private var imageOutput: AVCapturePhotoOutput!
    
    private var movieFileOutput: AVCaptureMovieFileOutput!
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var recordVideoPlayerLayer: AVPlayerLayer?
    
    private var cameraConfigureFinish = false
    
    private var layoutOK = false
    
    private var dragStart = false
    
    private var viewDidAppearCount = 0
    
    private var restartRecordAfterSwitchCamera = false
    
    private var cacheVideoOrientation: AVCaptureVideoOrientation = .portrait
    
    private var recordUrls: [URL] = []
    
    private var microPhontIsAvailable = true
    
    private lazy var focusCursorTapGes: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(adjustFocusPoint))
        tap.delegate = self
        return tap
    }()
    
    private var cameraFocusPanGes: UIPanGestureRecognizer?
    
    private var recordLongGes: UILongPressGestureRecognizer?
    
    /// 是否正在调整焦距
    private var isAdjustingFocusPoint = false
    
    // 仅支持竖屏
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        zl_debugPrint("ZLCustomCamera deinit")
        cleanTimer()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    @objc public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { videoGranted in
            guard videoGranted else {
                ZLMainAsync(after: 1) {
                    self.showAlertAndDismissAfterDoneAction(message: String(format: localLanguageTextValue(.noCameraAuthority), getAppName()), type: .camera)
                }
                return
            }
            guard ZLPhotoConfiguration.default().allowRecordVideo else {
                self.addNotification()
                return
            }
            
            AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                self.addNotification()
                if !audioGranted {
                    ZLMainAsync(after: 1) {
                        self.showNoMicrophoneAuthorityAlert()
                    }
                }
            }
        }
        
        if ZLPhotoConfiguration.default().allowRecordVideo {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoRecording, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                let err = error as NSError
                if err.code == AVAudioSession.ErrorCode.insufficientPriority.rawValue ||
                    err.code == AVAudioSession.ErrorCode.isBusy.rawValue
                {
                    microPhontIsAvailable = false
                }
            }
        }
        
        setupCamera()
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observerDeviceMotion()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            showAlertAndDismissAfterDoneAction(message: localLanguageTextValue(.cameraUnavailable), type: .camera)
        } else if !ZLPhotoConfiguration.default().allowTakePhoto, !ZLPhotoConfiguration.default().allowRecordVideo {
            #if DEBUG
                fatalError("Error configuration of camera")
            #else
                showAlertAndDismissAfterDoneAction(message: "Error configuration of camera", type: nil)
            #endif
        } else if cameraConfigureFinish, viewDidAppearCount == 0 {
            showTipsLabel(animate: true)
            let animation = getFadeAnimation(fromValue: 0, toValue: 1, duration: 0.15)
            previewLayer?.add(animation, forKey: nil)
            setFocusCusor(point: view.center)
        }
        viewDidAppearCount += 1
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !layoutOK else { return }
        layoutOK = true
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        let previewLayerY: CGFloat = deviceSafeAreaInsets().top > 0 ? 20 : 0
        previewLayer?.frame = CGRect(x: 0, y: previewLayerY, width: view.bounds.width, height: view.bounds.height)
        recordVideoPlayerLayer?.frame = view.bounds
        takedImageView.frame = view.bounds
        
        bottomView.frame = CGRect(x: 0, y: view.bounds.height - insets.bottom - ZLCustomCamera.Layout.bottomViewH - 50, width: view.bounds.width, height: ZLCustomCamera.Layout.bottomViewH)
        let largeCircleH = ZLCustomCamera.Layout.largeCircleRadius
        largeCircleView.frame = CGRect(x: (view.bounds.width - largeCircleH) / 2, y: (ZLCustomCamera.Layout.bottomViewH - largeCircleH) / 2, width: largeCircleH, height: largeCircleH)
        let smallCircleH = ZLCustomCamera.Layout.smallCircleRadius
        smallCircleView.frame = CGRect(x: (view.bounds.width - smallCircleH) / 2, y: (ZLCustomCamera.Layout.bottomViewH - smallCircleH) / 2, width: smallCircleH, height: smallCircleH)
        
        dismissBtn.frame = CGRect(x: 60, y: (ZLCustomCamera.Layout.bottomViewH - 25) / 2, width: 25, height: 25)
        
        let tipsTextHeight = (tipsLabel.text ?? " ").zl
            .boundingRect(
                font: .zl.font(ofSize: 14),
                limitSize: CGSize(width: view.bounds.width - 20, height: .greatestFiniteMagnitude)
            )
            .height
        tipsLabel.frame = CGRect(x: 10, y: bottomView.frame.minY - tipsTextHeight, width: view.bounds.width - 20, height: tipsTextHeight)
        
        retakeBtn.frame = CGRect(x: 30, y: insets.top + 10, width: 28, height: 28)
        switchCameraBtn.frame = CGRect(x: view.bounds.width - 30 - 28, y: insets.top + 10, width: 28, height: 28)
        
        let doneBtnW = localLanguageTextValue(.done).zl
            .boundingRect(
                font: ZLLayout.bottomToolTitleFont,
                limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40)
            )
            .width + 20
        let doneBtnY = view.bounds.height - 57 - insets.bottom
        doneBtn.frame = CGRect(x: view.bounds.width - doneBtnW - 20, y: doneBtnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(takedImageView)
        view.addSubview(focusCursorView)
        view.addSubview(tipsLabel)
        view.addSubview(bottomView)
        bottomView.addSubview(dismissBtn)
        bottomView.addSubview(largeCircleView)
        bottomView.addSubview(smallCircleView)
        
        var takePictureTap: UITapGestureRecognizer?
        if ZLPhotoConfiguration.default().allowTakePhoto {
            takePictureTap = UITapGestureRecognizer(target: self, action: #selector(takePicture))
            largeCircleView.addGestureRecognizer(takePictureTap!)
        }
        if ZLPhotoConfiguration.default().allowRecordVideo {
            let longGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
            longGes.minimumPressDuration = 0.3
            longGes.delegate = self
            largeCircleView.addGestureRecognizer(longGes)
            takePictureTap?.require(toFail: longGes)
            recordLongGes = longGes
            
            let panGes = UIPanGestureRecognizer(target: self, action: #selector(adjustCameraFocus(_:)))
            panGes.delegate = self
            panGes.maximumNumberOfTouches = 1
            largeCircleView.addGestureRecognizer(panGes)
            cameraFocusPanGes = panGes
            
            recordVideoPlayerLayer = AVPlayerLayer()
            recordVideoPlayerLayer?.backgroundColor = UIColor.black.cgColor
            recordVideoPlayerLayer?.videoGravity = .resizeAspect
            recordVideoPlayerLayer?.isHidden = true
            view.layer.insertSublayer(recordVideoPlayerLayer!, at: 0)
            
            NotificationCenter.default.addObserver(self, selector: #selector(recordVideoPlayFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        view.addSubview(retakeBtn)
        view.addSubview(switchCameraBtn)
        view.addSubview(doneBtn)
        
        view.addGestureRecognizer(focusCursorTapGes)
        
        let pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinchToAdjustCameraFocus(_:)))
        view.addGestureRecognizer(pinchGes)
    }
    
    private func observerDeviceMotion() {
        if !Thread.isMainThread {
            ZLMainAsync {
                self.observerDeviceMotion()
            }
            return
        }
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 0.5
        
        if motionManager?.isDeviceMotionAvailable == true {
            motionManager?.startDeviceMotionUpdates(to: .main, withHandler: { motion, _ in
                if let motion = motion {
                    self.handleDeviceMotion(motion)
                }
            })
        } else {
            motionManager = nil
        }
    }
    
    func handleDeviceMotion(_ motion: CMDeviceMotion) {
        let x = motion.gravity.x
        let y = motion.gravity.y
        
        if abs(y) >= abs(x) || abs(x) < 0.45 {
            if y >= 0.45 {
                orientation = .portraitUpsideDown
            } else {
                orientation = .portrait
            }
        } else {
            if x >= 0 {
                orientation = .landscapeLeft
            } else {
                orientation = .landscapeRight
            }
        }
    }
    
    private func setupCamera() {
        guard let backCamera = getCamera(position: .back) else { return }
        guard let input = try? AVCaptureDeviceInput(device: backCamera) else { return }
        
        session.beginConfiguration()
        
        // 相机画面输入流
        videoInput = input
        // 照片输出流
        imageOutput = AVCapturePhotoOutput()
        
        let preset = ZLPhotoConfiguration.default().cameraConfiguration.sessionPreset.avSessionPreset
        if session.canSetSessionPreset(preset) {
            session.sessionPreset = preset
        } else {
            session.sessionPreset = .hd1280x720
        }
        
        movieFileOutput = AVCaptureMovieFileOutput()
        // 解决视频录制超过10s没有声音的bug
        movieFileOutput.movieFragmentInterval = .invalid
        
        // 添加视频输入
        if let videoInput = videoInput, session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        // 添加音频输入
        addAudioInput()
        
        // 将输出流添加到session
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        }
        
        session.commitConfiguration()
        // 预览layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspect
        previewLayer?.opacity = 0
        view.layer.masksToBounds = true
        view.layer.insertSublayer(previewLayer!, at: 0)
        
        cameraConfigureFinish = true
    }
    
    private func getCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    private func getMicrophone() -> AVCaptureDevice? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified).devices.first
    }
    
    private func addAudioInput() {
        guard ZLPhotoConfiguration.default().allowRecordVideo else { return }
        // 音频输入流
        var audioInput: AVCaptureDeviceInput?
        if let microphone = getMicrophone() {
            audioInput = try? AVCaptureDeviceInput(device: microphone)
        }
        guard microPhontIsAvailable, let ai = audioInput else { return }
        removeAudioInput()
        
        if session.isRunning {
            session.beginConfiguration()
        }
        if session.canAddInput(ai) {
            session.addInput(ai)
        }
        if session.isRunning {
            session.commitConfiguration()
        }
    }
    
    private func removeAudioInput() {
        var audioInput: AVCaptureInput?
        for input in session.inputs {
            if (input as? AVCaptureDeviceInput)?.device.deviceType == .builtInMicrophone {
                audioInput = input
            }
        }
        guard let audioInput = audioInput else { return }
        
        if session.isRunning {
            session.beginConfiguration()
        }
        session.removeInput(audioInput)
        if session.isRunning {
            session.commitConfiguration()
        }
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        if ZLPhotoConfiguration.default().allowRecordVideo {
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        }
    }
    
    private func showNoMicrophoneAuthorityAlert() {
        let continueAction = ZLCustomAlertAction(title: localLanguageTextValue(.keepRecording), style: .default, handler: nil)
        let gotoSettingsAction = ZLCustomAlertAction(title: localLanguageTextValue(.gotoSettings), style: .tint) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        showAlertController(title: nil, message: String(format: localLanguageTextValue(.noMicrophoneAuthority), getAppName()), style: .alert, actions: [continueAction, gotoSettingsAction], sender: self)
    }
    
    private func showAlertAndDismissAfterDoneAction(message: String, type: ZLNoAuthorityType?) {
        let action = ZLCustomAlertAction(title: localLanguageTextValue(.done), style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                if let type = type {
                    ZLPhotoConfiguration.default().noAuthorityCallback?(type)
                }
            }
        }
        showAlertController(title: nil, message: message, style: .alert, actions: [action], sender: self)
    }
    
    private func showTipsLabel(animate: Bool) {
        tipsLabel.layer.removeAllAnimations()
        if animate {
            UIView.animate(withDuration: 0.25) {
                self.tipsLabel.alpha = 1
            }
        } else {
            tipsLabel.alpha = 1
        }
        startHideTipsLabelTimer()
    }
    
    private func hideTipsLabel(animate: Bool) {
        tipsLabel.layer.removeAllAnimations()
        if animate {
            UIView.animate(withDuration: 0.25) {
                self.tipsLabel.alpha = 0
            }
        } else {
            tipsLabel.alpha = 0
        }
    }
    
    @objc private func hideTipsLabel_timerFunc() {
        cleanTimer()
        hideTipsLabel(animate: true)
    }
    
    private func startHideTipsLabelTimer() {
        cleanTimer()
        hideTipsTimer = Timer.scheduledTimer(timeInterval: 3, target: ZLWeakProxy(target: self), selector: #selector(hideTipsLabel_timerFunc), userInfo: nil, repeats: false)
        RunLoop.current.add(hideTipsTimer!, forMode: .common)
    }
    
    private func cleanTimer() {
        hideTipsTimer?.invalidate()
        hideTipsTimer = nil
    }
    
    @objc private func appWillResignActive() {
        if session.isRunning {
            dismiss(animated: true, completion: nil)
        }
        if videoUrl != nil, let player = recordVideoPlayerLayer?.player {
            player.pause()
        }
    }
    
    @objc private func appDidBecomeActive() {
        if videoUrl != nil, let player = recordVideoPlayerLayer?.player {
            player.play()
        }
    }
    
    @objc private func handleAudioSessionInterruption(_ notify: Notification) {
        guard recordVideoPlayerLayer?.isHidden == false, let player = recordVideoPlayerLayer?.player else {
            return
        }
        guard player.rate == 0 else {
            return
        }
        
        let type = notify.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
        let option = notify.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt
        if type == AVAudioSession.InterruptionType.ended.rawValue, option == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
            player.play()
        }
    }
    
    @objc private func dismissBtnClick() {
        dismiss(animated: true) {
            self.cancelBlock?()
        }
    }
    
    @objc private func retakeBtnClick() {
        session.startRunning()
        resetSubViewStatus()
        takedImage = nil
        stopRecordAnimation()
        if let videoUrl = videoUrl {
            recordVideoPlayerLayer?.player?.pause()
            recordVideoPlayerLayer?.player = nil
            recordVideoPlayerLayer?.isHidden = true
            self.videoUrl = nil
            try? FileManager.default.removeItem(at: videoUrl)
        }
    }
    
    @objc private func switchCameraBtnClick() {
        do {
            guard !restartRecordAfterSwitchCamera else {
                return
            }
            
            guard let currInput = videoInput else {
                return
            }
            var newVideoInput: AVCaptureDeviceInput?
            if currInput.device.position == .back, let front = getCamera(position: .front) {
                newVideoInput = try AVCaptureDeviceInput(device: front)
            } else if currInput.device.position == .front, let back = getCamera(position: .back) {
                newVideoInput = try AVCaptureDeviceInput(device: back)
            } else {
                return
            }
            
            if let newVideoInput = newVideoInput {
                session.beginConfiguration()
                session.removeInput(currInput)
                if session.canAddInput(newVideoInput) {
                    session.addInput(newVideoInput)
                    videoInput = newVideoInput
                } else {
                    session.addInput(currInput)
                }
                session.commitConfiguration()
                if movieFileOutput.isRecording {
                    let pauseTime = animateLayer.convertTime(CACurrentMediaTime(), from: nil)
                    animateLayer.speed = 0
                    animateLayer.timeOffset = pauseTime
                    restartRecordAfterSwitchCamera = true
                }
            }
        } catch {
            zl_debugPrint("切换摄像头失败 \(error.localizedDescription)")
        }
    }
    
    @objc private func editImage() {
        guard ZLPhotoConfiguration.default().allowEditImage, let image = takedImage else {
            return
        }
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: image) { [weak self] in
            self?.retakeBtnClick()
        } completion: { [weak self] editImage, _ in
            self?.takedImage = editImage
            self?.takedImageView.image = editImage
            self?.doneBtnClick()
        }
    }
    
    @objc private func doneBtnClick() {
        recordVideoPlayerLayer?.player?.pause()
        // 置为nil会导致卡顿，先注释，不影响内存释放
//        self.recordVideoPlayerLayer?.player = nil
        dismiss(animated: true) {
            self.takeDoneBlock?(self.takedImage, self.videoUrl)
        }
    }
    
    // 点击拍照
    @objc private func takePicture() {
        guard ZLPhotoManager.hasCameraAuthority() else {
            return
        }
        
        let connection = imageOutput.connection(with: .video)
        connection?.videoOrientation = orientation
        if videoInput?.device.position == .front, connection?.isVideoMirroringSupported == true {
            connection?.isVideoMirrored = true
        }
        let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
        if videoInput?.device.hasFlash == true {
            setting.flashMode = ZLPhotoConfiguration.default().cameraConfiguration.flashMode.avFlashMode
        }
        imageOutput.capturePhoto(with: setting, delegate: self)
    }
    
    // 长按录像
    @objc private func longPressAction(_ longGes: UILongPressGestureRecognizer) {
        if longGes.state == .began {
            guard ZLPhotoManager.hasCameraAuthority(), ZLPhotoManager.hasMicrophoneAuthority() else {
                return
            }
            startRecord()
        } else if longGes.state == .cancelled || longGes.state == .ended {
            finishRecord()
        }
    }
    
    // 调整焦点
    @objc private func adjustFocusPoint(_ tap: UITapGestureRecognizer) {
        guard session.isRunning, !isAdjustingFocusPoint else {
            return
        }
        let point = tap.location(in: view)
        if point.y > bottomView.frame.minY - 30 {
            return
        }
        setFocusCusor(point: point)
    }
    
    private func setFocusCusor(point: CGPoint) {
        isAdjustingFocusPoint = true
        focusCursorView.center = point
        focusCursorView.layer.removeAllAnimations()
        focusCursorView.alpha = 1
        focusCursorView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        UIView.animate(withDuration: 0.5, animations: {
            self.focusCursorView.layer.transform = CATransform3DIdentity
        }) { _ in
            self.isAdjustingFocusPoint = false
            self.focusCursorView.alpha = 0
        }
        // ui坐标转换为摄像头坐标
        let cameraPoint = previewLayer?.captureDevicePointConverted(fromLayerPoint: point) ?? view.center
        focusCamera(
            mode: ZLPhotoConfiguration.default().cameraConfiguration.focusMode.avFocusMode,
            exposureMode: ZLPhotoConfiguration.default().cameraConfiguration.exposureMode.avFocusMode,
            point: cameraPoint
        )
    }
    
    // 调整焦距
    @objc private func adjustCameraFocus(_ pan: UIPanGestureRecognizer) {
        let convertRect = bottomView.convert(largeCircleView.frame, to: view)
        let point = pan.location(in: view)
        
        if pan.state == .began {
            dragStart = true
            startRecord()
        } else if pan.state == .changed {
            guard dragStart else {
                return
            }
            let maxZoomFactor = getMaxZoomFactor()
            var zoomFactor = (convertRect.midY - point.y) / convertRect.midY * maxZoomFactor
            zoomFactor = max(1, min(zoomFactor, maxZoomFactor))
            setVideoZoomFactor(zoomFactor)
        } else if pan.state == .cancelled || pan.state == .ended {
            guard dragStart else {
                return
            }
            dragStart = false
            finishRecord()
        }
    }
    
    @objc private func pinchToAdjustCameraFocus(_ pinch: UIPinchGestureRecognizer) {
        guard let device = videoInput?.device else {
            return
        }
        
        var zoomFactor = device.videoZoomFactor * pinch.scale
        zoomFactor = max(1, min(zoomFactor, getMaxZoomFactor()))
        setVideoZoomFactor(zoomFactor)
        
        pinch.scale = 1
    }
    
    private func getMaxZoomFactor() -> CGFloat {
        guard let device = videoInput?.device else {
            return 1
        }
        if #available(iOS 11.0, *) {
            return device.maxAvailableVideoZoomFactor / 2
        } else {
            return device.activeFormat.videoMaxZoomFactor / 2
        }
    }
    
    private func setVideoZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = videoInput?.device else {
            return
        }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
        } catch {
            zl_debugPrint("调整焦距失败 \(error.localizedDescription)")
        }
    }
    
    private func focusCamera(mode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, point: CGPoint) {
        do {
            guard let device = videoInput?.device else {
                return
            }
            
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(mode) {
                device.focusMode = mode
            }
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
            }
            if device.isExposureModeSupported(exposureMode) {
                device.exposureMode = exposureMode
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
            }
            
            device.unlockForConfiguration()
        } catch {
            zl_debugPrint("相机聚焦设置失败 \(error.localizedDescription)")
        }
    }
    
    private func startRecord() {
        guard !movieFileOutput.isRecording else {
            return
        }
        dismissBtn.isHidden = true
        let connection = movieFileOutput.connection(with: .video)
        connection?.videoScaleAndCropFactor = 1
        if !restartRecordAfterSwitchCamera {
            connection?.videoOrientation = orientation
            cacheVideoOrientation = orientation
        } else {
            connection?.videoOrientation = cacheVideoOrientation
        }
        // 解决前置摄像头录制视频时候左右颠倒的问题
        if videoInput?.device.position == .front, connection?.isVideoMirroringSupported == true {
            // 镜像设置
            connection?.isVideoMirrored = true
        }
        let url = URL(fileURLWithPath: ZLVideoManager.getVideoExportFilePath())
        movieFileOutput.startRecording(to: url, recordingDelegate: self)
    }
    
    private func finishRecord() {
        guard movieFileOutput.isRecording else {
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        movieFileOutput.stopRecording()
        stopRecordAnimation()
    }
    
    private func startRecordAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.largeCircleView.layer.transform = CATransform3DScale(CATransform3DIdentity, ZLCustomCamera.Layout.largeCircleRecordScale, ZLCustomCamera.Layout.largeCircleRecordScale, 1)
            self.smallCircleView.layer.transform = CATransform3DScale(CATransform3DIdentity, ZLCustomCamera.Layout.smallCircleRecordScale, ZLCustomCamera.Layout.smallCircleRecordScale, 1)
        }) { _ in
            self.largeCircleView.layer.addSublayer(self.animateLayer)
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = Double(ZLPhotoConfiguration.default().maxRecordDuration)
            animation.delegate = self
            self.animateLayer.add(animation, forKey: nil)
        }
    }
    
    private func stopRecordAnimation() {
        animateLayer.removeFromSuperlayer()
        animateLayer.removeAllAnimations()
        largeCircleView.transform = .identity
        smallCircleView.transform = .identity
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        finishRecord()
    }
    
    private func resetSubViewStatus() {
        if session.isRunning {
            showTipsLabel(animate: true)
            bottomView.isHidden = false
            dismissBtn.isHidden = false
            switchCameraBtn.isHidden = false
            retakeBtn.isHidden = true
            doneBtn.isHidden = true
            takedImageView.isHidden = true
            takedImage = nil
        } else {
            hideTipsLabel(animate: false)
            bottomView.isHidden = true
            dismissBtn.isHidden = true
            switchCameraBtn.isHidden = true
            retakeBtn.isHidden = false
            doneBtn.isHidden = false
        }
    }
    
    private func playRecordVideo(fileUrl: URL) {
        recordVideoPlayerLayer?.isHidden = false
        let player = AVPlayer(url: fileUrl)
        player.automaticallyWaitsToMinimizeStalling = false
        recordVideoPlayerLayer?.player = player
        player.play()
    }
    
    @objc private func recordVideoPlayFinished() {
        recordVideoPlayerLayer?.player?.seek(to: .zero)
        recordVideoPlayerLayer?.player?.play()
    }
}

extension ZLCustomCamera: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        ZLMainAsync {
            let animation = getFadeAnimation(fromValue: 0, toValue: 1, duration: 0.25)
            self.previewLayer?.add(animation, forKey: nil)
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        ZLMainAsync {
            if photoSampleBuffer == nil || error != nil {
                zl_debugPrint("拍照失败 \(error?.localizedDescription ?? "")")
                return
            }
            
            if let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                self.session.stopRunning()
                self.takedImage = UIImage(data: data)?.zl.fixOrientation()
                self.takedImageView.image = self.takedImage
                self.takedImageView.isHidden = false
                self.resetSubViewStatus()
                self.editImage()
            } else {
                zl_debugPrint("拍照失败，data为空")
            }
        }
    }
}

extension ZLCustomCamera: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        if restartRecordAfterSwitchCamera {
            restartRecordAfterSwitchCamera = false
            // 稍微加一个延时，否则切换摄像头后拍摄时间会略小于设置的最大值
            ZLMainAsync(after: 0.1) {
                let pauseTime = self.animateLayer.timeOffset
                self.animateLayer.speed = 1
                self.animateLayer.timeOffset = 0
                self.animateLayer.beginTime = 0
                let timeSincePause = self.animateLayer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
                self.animateLayer.beginTime = timeSincePause
            }
        } else {
            ZLMainAsync {
                self.startRecordAnimation()
            }
        }
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        ZLMainAsync {
            if self.restartRecordAfterSwitchCamera {
                self.recordUrls.append(outputFileURL)
                self.startRecord()
                return
            }
            self.recordUrls.append(outputFileURL)
            
            var duration: Double = 0
            if self.recordUrls.count == 1 {
                duration = output.recordedDuration.seconds
            } else {
                for url in self.recordUrls {
                    let temp = AVAsset(url: url)
                    duration += temp.duration.seconds
                }
            }
            
            // 重置焦距
            self.setVideoZoomFactor(1)
            if duration < Double(ZLPhotoConfiguration.default().minRecordDuration) {
                showAlertView(String(format: localLanguageTextValue(.minRecordTimeTips), ZLPhotoConfiguration.default().minRecordDuration), self)
                self.resetSubViewStatus()
                self.recordUrls.forEach { try? FileManager.default.removeItem(at: $0) }
                self.recordUrls.removeAll()
                return
            }
            
            // 拼接视频
            self.session.stopRunning()
            self.resetSubViewStatus()
            if self.recordUrls.count > 1 {
                ZLVideoManager.mergeVideos(fileUrls: self.recordUrls) { [weak self] url, error in
                    if let url = url, error == nil {
                        self?.videoUrl = url
                        self?.playRecordVideo(fileUrl: url)
                    } else if let error = error {
                        self?.videoUrl = nil
                        showAlertView(error.localizedDescription, self)
                    }

                    self?.recordUrls.forEach { try? FileManager.default.removeItem(at: $0) }
                    self?.recordUrls.removeAll()
                }
            } else {
                self.videoUrl = outputFileURL
                self.playRecordVideo(fileUrl: outputFileURL)
                self.recordUrls.removeAll()
            }
        }
    }
}

extension ZLCustomCamera: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesTuples: [(UIGestureRecognizer?, UIGestureRecognizer?)] = [(recordLongGes, cameraFocusPanGes), (recordLongGes, focusCursorTapGes), (cameraFocusPanGes, focusCursorTapGes)]
        
        let result = gesTuples.map { ges1, ges2 in
            (ges1 == gestureRecognizer && ges2 == otherGestureRecognizer) ||
                (ges2 == otherGestureRecognizer && ges1 == gestureRecognizer)
        }.filter { $0 == true }
        
        return result.count > 0
    }
}
