//
//  ZLThumbnailViewController.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLThumbnailViewController.h"
#import <Photos/Photos.h>
#import "ZLDefine.h"
#import "ZLCollectionCell.h"
#import "ZLPhotoManager.h"
#import "ZLPhotoModel.h"
#import "ZLShowBigImgViewController.h"
#import "ZLPhotoBrowser.h"
#import "ToastUtils.h"
#import "ZLProgressHUD.h"
#import "ZLForceTouchPreviewController.h"
#import "ZLEditViewController.h"
#import "ZLEditVideoController.h"

typedef NS_ENUM(NSUInteger, SlideSelectType) {
    SlideSelectTypeNone,
    SlideSelectTypeSelect,
    SlideSelectTypeCancel,
};

@interface ZLThumbnailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerPreviewingDelegate>
{
    BOOL _isLayoutOK;
    
    //设备旋转前的第一个可视indexPath
    NSIndexPath *_visibleIndexPath;
    //是否切换横竖屏
    BOOL _switchOrientation;
    
    //开始滑动选择 或 取消
    BOOL _beginSelect;
    /**
     滑动选择 或 取消
     当初始滑动的cell处于未选择状态，则开始选择，反之，则开始取消选择
     */
    SlideSelectType _selectType;
    /**开始滑动的indexPath*/
    NSIndexPath *_beginSlideIndexPath;
    /**最后滑动经过的index，开始的indexPath不计入，优化拖动手势计算，避免单个cell中冗余计算多次*/
    NSInteger _lastSlideIndex;
}

@property (nonatomic, strong) NSMutableArray<ZLPhotoModel *> *arrDataSources;
@property (nonatomic, assign) BOOL allowTakePhoto;
/**所有滑动经过的indexPath*/
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *arrSlideIndexPath;
/**所有滑动经过的indexPath的初始选择状态*/
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dicOriSelectStatus;
@end

@implementation ZLThumbnailViewController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray<ZLPhotoModel *> *)arrDataSources
{
    if (!_arrDataSources) {
        ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
        [hud show];
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        if (!_albumListModel) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                zl_weakify(self);
                [ZLPhotoManager getCameraRollAlbumList:nav.allowSelectVideo allowSelectImage:nav.allowSelectImage complete:^(ZLAlbumListModel *album) {
                    zl_strongify(weakSelf);
                    ZLImageNavigationController *weakNav = (ZLImageNavigationController *)strongSelf.navigationController;
                    
                    strongSelf.albumListModel = album;
                    [ZLPhotoManager markSelcectModelInArr:strongSelf.albumListModel.models selArr:weakNav.arrSelectedModels];
                    strongSelf.arrDataSources = [NSMutableArray arrayWithArray:strongSelf.albumListModel.models];
                    [hud hide];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakNav.allowTakePhotoInLibrary && weakNav.allowSelectImage) {
                            strongSelf.allowTakePhoto = YES;
                        }
                        strongSelf.title = album.title;
                        [strongSelf.collectionView reloadData];
                        [strongSelf scrollToBottom];
                    });
                }];
            });
        } else {
            if (nav.allowTakePhotoInLibrary && nav.allowSelectImage && self.albumListModel.isCameraRoll) {
                self.allowTakePhoto = YES;
            }
            [ZLPhotoManager markSelcectModelInArr:self.albumListModel.models selArr:nav.arrSelectedModels];
            _arrDataSources = [NSMutableArray arrayWithArray:self.albumListModel.models];
            [hud hide];
        }
    }
    return _arrDataSources;
}

- (NSMutableArray<NSIndexPath *> *)arrSlideIndexPath
{
    if (!_arrSlideIndexPath) {
        _arrSlideIndexPath = [NSMutableArray array];
    }
    return _arrSlideIndexPath;
}

