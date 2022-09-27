//
//  ZLEditImageConfiguration.swift
//  ZLPhotoBrowser
//
//  Created by long on 2021/12/17.
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

/// Provide an image sticker container view that conform to this protocol must be a subclass of UIView
/// 必须是UIView的子类遵循这个协议
@objc public protocol ZLImageStickerContainerDelegate {
    @objc var selectImageBlock: ((UIImage) -> Void)? { get set }
    
    @objc var hideBlock: (() -> Void)? { get set }
    
    @objc func show(in view: UIView)
}

public class ZLEditImageConfiguration: NSObject {
    @objc public enum EditTool: Int, CaseIterable {
        case draw
        case clip
        case imageSticker
        case textSticker
        case mosaic
        case filter
        case adjust
    }
    
    @objc public enum AdjustTool: Int, CaseIterable {
        case brightness
        case contrast
        case saturation
        
        var key: String {
            switch self {
            case .brightness:
                return kCIInputBrightnessKey
            case .contrast:
                return kCIInputContrastKey
            case .saturation:
                return kCIInputSaturationKey
            }
        }
        
        func filterValue(_ value: Float) -> Float {
            switch self {
            case .brightness:
                // 亮度范围-1---1，默认0，这里除以3，取 -0.33---0.33
                return value / 3
            case .contrast:
                // 对比度范围0---4，默认1，这里计算下取0.5---2.5
                let v: Float
                if value < 0 {
                    v = 1 + value * (1 / 2)
                } else {
                    v = 1 + value * (3 / 2)
                }
                return v
            case .saturation:
                // 饱和度范围0---2，默认1
                return value + 1
            }
        }
    }
    
    private var pri_tools: [ZLEditImageConfiguration.EditTool] = ZLEditImageConfiguration.EditTool.allCases
    /// Edit image tools. (Default order is draw, clip, imageSticker, textSticker, mosaic, filtter)
    /// Because Objective-C Array can't contain Enum styles, so this property is invalid in Objective-C.
    /// - warning: If you want to use the image sticker feature, you must provide a view that implements ZLImageStickerContainerDelegate.
    public var tools: [ZLEditImageConfiguration.EditTool] {
        get {
            if pri_tools.isEmpty {
                return ZLEditImageConfiguration.EditTool.allCases
            } else {
                return pri_tools
            }
        }
        set {
            pri_tools = newValue
        }
    }
    
    /// Edit image tools.  (This property is only for objc).
    /// - warning: If you want to use the image sticker feature, you must provide a view that implements ZLImageStickerContainerDelegate.
    @objc public var tools_objc: [Int] = [] {
        didSet {
            tools = tools_objc.compactMap { ZLEditImageConfiguration.EditTool(rawValue: $0) }
        }
    }
    
    private static let defaultDrawColors: [UIColor] = [.white, .black, .zl.rgba(241, 79, 79), .zl.rgba(243, 170, 78), .zl.rgba(80, 169, 56), .zl.rgba(30, 183, 243), .zl.rgba(139, 105, 234)]
    
    private var pri_drawColors: [UIColor] = ZLEditImageConfiguration.defaultDrawColors
    /// Draw colors for image editor.
    @objc public var drawColors: [UIColor] {
        get {
            if pri_drawColors.isEmpty {
                return ZLEditImageConfiguration.defaultDrawColors
            } else {
                return pri_drawColors
            }
        }
        set {
            pri_drawColors = newValue
        }
    }
    
    /// The default draw color. If this color not in editImageDrawColors, will pick the first color in editImageDrawColors as the default.
    @objc public var defaultDrawColor: UIColor = .zl.rgba(241, 79, 79)
    
    private var pri_clipRatios: [ZLImageClipRatio] = [.custom]
    /// Edit ratios for image editor.
    @objc public var clipRatios: [ZLImageClipRatio] {
        get {
            if pri_clipRatios.isEmpty {
                return [.custom]
            } else {
                return pri_clipRatios
            }
        }
        set {
            pri_clipRatios = newValue
        }
    }
    
    private static let defaultTextStickerTextColors: [UIColor] = [.white, .black, .zl.rgba(241, 79, 79), .zl.rgba(243, 170, 78), .zl.rgba(80, 169, 56), .zl.rgba(30, 183, 243), .zl.rgba(139, 105, 234)]
    
    private var pri_textStickerTextColors: [UIColor] = ZLEditImageConfiguration.defaultTextStickerTextColors
    /// Text sticker colors for image editor.
    @objc public var textStickerTextColors: [UIColor] {
        get {
            if pri_textStickerTextColors.isEmpty {
                return ZLEditImageConfiguration.defaultTextStickerTextColors
            } else {
                return pri_textStickerTextColors
            }
        }
        set {
            pri_textStickerTextColors = newValue
        }
    }
    
    /// The default text sticker color. If this color not in textStickerTextColors, will pick the first color in textStickerTextColors as the default.
    @objc public var textStickerDefaultTextColor = UIColor.white
    
    private var pri_filters: [ZLFilter] = ZLFilter.all
    /// Filters for image editor.
    @objc public var filters: [ZLFilter] {
        get {
            if pri_filters.isEmpty {
                return ZLFilter.all
            } else {
                return pri_filters
            }
        }
        set {
            pri_filters = newValue
        }
    }
    
    @objc public var imageStickerContainerView: (UIView & ZLImageStickerContainerDelegate)?
    
