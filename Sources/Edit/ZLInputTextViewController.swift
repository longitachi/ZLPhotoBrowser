//
//  ZLInputTextViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/10/30.
//

import UIKit

class ZLInputTextViewController: UIViewController {

    let image: UIImage?
    
    var text: String
    
    var cancelBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var textView: UITextView!
    
    var endInput: ( (String) -> Void )?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(image: UIImage?, text: String?) {
        self.image = image
        self.text = text ?? ""
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        let btnY = insets.top + 20
        let cancelBtnW = localLanguageTextValue(.previewCancel).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        cancelBtn.frame = CGRect(x: 15, y: btnY, width: cancelBtnW, height: ZLLayout.bottomToolBtnH)
        
        let doneBtnW = localLanguageTextValue(.done).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        doneBtn.frame = CGRect(x: view.bounds.width - 20 - doneBtnW, y: btnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
        
        textView.frame = CGRect(x: 20, y: cancelBtn.frame.maxY + 20, width: view.bounds.width - 40, height: 150)
    }
    
    func setupUI() {
        view.backgroundColor = .black
        
        // blur image
        let inputImage = image?.toCIImage()
        let context = CIContext()
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        filter.setValue(6, forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage!
        let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent)
        
        let img = UIImage(cgImage: cgImage!)
        let bgImageView = UIImageView(image: image)
        bgImageView.frame = view.bounds
        bgImageView.contentMode = .scaleAspectFit
        view.addSubview(bgImageView)
        
//        let coverView = UIView(frame: bgImageView.bounds)
//        coverView.backgroundColor = .black
//        coverView.alpha = 0.6
//        bgImageView.addSubview(coverView)
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle(localLanguageTextValue(.previewCancel), for: .normal)
        cancelBtn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        doneBtn = UIButton(type: .custom)
        doneBtn.setTitle(localLanguageTextValue(.done), for: .normal)
        doneBtn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        view.addSubview(doneBtn)
        
        textView = UITextView(frame: .zero)
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.tintColor = .bottomToolViewBtnNormalBgColor
        textView.textColor = .white
        textView.font = UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        view.addSubview(textView)
    }
    
    @objc func cancelBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneBtnClick() {
        endInput?(textView.text)
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension ZLInputTextViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            doneBtnClick()
            return false
        }
        return true
    }
    
}