- (NSMutableDictionary<NSString *, NSNumber *> *)dicOriSelectStatus
{
    if (!_dicOriSelectStatus) {
        _dicOriSelectStatus = [NSMutableDictionary dictionary];
    }
    return _dicOriSelectStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.albumListModel.title;
    
    [self initNavBtn];
    [self setupCollectionView];
    [self setupBottomView];
    
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    if (nav.allowSlideSelect) {
        //添加滑动选择手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self.view addGestureRecognizer:pan];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self resetBottomBtnsStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isLayoutOK = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    
    CGFloat bottomViewH = 44;
    CGFloat bottomBtnH = 30;
    
    CGFloat width = kViewWidth-inset.left-inset.right;
    self.collectionView.frame = CGRectMake(inset.left, 0, width, kViewHeight-inset.bottom-bottomViewH);
    
    self.bottomView.frame = CGRectMake(inset.left, kViewHeight-bottomViewH-inset.bottom, width, bottomViewH+inset.bottom);
    self.bline.frame = CGRectMake(0, 0, width, 1/[UIScreen mainScreen].scale);
    
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    CGFloat offsetX = 12;
    if (nav.allowEditImage || nav.allowEditVideo) {
        self.btnEdit.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserEditText), 15, YES, bottomBtnH), bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnEdit.frame) + 10;
    }
    self.btnPreView.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserPreviewText), 15, YES, bottomBtnH), bottomBtnH);
    offsetX = CGRectGetMaxX(self.btnPreView.frame) + 10;
    
    self.btnOriginalPhoto.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText), 15, YES, bottomBtnH)+self.btnOriginalPhoto.imageView.frame.size.width, bottomBtnH);
    offsetX = CGRectGetMaxX(self.btnOriginalPhoto.frame) + 5;
    
    self.labPhotosBytes.frame = CGRectMake(offsetX, 7, 60, bottomBtnH);
    
    CGFloat doneWidth = GetMatchValue(self.btnDone.currentTitle, 15, YES, bottomBtnH);
    doneWidth = MAX(70, doneWidth);
    self.btnDone.frame = CGRectMake(width-doneWidth-12, 7, doneWidth, bottomBtnH);
    
    if (!_isLayoutOK && self.albumListModel) {
        [self scrollToBottom];
    } else if (_switchOrientation) {
        _switchOrientation = NO;
        [self.collectionView scrollToItemAtIndexPath:_visibleIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

#pragma mark - 设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    CGPoint pInView = [self.view convertPoint:CGPointMake(0, 70) toView:self.collectionView];
    _visibleIndexPath = [self.collectionView indexPathForItemAtPoint:pInView];
    _switchOrientation = YES;
}

- (BOOL)forceTouchAvailable
{
    if (@available(iOS 9.0, *)) {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    } else {
        return NO;
    }
}

- (void)scrollToBottom
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (!nav.sortAscending) {
        return;
    }
    if (self.arrDataSources.count > 0) {
        NSInteger index = self.arrDataSources.count-1;
        if (self.allowTakePhoto) {
            index += 1;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)resetBottomBtnsStatus
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.arrSelectedModels.count > 0) {
        self.btnOriginalPhoto.enabled = YES;
        self.btnPreView.enabled = YES;
        self.btnDone.enabled = YES;
        if (nav.isSelectOriginalPhoto) {
            [self getOriginalImageBytes];
        } else {
            self.labPhotosBytes.text = nil;
        }
        self.btnOriginalPhoto.selected = nav.isSelectOriginalPhoto;
        [self.btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), nav.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:nav.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:nav.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        self.btnDone.backgroundColor = nav.bottomBtnsNormalTitleColor;
        [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.btnOriginalPhoto.selected = NO;
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        self.labPhotosBytes.text = nil;
        [self.btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateDisabled];
        [self.btnOriginalPhoto setTitleColor:nav.bottomBtnsDisableBgColor forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:nav.bottomBtnsDisableBgColor forState:UIControlStateDisabled];
        self.btnDone.backgroundColor = nav.bottomBtnsDisableBgColor;
        [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    }
    
    BOOL canEdit = NO;
    if (nav.arrSelectedModels.count == 1) {
        ZLPhotoModel *m = nav.arrSelectedModels.firstObject;
        canEdit = (nav.allowEditImage && ((m.type == ZLAssetMediaTypeImage) ||
        (m.type == ZLAssetMediaTypeGif && !nav.allowSelectGif) ||
        (m.type == ZLAssetMediaTypeLivePhoto && !nav.allowSelectLivePhoto))) ||
        (nav.allowEditVideo && m.type == ZLAssetMediaTypeVideo && round(m.asset.duration) >= nav.maxEditVideoTime);
    }
    [self.btnEdit setTitleColor:canEdit?nav.bottomBtnsNormalTitleColor:nav.bottomBtnsDisableBgColor forState:UIControlStateNormal];
    self.btnEdit.userInteractionEnabled = canEdit;
}

#pragma mark - ui
- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat width = MIN(kViewWidth, kViewHeight);
    
    NSInteger columnCount;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        columnCount = 6;
    } else {
        columnCount = 4;
    }
    
    layout.itemSize = CGSizeMake((width-1.5*columnCount)/columnCount, (width-1.5*columnCount)/columnCount);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:NSClassFromString(@"ZLTakePhotoCell") forCellWithReuseIdentifier:@"ZLTakePhotoCell"];
    [self.collectionView registerClass:NSClassFromString(@"ZLCollectionCell") forCellWithReuseIdentifier:@"ZLCollectionCell"];
    //注册3d touch
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.allowForceTouch && [self forceTouchAvailable]) {
        [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
    }
}

