//
//  ZLWeakProxy.swift
//  ZLPhotoBrowser
//
//  Created by long on 2021/3/10.
//

import UIKit

class ZLWeakProxy: NSObject {

    private weak var target: NSObjectProtocol?
    
    init(target: NSObjectProtocol) {
        self.target = target
        super.init()
    }
    
    class func proxy(withTarget target: NSObjectProtocol) -> ZLWeakProxy {
        return ZLWeakProxy.init(target: target)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return target?.responds(to: aSelector) ?? false
    }
    
}
