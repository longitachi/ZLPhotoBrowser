//
//  ZLTextStickerContentView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2026/05/12.
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

/// Shared vector text renderer used by both `ZLInputTextViewController`
/// (editable preview) and `ZLTextStickerView` (read-only sticker).
///
/// Keeps text as a live `UITextView` so that zooming / final export via
/// `CALayer.render(in:)` re-rasterizes glyphs at the destination CTM —
/// no more blurry text stickers.
class ZLTextStickerContentView: UIView {
    // MARK: - Public state

    private let maxTextCount = 100
    
    var text: String {
        get { textView.text }
        set {
            textView.text = newValue
            strokeTextView.text = newValue
            applyAttributes()
        }
    }

    var textColor: UIColor = .white {
        didSet {
            guard textColor != oldValue else { return }
            strokeTextView.strokeColor = textColor
            applyAttributes()
        }
    }

    var font: UIFont = .boldSystemFont(ofSize: ZLTextStickerView.fontSize) {
        didSet {
            guard font != oldValue else { return }
            strokeTextView.font = font
            applyAttributes()
        }
    }

    var style: ZLInputTextStyle = .normal {
        didSet {
            guard style != oldValue else { return }
            strokeTextView.isHidden = style != .stroke
            applyAttributes()
        }
    }

    /// Whether the inner `UITextView` accepts user input.
    var isEditable = false {
        didSet {
            textView.isEditable = isEditable
            textView.isUserInteractionEnabled = isEditable
        }
    }

    /// Whether the inner `UITextView` scrolls. Sticker mode disables it
    /// to allow full-content layout; input mode keeps the default.
    var isScrollEnabled: Bool {
        get { textView.isScrollEnabled }
        set { textView.isScrollEnabled = newValue }
    }

    /// Forwarded delegate for the inner text view (used by input VC).
    weak var textViewDelegate: UITextViewDelegate?

    // MARK: - Subviews

    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        tv.textContainer.lineFragmentPadding = 0
        tv.textAlignment = .left
        tv.delegate = self
        tv.layoutManager.delegate = self
        tv.isEditable = false
        tv.isUserInteractionEnabled = false
        return tv
    }()

    let strokeTextView = ZLStrokeTextView()

    private let textLayer = CAShapeLayer()

    private let textLayerRadius: CGFloat = 10

    private var frameObservation: NSKeyValueObservation?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(textView)
        strokeTextView.backgroundColor = .clear
        strokeTextView.isHidden = true
        applyAttributes()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        frameObservation?.invalidate()
    }

    // MARK: - API

    func configure(text: String, textColor: UIColor, font: UIFont, style: ZLInputTextStyle) {
        self.textColor = textColor
        self.font = font
        self.style = style
        self.text = text
        strokeTextView.text = text
        strokeTextView.font = font
        strokeTextView.strokeColor = textColor
        strokeTextView.isHidden = style != .stroke
        // Make sure attributes are applied even if values equal defaults.
        applyAttributes()
    }

    /// Size needed to display the current text at the given max width
    /// (including `textContainerInset`).
    func intrinsicSize(maxWidth: CGFloat) -> CGSize {
        return textView.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = bounds
        installStrokeViewIfNeeded()
        updateStrokeViewFrame()
        drawTextBackground()
    }

    // MARK: - Contents scale

    /// Walk the entire layer tree and force every layer to rasterize at the
    /// given pixel density, then request redraw. Needed because the sticker
    /// is zoomed via `transform.scaledBy`, which by default just GPU-scales
    /// the cached bitmap — producing blurry glyphs and jagged rounded-corner
    /// paths. Bumping `contentsScale` makes UIKit / CoreText / CAShapeLayer
    /// re-rasterize at the target resolution instead.
    func applyContentsScale(_ scale: CGFloat) {
        let clamped = max(UIScreen.main.scale, scale)
        applyContentsScale(clamped, to: layer)
        strokeTextView.setNeedsDisplay()
    }

    private func applyContentsScale(_ scale: CGFloat, to layer: CALayer) {
        if abs(layer.contentsScale - scale) > .ulpOfOne {
            layer.contentsScale = scale
            layer.setNeedsDisplay()
        }
        layer.sublayers?.forEach { applyContentsScale(scale, to: $0) }
    }

    // MARK: - Attributes

    private var attribute: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        var att: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        var foregroundColor = textColor

        if style == .bg {
            if textColor == .white {
                foregroundColor = .black
            } else if textColor == .black {
                foregroundColor = .white
            } else {
                foregroundColor = .white
            }
        } else if style == .shadow {
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black
            shadow.shadowOffset = CGSize(width: 2, height: 2)
            shadow.shadowBlurRadius = 3
            att[.shadow] = shadow
        }

        att[.foregroundColor] = foregroundColor
        return att
    }

    private func applyAttributes() {
        // Preserve selection across attribute refresh if editing.
        let selected = textView.selectedRange
        textView.attributedText = NSAttributedString(string: textView.text, attributes: attribute)
        textView.typingAttributes = attribute
        if textView.isEditable {
            textView.selectedRange = NSRange(
                location: min(selected.location, (textView.text as NSString?)?.length ?? 0),
                length: 0
            )
        }
        
        if style == .stroke {
            strokeTextView.setNeedsDisplay()
        }
        setNeedsLayout()
    }

    // MARK: - Stroke view frame tracking

    private func installStrokeViewIfNeeded() {
        guard strokeTextView.superview == nil else { return }
        for subview in textView.subviews {
            if NSStringFromClass(subview.classForCoder) == "_UITextContainerView" {
                textView.insertSubview(strokeTextView, belowSubview: subview)
                frameObservation?.invalidate()
                frameObservation = subview.observe(\.frame, options: .new) { [weak self] _, _ in
                    self?.updateStrokeViewFrame()
                    self?.drawTextBackground()
                }
                break
            }
        }
    }

    private func updateStrokeViewFrame() {
        for subview in textView.subviews {
            if NSStringFromClass(subview.classForCoder) == "_UITextContainerView" {
                var rect = textView.convert(subview.frame, from: subview)
                rect = rect.insetBy(dx: textView.textContainerInset.left, dy: 0)
                rect.origin.y += textView.textContainerInset.top + 0.5
                strokeTextView.frame = rect
                break
            }
        }
    }

    // MARK: - Background path

    private func drawTextBackground() {
        guard style == .bg, !text.isEmpty else {
            textLayer.removeFromSuperlayer()
            return
        }

        let rects = calculateTextRects()
        guard !rects.isEmpty else {
            textLayer.removeFromSuperlayer()
            return
        }

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
        textLayer.fillColor = isEditable ? textColor.cgColor : textColor.withAlphaComponent(0.9).cgColor
        if textLayer.superlayer == nil {
            textView.layer.insertSublayer(textLayer, at: 0)
        }
    }

    private func calculateTextRects() -> [CGRect] {
        let layoutManager = textView.layoutManager

        let rawText = textView.text ?? ""
        // 用 utf16.count 兼容 emoji
        let range = layoutManager.glyphRange(forCharacterRange: NSRange(location: 0, length: rawText.utf16.count), actualCharacterRange: nil)
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)

        var rects: [CGRect] = []
        let insetLeft = textView.textContainerInset.left
        let insetTop = textView.textContainerInset.top
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, usedRect, _, _, _ in
            rects.append(CGRect(
                x: usedRect.minX - 10 + insetLeft,
                y: usedRect.minY - 8 + insetTop,
                width: usedRect.width + 20,
                height: usedRect.height + 16
            ))
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

        // 当前 rect 宽度大于上方的 rect，但差值小于 2 倍圆角
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