- (void)setupBottomView
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = nav.bottomViewBgColor;
    [self.view addSubview:self.bottomView];
    
    self.bline = [[UIView alloc] init];
    self.bline.backgroundColor = kRGB(232, 232, 232);
    [self.bottomView addSubview:self.bline];
    
    if (nav.allowEditImage || nav.allowEditVideo) {
        self.btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnEdit.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnEdit setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserEditText) forState:UIControlStateNormal];
        [self.btnEdit addTarget:self action:@selector(btnEdit_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.btnEdit];
    }
    
    self.btnPreView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnPreView.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnPreView setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserPreviewText) forState:UIControlStateNormal];
    [self.btnPreView addTarget:self action:@selector(btnPreview_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnPreView];
    
    self.btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnOriginalPhoto setImage:GetImageWithName(@"btn_original_circle") forState:UIControlStateNormal];
    [self.btnOriginalPhoto setImage:GetImageWithName(@"btn_selected") forState:UIControlStateSelected];
    [self.btnOriginalPhoto setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText) forState:UIControlStateNormal];
    [self.btnOriginalPhoto addTarget:self action:@selector(btnOriginalPhoto_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnOriginalPhoto];
    
    self.labPhotosBytes = [[UILabel alloc] init];
    self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
    self.labPhotosBytes.textColor = nav.bottomBtnsNormalTitleColor;
    [self.bottomView addSubview:self.labPhotosBytes];
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    [self.btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnDone];
}

- (void)initNavBtn
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:nav.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - UIButton Action
- (void)btnEdit_Click:(id)sender {
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoModel *m = nav.arrSelectedModels.firstObject;
    
    if (m.type == ZLAssetMediaTypeVideo) {
        ZLEditVideoController *vc = [[ZLEditVideoController alloc] init];
        vc.model = m;
        [self.navigationController pushViewController:vc animated:NO];
    } else if (m.type == ZLAssetMediaTypeImage ||
               m.type == ZLAssetMediaTypeGif ||
               m.type == ZLAssetMediaTypeLivePhoto) {
        ZLEditViewController *vc = [[ZLEditViewController alloc] init];
        vc.model = m;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)btnPreview_Click:(id)sender
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    UIViewController *vc = [self getBigImageVCWithData:nav.arrSelectedModels index:nav.arrSelectedModels.count-1];
    [self.navigationController showViewController:vc sender:nil];
}

