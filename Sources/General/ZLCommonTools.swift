//
//  ZLCommonTools.swift
//  ZLPhotoBrowser
//
//  Created by long on 2025/9/28.
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

class ZLCommonTools: NSObject {
    class func formatVideoDuration(_ duration: TimeInterval) -> String {
        let duration = Int(round(duration))
        
        switch duration {
        case 0..<60:
            return String(format: "00:%02d", duration)
        case 60..<3600:
            let m = duration / 60
            let s = duration % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = duration / 3600
            let m = (duration % 3600) / 60
            let s = duration % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
    
    class func getLocalFileSize(for fileURL: URL) -> ZLPhotoConfiguration.KBUnit {
        guard fileURL.isFileURL else {
            return 0
        }

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return 0
        }

        do {
            let info = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            var size = (info[.size] as? ZLPhotoConfiguration.KBUnit) ?? 0
            
            let subpaths = FileManager.default.subpaths(atPath: fileURL.path) ?? []
            if subpaths.isEmpty {
                return ZLPhotoConfiguration.KBUnit(size / 1024)
            }
            
            subpaths.forEach {
                size += getLocalFileSize(for: URL(fileURLWithPath: $0))
            }
            
            return size
        } catch {
            return 0
        }
    }
    
    class func deviceIsiPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    class func deviceIsFoldableDevice() -> Bool {
        let identifier = deviceModelIdentifier()
        // 先写死真机型号，后面看有没有API
        if identifier == "iPhone19,4" {
            return true
        }
        if UIScreen.screens.count > 1 {
            return true
        }
        return false
    }
    
    class func deviceIsiPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    class func deviceModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
