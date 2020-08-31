//
//  ZLImageNavController.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/18.
//

import UIKit
import Photos

class ZLImageNavController: UINavigationController {

    var isSelectedOriginal: Bool = false
    
    var arrSelectedModels: [ZLPhotoModel] = []
    
    var selectImageBlock: ( () -> Void )?
    
    var cancelBlock: ( () -> Void )?
    
    deinit {
        debugPrint("ZLImageNavController deinit")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ZLPhotoConfiguration.default().statusBarStyle
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.navigationBar.barStyle = .black
        self.navigationBar.isTranslucent = true
        self.modalPresentationStyle = .fullScreen
        
        let colorDeploy = ZLPhotoConfiguration.default().themeColorDeploy
        self.navigationBar.setBackgroundImage(self.image(color: colorDeploy.navBarColor), for: .default)
        self.navigationBar.tintColor = colorDeploy.navTitleColor
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colorDeploy.navTitleColor]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func image(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