- (UIViewController *)getBigImageVCWithData:(NSArray<ZLPhotoModel *> *)data index:(NSInteger)index
{
    ZLShowBigImgViewController *vc = [[ZLShowBigImgViewController alloc] init];
    vc.models = data.copy;
    vc.selectIndex = index;
    zl_weakify(self);
    [vc setBtnBackBlock:^(NSArray<ZLPhotoModel *> *selectedModels, BOOL isOriginal) {
        zl_strongify(weakSelf);
        [ZLPhotoManager markSelcectModelInArr:strongSelf.arrDataSources selArr:selectedModels];
        [strongSelf.collectionView reloadData];
    }];
    return vc;
}

- (void)btnOriginalPhoto_Click:(id)sender
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    self.btnOriginalPhoto.selected = !self.btnOriginalPhoto.selected;
    nav.isSelectOriginalPhoto = self.btnOriginalPhoto.selected;
    if (nav.isSelectOriginalPhoto) {
        [self getOriginalImageBytes];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)btnDone_Click:(id)sender
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.callSelectImageBlock) {
        nav.callSelectImageBlock();
    }
}

- (void)navLeftBtn_Click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.cancelBlock) {
        nav.cancelBlock();
    }
    [nav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - pan action
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    BOOL asc = !self.allowTakePhoto || nav.sortAscending;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _beginSelect = !indexPath ? NO : ![cell isKindOfClass:ZLTakePhotoCell.class];
        
        if (_beginSelect) {
            NSInteger index = asc ? indexPath.row : indexPath.row-1;
            
            ZLPhotoModel *m = self.arrDataSources[index];
            _selectType = m.isSelected ? SlideSelectTypeCancel : SlideSelectTypeSelect;
            _beginSlideIndexPath = indexPath;
            
            if (!m.isSelected && [self canAddModel:m]) {
                if (nav.editAfterSelectThumbnailImage &&
                    nav.maxSelectCount == 1 &&
                    (nav.allowEditImage || nav.allowEditVideo)) {
                    [self shouldDirectEdit:m];
                    _selectType = SlideSelectTypeNone;
                    return;
                } else {
                    m.selected = YES;
                    [nav.arrSelectedModels addObject:m];
                }
            } else if (m.isSelected) {
                m.selected = NO;
                for (ZLPhotoModel *sm in nav.arrSelectedModels) {
                    if ([sm.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                        [nav.arrSelectedModels removeObject:sm];
                        break;
                    }
                }
            }
            ZLCollectionCell *c = (ZLCollectionCell *)cell;
            c.btnSelect.selected = m.isSelected;
            c.topView.hidden = nav.showSelectedMask ? !m.isSelected : YES;
            [self resetBottomBtnsStatus];
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (!_beginSelect ||
            !indexPath ||
            indexPath.row == _lastSlideIndex ||
            [cell isKindOfClass:ZLTakePhotoCell.class] ||
            _selectType == SlideSelectTypeNone) return;
        
        _lastSlideIndex = indexPath.row;
        
        NSInteger minIndex = MIN(indexPath.row, _beginSlideIndexPath.row);
        NSInteger maxIndex = MAX(indexPath.row, _beginSlideIndexPath.row);
        
        BOOL minIsBegin = minIndex == _beginSlideIndexPath.row;
        
        for (NSInteger i = _beginSlideIndexPath.row;
             minIsBegin ? i<=maxIndex: i>= minIndex;
             minIsBegin ? i++ : i--) {
            if (i == _beginSlideIndexPath.row) continue;
            NSIndexPath *p = [NSIndexPath indexPathForRow:i inSection:0];
            if (![self.arrSlideIndexPath containsObject:p]) {
                [self.arrSlideIndexPath addObject:p];
                NSInteger index = asc ? i : i-1;
                ZLPhotoModel *m = self.arrDataSources[index];
                [self.dicOriSelectStatus setValue:@(m.isSelected) forKey:@(p.row).stringValue];
            }
        }
        
        for (NSIndexPath *path in self.arrSlideIndexPath) {
            NSInteger index = asc ? path.row : path.row-1;
            
            //是否在最初和现在的间隔区间内
            BOOL inSection = path.row >= minIndex && path.row <= maxIndex;
            
            ZLPhotoModel *m = self.arrDataSources[index];
            switch (_selectType) {
                case SlideSelectTypeSelect: {
                    if (inSection &&
                        !m.isSelected &&
                        [self canAddModel:m]) m.selected = YES;
                }
                    break;
                case SlideSelectTypeCancel: {
                    if (inSection) m.selected = NO;
                }
                    break;
                default:
                    break;
            }
            
            if (!inSection) {
                //未在区间内的model还原为初始选择状态
                m.selected = [self.dicOriSelectStatus[@(path.row).stringValue] boolValue];
            }
            
            //判断当前model是否已存在于已选择数组中
            BOOL flag = NO;
            NSMutableArray *arrDel = [NSMutableArray array];
            for (ZLPhotoModel *sm in nav.arrSelectedModels) {
                if ([sm.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                    if (!m.isSelected) {
                        [arrDel addObject:sm];
                    }
                    flag = YES;
                    break;
                }
            }
            
            [nav.arrSelectedModels removeObjectsInArray:arrDel];
            
            if (!flag && m.isSelected) {
                [nav.arrSelectedModels addObject:m];
            }
            
            ZLCollectionCell *c = (ZLCollectionCell *)[self.collectionView cellForItemAtIndexPath:path];
            c.btnSelect.selected = m.isSelected;
            c.topView.hidden = nav.showSelectedMask ? !m.isSelected : YES;
            
            [self resetBottomBtnsStatus];
        }
    } else if (pan.state == UIGestureRecognizerStateEnded ||
               pan.state == UIGestureRecognizerStateCancelled) {
        //清空临时属性及数组
        _selectType = SlideSelectTypeNone;
        [self.arrSlideIndexPath removeAllObjects];
        [self.dicOriSelectStatus removeAllObjects];
    }
}

- (BOOL)canAddModel:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.arrSelectedModels.count >= nav.maxSelectCount) {
        ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxSelectCountText), nav.maxSelectCount);
        return NO;
    }
    if (nav.arrSelectedModels.count > 0) {
        ZLPhotoModel *sm = nav.arrSelectedModels.firstObject;
        if (!nav.allowMixSelect &&
            ((model.type < ZLAssetMediaTypeVideo && sm.type == ZLAssetMediaTypeVideo) || (model.type == ZLAssetMediaTypeVideo && sm.type < ZLAssetMediaTypeVideo))) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserCannotSelectVideo));
            return NO;
        }
    }
    if (![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
        ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowseriCloudPhotoText));
        return NO;
    }
    if (model.type == ZLAssetMediaTypeVideo && GetDuration(model.duration) > nav.maxVideoDuration) {
        ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxVideoDurationText), nav.maxVideoDuration);
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.allowTakePhoto) {
        return self.arrDataSources.count + 1;
    }
    return self.arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    if (self.allowTakePhoto && ((nav.sortAscending && indexPath.row >= self.arrDataSources.count) || (!nav.sortAscending && indexPath.row == 0))) {
        ZLTakePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLTakePhotoCell" forIndexPath:indexPath];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = nav.cellCornerRadio;
        if (nav.showCaptureImageOnTakePhotoBtn) {
            [cell startCapture];
        }
        return cell;
    }
    
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    
    ZLPhotoModel *model;
    if (!self.allowTakePhoto || nav.sortAscending) {
        model = self.arrDataSources[indexPath.row];
    } else {
        model = self.arrDataSources[indexPath.row-1];
    }

    zl_weakify(self);
    __weak typeof(cell) weakCell = cell;
    
    cell.selectedBlock = ^(BOOL selected) {
        zl_strongify(weakSelf);
        __strong typeof(weakCell) strongCell = weakCell;
        
        ZLImageNavigationController *weakNav = (ZLImageNavigationController *)strongSelf.navigationController;
        if (!selected) {
            //选中
            if ([strongSelf canAddModel:model]) {
                if (![strongSelf shouldDirectEdit:model]) {
                    model.selected = YES;
                    [weakNav.arrSelectedModels addObject:model];
                    strongCell.btnSelect.selected = YES;
                    [strongSelf shouldDirectEdit:model];
                }
            }
        } else {
            strongCell.btnSelect.selected = NO;
            model.selected = NO;
            for (ZLPhotoModel *m in weakNav.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [weakNav.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
        
        if (weakNav.showSelectedMask) {
            strongCell.topView.hidden = !model.isSelected;
        }
        [strongSelf resetBottomBtnsStatus];
    };
    
    cell.allSelectGif = nav.allowSelectGif;
    cell.allSelectLivePhoto = nav.allowSelectLivePhoto;
    cell.showSelectBtn = nav.showSelectBtn;
    cell.cornerRadio = nav.cellCornerRadio;
    cell.showMask = nav.showSelectedMask;
    cell.maskColor = nav.selectedMaskColor;
    cell.model = model;

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (self.allowTakePhoto && ((nav.sortAscending && indexPath.row >= self.arrDataSources.count) || (!nav.sortAscending && indexPath.row == 0))) {
        //拍照
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusRestricted ||
            status == AVAuthorizationStatusDenied) {
            NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoCameraAuthorityText), [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(ZLPhotoBrowserOKText) style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        [self takePhoto];
        return;
    }
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !nav.sortAscending) {
        index = indexPath.row - 1;
    }
    ZLPhotoModel *model = self.arrDataSources[index];
    
    if ([self shouldDirectEdit:model]) return;
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:nil];
    }
}

