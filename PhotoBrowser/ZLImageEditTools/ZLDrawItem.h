//
//  ZLDrawItem.h
//  ZLPhotoBrowser
//
//  Created by long on 2018/5/9.
//  Copyright © 2018年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZLDrawItemColorType) {
    ZLDrawItemColorTypeWhite,
    ZLDrawItemColorTypeDarkGray,
    ZLDrawItemColorTypeRed,
    ZLDrawItemColorTypeYellow,
    ZLDrawItemColorTypeGreen,
    ZLDrawItemColorTypeBlue,
    ZLDrawItemColorTypePurple,
};

@interface ZLDrawItem : UIView

- (UIColor *)color;

- (instancetype)initWithFrame:(CGRect)frame
                    colorType:(ZLDrawItemColorType)colorType
                       target:(id)target
                       action:(SEL)action NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL selected;

@end
