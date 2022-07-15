//
//  UIColor+Hex.swift
//  Example
//
//  Created by long on 2022/7/1.
//

import UIKit

extension UIColor {
    class func color(hexRGB: Int64, alpha: CGFloat = 1.0) -> UIColor {
        let r: Int64 = (hexRGB & 0xFF0000) >> 16
        let g: Int64 = (hexRGB & 0xFF00) >> 8
        let b: Int64 = (hexRGB & 0xFF)
        
        let color = UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: alpha
        )

        return color
    }
}