- (BOOL)shouldDirectEdit:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    //当前点击图片可编辑
    BOOL editImage = nav.editAfterSelectThumbnailImage && nav.allowEditImage && nav.maxSelectCount == 1 && (model.type == ZLAssetMediaTypeImage || model.type == ZLAssetMediaTypeGif || model.type == ZLAssetMediaTypeLivePhoto);
    //当前点击视频可编辑
    BOOL editVideo = nav.editAfterSelectThumbnailImage && nav.allowEditVideo && model.type == ZLAssetMediaTypeVideo && nav.maxSelectCount == 1 && round(model.asset.duration) >= nav.maxEditVideoTime;
    //当前为选择图片 或已经选择了一张并且点击的是已选择的图片
    BOOL flag = nav.arrSelectedModels.count == 0 || (nav.arrSelectedModels.count == 1 && [nav.arrSelectedModels.firstObject.asset.localIdentifier isEqualToString:model.asset.localIdentifier]);
    
    if (editImage && flag) {
        [nav.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    } else if (editVideo && flag) {
        [nav.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    }
    
    return nav.editAfterSelectThumbnailImage && nav.maxSelectCount == 1 && (nav.allowEditImage || nav.allowEditVideo);
}

/**
 获取对应的vc
 */
- (UIViewController *)getMatchVCWithModel:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    
    if (nav.arrSelectedModels.count > 0) {
        ZLPhotoModel *sm = nav.arrSelectedModels.firstObject;
        if (!nav.allowMixSelect &&
            ((model.type < ZLAssetMediaTypeVideo && sm.type == ZLAssetMediaTypeVideo) || (model.type == ZLAssetMediaTypeVideo && sm.type < ZLAssetMediaTypeVideo))) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserCannotSelectVideo));
            return nil;
        }
    }
    
    BOOL allowSelImage = !(model.type==ZLAssetMediaTypeVideo)?YES:nav.allowMixSelect;
    BOOL allowSelVideo = model.type==ZLAssetMediaTypeVideo?YES:nav.allowMixSelect;
    
    NSArray *arr = [ZLPhotoManager getPhotoInResult:self.albumListModel.result allowSelectVideo:allowSelVideo allowSelectImage:allowSelImage allowSelectGif:nav.allowSelectGif allowSelectLivePhoto:nav.allowSelectLivePhoto];
    
    NSMutableArray *selIdentifiers = [NSMutableArray array];
    for (ZLPhotoModel *m in nav.arrSelectedModels) {
        [selIdentifiers addObject:m.asset.localIdentifier];
    }
    
    int i = 0;
    BOOL isFind = NO;
    for (ZLPhotoModel *m in arr) {
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            isFind = YES;
        }
        if ([selIdentifiers containsObject:m.asset.localIdentifier]) {
            m.selected = YES;
        }
        if (!isFind) {
            i++;
        }
    }
    
    return [self getBigImageVCWithData:arr index:i];
}

