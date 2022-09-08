//
//  Array+ZLPhotoBrowser.swift
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

import Photos
import UIKit

extension ZLPhotoBrowserWrapper where Base == [PHAsset] {
    func removeDuplicate() -> [PHAsset] {
        return base.enumerated().filter { index, value -> Bool in
            base.firstIndex(of: value) == index
        }.map { $0.element }
    }
}

extension ZLPhotoBrowserWrapper where Base == [ZLResultModel] {
    func removeDuplicate() -> [ZLResultModel] {
        return base.enumerated().filter { index, value -> Bool in
            base.firstIndex(of: value) == index
        }.map { $0.element }
    }
}
