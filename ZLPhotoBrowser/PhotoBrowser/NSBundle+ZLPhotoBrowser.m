//
//  NSBundle+ZLPhotoBrowser.m
//  ZLPhotoBrowser
//
//  Created by long on 16/10/20.
//  Copyright © 2016年 long. All rights reserved.
//

#import "NSBundle+ZLPhotoBrowser.h"
#import "ZLPhotoActionSheet.h"
#import "ZLDefine.h"

@implementation NSBundle (ZLPhotoBrowser)

+ (instancetype)zlPhotoBrowserBundle
{
    static NSBundle *photoBrowserBundle = nil;
    if (photoBrowserBundle == nil) {
        photoBrowserBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ZLPhotoActionSheet class]] pathForResource:@"ZLPhotoBrowser" ofType:@"bundle"]];
    }
    return photoBrowserBundle;
}

static NSBundle *bundle = nil;
+ (void)resetLanguage
{
    bundle = nil;
}

+ (NSString *)zlLocalizedStringForKey:(NSString *)key
{
    return [self zlLocalizedStringForKey:key value:nil];
}

+ (NSString *)zlLocalizedStringForKey:(NSString *)key value:(NSString *)value
{
    if (bundle == nil) {
        // 从bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle zlPhotoBrowserBundle] pathForResource:[self getLanguage] ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

+ (NSString *)getLanguage
{
    ZLLanguageType type = [[[NSUserDefaults standardUserDefaults] valueForKey:ZLLanguageTypeKey] integerValue];
    
    NSString *language = nil;
    switch (type) {
        case ZLLanguageSystem: {
            language = [NSLocale preferredLanguages].firstObject;
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
        }
            break;
        case ZLLanguageChineseSimplified:
            language = @"zh-Hans";
            break;
        case ZLLanguageChineseTraditional:
            language = @"zh-Hant";
            break;
        case ZLLanguageEnglish:
            language = @"en";
            break;
        case ZLLanguageJapanese:
            language = @"ja-US";
            break;
    }
    return language;
}

@end
