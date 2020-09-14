//
//  Bundle+ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/12.
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

import Foundation

extension Bundle {
    
    private static var bundle: Bundle? = nil
    
    static var zlPhotoBrowserBundle: Bundle? = {
        let bundleName = "ZLPhotoBrowser"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: ZLPhotoPreviewSheet.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return nil
    }()
    
    class func resetLanguage() {
        self.bundle = nil
    }
    
    class func zlLocalizedString(_ key: String) -> String {
        if self.bundle == nil {
            guard let path = Bundle.zlPhotoBrowserBundle?.path(forResource: self.getLanguage(), ofType: "lproj") else {
                return ""
            }
            self.bundle = Bundle(path: path)
        }
        
        let value = self.bundle?.localizedString(forKey: key, value: nil, table: nil)
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
    
    private class func getLanguage() -> String {
        var language = "en"
        
        switch ZLCustomLanguageDeploy.language {
        case .system:
            language = Locale.preferredLanguages.first ?? "en"
            
            if language.hasPrefix("en") {
                language = "en"
            } else if language.hasPrefix("zh") {
                if language.range(of: "Hans") != nil {
                    language = "zh-Hans"
                } else {
                    language = "zh-Hant"
                }
            } else if language.hasPrefix("ja") {
                language = "ja-US"
            }
        case .chineseSimplified:
            language = "zh-Hans"
        case .chineseTraditional:
            language = "zh-Hant"
        case .english:
            language = "en"
        case .japanese:
            language = "ja-US"
        }
        
        return language
    }
    
    
}
