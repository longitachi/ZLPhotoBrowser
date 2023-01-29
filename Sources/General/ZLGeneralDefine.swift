//
//  ZLGeneralDefine.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
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

let ZLMaxImageWidth: CGFloat = 500

enum ZLLayout {
    static let navTitleFont: UIFont = .zl.font(ofSize: 17)
    
    static let bottomToolViewH: CGFloat = 55
    
    static let bottomToolBtnH: CGFloat = 34
    
    static let bottomToolBtnY: CGFloat = 10
    
    static let bottomToolTitleFont: UIFont = .zl.font(ofSize: 17)
    
    static let bottomToolBtnCornerRadius: CGFloat = 5
}

func markSelected(source: inout [ZLPhotoModel], selected: inout [ZLPhotoModel]) {
    guard selected.count > 0 else {
        return
    }
    
    var selIds: [String: Bool] = [:]
    var selEditImage: [String: UIImage] = [:]
    var selEditModel: [String: ZLEditImageModel] = [:]
    var selIdAndIndex: [String: Int] = [:]
    
    for (index, m) in selected.enumerated() {
        selIds[m.ident] = true
        selEditImage[m.ident] = m.editImage
        selEditModel[m.ident] = m.editImageModel
        selIdAndIndex[m.ident] = index
    }
    
    source.forEach { m in
        if selIds[m.ident] == true {
            m.isSelected = true
            m.editImage = selEditImage[m.ident]
            m.editImageModel = selEditModel[m.ident]
            selected[selIdAndIndex[m.ident]!] = m
        } else {
            m.isSelected = false
        }
    }
}

func getAppName() -> String {
    if let name = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
        return name
    }
    return "App"
}

func deviceIsiPhone() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}

func deviceIsiPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

func deviceSafeAreaInsets() -> UIEdgeInsets {
    var insets: UIEdgeInsets = .zero
    
    if #available(iOS 11, *) {
        insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
    
    return insets
}

func deviceIsFringeScreen() -> Bool {
    return deviceSafeAreaInsets().top > 0
}

func isSmallScreen() -> Bool {
    return UIScreen.main.bounds.height <= 812
}

func showAlertView(_ message: String, _ sender: UIViewController?) {
    let action = ZLCustomAlertAction(title: localLanguageTextValue(.ok), style: .default, handler: nil)
    showAlertController(title: nil, message: message, style: .alert, actions: [action], sender: sender)
}

func showAlertController(title: String?, message: String?, style: ZLCustomAlertStyle, actions: [ZLCustomAlertAction], sender: UIViewController?) {
    if let alertClass = ZLPhotoUIConfiguration.default().customAlertClass {
        let alert = alertClass.alert(title: title, message: message ?? "", style: style)
        actions.forEach { alert.addAction($0) }
        alert.show(with: sender)
        return
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: style.toSystemAlertStyle)
    actions
        .map { $0.toSystemAlertAction() }
        .forEach { alert.addAction($0) }
    if deviceIsiPad() {
        alert.popoverPresentationController?.sourceView = sender?.view
    }
    (sender ?? UIApplication.shared.keyWindow?.rootViewController)?.zl.showAlertController(alert)
}

func canAddModel(_ model: ZLPhotoModel, currentSelectCount: Int, sender: UIViewController?, showAlert: Bool = true) -> Bool {
    guard ZLPhotoConfiguration.default().canSelectAsset?(model.asset) ?? true else {
        return false
    }
    
    if currentSelectCount >= ZLPhotoConfiguration.default().maxSelectCount {
        if showAlert {
            let message = String(format: localLanguageTextValue(.exceededMaxSelectCount), ZLPhotoConfiguration.default().maxSelectCount)
            showAlertView(message, sender)
        }
        return false
    }
    if currentSelectCount > 0 {
        if !ZLPhotoConfiguration.default().allowMixSelect, model.type == .video {
            return false
        }
    }
    if model.type == .video {
        if model.second > ZLPhotoConfiguration.default().maxSelectVideoDuration {
            if showAlert {
                let message = String(format: localLanguageTextValue(.longerThanMaxVideoDuration), ZLPhotoConfiguration.default().maxSelectVideoDuration)
                showAlertView(message, sender)
            }
            return false
        }
        if model.second < ZLPhotoConfiguration.default().minSelectVideoDuration {
            if showAlert {
                let message = String(format: localLanguageTextValue(.shorterThanMaxVideoDuration), ZLPhotoConfiguration.default().minSelectVideoDuration)
                showAlertView(message, sender)
            }
            return false
        }
    }
    return true
}

func ZLMainAsync(after: TimeInterval = 0, handler: @escaping (() -> Void)) {
    if after > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            handler()
        }
    } else {
        if Thread.isMainThread {
            handler()
        } else {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}

func zl_debugPrint(_ message: Any...) {
//    message.forEach { debugPrint($0) }
}

func zlLoggerInDebug(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    #if DEBUG
        print("\(file):\(line): \(lastMessage())")
    #endif
}
