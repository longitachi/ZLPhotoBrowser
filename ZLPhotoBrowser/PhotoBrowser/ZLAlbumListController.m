//
//  ZLPhotoBrowser.m
//  多选相册照片
//
//  Created by long on 15/11/27.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLAlbumListController.h"
#import "ZLPhotoBrowserCell.h"
#import "ZLPhotoManager.h"
#import "ZLPhotoModel.h"
#import "ZLThumbnailViewController.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation ZLImageNavigationController

- (void)dealloc
{
    [[SDWebImageManager sharedManager] cancelAll];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationBar.translucent = YES;
    }
    return self;
}

- (NSMutableArray<ZLPhotoModel *> *)arrSelectedModels
{
    if (!_arrSelectedModels) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}

- (void)setConfiguration:(ZLPhotoConfiguration *)configuration
{
    _configuration = configuration;
    
    [UIApplication sharedApplication].statusBarStyle = self.configuration.statusBarStyle;
    [self.navigationBar setBackgroundImage:[self imageWithColor:configuration.navBarColor] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTintColor:configuration.navTitleColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: configuration.navTitleColor}];
    [self.navigationBar setBackIndicatorImage:GetImageWithName(@"zl_navBack")];
    [self.navigationBar setBackIndicatorTransitionMaskImage:GetImageWithName(@"zl_navBack")];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarStyle = self.configuration.statusBarStyle;
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
    //    [self setNeedsStatusBarAppearanceUpdate];
}

//BOOL dismiss = NO;
//- (UIStatusBarStyle)previousStatusBarStyle
//{
//    if (!dismiss) {
//        return UIStatusBarStyleLightContent;
//    } else {
//        return self.previousStatusBarStyle;
//    }
//}

@end


@interface ZLAlbumListController ()

@property (nonatomic, strong) NSMutableArray<ZLAlbumListModel *> *arrayDataSources;

@property (nonatomic, strong) UIView *placeholderView;

@end

@implementation ZLAlbumListController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (UIView *)placeholderView
{
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
        imageView.image = GetImageWithName(@"zl_defaultphoto");
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.center = CGPointMake(kViewWidth/2, kViewHeight/2-90);
        [_placeholderView addSubview:imageView];
        
        UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kViewHeight/2-40, kViewWidth, 20)];
        placeholderLabel.text = GetLocalLanguageTextValue(ZLPhotoBrowserNoPhotoText);
        placeholderLabel.textAlignment = NSTextAlignmentCenter;
        placeholderLabel.textColor = [UIColor darkGrayColor];
        placeholderLabel.font = [UIFont systemFontOfSize:15];
        [_placeholderView addSubview:placeholderLabel];
        
        _placeholderView.hidden = YES;
        [self.view addSubview:_placeholderView];
    }
    return _placeholderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.title = GetLocalLanguageTextValue(ZLPhotoBrowserPhotoText);
    
    self.tableView.tableFooterView = [[UIView alloc] init];
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:GetLocalLanguageTextValue(ZLPhotoBrowserBackText) style:UIBarButtonItemStylePlain target:nil action:nil];
    [self initNavBtn];
    
    if (@available(iOS 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
        zl_weakify(self);
        [ZLPhotoManager getPhotoAblumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage complete:^(NSArray<ZLAlbumListModel *> *albums) {
            zl_strongify(weakSelf);
            strongSelf.arrayDataSources = [NSMutableArray arrayWithArray:albums];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }];
    });
}

- (void)initNavBtn
{
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:configuration.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)navRightBtn_Click
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.cancelBlock) {
        nav.cancelBlock();
    }
    [nav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrayDataSources.count == 0) {
        self.placeholderView.hidden = NO;
    } else {
        self.placeholderView.hidden = YES;
    }
    return self.arrayDataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLPhotoBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLPhotoBrowserCell"];
    
    if (!cell) {
        cell = [[kZLPhotoBrowserBundle loadNibNamed:@"ZLPhotoBrowserCell" owner:self options:nil] lastObject];
    }
    
    ZLAlbumListModel *albumModel = self.arrayDataSources[indexPath.row];
    
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    cell.cornerRadio = configuration.cellCornerRadio;
    
    cell.model = albumModel;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushThumbnailVCWithIndex:indexPath.row animated:YES];
}

- (void)pushThumbnailVCWithIndex:(NSInteger)index animated:(BOOL)animated
{
    ZLAlbumListModel *model = self.arrayDataSources[index];
    
    ZLThumbnailViewController *tvc = [[ZLThumbnailViewController alloc] init];
    tvc.albumListModel = model;
    
    [self.navigationController showViewController:tvc sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
