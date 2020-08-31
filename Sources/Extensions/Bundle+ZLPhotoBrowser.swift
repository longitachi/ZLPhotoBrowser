//
//  Bundle+ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/12.
//

import Foundation

extension Bundle {
    
    private static var bundle: Bundle? = nil
    
    static var zlPhotoBrowserBundle: Bundle? = {
        let bc = Bundle(for: ZLPhotoPreviewSheet.classForCoder())
        guard let path = bc.path(forResource: "ZLPhotoBrowser", ofType: "bundle") else {
            return nil
        }
        return Bundle(path: path)
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