- (void)takePhoto
{
    //拍照
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self showDetailViewController:picker sender:self];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    zl_weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        zl_strongify(weakSelf);
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
        [hud show];
        
        [ZLPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (suc) {
                    ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeImage duration:nil];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveImageErrorText));
                }
                [hud hide];
            });
        }];
    }];
}

- (void)handleDataArray:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    if (nav.sortAscending) {
        [self.arrDataSources addObject:model];
    } else {
        [self.arrDataSources insertObject:model atIndex:0];
    }
    if (nav.maxSelectCount > 1 && nav.arrSelectedModels.count < nav.maxSelectCount) {
        model.selected = YES;
        [nav.arrSelectedModels addObject:model];
        self.albumListModel = [ZLPhotoManager getCameraRollAlbumList:nav.allowSelectVideo allowSelectImage:nav.allowSelectImage];
    } else if (nav.maxSelectCount == 1 && !nav.arrSelectedModels.count) {
        model.selected = YES;
        [nav.arrSelectedModels addObject:model];
        [self btnDone_Click:nil];
        return;
    }
    [self.collectionView reloadData];
    [self scrollToBottom];
    [self resetBottomBtnsStatus];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)getOriginalImageBytes
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    zl_weakify(self);
    [ZLPhotoManager getPhotosBytesWithArray:nav.arrSelectedModels completion:^(NSString *photosBytes) {
        zl_strongify(weakSelf);
        strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
    }];
}

#pragma mark - UIViewControllerPreviewingDelegate
//!!!!: 3D Touch
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if (!indexPath) {
        return nil;
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZLTakePhotoCell class]]) {
        return nil;
    }
    
    //设置突出区域
    previewingContext.sourceRect = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    
    ZLForceTouchPreviewController *vc = [[ZLForceTouchPreviewController alloc] init];
    
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !nav.sortAscending) {
        index = indexPath.row - 1;
    }
    ZLPhotoModel *model = self.arrDataSources[index];
    vc.model = model;
    vc.allowSelectGif = nav.allowSelectGif;
    vc.allowSelectLivePhoto = nav.allowSelectLivePhoto;
    
    vc.preferredContentSize = [self getSize:model];
    
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    ZLPhotoModel *model = [(ZLForceTouchPreviewController *)viewControllerToCommit model];
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:self];
    }
}

- (CGSize)getSize:(ZLPhotoModel *)model
{
    CGFloat w = MIN(model.asset.pixelWidth, kViewWidth);
    CGFloat h = w * model.asset.pixelHeight / model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kViewHeight || isnan(h)) {
        h = kViewHeight;
        w = h * model.asset.pixelWidth / model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
}

@end
