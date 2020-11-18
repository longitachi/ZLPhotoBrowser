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

        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        let btnY = insets.top + 20
        let cancelBtnW = localLanguageTextValue(.previewCancel).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        self.cancelBtn.frame = CGRect(x: 15, y: btnY, width: cancelBtnW, height: ZLLayout.bottomToolBtnH)
        
        let doneBtnW = localLanguageTextValue(.done).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        self.doneBtn.frame = CGRect(x: view.bounds.width - 20 - doneBtnW, y: btnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
        
        self.textView.frame = CGRect(x: 20, y: cancelBtn.frame.maxY + 20, width: view.bounds.width - 40, height: 150)
    }
    
    func setupUI() {
        self.view.backgroundColor = .black
        
        let bgImageView = UIImageView(image: image?.blurImage(level: 4))
        bgImageView.frame = self.view.bounds
        bgImageView.contentMode = .scaleAspectFit
        self.view.addSubview(bgImageView)
        
        let coverView = UIView(frame: bgImageView.bounds)
        coverView.backgroundColor = .black
        coverView.alpha = 0.4
        bgImageView.addSubview(coverView)
        
        self.cancelBtn = UIButton(type: .custom)
        self.cancelBtn.setTitle(localLanguageTextValue(.previewCancel), for: .normal)
        self.cancelBtn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        view.addSubview(self.cancelBtn)
        
        self.doneBtn = UIButton(type: .custom)
        self.doneBtn.setTitle(localLanguageTextValue(.done), for: .normal)
        self.doneBtn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        self.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        view.addSubview(self.doneBtn)
        
        self.textView = UITextView(frame: .zero)
        self.textView.keyboardAppearance = .dark
        self.textView.returnKeyType = .done
        self.textView.delegate = self
        self.textView.backgroundColor = .clear
        self.textView.tintColor = .bottomToolViewBtnNormalBgColor
        self.textView.textColor = .white
        self.textView.text = self.text
        self.textView.font = UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        view.addSubview(self.textView)
    }
    
    @objc func cancelBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneBtnClick() {
        self.endInput?(self.textView.text)
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension ZLInputTextViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.doneBtnClick()
            return false
        }
        return true
    }
    
}
