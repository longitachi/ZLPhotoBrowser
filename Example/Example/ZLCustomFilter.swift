//
//  ZLCustomFilter.swift
//  Example
//
//  Created by long on 2020/10/10.
//

import UIKit

/// https://github.com/Yummypets/YPImagePicker
class ZLCustomFilter: NSObject {

    class func hazeRemovalFilter(image: UIImage) -> UIImage {
        var ci = image.ciImage
        if ci == nil, let cg = image.cgImage {
            ci = CIImage(cgImage: cg)
        }
        guard let ciImage = ci else {
            return image
        }
        
        let filter = HazeRemovalFilter()
        filter.inputImage = ciImage
        
        guard let outputCIImage = filter.outputImage else {
            return image
        }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return image
        }
        return UIImage(cgImage: cgImage)
    }
    
}

class HazeRemovalFilter: CIFilter {
    var inputImage: CIImage!
    var inputColor: CIColor! = CIColor(red: 0.7, green: 0.9, blue: 1.0)
    var inputDistance: Float! = 0.2
    var inputSlope: Float! = 0.0
    var hazeRemovalKernel: CIKernel!
    
    override init() {
        // check kernel has been already initialized
        let code: String = """
kernel vec4 myHazeRemovalKernel(
    sampler src,
    __color color,
    float distance,
    float slope)
{
    vec4 t;
    float d;

    d = destCoord().y * slope + distance;
    t = unpremultiply(sample(src, samplerCoord(src)));
    t = (t - d * color) / (1.0 - d);

    return premultiply(t);
}
"""
        self.hazeRemovalKernel = CIKernel(source: code)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var outputImage: CIImage? {
        guard let inputImage = self.inputImage,
            let hazeRemovalKernel = self.hazeRemovalKernel,
            let inputColor = self.inputColor,
            let inputDistance = self.inputDistance,
            let inputSlope = self.inputSlope
            else {
                return nil
        }
        let src: CISampler = CISampler(image: inputImage)
        return hazeRemovalKernel.apply(extent: inputImage.extent,
            roiCallback: { (_, rect) -> CGRect in
                return rect
        }, arguments: [
            src,
            inputColor,
            inputDistance,
            inputSlope
            ])
    }
    
    override var attributes: [String: Any] {
        return [
            kCIAttributeFilterDisplayName: "Haze Removal Filter",
            "inputDistance": [
                kCIAttributeMin: 0.0,
                kCIAttributeMax: 1.0,
                kCIAttributeSliderMin: 0.0,
                kCIAttributeSliderMax: 0.7,
                kCIAttributeDefault: 0.2,
                kCIAttributeIdentity: 0.0,
                kCIAttributeType: kCIAttributeTypeScalar
            ],
            "inputSlope": [
                kCIAttributeSliderMin: -0.01,
                kCIAttributeSliderMax: 0.01,
                kCIAttributeDefault: 0.00,
                kCIAttributeIdentity: 0.00,
                kCIAttributeType: kCIAttributeTypeScalar
            ],
            kCIInputColorKey: [
                kCIAttributeDefault: CIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            ]
        ]
    }
}
