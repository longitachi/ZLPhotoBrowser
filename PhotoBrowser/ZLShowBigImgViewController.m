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
#import "ZLDefine.h"
#import "ZLSelectPhotoModel.h"
#import "ZLPhotoTool.h"
#import "ToastUtils.h"

@interface ZLShowBigImgViewController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    
    NSMutableArray<PHAsset *> *_arrayDataSources;
    UIButton *_navRightBtn;
    
    //底部view
    UIView   *_bottomView;
    UIButton *_btnOriginalPhoto;
    UIButton *_btnDone;
    
    //双击的scrollView
    UIScrollView *_selectScrollView;
    NSInteger _currentPage;
}

@property (nonatomic, strong) UILabel *labPhotosBytes;

@end

@implementation ZLShowBigImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initNavBtns];
    [self sortAsset];
    [self initCollectionView];
    [self initBottomView];
    [self changeBtnDoneTitle];
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
    UIImage *navBackImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"navBackBtn.png")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"navBackBtn.png")];
                           
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    //right nav btn
    _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navRightBtn.frame = CGRectMake(0, 0, 25, 25);
    UIImage *normalImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"btn_circle.png")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"btn_circle.png")];
    UIImage *selImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"btn_selected.png")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"btn_selected.png")];
    [_navRightBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_navRightBtn setBackgroundImage:selImg forState:UIControlStateSelected];
    [_navRightBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navRightBtn];
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
    [_collectionView registerClass:[ZLBigImageCell class] forCellWithReuseIdentifier:@"ZLBigImageCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [self.view addSubview:_collectionView];
}

- (void)initBottomView
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, kViewWidth, 44)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    _btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnOriginalPhoto.frame = CGRectMake(12, 7, 60, 30);
    [_btnOriginalPhoto setTitle:@"原图" forState:UIControlStateNormal];
    _btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnOriginalPhoto setTitleColor:kRGB(80, 180, 234) forState: UIControlStateNormal];
    [_btnOriginalPhoto setTitleColor:kRGB(80, 180, 234) forState: UIControlStateSelected];
    UIImage *normalImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"btn_original_circle.png")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"btn_original_circle.png")];
    UIImage *selImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"btn_selected.png")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"btn_selected.png")];
    [_btnOriginalPhoto setImage:normalImg forState:UIControlStateNormal];
    [_btnOriginalPhoto setImage:selImg forState:UIControlStateSelected];
    [_btnOriginalPhoto setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [_btnOriginalPhoto addTarget:self action:@selector(btnOriginalImage_Click:) forControlEvents:UIControlEventTouchUpInside];
    _btnOriginalPhoto.selected = self.isSelectOriginalPhoto;
    if (self.arraySelectPhotos.count > 0) {
        [self getPhotosBytes];
    }
    [_bottomView addSubview:_btnOriginalPhoto];
    
    self.labPhotosBytes = [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 80, 30)];
    self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
    self.labPhotosBytes.textColor = kRGB(80, 180, 234);
    [_bottomView addSubview:self.labPhotosBytes];
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDone.frame = CGRectMake(kViewWidth - 82, 7, 70, 30);
    [_btnDone setTitle:@"确定" forState:UIControlStateNormal];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    _btnDone.layer.masksToBounds = YES;
    _btnDone.layer.cornerRadius = 3.0f;
    [_btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDone setBackgroundColor:kRGB(80, 180, 234)];
    [_btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_btnDone];
    
    [self.view addSubview:_bottomView];
}

#pragma mark - UIButton Actions
- (void)btnOriginalImage_Click:(UIButton *)btn
{
    self.isSelectOriginalPhoto = btn.selected = !btn.selected;
    if (btn.selected) {
        if (![self isHaveCurrentPageImage]) {
            [self navRightBtn_Click:_navRightBtn];
        } else {
            [self getPhotosBytes];
        }
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)btnDone_Click:(UIButton *)btn
{
    if (self.arraySelectPhotos.count == 0) {
        PHAsset *asset = _arrayDataSources[_currentPage-1];
        if (![[ZLPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"图片加载中，请稍后");
            return;
        }
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    }
    if (self.btnDoneBlock) {
        self.btnDoneBlock(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
}

- (void)btnBack_Click
{
    if (self.onSelectedPhotos) {
        self.onSelectedPhotos(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
    
    if (self.isPresent) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        //由于collectionView的frame的width是大于该界面的width，所以设置这个颜色是为了pop时候隐藏collectionView的黑色背景
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)navRightBtn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        [self getPhotosBytes];
        ShowToastLong(@"最多只能选择%ld张图片", self.maxSelectCount);
        return;
    }
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    if (![self isHaveCurrentPageImage]) {
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        
        if (![[ZLPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"图片加载中，请稍后");
            return;
        }
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    } else {
        [self removeCurrentPageImage];
    }
    
    btn.selected = !btn.selected;
    [self getPhotosBytes];
    [self changeBtnDoneTitle];
}

- (BOOL)isHaveCurrentPageImage
{
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeCurrentPageImage
{
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            [_arraySelectPhotos removeObject:model];
            break;
        }
    }
}

#pragma mark - 更新按钮、导航条等显示状态
- (void)changeNavRightBtnStatus
{
    if ([self isHaveCurrentPageImage]) {
        _navRightBtn.selected = YES;
    } else {
        _navRightBtn.selected = NO;
    }
}

- (void)changeBtnDoneTitle
{
    if (self.arraySelectPhotos.count > 0) {
        [_btnDone setTitle:[NSString stringWithFormat:@"确定(%ld)", self.arraySelectPhotos.count] forState:UIControlStateNormal];
    } else {
        [_btnDone setTitle:@"确定" forState:UIControlStateNormal];
    }
}

- (void)getPhotosBytes
{
    if (!self.isSelectOriginalPhoto) return;
    
    if (self.arraySelectPhotos.count > 0) {
        weakify(self);
        [[ZLPhotoTool sharePhotoTool] getPhotosBytesWithArray:self.arraySelectPhotos completion:^(NSString *photosBytes) {
            strongify(weakSelf);
            strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
        }];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)showNavBarAndBottomView
{
    self.navigationController.navigationBar.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    _bottomView.hidden = NO;
}

- (void)hideNavBarAndBottomView
{
    self.navigationController.navigationBar.hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
    _bottomView.hidden = YES;
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
        //当前页
        _currentPage = _arrayDataSources.count-self.selectIndex;
    } else {
        [_arrayDataSources addObjectsFromArray:self.assets];
        _currentPage = self.selectIndex + 1;
    }
    self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _arrayDataSources.count];
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
    
    cell.asset = asset;
    weakify(self);
    cell.singleTapCallBack = ^() {
        strongify(weakSelf);
        if (strongSelf.navigationController.navigationBar.isHidden) {
            [strongSelf showNavBarAndBottomView];
        } else {
            [strongSelf hideNavBarAndBottomView];
        }
    };
    
    return cell;
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

@end