    private var pri_adjustTools: [ZLEditImageConfiguration.AdjustTool] = ZLEditImageConfiguration.AdjustTool.allCases
    /// Adjust image tools. (Default order is brightness, contrast, saturation)
    /// Valid when the tools contain EditTool.adjust
    /// Because Objective-C Array can't contain Enum styles, so this property is invalid in Objective-C.
    public var adjustTools: [ZLEditImageConfiguration.AdjustTool] {
        get {
            if pri_adjustTools.isEmpty {
                return ZLEditImageConfiguration.AdjustTool.allCases
            } else {
                return pri_adjustTools
            }
        }
        set {
            pri_adjustTools = newValue
        }
    }
    
    /// Adjust image tools.  (This property is only for objc).
    /// Valid when the tools contain EditTool.adjust
    @objc public var adjustTools_objc: [Int] = [] {
        didSet {
            adjustTools = adjustTools_objc.compactMap { ZLEditImageConfiguration.AdjustTool(rawValue: $0) }
        }
    }
    
    /// Give an impact feedback when the adjust slider value is zero. Defaults to true.
    @objc public var impactFeedbackWhenAdjustSliderValueIsZero = true
    
    /// Impact feedback style. Defaults to .medium
    @objc public var impactFeedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    
    /// Whether to support redo in graffiti and mosaic tools. Defaults to false
    @objc public var canRedo = false
}

// MARK: chaining

public extension ZLEditImageConfiguration {
    @discardableResult
    func tools(_ tools: [ZLEditImageConfiguration.EditTool]) -> ZLEditImageConfiguration {
        self.tools = tools
        return self
    }
    
    @discardableResult
    func drawColors(_ colors: [UIColor]) -> ZLEditImageConfiguration {
        drawColors = colors
        return self
    }
    
    func defaultDrawColor(_ color: UIColor) -> ZLEditImageConfiguration {
        defaultDrawColor = color
        return self
    }
    
    @discardableResult
    func clipRatios(_ ratios: [ZLImageClipRatio]) -> ZLEditImageConfiguration {
        clipRatios = ratios
        return self
    }
    
    @discardableResult
    func textStickerTextColors(_ colors: [UIColor]) -> ZLEditImageConfiguration {
        textStickerTextColors = colors
        return self
    }
    
    @discardableResult
    func textStickerDefaultTextColor(_ color: UIColor) -> ZLEditImageConfiguration {
        textStickerDefaultTextColor = color
        return self
    }
    
    @discardableResult
    func filters(_ filters: [ZLFilter]) -> ZLEditImageConfiguration {
        self.filters = filters
        return self
    }
    
    @discardableResult
    func imageStickerContainerView(_ view: (UIView & ZLImageStickerContainerDelegate)?) -> ZLEditImageConfiguration {
        imageStickerContainerView = view
        return self
    }
    
    @discardableResult
    func adjustTools(_ tools: [ZLEditImageConfiguration.AdjustTool]) -> ZLEditImageConfiguration {
        adjustTools = tools
        return self
    }
    
    @discardableResult
    func impactFeedbackWhenAdjustSliderValueIsZero(_ value: Bool) -> ZLEditImageConfiguration {
        impactFeedbackWhenAdjustSliderValueIsZero = value
        return self
    }
    
    @discardableResult
    func impactFeedbackStyle(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> ZLEditImageConfiguration {
        impactFeedbackStyle = style
        return self
    }
    
    @discardableResult
    func canRedo(_ value: Bool) -> ZLEditImageConfiguration {
        canRedo = value
        return self
    }
}

// MARK: 裁剪比例

public class ZLImageClipRatio: NSObject {
    @objc public var title: String
    
    @objc public let whRatio: CGFloat
    
    @objc public let isCircle: Bool
    
    @objc public init(title: String, whRatio: CGFloat, isCircle: Bool = false) {
        self.title = title
        self.whRatio = isCircle ? 1 : whRatio
        self.isCircle = isCircle
        super.init()
    }
}

extension ZLImageClipRatio {
    static func ==(lhs: ZLImageClipRatio, rhs: ZLImageClipRatio) -> Bool {
        return lhs.whRatio == rhs.whRatio && lhs.title == rhs.title
    }
}

public extension ZLImageClipRatio {
    @objc static let custom = ZLImageClipRatio(title: "custom", whRatio: 0)
    
    @objc static let circle = ZLImageClipRatio(title: "circle", whRatio: 1, isCircle: true)
    
    @objc static let wh1x1 = ZLImageClipRatio(title: "1 : 1", whRatio: 1)
    
    @objc static let wh3x4 = ZLImageClipRatio(title: "3 : 4", whRatio: 3.0 / 4.0)
    
    @objc static let wh4x3 = ZLImageClipRatio(title: "4 : 3", whRatio: 4.0 / 3.0)
    
    @objc static let wh2x3 = ZLImageClipRatio(title: "2 : 3", whRatio: 2.0 / 3.0)
    
    @objc static let wh3x2 = ZLImageClipRatio(title: "3 : 2", whRatio: 3.0 / 2.0)
    
    @objc static let wh9x16 = ZLImageClipRatio(title: "9 : 16", whRatio: 9.0 / 16.0)
    
    @objc static let wh16x9 = ZLImageClipRatio(title: "16 : 9", whRatio: 16.0 / 9.0)
}
