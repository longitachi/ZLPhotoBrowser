//
//  ZLNoAuthorityViewController.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLNoAuthorityViewController.h"
#import "ZLDefine.h"

@interface ZLNoAuthorityViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labPrompt;

@end

@implementation ZLNoAuthorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = GetLocalLanguageTextValue(ZLPhotoBrowserPhotoText);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoAblumAuthorityText), [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];
    
    self.labPrompt.text = message;
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)navRightBtn_Click
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)btnSetting_Click:(id)sender {
//    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//    if ([[UIApplication sharedApplication] canOpenURL:url]) {
//        //如果点击打开的话，需要记录当前的状态，从设置回到应用的时候会用到
//        [[UIApplication sharedApplication] openURL:url];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
