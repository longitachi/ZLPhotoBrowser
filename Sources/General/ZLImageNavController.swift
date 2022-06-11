//
//  ZLImageNavController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
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
import Photos

class ZLImageNavController: UINavigationController {
    
    var isSelectedOriginal: Bool = false
    
    var arrSelectedModels: [ZLPhotoModel] = []
    
    var selectImageBlock: (() -> Void)?
    
    var cancelBlock: (() -> Void)?
    
    deinit {
        zl_debugPrint("ZLImageNavController deinit")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ZLPhotoUIConfiguration.default().statusBarStyle
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = true
        modalPresentationStyle = .fullScreen
        isNavigationBarHidden = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
