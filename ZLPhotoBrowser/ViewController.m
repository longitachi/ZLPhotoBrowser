//
//  ViewController.m
//  ZLPhotoBrowser
//
//  Created by long on 15/12/1.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ViewController.h"
#import "ZLPhotoActionSheet.h"
#import "ZLShowBigImage.h"

///////////////////////////////////////////////////
// git 地址： https://github.com/longitachi/ZLPhotoBrowser
// 喜欢的朋友请去给个star，莫大的支持，谢谢
///////////////////////////////////////////////////
@interface ViewController ()
{
    ZLPhotoActionSheet *actionSheet;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 5;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 20;
}

- (IBAction)btnSelectPhoto_Click:(id)sender
{
    __weak typeof(self) weakSelf = self;
    
    [actionSheet showWithSender:self animate:YES completion:^(NSArray<UIImage *> * _Nonnull selectPhotos) {
        [weakSelf.baseView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width/4-2;
        for (int i = 0; i < selectPhotos.count; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i%4*(width+2), i/4*(width+2), width, width)];
            imgView.image = selectPhotos[i];
            [weakSelf.baseView addSubview:imgView];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    for (UIView *view in self.baseView.subviews) {
        CGRect convertRect = [self.baseView convertRect:view.frame toView:self.view];
        if ([view isKindOfClass:[UIImageView class]] &&
            CGRectContainsPoint(convertRect, point)) {
            [ZLShowBigImage showBigImage:(UIImageView *)view];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
