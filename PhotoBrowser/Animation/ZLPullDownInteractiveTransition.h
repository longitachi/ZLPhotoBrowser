//
//  ZLPullDownInteractiveTransition.h
//  ZLPhotoBrowser
//
//  Created by long on 2018/11/29.
//  Copyright © 2018年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZLDismissType) {
    ZLDismissTypeDismiss,
    ZLDismissTypePop,
};

@interface ZLPullDownInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, assign) BOOL interactive;

- (instancetype)initWithViewController:(UIViewController *)vc type:(ZLDismissType)type;

@end

NS_ASSUME_NONNULL_END
