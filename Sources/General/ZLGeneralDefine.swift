//
//  ZLGeneralDefine.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
//

import UIKit

let ZLMaxImageWidth: CGFloat = 600

func zlRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
}

func getImage(_ named: String) -> UIImage? {
    if ZLCustomImageDeply.deploy.contains(named) {
        return UIImage(named: named)
    }
    return UIImage(named: "ZLPhotoBrowser.bundle/" + named) ?? UIImage(named: "Frameworks/ZLPhotoBrowser.framework/ZLPhotoBrowser.bundle/" + named)
}

func getFont(_ size: CGFloat) -> UIFont {
    guard let name = ZLCustomFontDeploy.fontName else {
        return UIFont.systemFont(ofSize: size)
    }
    
    return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
}

func markSelected(source: inout [ZLPhotoModel], selected: inout [ZLPhotoModel]) {
    guard selected.count > 0 else {
        return
    }
    
    var selIds: [String: Bool] = [:]
    var selEditImage: [String: UIImage] = [:]
    var selIdAndIndex: [String: Int] = [:]
    
    for (index, m) in selected.enumerated() {
        selIds[m.ident] = true
        selEditImage[m.ident] = m.editImage
        selIdAndIndex[m.ident] = index
    }
    
    source.forEach { (m) in
        if selIds[m.ident] == true {
            m.isSelected = true
            m.editImage = selEditImage[m.ident]
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
    return UI_USER_INTERFACE_IDIOM() == .phone
}

func deviceIsiPad() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .pad
}

func deviceSafeAreaInsets() -> UIEdgeInsets {
    var insets: UIEdgeInsets = .zero
    
    if #available(iOS 11, *) {
        insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
    
    return insets
}

func getSpringAnimation() -> CAKeyframeAnimation {
    let animate = CAKeyframeAnimation(keyPath: "transform")
    animate.duration = 0.3
    animate.isRemovedOnCompletion = true
    animate.fillMode = .forwards
    
    animate.values = [CATransform3DMakeScale(0.7, 0.7, 1),
                      CATransform3DMakeScale(1.2, 1.2, 1),
                      CATransform3DMakeScale(0.8, 0.8, 1),
                      CATransform3DMakeScale(1, 1, 1)]
    return animate
}

func showAlertView(_ message: String, _ sender: UIViewController?) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: localLanguageTextValue(.ok), style: .default, handler: nil)
    alert.addAction(action)
    if deviceIsiPad() {
        alert.popoverPresentationController?.sourceView = sender?.view
    }
    (sender ?? UIApplication.shared.keyWindow?.rootViewController)?.showDetailViewController(alert, sender: nil)
}

func canAddModel(_ model: ZLPhotoModel, currentSelectCount: Int, sender: UIViewController?, showAlert: Bool = true) -> Bool {
    if currentSelectCount >= ZLPhotoConfiguration.default().maxSelectCount {
        if showAlert {
            let message = String(format: localLanguageTextValue(.maxSelectCount), ZLPhotoConfiguration.default().maxSelectCount)
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
