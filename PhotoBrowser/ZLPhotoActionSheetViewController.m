//
//  ZLPhotoActionSheetViewController.m
//  ZLPhotoBrowser
//
//  Created by Yalin on 16/7/11.
//  Copyright © 2016年 long. All rights reserved.
//

#import "ZLPhotoActionSheetViewController.h"
#import "ZLPhotoActionSheet.h"

@interface ZLPhotoActionSheetViewController ()

@end

@implementation ZLPhotoActionSheetViewController

+ (instancetype)createWithActionSheetView:(ZLPhotoActionSheet *)actionSheetView
{
    ZLPhotoActionSheetViewController *controller = [self new];
    controller.view = actionSheetView;
    return controller;
}

- (void)showWithController:(UIViewController *)controller
{
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [controller presentViewController:self animated:YES completion:nil];
}

- (void)hide
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
