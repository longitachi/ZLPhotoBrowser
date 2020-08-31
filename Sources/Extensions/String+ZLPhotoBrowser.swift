//
//  String+ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
//

import Foundation
import UIKit

extension String {
    
    func boundingRect(font: UIFont, limitSize: CGSize) -> CGSize {
        let att = [NSAttributedString.Key.font: font]

        let attContent = NSMutableAttributedString(string: self, attributes: att)
        
        let size = attContent.boundingRect(with: limitSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
}
