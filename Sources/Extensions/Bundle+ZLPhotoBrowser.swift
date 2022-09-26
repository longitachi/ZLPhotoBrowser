//
//  Bundle+ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/12.
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

import Foundation

private class BundleFinder {}

extension Bundle {
    private static var bundle: Bundle?
    
    static var normalModule: Bundle? = {
        let bundleName = "ZLPhotoBrowser"

        var candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: ZLPhotoPreviewSheet.self).resourceURL,
            
            // For command-line tools.
            Bundle.main.bundleURL,
        ]
        
        #if SWIFT_PACKAGE
            // For SWIFT_PACKAGE.
            candidates.append(Bundle.module.bundleURL)
        #endif

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return nil
    }()
    
    static var spmModule: Bundle? = {
        let bundleName = "ZLPhotoBrowser_ZLPhotoBrowser"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,
            
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
    
    static var zlPhotoBrowserBundle: Bundle? {
        return normalModule ?? spmModule
    }
    
    class func resetLanguage() {
        bundle = nil
    }
    
    class func zlLocalizedString(_ key: String) -> String {
        if bundle == nil {
            guard let path = Bundle.zlPhotoBrowserBundle?.path(forResource: getLanguage(), ofType: "lproj") else {
                return ""
            }
            bundle = Bundle(path: path)
        }
        
        let value = bundle?.localizedString(forKey: key, value: nil, table: nil)
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
    
    private class func getLanguage() -> String {
        var language = "en"
        
        switch ZLCustomLanguageDeploy.language {
        case .system:
            language = Locale.preferredLanguages.first ?? "en"
            
            if language.hasPrefix("zh") {
                if language.range(of: "Hans") != nil {
                    language = "zh-Hans"
                } else {
                    language = "zh-Hant"
                }
            } else if language.hasPrefix("ja") {
                language = "ja-US"
            } else if language.hasPrefix("fr") {
                language = "fr"
            } else if language.hasPrefix("de") {
                language = "de"
            } else if language.hasPrefix("ru") {
                language = "ru"
            } else if language.hasPrefix("vi") {
                language = "vi"
            } else if language.hasPrefix("ko") {
                language = "ko"
            } else if language.hasPrefix("ms") {
                language = "ms"
            } else if language.hasPrefix("it") {
                language = "it"
            } else if language.hasPrefix("id") {
                language = "id"
            } else if language.hasPrefix("pt") {
                language = "pt-BR"
            } else if language.hasPrefix("es") {
                language = "es-419"
            } else if language.hasPrefix("tr") {
                language = "tr"
            } else if language.hasPrefix("ar") {
                language = "ar"
            } else {
                language = "en"
            }
        case .chineseSimplified:
            language = "zh-Hans"
        case .chineseTraditional:
            language = "zh-Hant"
        case .english:
            language = "en"
        case .japanese:
            language = "ja-US"
        case .french:
            language = "fr"
        case .german:
            language = "de"
        case .russian:
            language = "ru"
        case .vietnamese:
            language = "vi"
        case .korean:
            language = "ko"
        case .malay:
            language = "ms"
        case .italian:
            language = "it"
        case .indonesian:
            language = "id"
        case .portuguese:
            language = "pt-BR"
        case .spanish:
            language = "es-419"
        case .turkish:
            language = "tr"
        case .arabic:
            language = "ar"
        }
        
        return language
    }
}
