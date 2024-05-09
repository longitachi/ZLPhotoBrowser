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
            refreshTextViewUI()
        }
    }
    
    private var textStyle: ZLInputTextStyle
    
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
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.tintColor = .zl.bottomToolViewBtnNormalBgColor
        textView.textColor = currentColor
        textView.text = text
        textView.font = font
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.delegate = self
        return textView
    }()
    
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
    
    private lazy var textLayer = CAShapeLayer()
    
    private let textLayerRadius: CGFloat = 10
    
    private let maxTextCount = 100
    
    /// text, textColor, image, style
    var endInput: ((String, UIColor, UIFont, UIImage?, ZLInputTextStyle) -> Void)?
    
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
        if let font = font {
            self.font = font.withSize(ZLTextStickerView.fontSize)
        }
        if let textColor = textColor {
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
        
        textView.frame = CGRect(x: 10, y: doneBtn.zl.bottom + 30, width: view.zl.width - 20, height: 200)
        
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
        view.addSubview(textView)
        view.addSubview(toolView)
        toolView.addSubview(textStyleBtn)
        toolView.addSubview(collectionView)
        
        // 这个要放到这里，不能放到懒加载里，因为放到懒加载里会触发layoutManager(_:, didCompleteLayoutFor:,atEnd)，导致循环调用
        textView.textAlignment = .left
        
        refreshTextViewUI()
    }
    
    private func refreshTextViewUI() {
        textStyleBtn.setImage(textStyle.btnImage, for: .normal)
        textStyleBtn.setImage(textStyle.btnImage, for: .highlighted)
        
        drawTextBackground()
        
        guard textStyle == .bg else {
            textView.textColor = currentColor
            return
        }
        
        if currentColor == .white {
            textView.textColor = .black
        } else if currentColor == .black {
            textView.textColor = .white
        } else {
            textView.textColor = .white
        }
    }
    
    @objc private func textStyleBtnClick() {
        if textStyle == .normal {
            textStyle = .bg
        } else {
            textStyle = .normal
        }
        
        refreshTextViewUI()
    }
    
    @objc private func cancelBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneBtnClick() {
        textView.tintColor = .clear
        textView.endEditing(true)

        var image: UIImage?
        
        if !textView.text.isEmpty {
            for subview in textView.subviews {
                if NSStringFromClass(subview.classForCoder) == "_UITextContainerView" {
                    let size = textView.sizeThatFits(subview.frame.size)
                    image = UIGraphicsImageRenderer.zl.renderImage(size: size) { context in
                        if textStyle == .bg {
                            textLayer.render(in: context)
                        }

                        subview.layer.render(in: context)
                    }
                }
            }
        }
        
        endInput?(textView.text, currentColor, font, image, textStyle)
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
        
        var textViewFrame = textView.frame
        textViewFrame.size.height = toolViewFrame.minY - textViewFrame.minY - 20
        
        UIView.animate(withDuration: max(duration, 0.25)) {
            self.toolView.frame = toolViewFrame
            self.textView.frame = textViewFrame
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
        
        var textViewFrame = textView.frame
        textViewFrame.size.height = toolViewFrame.minY - textViewFrame.minY - 20
        
        UIView.animate(withDuration: max(duration, 0.25)) {
            self.toolView.frame = toolViewFrame
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

// MARK: Draw text layer

extension ZLInputTextViewController {
    private func drawTextBackground() {
        guard textStyle == .bg, !textView.text.isEmpty else {
            textLayer.removeFromSuperlayer()
            return
        }
        
        let rects = calculateTextRects()
        
        let path = UIBezierPath()
        for (index, rect) in rects.enumerated() {
            if index == 0 {
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + textLayerRadius))
                path.addArc(withCenter: CGPoint(x: rect.minX + textLayerRadius, y: rect.minY + textLayerRadius), radius: textLayerRadius, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
                path.addLine(to: CGPoint(x: rect.maxX - textLayerRadius, y: rect.minY))
                path.addArc(withCenter: CGPoint(x: rect.maxX - textLayerRadius, y: rect.minY + textLayerRadius), radius: textLayerRadius, startAngle: .pi * 1.5, endAngle: .pi * 2, clockwise: true)
            } else {
                let preRect = rects[index - 1]
                if rect.maxX > preRect.maxX {
                    path.addLine(to: CGPoint(x: preRect.maxX, y: rect.minY - textLayerRadius))
                    path.addArc(withCenter: CGPoint(x: preRect.maxX + textLayerRadius, y: rect.minY - textLayerRadius), radius: textLayerRadius, startAngle: -.pi, endAngle: -.pi * 1.5, clockwise: false)
                    path.addLine(to: CGPoint(x: rect.maxX - textLayerRadius, y: rect.minY))
                    path.addArc(withCenter: CGPoint(x: rect.maxX - textLayerRadius, y: rect.minY + textLayerRadius), radius: textLayerRadius, startAngle: .pi * 1.5, endAngle: .pi * 2, clockwise: true)
                } else if rect.maxX < preRect.maxX {
                    path.addLine(to: CGPoint(x: preRect.maxX, y: preRect.maxY - textLayerRadius))
                    path.addArc(withCenter: CGPoint(x: preRect.maxX - textLayerRadius, y: preRect.maxY - textLayerRadius), radius: textLayerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
                    path.addLine(to: CGPoint(x: rect.maxX + textLayerRadius, y: preRect.maxY))
                    path.addArc(withCenter: CGPoint(x: rect.maxX + textLayerRadius, y: preRect.maxY + textLayerRadius), radius: textLayerRadius, startAngle: -.pi / 2, endAngle: -.pi, clockwise: false)
                } else {
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + textLayerRadius))
                }
            }
            
            if index == rects.count - 1 {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - textLayerRadius))
                path.addArc(withCenter: CGPoint(x: rect.maxX - textLayerRadius, y: rect.maxY - textLayerRadius), radius: textLayerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
                path.addLine(to: CGPoint(x: rect.minX + textLayerRadius, y: rect.maxY))
                path.addArc(withCenter: CGPoint(x: rect.minX + textLayerRadius, y: rect.maxY - textLayerRadius), radius: textLayerRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
                
                let firstRect = rects[0]
                path.addLine(to: CGPoint(x: firstRect.minX, y: firstRect.minY + textLayerRadius))
                path.close()
            }
        }
        
        textLayer.path = path.cgPath
        textLayer.fillColor = currentColor.cgColor
        if textLayer.superlayer == nil {
            textView.layer.insertSublayer(textLayer, at: 0)
        }
    }
    
    private func calculateTextRects() -> [CGRect] {
        let layoutManager = textView.layoutManager
        
        // 这里必须用utf16.count 或者 (text as NSString).length，因为用count的话不准，一个emoji表情的count为2或更大
        let range = layoutManager.glyphRange(forCharacterRange: NSMakeRange(0, textView.text.utf16.count), actualCharacterRange: nil)
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        
        var rects: [CGRect] = []
        
        let insetLeft = textView.textContainerInset.left
        let insetTop = textView.textContainerInset.top
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, usedRect, _, _, _ in
            rects.append(CGRect(x: usedRect.minX - 10 + insetLeft, y: usedRect.minY - 8 + insetTop, width: usedRect.width + 20, height: usedRect.height + 16))
        }
        
        guard rects.count > 1 else {
            return rects
        }
        
        for i in 1..<rects.count {
            processRects(&rects, index: i, maxIndex: i)
        }
        
        return rects
    }
    
    private func processRects(_ rects: inout [CGRect], index: Int, maxIndex: Int) {
        guard rects.count > 1, index > 0, index <= maxIndex else {
            return
        }
        
        var preRect = rects[index - 1]
        var currRect = rects[index]
        
        var preChanged = false
        var currChanged = false
        
        // 当前rect宽度大于上方的rect，但差值小于2倍圆角
        if currRect.width > preRect.width, currRect.width - preRect.width < 2 * textLayerRadius {
            var size = preRect.size
            size.width = currRect.width
            preRect = CGRect(origin: preRect.origin, size: size)
            preChanged = true
        }
        
        if currRect.width < preRect.width, preRect.width - currRect.width < 2 * textLayerRadius {
            var size = currRect.size
            size.width = preRect.width
            currRect = CGRect(origin: currRect.origin, size: size)
            currChanged = true
        }
        
        if preChanged {
            rects[index - 1] = preRect
            processRects(&rects, index: index - 1, maxIndex: maxIndex)
        }
        
        if currChanged {
            rects[index] = currRect
            processRects(&rects, index: index + 1, maxIndex: maxIndex)
        }
    }
}

extension ZLInputTextViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let markedTextRange = textView.markedTextRange
        guard markedTextRange == nil || (markedTextRange?.isEmpty ?? true) else {
            return
        }
        
        let text = textView.text ?? ""
        if text.count > maxTextCount {
            let endIndex = text.index(text.startIndex, offsetBy: maxTextCount)
            textView.text = String(text[..<endIndex])
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            doneBtnClick()
            return false
        }
        return true
    }
}

extension ZLInputTextViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        guard layoutFinishedFlag else {
            return
        }
        
        drawTextBackground()
    }
}

public enum ZLInputTextStyle {
    case normal
    case bg
    
    fileprivate var btnImage: UIImage? {
        switch self {
        case .normal:
            return .zl.getImage("zl_input_font")
        case .bg:
            return .zl.getImage("zl_input_font_bg")
        }
    }
}
