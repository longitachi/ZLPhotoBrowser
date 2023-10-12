//
//  LanguagePickerView.swift
//  Example
//
//  Created by long on 2020/10/20.
//

import UIKit
import ZLPhotoBrowser

extension ZLLanguageType {
    
    func toString() -> String {
        switch self {
        case .system:
            return "System"
        case .english:
            return "English"
        case .chineseSimplified:
            return "中文简体 (Chinese Simplified)"
        case .chineseTraditional:
            return "中文繁体 (Chinese Traditional)"
        case .japanese:
            return "日本語 (Japanese)"
        case .french:
            return "Français (French)"
        case .german:
            return "Deutsch (German)"
        case .russian:
            return "Pусский (Russian)"
        case .vietnamese:
            return "Tiếng Việt (Vietnamese)"
        case .korean:
            return "한국어 (Korean)"
        case .malay:
            return "Bahasa Melayu (Malay)"
        case .italian:
            return "Italiano (Italian)"
        case .indonesian:
            return "Bahasa Indonesia (Indonesian)"
        case .portuguese:
            return "Português (Portuguese)"
        case .spanish:
            return "Español (Spanish)"
        case .turkish:
            return "Türkçe (Turkish)"
        case .arabic:
            return "عربي (Arabic)"
        case .dutch:
            return "Nederlands (Dutch)"
        }
    }
    
}

class LanguagePickerView: UIView {
    
    var baseView: UIView!
    
    var doneBtn: UIButton!
    
    var pickerView: UIPickerView!
    
    var selectBlock: ( (ZLLanguageType) -> Void )?
    
    var selectedIndex = 0
    
    let languages = ZLLanguageType.allCases
    
    init(selectedLanguage: ZLLanguageType) {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.addGestureRecognizer(tap)
        
        self.baseView = UIView()
        self.baseView.backgroundColor = .white
        self.baseView.layer.shadowColor = UIColor.black.cgColor
        self.baseView.layer.shadowOffset = CGSize(width: 0, height: -3)
        self.baseView.layer.shadowRadius = 10
        self.baseView.layer.shadowOpacity = 0.4
        self.addSubview(self.baseView)
        self.baseView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(self)
        }
        
        self.doneBtn = UIButton(type: .custom)
        self.doneBtn.backgroundColor = .black
        self.doneBtn.setTitleColor(.white, for: .normal)
        self.doneBtn.setTitle("Done", for: .normal)
        self.doneBtn.layer.cornerRadius = 5
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        self.baseView.addSubview(self.doneBtn)
        self.doneBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.baseView).offset(10)
            make.right.equalTo(self.baseView).offset(-20)
            make.size.equalTo(CGSize(width: 50, height: 35))
        }
        
        self.pickerView = UIPickerView()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.baseView.addSubview(self.pickerView)
        self.pickerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.doneBtn.snp.bottom).offset(10)
            make.left.bottom.right.equalTo(self.baseView)
            make.height.equalTo(200)
        }
        
        if let index = languages.firstIndex(of: selectedLanguage) {
            self.selectedIndex = index
            self.pickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if self.baseView.frame.contains(tap.location(in: self)) {
            return
        }
        self.hide()
    }
    
    @objc func doneBtnClick() {
        self.selectBlock?(languages[self.selectedIndex])
        self.hide()
    }
    
    func show(in view: UIView) {
        view.addSubview(self)
        self.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { (_) in
            self.removeFromSuperview()
        }

    }

}


extension LanguagePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].toString()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedIndex = row
    }
    
}
