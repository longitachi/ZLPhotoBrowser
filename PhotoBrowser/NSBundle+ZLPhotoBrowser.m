//
//  NSBundle+ZLPhotoBrowser.m
//  ZLPhotoBrowser
//
//  Created by long on 16/10/20.
//  Copyright © 2016年 long. All rights reserved.
//

#import "NSBundle+ZLPhotoBrowser.h"
#import "ZLPhotoActionSheet.h"

@implementation NSBundle (ZLPhotoBrowser)

+ (instancetype)zlPhotoBrowserBundle
{
    static NSBundle *refreshBundle = nil;
    if (refreshBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        refreshBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ZLPhotoActionSheet class]] pathForResource:@"ZLPhotoBrowser" ofType:@"bundle"]];
    }
    return refreshBundle;
}

+ (NSString *)zlLocalizedStringForKey:(NSString *)key
{
    return [self zlLocalizedStringForKey:key value:nil];
}

+ (NSString *)zlLocalizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans"; // 简体中文
            } else { // zh-Hant\zh-HK\zh-TW
                language = @"zh-Hant"; // 繁體中文
            }
        } else if ([language hasPrefix:@"ja"]) {
            language = @"ja-US";
        } else {
            language = @"en";
        }
        
        // 从MJRefresh.bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle zlPhotoBrowserBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
