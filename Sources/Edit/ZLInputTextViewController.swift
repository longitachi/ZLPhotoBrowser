//
//  ZLInputTextViewController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/10/30.
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

class ZLInputTextViewController: UIViewController {

    static let collectionViewHeight: CGFloat = 50
    
    let image: UIImage?
    
    var text: String
    
    var cancelBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var textView: UITextView!
    
    var collectionView: UICollectionView!
    
    var currentTextColor: UIColor
    
    /// text, textColor, bgColor
    var endInput: ( (String, UIColor, UIColor) -> Void )?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        zl_debugPrint("ZLInputTextViewController deinit")
    }
    
    init(image: UIImage?, text: String? = nil, textColor: UIColor? = nil, bgColor: UIColor? = nil) {
        self.image = image
        self.text = text ?? ""
        if let _ = textColor {
            self.currentTextColor = textColor!
        } else {
            if !ZLPhotoConfiguration.default().textStickerTextColors.contains(ZLPhotoConfiguration.default().textStickerDefaultTextColor) {
                self.currentTextColor = ZLPhotoConfiguration.default().textStickerTextColors.first!
            } else {
                self.currentTextColor = ZLPhotoConfiguration.default().textStickerDefaultTextColor
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        let btnY = insets.top + 20
        let cancelBtnW = localLanguageTextValue(.cancel).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        self.cancelBtn.frame = CGRect(x: 15, y: btnY, width: cancelBtnW, height: ZLLayout.bottomToolBtnH)
        
        let doneBtnW = localLanguageTextValue(.done).boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        self.doneBtn.frame = CGRect(x: view.bounds.width - 20 - doneBtnW, y: btnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
        
        self.textView.frame = CGRect(x: 20, y: cancelBtn.frame.maxY + 20, width: view.bounds.width - 40, height: 150)
        
        if let index = ZLPhotoConfiguration.default().textStickerTextColors.firstIndex(where: { $0 == self.currentTextColor}) {
            self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
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
        self.cancelBtn.setTitle(localLanguageTextValue(.cancel), for: .normal)
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
        self.textView.textColor = self.currentTextColor
        self.textView.text = self.text
        self.textView.font = UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        view.addSubview(self.textView)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: self.view.frame.height - ZLInputTextViewController.collectionViewHeight, width: self.view.frame.width, height: ZLInputTextViewController.collectionViewHeight), collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.collectionView)
        
        ZLDrawColorCell.zl_register(self.collectionView)
    }
    
    @objc func cancelBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneBtnClick() {
        self.endInput?(self.textView.text, self.currentTextColor, .clear)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notify: Notification) {
        let rect = notify.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardH = rect?.height ?? 366
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        
        UIView.animate(withDuration: max(duration, 0.25)) {
            self.collectionView.frame = CGRect(x: 0, y: self.view.frame.height - keyboardH - ZLInputTextViewController.collectionViewHeight, width: self.view.frame.width, height: ZLInputTextViewController.collectionViewHeight)
        }
    }
    
}


extension ZLInputTextViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ZLPhotoConfiguration.default().textStickerTextColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.zl_identifier(), for: indexPath) as! ZLDrawColorCell
        
        let c = ZLPhotoConfiguration.default().textStickerTextColors[indexPath.row]
        cell.color = c
        if c == self.currentTextColor {
            cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        } else {
            cell.bgWhiteView.layer.transform = CATransform3DIdentity
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentTextColor = ZLPhotoConfiguration.default().textStickerTextColors[indexPath.row]
        self.textView.textColor = self.currentTextColor
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
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
