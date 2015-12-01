//
//  ZLShowBigImgViewController.m
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLShowBigImgViewController.h"
#import <Photos/Photos.h>
#import "ZLBigImageCell.h"
#import "ZLAnimationTool.h"
#import "ZLDefine.h"
#import "ZLSelectPhotoModel.h"
#import "ZLPhotoTool.h"
#import "ToastUtils.h"

@interface ZLShowBigImgViewController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    
    NSMutableArray<PHAsset *> *_arrayDataSources;
    UIButton *_navRightBtn;
    //双击的scrollView
    UIScrollView *_selectScrollView;
    NSInteger _currentPage;
}
@end

@implementation ZLShowBigImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //当前页
    _currentPage = self.assets.count-self.selectIndex;
    self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, self.assets.count];
    
    [self initNavBtns];
    [self sortAsset];
    [self initCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.shouldReverseAssets) {
        [_collectionView setContentOffset:CGPointMake((self.assets.count-self.selectIndex-1)*(kViewWidth+kItemMargin), 0)];
    } else {
        [_collectionView setContentOffset:CGPointMake(self.selectIndex*(kViewWidth+kItemMargin), 0)];
    }
    
    [self changeNavRightBtnStatus];
}

- (void)initNavBtns
{
    //left nav btn
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navBackBtn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    //right nav btn
    _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navRightBtn.frame = CGRectMake(0, 0, 25, 25);
    [_navRightBtn setBackgroundImage:[UIImage imageNamed:@"btn_unselected.png"] forState:UIControlStateNormal];
    [_navRightBtn setBackgroundImage:[UIImage imageNamed:@"btn_selected.png"] forState:UIControlStateSelected];
    [_navRightBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navRightBtn];
}

#pragma mark - UIButton Actions
- (void)btnBack_Click
{
    if (self.onSelectedPhotos) {
        self.onSelectedPhotos(_arraySelectPhotos);
    }
    if (self.showPopAnimate) {
        [self.navigationController.view.layer addAnimation:[ZLAnimationTool animateWithType:kCATransitionMoveIn subType:kCATransitionFromBottom duration:0.3] forKey:nil];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)navRightBtn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount) {
        ShowToastLong(@"最多只能选择%ld张图片", self.maxSelectCount);
        return;
    }
    
    btn.selected = !btn.selected;
    if (![self isHaveCurrentPageImage]) {
        [btn.layer addAnimation:[ZLAnimationTool animateWithBtnStatusChanged] forKey:nil];
        
        PHAsset *asset = _arrayDataSources[_currentPage-1];
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        ZLBigImageCell *cell = (ZLBigImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
        model.image = cell.imageView.image;
        model.imageName = [asset valueForKey:@"filename"];
        [_arraySelectPhotos addObject:model];
    } else {
        [self removeCurrentPageImage];
    }
}

- (BOOL)isHaveCurrentPageImage
{
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.imageName isEqualToString:[asset valueForKey:@"filename"]]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeCurrentPageImage
{
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.imageName isEqualToString:[asset valueForKey:@"filename"]]) {
            [_arraySelectPhotos removeObject:model];
            break;
        }
    }
}

- (void)changeNavRightBtnStatus
{
    if ([self isHaveCurrentPageImage]) {
        _navRightBtn.selected = YES;
    } else {
        _navRightBtn.selected = NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.navigationController.isNavigationBarHidden) {
        [self showStatusBarAndNavBar];
    } else {
        [self hidStatusBarAndNavBar];
    }
}

- (void)sortAsset
{
    _arrayDataSources = [NSMutableArray array];
    if (self.shouldReverseAssets) {
        NSEnumerator *enumerator = [self.assets reverseObjectEnumerator];
        id obj;
        while (obj = [enumerator nextObject]) {
            [_arrayDataSources addObject:obj];
        }
    } else {
        [_arrayDataSources addObjectsFromArray:self.assets];
    }
}

#pragma mark - 初始化CollectionView
- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = kItemMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    layout.itemSize = self.view.bounds.size;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-kItemMargin/2, 0, kViewWidth+kItemMargin, kViewHeight) collectionViewLayout:layout];
    [_collectionView registerNib:[UINib nibWithNibName:@"ZLBigImageCell" bundle:nil] forCellWithReuseIdentifier:@"ZLBigImageCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [self.view addSubview:_collectionView];
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrayDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLBigImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLBigImageCell" forIndexPath:indexPath];
    PHAsset *asset = _arrayDataSources[indexPath.row];
    
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:asset size:PHImageManagerMaximumSize resizeMode:PHImageRequestOptionsResizeModeNone completion:^(UIImage *image) {
        cell.imageView.image = image;
    }];
    
    cell.scrollView.delegate = self;
    
    [self addDoubleTapOnScrollView:cell.scrollView];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLBigImageCell *cell1 = (ZLBigImageCell *)cell;
    cell1.scrollView.zoomScale = 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - 图片缩放相关方法
- (void)addDoubleTapOnScrollView:(UIScrollView *)scrollView
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [scrollView addGestureRecognizer:doubleTap];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap
{
    UIScrollView *scrollView = (UIScrollView *)tap.view;
    _selectScrollView = scrollView;
    CGFloat scale = 1;
    if (scrollView.zoomScale != 3.0) {
        scale = 3;
    } else {
        scale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:[tap locationInView:tap.view]];
    [scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == (UIScrollView *)_collectionView) {
        //改变导航标题
        CGFloat page = scrollView.contentOffset.x/(kViewWidth+kItemMargin);
        NSString *str = [NSString stringWithFormat:@"%.0f", page];
        _currentPage = str.integerValue + 1;
        self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _arrayDataSources.count];
        [self changeNavRightBtnStatus];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = _selectScrollView.frame.size.height / scale;
    zoomRect.size.width  = _selectScrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return scrollView.subviews[0];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    UIImageView *im = scrollView.subviews[0];
    NSLog(@"%f, %f\n%f, %f", im.frame.size.width, im.frame.size.height, im.image.size.width, im.image.size.height);
    NSLog(@"%@, %@, %@", NSStringFromCGRect(im.frame), NSStringFromCGSize(im.image.size), NSStringFromCGSize(scrollView.contentSize));
//    if (im.image.size.width > im.image.size.height) {
//        //根据imageView计算图片实际占有高度
//        CGFloat imgActualHeight = im.image.size.height*im.frame.size.width/im.image.size.width;
//        if (imgActualHeight < kViewHeight) {
//            [scrollView setContentSize:CGSizeMake(im.frame.size.width, kViewHeight)];
//            im.center = scrollView.center;
//        } else {
//            [scrollView setContentSize:CGSizeMake(im.frame.size.width, imgActualHeight)];
//        }
//    }
}

#pragma mark - 显示隐藏导航条状态栏
- (void)showStatusBarAndNavBar
{
    self.navigationController.navigationBar.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)hidStatusBarAndNavBar
{
    self.navigationController.navigationBar.hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

@end
