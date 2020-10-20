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
        }
    }
    
}

class LanguagePickerView: UIView {

    var cancelBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var pickerView: UIPickerView!
    
    var selectBlock: ( (ZLLanguageType) -> Void )?
    
    var selectedIndex = 0
    
    let languages: [ZLLanguageType] = [.system, .english, .chineseSimplified, .chineseTraditional, .japanese, .french, .german, .russian, .vietnamese, .korean, .malay, .italian]
    
    init(selectedLanguage: ZLLanguageType) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: -5)
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.5
        
        self.cancelBtn = UIButton(type: .custom)
        self.cancelBtn.backgroundColor = .black
        self.cancelBtn.setTitleColor(.white, for: .normal)
        self.cancelBtn.setTitle("Cancel", for: .normal)
        self.cancelBtn.layer.cornerRadius = 5
        self.cancelBtn.layer.masksToBounds = true
        self.cancelBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        self.addSubview(self.cancelBtn)
        self.cancelBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self).offset(20)
            make.size.equalTo(CGSize(width: 60, height: 35))
        }
        
        self.doneBtn = UIButton(type: .custom)
        self.doneBtn.backgroundColor = .black
        self.doneBtn.setTitleColor(.white, for: .normal)
        self.doneBtn.setTitle("Done", for: .normal)
        self.doneBtn.layer.cornerRadius = 5
        self.doneBtn.layer.masksToBounds = true
        self.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        self.addSubview(self.doneBtn)
        self.doneBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.size.equalTo(CGSize(width: 50, height: 35))
        }
        
        self.pickerView = UIPickerView()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.addSubview(self.pickerView)
        self.pickerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.cancelBtn.snp.bottom).offset(10)
            make.left.bottom.right.equalTo(self)
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
    
    @objc func cancelBtnClick() {
        self.removeFromSuperview()
    }
    
    @objc func doneBtnClick() {
        self.selectBlock?(languages[self.selectedIndex])
        self.removeFromSuperview()
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