// MARK: - UITextViewDelegate

extension ZLTextStickerContentView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        defer {
            strokeTextView.text = textView.text
            if style == .stroke {
                strokeTextView.setNeedsDisplay()
            }
        }
        
        let markedTextRange = textView.markedTextRange
        guard markedTextRange == nil || (markedTextRange?.isEmpty ?? true) else {
            return
        }

        let text = textView.text ?? ""
        if text.count > maxTextCount {
            let endIndex = text.index(text.startIndex, offsetBy: maxTextCount)
            let truncated = String(text[..<endIndex])
            self.text = truncated
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textViewDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewDelegate?.textViewDidBeginEditing?(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDelegate?.textViewDidEndEditing?(textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        textViewDelegate?.textViewDidChangeSelection?(textView)
    }
}

// MARK: - NSLayoutManagerDelegate

extension ZLTextStickerContentView: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        guard layoutFinishedFlag else { return }
        drawTextBackground()
    }
}

// MARK: - ZLStrokeTextView (moved from ZLInputTextViewController)

class ZLStrokeTextView: UIView {
    var font: UIFont = .boldSystemFont(ofSize: ZLTextStickerView.fontSize)
    var strokeColor: UIColor = .white
    var strokeWidth: CGFloat = 4.0
    var text = ""

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(bounds)
        context.saveGState()
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // 设置描边和填充颜色
        var textColorARGB = strokeColor.zl.argbTuple()
        if textColorARGB.red <= 0.1, textColorARGB.green <= 0.1, textColorARGB.blue <= 0.1 {
            // 黑色的话修改为白色，方便看出边框
            textColorARGB = (1, 1, 1, 1)
        }
        let fillColor = UIColor(red: textColorARGB.red * 0.55, green: textColorARGB.green * 0.55, blue: textColorARGB.blue * 0.55, alpha: 1)

        context.setTextDrawingMode(.fillStroke)
        // 描边宽度
        context.setLineWidth(strokeWidth)
        context.setFillColor(fillColor.cgColor)
        context.setLineJoin(.round)

        // 创建 Core Text 绘制
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.2
        let attributedString = NSAttributedString(string: text, attributes: [.foregroundColor: fillColor, .font: font, .paragraphStyle: paragraphStyle])

        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let path = CGMutablePath()

        path.addRect(bounds)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedString.length), path, nil)

        // 绘制文本
        CTFrameDraw(frame, context)
        context.restoreGState()
    }
}
