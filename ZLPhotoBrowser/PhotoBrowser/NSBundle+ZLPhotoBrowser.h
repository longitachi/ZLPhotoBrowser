//
//  NSBundle+ZLPhotoBrowser.h
//  ZLPhotoBrowser
//
//  Created by long on 16/10/20.
//  Copyright © 2016年 long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (ZLPhotoBrowser)

+ (instancetype)zlPhotoBrowserBundle;

+ (void)resetLanguage;

+ (NSString *)zlLocalizedStringForKey:(NSString *)key;

+ (NSString *)zlLocalizedStringForKey:(NSString *)key value:(NSString *)value;

@end
