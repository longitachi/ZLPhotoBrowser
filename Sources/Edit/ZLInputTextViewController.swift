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
    private static let collectionViewHeight: CGFloat = 50
    
    private let image: UIImage?
    
    private var text: String
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(localLanguageTextValue(.done), for: .normal)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.setTitleColor(.zl.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        btn.backgroundColor = .zl.bottomToolViewBtnNormalBgColor
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    private lazy var textView: UITextView = {
        let y = max(deviceSafeAreaInsets().top, 20) + 20 + ZLLayout.bottomToolBtnH + 20
        let textView = UITextView(frame: CGRect(x: 20, y: y, width: view.zl.width - 40, height: 200))
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.tintColor = .zl.bottomToolViewBtnNormalBgColor
        textView.textColor = currentTextColor
        textView.text = text
        textView.font = UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        return textView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = ZLCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        
        let collectionView = UICollectionView(
            frame: CGRect(
                x: 0,
                y: view.frame.height - ZLInputTextViewController.collectionViewHeight,
                width: view.frame.width,
                height: ZLInputTextViewController.collectionViewHeight
            ),
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        ZLDrawColorCell.zl.register(collectionView)
        
        return collectionView
    }()
    
    private var currentTextColor: UIColor
    
    /// text, textColor, bgColor
    var endInput: ((String, UIColor, UIColor) -> Void)?
    
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
        if let textColor = textColor {
            currentTextColor = textColor
        } else {
            let editConfig = ZLPhotoConfiguration.default().editImageConfiguration
            if !editConfig.textStickerTextColors.contains(editConfig.textStickerDefaultTextColor) {
                currentTextColor = editConfig.textStickerTextColors.first!
            } else {
                currentTextColor = editConfig.textStickerDefaultTextColor
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let btnY = max(deviceSafeAreaInsets().top, 20) + 20
        let cancelBtnW = localLanguageTextValue(.cancel).zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        cancelBtn.frame = CGRect(x: 15, y: btnY, width: cancelBtnW, height: ZLLayout.bottomToolBtnH)
        
        let doneBtnW = localLanguageTextValue(.done).zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        doneBtn.frame = CGRect(x: view.zl.width - 20 - doneBtnW, y: btnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
        
        if let index = ZLPhotoConfiguration.default().editImageConfiguration.textStickerTextColors.firstIndex(where: { $0 == self.currentTextColor }) {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        let bgImageView = UIImageView(image: image?.zl.blurImage(level: 4))
        bgImageView.frame = view.bounds
        bgImageView.contentMode = .scaleAspectFit
        view.addSubview(bgImageView)
        
        let coverView = UIView(frame: bgImageView.bounds)
        coverView.backgroundColor = .black
        coverView.alpha = 0.4
        bgImageView.addSubview(coverView)
        
        view.addSubview(cancelBtn)
        view.addSubview(doneBtn)
        view.addSubview(textView)
        view.addSubview(collectionView)
    }
    
    @objc private func cancelBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneBtnClick() {
        endInput?(textView.text, currentTextColor, .clear)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShow(_ notify: Notification) {
        let rect = notify.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardH = rect?.height ?? 366
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        
        let collectionViewFrame = CGRect(
            x: 0,
            y: view.zl.height - keyboardH - Self.collectionViewHeight,
            width: view.zl.width,
            height: Self.collectionViewHeight
        )
        
        var textViewFrame = textView.frame
        textViewFrame.size.height = collectionViewFrame.minY - textViewFrame.minY - 20
        
        UIView.animate(withDuration: max(duration, 0.25)) {
            self.collectionView.frame = collectionViewFrame
            self.textView.frame = textViewFrame
        }
    }
    
    @objc private func keyboardWillHide(_ notify: Notification) {
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        
        let collectionViewFrame = CGRect(
            x: 0,
            y: view.zl.height - deviceSafeAreaInsets().bottom - Self.collectionViewHeight,
            width: view.zl.width,
            height: Self.collectionViewHeight
        )
        
        var textViewFrame = textView.frame
        textViewFrame.size.height = collectionViewFrame.minY - textViewFrame.minY - 20
        
        UIView.animate(withDuration: max(duration, 0.25)) {
            self.collectionView.frame = collectionViewFrame
            self.textView.frame = textViewFrame
        }
    }
}

extension ZLInputTextViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ZLPhotoConfiguration.default().editImageConfiguration.textStickerTextColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.zl.identifier, for: indexPath) as! ZLDrawColorCell
        
        let c = ZLPhotoConfiguration.default().editImageConfiguration.textStickerTextColors[indexPath.row]
        cell.color = c
        if c == currentTextColor {
            cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        } else {
            cell.bgWhiteView.layer.transform = CATransform3DIdentity
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentTextColor = ZLPhotoConfiguration.default().editImageConfiguration.textStickerTextColors[indexPath.row]
        textView.textColor = currentTextColor
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
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
