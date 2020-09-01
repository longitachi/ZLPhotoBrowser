//
//  UIImage+ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/22.
//
//  Copyright (c) 2020 Long Zhang <longitachi@163.com>
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

/// https://github.com/kiritmodi2702/GIF-Swift
extension UIImage {
    
    class func zl_animateGifImage(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        
        let animateImage: UIImage?
        if count <= 1 {
            animateImage = UIImage(data: data)
        } else {
//            var images: [UIImage] = []
//            var duration: Double = 0
//
//            for i in 0..<count {
//                if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
//                    images.append(UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up))
//                }
//                duration += UIImage.zl_delayForImageAtIndex(i, source: source)
//            }
//            if duration == 0 {
//                duration = (1.0 / 10.0) * Double(count)
//            }
//            animateImage = UIImage.animatedImage(with: images, duration: duration)
            
            var images = [CGImage]()
            var delays = [Int]()

            for i in 0..<count {
                if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(image)
                }

                let delaySeconds = UIImage.zl_delayForImageAtIndex(Int(i),
                    source: source)
                delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
            }

            let duration: Int = {
                var sum = 0

                for val: Int in delays {
                    sum += val
                }

                return sum
            }()

            let gcd = zl_gcdForArray(delays)
            var frames = [UIImage]()

            var frame: UIImage
            var frameCount: Int
            for i in 0..<count {
                frame = UIImage(cgImage: images[Int(i)])
                frameCount = Int(delays[Int(i)] / gcd)

                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            }

            animateImage = UIImage.animatedImage(with: frames,
                duration: Double(duration) / 1000.0)
        }
        
        return animateImage
    }
    
    class func zl_delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.011 {
            delay = 0.1
        }
        
        return delay
    }
    
    
    class func zl_gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.zl_gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func zl_gcdForPair(_ a1: Int?, _ b1: Int?) -> Int {
        var a = a1
        var b = b1
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
}


/// 修复转向
extension UIImage {
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = CGAffineTransform(translationX: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        
        case .left, .leftMirrored:
            transform = CGAffineTransform(translationX: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
            
        case .right, .rightMirrored:
            transform = CGAffineTransform(translationX: 0, y: self.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
            
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        
        default:
            break
        }
        
        guard let ci = self.cgImage, let colorSpace = ci.colorSpace else {
            return self
        }
        let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: ci.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: ci.bitmapInfo.rawValue)
        context?.concatenate(transform)
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(ci, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            context?.draw(ci, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        guard let newCgimg = context?.makeImage() else {
            return self
        }
        return UIImage(cgImage: newCgimg)
    }
    
}


/// 旋转方向
extension UIImage {
  
    func rotate(orientation: UIImage.Orientation) -> UIImage {
        guard let imagRef = self.cgImage else {
            return self
        }
        var bnds = CGRect.zero
        bnds.size.width = CGFloat(imagRef.width)
        bnds.size.height = CGFloat(imagRef.height)
        
        let rect = bnds
        
        var transform = CGAffineTransform.identity
        
        switch orientation {
        case .up:
            return self
        case .upMirrored:
            transform = transform.translatedBy(x: rect.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .down:
            transform = transform.translatedBy(x: rect.width, y: rect.height)
            transform.rotated(by: .pi)
        case .downMirrored:
            transform = transform.translatedBy(x: 0, y: rect.height)
            transform = transform.scaledBy(x: 1, y: -1)
        case .left:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: 0, y: rect.width)
            transform = transform.rotated(by: CGFloat.pi * 3 / 2)
        case .leftMirrored:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: rect.height, y: rect.width)
            transform.scaledBy(x: -1, y: 1)
            transform.rotated(by: CGFloat.pi * 3 / 2)
        case .right:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: rect.height, y: 0)
            transform.rotated(by: CGFloat.pi / 2)
        case .rightMirrored:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat.pi / 2)
        @unknown default:
            break
        }
        
        /**
         UIGraphicsBeginImageContext(bnds.size);
         ctxt = UIGraphicsGetCurrentContext();
         
         switch(orient) {
             case UIImageOrientationLeft:
             case UIImageOrientationLeftMirrored:
             case UIImageOrientationRight:
             case UIImageOrientationRightMirrored:
                 CGContextScaleCTM(ctxt, -1.0, 1.0);
                 CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
                 break;
                 
             default:
                 CGContextScaleCTM(ctxt, 1.0, -1.0);
                 CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
                 break;
         }
         
         CGContextConcatCTM(ctxt, tran);
         CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
         
         copy = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         */
        UIGraphicsBeginImageContext(bnds.size)
        let context = UIGraphicsGetCurrentContext()
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.scaleBy(x: -1, y: 1)
            context?.translateBy(x: -rect.height, y: 0)
        default:
            context?.scaleBy(x: 1, y: -1)
            context?.translateBy(x: 0, y: -rect.height)
        }
        context?.concatenate(transform)
        context?.draw(imagRef, in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
    func swapRectWidthAndHeight(_ rect: CGRect) -> CGRect {
        var r = rect
        r.size.width = rect.height
        r.size.height = rect.width
        return r
    }
    
}
