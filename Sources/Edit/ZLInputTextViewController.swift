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
    private static let toolViewHeight: CGFloat = 70
    
    private let image: UIImage?
    
    private var text: String
    
    private var font: UIFont = .boldSystemFont(ofSize: ZLTextStickerView.fontSize)
    
    private var currentColor: UIColor {
        didSet {
            contentView.textColor = currentColor
        }
    }
    
    private var textStyle: ZLInputTextStyle {
        didSet {
            contentView.style = textStyle
        }
    }
    
    private lazy var bgImageView: UIImageView = {
        let view = UIImageView(image: image?.zl.blurImage(level: 4))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var coverView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.4
        return view
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
        btn.setTitleColor(.zl.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(localLanguageTextValue(.inputDone), for: .normal)
        btn.titleLabel?.font = ZLLayout.bottomToolTitleFont
        btn.setTitleColor(.zl.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        btn.backgroundColor = .zl.bottomToolViewBtnNormalBgColor
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = ZLLayout.bottomToolBtnCornerRadius
        return btn
    }()

    private lazy var contentView: ZLTextStickerContentView = {
        let view = ZLTextStickerContentView()
        view.isEditable = true
        view.textView.keyboardAppearance = .dark
        view.textView.returnKeyType = .done
        view.textView.tintColor = .zl.bottomToolViewBtnNormalBgColor
        view.textViewDelegate = self
        return view
    }()

    private var textView: UITextView {
        return contentView.textView
    }

    private lazy var toolView = UIView(frame: CGRect(
        x: 0,
        y: view.zl.height - Self.toolViewHeight,
        width: view.zl.width,
        height: Self.toolViewHeight
    ))
    
    private lazy var textStyleBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(textStyleBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = ZLCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 36, height: 36)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let inset = (Self.toolViewHeight - layout.itemSize.height) / 2
        layout.sectionInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        ZLDrawColorCell.zl.register(collectionView)
        
        return collectionView
    }()
    
    private var shouldLayout = true

    /// text, textColor, font, style
    var endInput: ((String, UIColor, UIFont, ZLInputTextStyle) -> Void)?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        deviceIsiPhone() ? .portrait : .all
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        zl_debugPrint("ZLInputTextViewController deinit")
    }
    
    init(image: UIImage?, text: String? = nil, textColor: UIColor? = nil, font: UIFont? = nil, style: ZLInputTextStyle = .normal) {
        self.image = image
        self.text = text ?? ""
        if let font {
            self.font = font.withSize(ZLTextStickerView.fontSize)
        }
        if let textColor {
            currentColor = textColor
        } else {
            let editConfig = ZLPhotoConfiguration.default().editImageConfiguration
            if !editConfig.textStickerTextColors.contains(editConfig.textStickerDefaultTextColor) {
                currentColor = editConfig.textStickerTextColors.first!
            } else {
                currentColor = editConfig.textStickerDefaultTextColor
            }
        }
        textStyle = style
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
        
        guard shouldLayout else { return }
        
        shouldLayout = false
        bgImageView.frame = view.bounds
        
        // iPad图片由竖屏切换到横屏时候填充方式会有点异常，这里重置下
        if deviceIsiPad() {
            if UIApplication.shared.statusBarOrientation.isLandscape {
                bgImageView.contentMode = .scaleAspectFill
            } else {
                bgImageView.contentMode = .scaleAspectFit
            }
        }
        
        coverView.frame = bgImageView.bounds
        
        let btnY = max(deviceSafeAreaInsets().top, 20)
        let cancelBtnW = localLanguageTextValue(.cancel).zl.boundingRect(font: ZLLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)).width + 20
        cancelBtn.frame = CGRect(x: 15, y: btnY, width: cancelBtnW, height: ZLLayout.bottomToolBtnH)
        
        let doneBtnW = (doneBtn.currentTitle ?? "")
            .zl.boundingRect(
                font: ZLLayout.bottomToolTitleFont,
                limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLLayout.bottomToolBtnH)
            ).width + 20
        doneBtn.frame = CGRect(x: view.zl.width - 20 - doneBtnW, y: btnY, width: doneBtnW, height: ZLLayout.bottomToolBtnH)
        
        contentView.frame = CGRect(x: 10, y: doneBtn.zl.bottom + 30, width: view.zl.width - 20, height: 200)
        
        textStyleBtn.frame = CGRect(
            x: 12,
            y: 0,
            width: 50,
            height: Self.toolViewHeight
        )
        collectionView.frame = CGRect(
            x: textStyleBtn.zl.right + 5,
            y: 0,
            width: view.zl.width - textStyleBtn.zl.right - 5 - 24,
            height: Self.toolViewHeight
        )

        if let index = ZLPhotoConfiguration.default().editImageConfiguration.textStickerTextColors.firstIndex(where: { $0 == self.currentColor }) {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        shouldLayout = true
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(bgImageView)
        bgImageView.addSubview(coverView)
        view.addSubview(cancelBtn)
        view.addSubview(doneBtn)
        view.addSubview(contentView)
        view.addSubview(toolView)
        toolView.addSubview(textStyleBtn)
        toolView.addSubview(collectionView)

        contentView.configure(text: text, textColor: currentColor, font: font, style: textStyle)
        refreshTextStyleBtn()
    }

    private func refreshTextStyleBtn() {
        textStyleBtn.setImage(textStyle.btnImage, for: .normal)
        textStyleBtn.setImage(textStyle.btnImage, for: .highlighted)
    }
    
    @objc private func textStyleBtnClick() {
        textStyle = textStyle.next
        refreshTextStyleBtn()
    }
    
    @objc private func cancelBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneBtnClick() {
        textView.tintColor = .clear
        textView.endEditing(true)

        endInput?(textView.text ?? "", currentColor, font, textStyle)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShow(_ notify: Notification) {
        let rect = notify.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardH = rect?.height ?? 366
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        
        let toolViewFrame = CGRect(
            x: 0,
            y: view.zl.height - keyboardH - Self.toolViewHeight,
            width: view.zl.width,
            height: Self.toolViewHeight
        )

        var contentFrame = contentView.frame
        contentFrame.size.height = toolViewFrame.minY - contentFrame.minY - 20

        UIView.animate(withDuration: max(duration, 0.25)) {
            self.toolView.frame = toolViewFrame
            self.contentView.frame = contentFrame
        }
    }
    
    @objc private func keyboardWillHide(_ notify: Notification) {
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        
        let toolViewFrame = CGRect(
            x: 0,
            y: view.zl.height - deviceSafeAreaInsets().bottom - Self.toolViewHeight,
            width: view.zl.width,
            height: Self.toolViewHeight
        )

        var contentFrame = contentView.frame
        contentFrame.size.height = toolViewFrame.minY - contentFrame.minY - 20

        UIView.animate(withDuration: max(duration, 0.25)) {
            self.toolView.frame = toolViewFrame
            self.contentView.frame = contentFrame
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
        if c == currentColor {
            cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.33, 1.33, 1)
            cell.colorView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        } else {
            cell.bgWhiteView.layer.transform = CATransform3DIdentity
            cell.colorView.layer.transform = CATransform3DIdentity
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentColor = ZLPhotoConfiguration.default().editImageConfiguration.textStickerTextColors[indexPath.row]
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

public enum ZLInputTextStyle {
    case normal
    case bg
    case stroke
    case shadow
    
    fileprivate var next: ZLInputTextStyle {
        switch self {
        case .normal:
            return .bg
        case .bg:
            return .stroke
        case .stroke:
            return .shadow
        case .shadow:
            return.normal
        }
    }
    
    fileprivate var btnImage: UIImage? {
        switch self {
        case .normal:
            return .zl.getImage("zl_input_font")
        case .bg:
            return .zl.getImage("zl_input_font_bg")
        case .stroke:
            return .zl.getImage("zl_input_font_stroke")
        case .shadow:
            return .zl.getImage("zl_input_font_shadow")
        }
    }
}
