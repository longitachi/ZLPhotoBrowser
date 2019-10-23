//
//  ZLEnlargeButton.h
//  ZLPhotoBrowser
//
//  Created by Samuel's on 2019/10/23.
//  Copyright © 2019 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLEnlargeButton : UIButton

@property (nonatomic, assign) UIEdgeInsets enlargeClickInset;
@property (nonatomic, assign) CGSize minClickArea;

@end

NS_ASSUME_NONNULL_END
