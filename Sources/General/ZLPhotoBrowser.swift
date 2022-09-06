//
//  ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/9/2.
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
import Foundation
import Photos

let version = "4.3.6"

public struct ZLPhotoBrowserWrapper<Base> {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ZLPhotoBrowserCompatible: AnyObject { }

public protocol ZLPhotoBrowserCompatibleValue { }

extension ZLPhotoBrowserCompatible {
    public var zl: ZLPhotoBrowserWrapper<Self> {
        get { ZLPhotoBrowserWrapper(self) }
        set { }
    }
    
    public static var zl: ZLPhotoBrowserWrapper<Self>.Type {
        get { ZLPhotoBrowserWrapper<Self>.self }
        set { }
    }
}

extension ZLPhotoBrowserCompatibleValue {
    public var zl: ZLPhotoBrowserWrapper<Self> {
        get { ZLPhotoBrowserWrapper(self) }
        set { }
    }
}

extension UIViewController: ZLPhotoBrowserCompatible { }
extension UICollectionViewCell: ZLPhotoBrowserCompatible { }
extension UITableViewCell: ZLPhotoBrowserCompatible { }
extension UIColor: ZLPhotoBrowserCompatible { }
extension UIImage: ZLPhotoBrowserCompatible { }
extension CIImage: ZLPhotoBrowserCompatible { }
extension PHAsset: ZLPhotoBrowserCompatible { }
extension UIFont: ZLPhotoBrowserCompatible { }

extension Array: ZLPhotoBrowserCompatibleValue { }
extension String: ZLPhotoBrowserCompatibleValue { }
extension CGFloat: ZLPhotoBrowserCompatibleValue { }
extension Bool: ZLPhotoBrowserCompatibleValue { }
