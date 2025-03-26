//
//  ZLNoAuthTipsView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2025/3/13.
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

class ZLNoAuthTipsView: UIView {
    private enum Layout {
        static let titleFont = UIFont.zl.font(ofSize: 24, bold: true)
        static let descFont = UIFont.zl.font(ofSize: 17)
        static let btnFont = UIFont.zl.font(ofSize: 17, bold: true)
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = localLanguageTextValue(.noLibraryAuthTitleInThumbList)
        label.textColor = .zl.noLibraryAuthTitleAndDescColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = Layout.titleFont
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.text = localLanguageTextValue(.noLibraryAuthDescInThumbList)
            .replacingOccurrences(of: "%@", with: getAppName())
        label.textColor = .zl.noLibraryAuthTitleAndDescColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = Layout.descFont
        return label
    }()
    
    private lazy var gotoSettingControl: UIControl = {
        let control = UIControl()
        control.zl.setCornerRadius(6)
        control.backgroundColor = .zl.bottomToolViewBtnNormalBgColor
        control.addTarget(self, action: #selector(gotoSetting), for: .touchUpInside)
        return control
    }()
    
    private lazy var gotoSettingLabel: UILabel = {
        let label = UILabel()
        label.text = localLanguageTextValue(.gotoSystemSettingInThumbList)
        label.textColor = .zl.noLibraryAuthGotoSettingBtnTitleColor
        label.font = Layout.btnFont
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *), deviceIsFringeScreen() {
            insets = safeAreaInsets
        }
        let totalLRInset = insets.left + insets.right
        
        let titleY = zl.height / 4.6
        let titleH = ceil(
            (titleLabel.text ?? "").zl.boundingRect(
                font: Layout.titleFont,
                limitSize: CGSize(width: zl.width - 40 - totalLRInset, height: .greatestFiniteMagnitude),
                lineBreakMode: .byWordWrapping
            ).height
        )
        titleLabel.frame = CGRect(x: 20 + totalLRInset / 2, y: titleY, width: zl.width - 40 - totalLRInset, height: titleH)
        
        let descY = titleLabel.zl.bottom + 18
        let descH = ceil(
            (descLabel.text ?? "").zl.boundingRect(
                font: Layout.descFont,
                limitSize: CGSize(width: zl.width - 40 - totalLRInset, height: .greatestFiniteMagnitude),
                lineBreakMode: .byWordWrapping
            ).height
        )
        descLabel.frame = CGRect(x: 20 + totalLRInset / 2, y: descY, width: zl.width - 40 - totalLRInset, height: descH)
        
        var controlSize = CGSize.zero
        let settingLabelSize = (gotoSettingLabel.text ?? "").zl.boundingRect(
            font: Layout.btnFont,
            limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            lineBreakMode: .byWordWrapping
        )
        
        let maxSettingLabelW: CGFloat = 250
        
        if settingLabelSize.width <= 170 {
            controlSize.width = 200
        } else if (171...maxSettingLabelW) ~= settingLabelSize.width {
            controlSize.width = settingLabelSize.width + 30
        } else {
            controlSize.width = 280
        }
        
        let settingLabelHeight = ceil(
            (gotoSettingLabel.text ?? "").zl.boundingRect(
                font: Layout.btnFont,
                limitSize: CGSize(width: min(settingLabelSize.width, maxSettingLabelW), height: CGFloat.greatestFiniteMagnitude),
                lineBreakMode: .byWordWrapping
            ).height
        )
        
        if settingLabelHeight > ceil(Layout.btnFont.lineHeight) {
            controlSize.height = max(settingLabelHeight + 30, 50)
        } else {
            controlSize.height = 50
        }
        
        gotoSettingControl.frame = CGRect(
            x: zl.centerX - controlSize.width / 2,
            y: zl.height - controlSize.height - 40,
            width: controlSize.width,
            height: controlSize.height
        )
        
        gotoSettingLabel.frame = CGRect(
            x: (controlSize.width - min(maxSettingLabelW, settingLabelSize.width)) / 2,
            y: 0,
            width: min(maxSettingLabelW, settingLabelSize.width),
            height: controlSize.height
        )
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(gotoSettingControl)
        gotoSettingControl.addSubview(gotoSettingLabel)
    }
    
    @objc private func gotoSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
