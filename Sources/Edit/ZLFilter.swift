//
//  ZLFilter.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/10/9.
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

/// Filter code reference from https://github.com/Yummypets/YPImagePicker

public typealias ZLFilterApplierType = (_ image: UIImage) -> UIImage

@objc public enum ZLFilterType: Int {
    case normal
    case chrome
    case fade
    case instant
    case process
    case transfer
    case tone
    case linear
    case sepia
    case mono
    case noir
    case tonal
    
    var coreImageFilterName: String {
        switch self {
        case .normal:
            return ""
        case .chrome:
            return "CIPhotoEffectChrome"
        case .fade:
            return "CIPhotoEffectFade"
        case .instant:
            return "CIPhotoEffectInstant"
        case .process:
            return "CIPhotoEffectProcess"
        case .transfer:
            return "CIPhotoEffectTransfer"
        case .tone:
            return "CILinearToSRGBToneCurve"
        case .linear:
            return "CISRGBToneCurveToLinear"
        case .sepia:
            return "CISepiaTone"
        case .mono:
            return "CIPhotoEffectMono"
        case .noir:
            return "CIPhotoEffectNoir"
        case .tonal:
            return "CIPhotoEffectTonal"
        }
    }
}

public class ZLFilter: NSObject {
    public var name: String
    
    let applier: ZLFilterApplierType?
    
    @objc public init(name: String, filterType: ZLFilterType) {
        self.name = name
        
        if filterType != .normal {
            applier = { image -> UIImage in
                guard let ciImage = image.zl.toCIImage() else {
                    return image
                }
                
                let filter = CIFilter(name: filterType.coreImageFilterName)
                filter?.setValue(ciImage, forKey: kCIInputImageKey)
                guard let outputImage = filter?.outputImage?.zl.toUIImage() else {
                    return image
                }
                return outputImage
            }
        } else {
            applier = nil
        }
    }
    
    /// 可传入 applier 自定义滤镜
    @objc public init(name: String, applier: ZLFilterApplierType?) {
        self.name = name
        self.applier = applier
    }
}

extension ZLFilter {
    class func clarendonFilter(image: UIImage) -> UIImage {
        guard let ciImage = image.zl.toCIImage() else {
            return image
        }
        
        let backgroundImage = getColorImage(red: 127, green: 187, blue: 227, alpha: Int(255 * 0.2), rect: ciImage.extent)
        let outputCIImage = ciImage.applyingFilter("CIOverlayBlendMode", parameters: [
            "inputBackgroundImage": backgroundImage
        ])
        .applyingFilter("CIColorControls", parameters: [
            "inputSaturation": 1.35,
            "inputBrightness": 0.05,
            "inputContrast": 1.1
        ])
        guard let outputImage = outputCIImage.zl.toUIImage() else {
            return image
        }
        return outputImage
    }
    
    class func nashvilleFilter(image: UIImage) -> UIImage {
        guard let ciImage = image.zl.toCIImage() else {
            return image
        }
        
        let backgroundImage = getColorImage(red: 247, green: 176, blue: 153, alpha: Int(255 * 0.56), rect: ciImage.extent)
        let backgroundImage2 = getColorImage(red: 0, green: 70, blue: 150, alpha: Int(255 * 0.4), rect: ciImage.extent)
        let outputCIImage = ciImage
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
            ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.2
            ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.2,
                "inputBrightness": 0.05,
                "inputContrast": 1.1
            ])
            .applyingFilter("CILightenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage2
            ])
        
        guard let outputImage = outputCIImage.zl.toUIImage() else {
            return image
        }
        return outputImage
    }
    
    class func apply1977Filter(image: UIImage) -> UIImage {
        guard let ciImage = image.zl.toCIImage() else {
            return image
        }
        
        let filterImage = getColorImage(red: 243, green: 106, blue: 188, alpha: Int(255 * 0.1), rect: ciImage.extent)
        let backgroundImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.3,
                "inputBrightness": 0.1,
                "inputContrast": 1.05
            ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.3
            ])
        
        let outputCIImage = filterImage
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
            ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0),
                "inputPoint1": CIVector(x: 0.25, y: 0.20),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.80),
                "inputPoint4": CIVector(x: 1, y: 1)
            ])
        
        guard let outputImage = outputCIImage.zl.toUIImage() else {
            return image
        }
        return outputImage
    }
    
    class func toasterFilter(image: UIImage) -> UIImage {
        guard let ciImage = image.zl.toCIImage() else {
            return image
        }
        
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width / 4.0, height / 4.0)
        let radius1 = min(width / 1.5, height / 1.5)
        
        let color0 = getColor(red: 128, green: 78, blue: 15, alpha: 255)
        let color1 = getColor(red: 79, green: 0, blue: 79, alpha: 255)
        let circle = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1
        ])?.outputImage?.cropped(to: ciImage.extent)
        
        let outputCIImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.0,
                "inputBrightness": 0.01,
                "inputContrast": 1.1
            ])
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": circle!
            ])
        
        guard let outputImage = outputCIImage.zl.toUIImage() else {
            return image
        }
        return outputImage
    }
    
    class func getColor(red: Int, green: Int, blue: Int, alpha: Int = 255) -> CIColor {
        return CIColor(
            red: CGFloat(Double(red) / 255.0),
            green: CGFloat(Double(green) / 255.0),
            blue: CGFloat(Double(blue) / 255.0),
            alpha: CGFloat(Double(alpha) / 255.0)
        )
    }
    
    class func getColorImage(red: Int, green: Int, blue: Int, alpha: Int = 255, rect: CGRect) -> CIImage {
        let color = getColor(red: red, green: green, blue: blue, alpha: alpha)
        return CIImage(color: color).cropped(to: rect)
    }
}

public extension ZLFilter {
    @objc static let all: [ZLFilter] = [.normal, .clarendon, .nashville, .apply1977, .toaster, .chrome, .fade, .instant, .process, .transfer, .tone, .linear, .sepia, .mono, .noir, .tonal]
    
    @objc static let normal = ZLFilter(name: "Normal", filterType: .normal)
    
    @objc static let clarendon = ZLFilter(name: "Clarendon", applier: ZLFilter.clarendonFilter)
    
    @objc static let nashville = ZLFilter(name: "Nashville", applier: ZLFilter.nashvilleFilter)
    
    @objc static let apply1977 = ZLFilter(name: "1977", applier: ZLFilter.apply1977Filter)
    
    @objc static let toaster = ZLFilter(name: "Toaster", applier: ZLFilter.toasterFilter)
    
    @objc static let chrome = ZLFilter(name: "Chrome", filterType: .chrome)
    
    @objc static let fade = ZLFilter(name: "Fade", filterType: .fade)
    
    @objc static let instant = ZLFilter(name: "Instant", filterType: .instant)
    
    @objc static let process = ZLFilter(name: "Process", filterType: .process)
    
    @objc static let transfer = ZLFilter(name: "Transfer", filterType: .transfer)
    
    @objc static let tone = ZLFilter(name: "Tone", filterType: .tone)
    
    @objc static let linear = ZLFilter(name: "Linear", filterType: .linear)
    
    @objc static let sepia = ZLFilter(name: "Sepia", filterType: .sepia)
    
    @objc static let mono = ZLFilter(name: "Mono", filterType: .mono)
    
    @objc static let noir = ZLFilter(name: "Noir", filterType: .noir)
    
    @objc static let tonal = ZLFilter(name: "Tonal", filterType: .tonal)
}
