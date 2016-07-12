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
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    __weak typeof(self) weakSelf = self;
    [controller presentViewController:self animated:YES completion:^{
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        }];
    }];
}

- (void)hide
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
         weakSelf.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
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
