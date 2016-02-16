//
//  ZLDefine.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#ifndef ZLDefine_h
#define ZLDefine_h

#import "ZLProgressHUD.h"

#define kRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
//如果项目中设置了导航条为不透明，即[UINavigationBar appearance].translucent=NO，那么这里的kViewHeight需要-64
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

////////ZLPhotoActionSheet
#define kBaseViewHeight 300

////////ZLShowBigImgViewController
#define kItemMargin 30

#endif /* ZLDefine_h */
