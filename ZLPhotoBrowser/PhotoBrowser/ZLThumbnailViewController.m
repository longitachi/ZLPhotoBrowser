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
#import "ZLAlbumListController.h"
#import "ToastUtils.h"
#import "ZLProgressHUD.h"
#import "ZLForceTouchPreviewController.h"
#import "ZLEditViewController.h"
#import "ZLEditVideoController.h"
#import "ZLCustomCamera.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZLInteractiveAnimateProtocol.h"

typedef NS_ENUM(NSUInteger, SlideSelectType) {
    SlideSelectTypeNone,
    SlideSelectTypeSelect,
    SlideSelectTypeCancel,
};

@interface ZLThumbnailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerPreviewingDelegate, ZLInteractiveAnimateProtocol>
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
    
    /**预览所选择图片，手势返回时候不调用scrollToIndex*/
    BOOL _isPreviewPush;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (NSMutableArray<ZLPhotoModel *> *)arrDataSources
{
    if (!_arrDataSources) {
        _arrDataSources = [NSMutableArray array];
        
        ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
        [hud show];
        
        ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
        ZLPhotoConfiguration *configuration = nav.configuration;
        
        if (!_albumListModel) {
            ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
            @zl_weakify(self);
            __weak typeof(nav) weakNav = nav;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [ZLPhotoManager getCameraRollAlbumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage complete:^(ZLAlbumListModel *album) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @zl_strongify(self);
                        __strong typeof(weakNav) strongNav  = weakNav;
                        
                        self.albumListModel = album;
                        [ZLPhotoManager markSelectModelInArr:self.albumListModel.models selArr:strongNav.arrSelectedModels];
                        [self.arrDataSources addObjectsFromArray:self.albumListModel.models];
                        
                        [hud hide];
                        if (configuration.allowTakePhotoInLibrary && (configuration.allowSelectImage || configuration.allowRecordVideo)) {
                            self.allowTakePhoto = YES;
                        }
                        self.title = album.title;
                        [self.collectionView reloadData];
                        [self scrollToBottom];
                    });
                }];
            });
        } else {
            if (configuration.allowTakePhotoInLibrary && (configuration.allowSelectImage || configuration.allowRecordVideo) && self.albumListModel.isCameraRoll) {
                self.allowTakePhoto = YES;
            }
            ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.albumListModel.models = [ZLPhotoManager getPhotoInResult:self.albumListModel.result allowSelectVideo:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage allowSelectGif:configuration.allowSelectGif allowSelectLivePhoto:configuration.allowSelectLivePhoto];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ZLPhotoManager markSelectModelInArr:self.albumListModel.models selArr:nav.arrSelectedModels];
                    [self.arrDataSources addObjectsFromArray:self.albumListModel.models];
                    
                    [hud hide];
                    if (configuration.allowTakePhotoInLibrary && (configuration.allowSelectImage || configuration.allowRecordVideo)) {
                        self.allowTakePhoto = YES;
                    }
                    [self.collectionView reloadData];
                    [self scrollToBottom];
                });
            });
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
    
    self.automaticallyAdjustsScrollViewInsets = true;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.albumListModel.title;
    
    [self initNavBtn];
    [self setupCollectionView];
    [self setupBottomView];
    
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    if (configuration.allowSlideSelect) {
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
    [self resetBottomBtnsStatus:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isLayoutOK = YES;
    _isPreviewPush = NO;
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    
    BOOL showBottomView = YES;
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    if (configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo)) {
        //点击后直接编辑则不需要下方工具条
        showBottomView = NO;
        inset.bottom = 0;
    }
    
    CGFloat bottomViewH = showBottomView ? 44 : 0;
    CGFloat bottomBtnH = 30;
    
    CGFloat width = kViewWidth-inset.left-inset.right;
    self.collectionView.frame = CGRectMake(inset.left, 0, width, kViewHeight-inset.bottom-bottomViewH);
    
    if (!showBottomView) return;
    
    self.bottomView.frame = CGRectMake(inset.left, kViewHeight-bottomViewH-inset.bottom, width, bottomViewH+inset.bottom);
    self.bline.frame = CGRectMake(0, 0, width, 1/[UIScreen mainScreen].scale);
    
    CGFloat offsetX = 12;
    if (configuration.allowEditImage || configuration.allowEditVideo) {
        self.btnEdit.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserEditText), 15, YES, bottomBtnH), bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnEdit.frame) + 10;
    }
    self.btnPreView.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserPreviewText), 15, YES, bottomBtnH), bottomBtnH);
    offsetX = CGRectGetMaxX(self.btnPreView.frame) + 10;
    
    if (configuration.allowSelectOriginal && configuration.allowSelectImage) {
        self.btnOriginalPhoto.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText), 15, YES, bottomBtnH)+25, bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnOriginalPhoto.frame) + 5;
        
        self.labPhotosBytes.frame = CGRectMake(offsetX, 7, 80, bottomBtnH);
    }
    
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
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    if (!configuration.sortAscending) {
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

- (void)resetBottomBtnsStatus:(BOOL)getBytes
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    if (nav.arrSelectedModels.count > 0) {
        self.btnOriginalPhoto.enabled = YES;
        self.btnPreView.enabled = YES;
        self.btnDone.enabled = YES;
        if (nav.isSelectOriginalPhoto) {
            if (getBytes) [self getOriginalImageBytes];
        } else {
            self.labPhotosBytes.text = nil;
        }
        self.btnOriginalPhoto.selected = nav.isSelectOriginalPhoto;
        [self.btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), nav.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnDone setTitleColor:configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        self.btnDone.backgroundColor = configuration.bottomBtnsNormalBgColor;
    } else {
        self.btnOriginalPhoto.selected = NO;
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        self.labPhotosBytes.text = nil;
        [self.btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateDisabled];
        [self.btnDone setTitleColor:configuration.bottomBtnsDisableTitleColor forState:UIControlStateDisabled];
        [self.btnOriginalPhoto setTitleColor:configuration.bottomBtnsDisableTitleColor forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:configuration.bottomBtnsDisableTitleColor forState:UIControlStateDisabled];
        self.btnDone.backgroundColor = configuration.bottomBtnsDisableBgColor;
    }
    
    BOOL canEdit = NO;
    if (nav.arrSelectedModels.count == 1) {
        ZLPhotoModel *m = nav.arrSelectedModels.firstObject;
        canEdit = (configuration.allowEditImage && ((m.type == ZLAssetMediaTypeImage) ||
        (m.type == ZLAssetMediaTypeGif && !configuration.allowSelectGif) ||
        (m.type == ZLAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto))) ||
        (configuration.allowEditVideo && m.type == ZLAssetMediaTypeVideo && round(m.asset.duration) >= configuration.maxEditVideoTime);
    }
    [self.btnEdit setTitleColor:canEdit?configuration.bottomBtnsNormalTitleColor:configuration.bottomBtnsDisableTitleColor forState:UIControlStateNormal];
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
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        [self.collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
    }
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:NSClassFromString(@"ZLTakePhotoCell") forCellWithReuseIdentifier:@"ZLTakePhotoCell"];
    [self.collectionView registerClass:NSClassFromString(@"ZLCollectionCell") forCellWithReuseIdentifier:@"ZLCollectionCell"];
    //注册3d touch
    if (@available(iOS 9.0, *)) {
        ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
        if (configuration.allowForceTouch && [self forceTouchAvailable]) {
            [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
        }
    }
}

- (void)setupBottomView
{
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    if (configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo)) {
        //点击后直接编辑则不需要下方工具条
        return;
    }
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = configuration.bottomViewBgColor;
    [self.view addSubview:self.bottomView];
    
    self.bline = [[UIView alloc] init];
    self.bline.backgroundColor = kRGB(232, 232, 232);
    [self.bottomView addSubview:self.bline];
    
    if (configuration.allowEditImage || configuration.allowEditVideo) {
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
    
    if (configuration.allowSelectOriginal) {
        self.btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnOriginalPhoto setImage:GetImageWithName(@"zl_btn_original_circle") forState:UIControlStateNormal];
        [self.btnOriginalPhoto setImage:GetImageWithName(@"zl_btn_original_selected") forState:UIControlStateSelected];
        [self.btnOriginalPhoto setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText) forState:UIControlStateNormal];
        [self.btnOriginalPhoto addTarget:self action:@selector(btnOriginalPhoto_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.btnOriginalPhoto];
        
        self.labPhotosBytes = [[UILabel alloc] init];
        self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
        self.labPhotosBytes.textColor = configuration.bottomBtnsNormalTitleColor;
        [self.bottomView addSubview:self.labPhotosBytes];
    }
    
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
    ZLPhotoConfiguration *configuration = nav.configuration;
    
//    nav.viewControllers.firstObject.navigationItem.backBarButtonItem.title = GetLocalLanguageTextValue(ZLPhotoBrowserBackText);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:GetImageWithName(@"zl_navBack") style:UIBarButtonItemStylePlain target:self action:@selector(navBackAction)];
    self.navigationItem.leftBarButtonItem = backItem;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:configuration.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - UIButton Action

- (void)navBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
    _isPreviewPush = YES;
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    UIViewController *vc = [self getBigImageVCWithData:nav.arrSelectedModels index:nav.arrSelectedModels.count-1];
    [self.navigationController showViewController:vc sender:nil];
}

- (UIViewController *)getBigImageVCWithData:(NSArray<ZLPhotoModel *> *)data index:(NSInteger)index
{
    ZLShowBigImgViewController *vc = [[ZLShowBigImgViewController alloc] init];
    vc.models = data.copy;
    vc.selectIndex = index;
    vc.isPush = YES;
    @zl_weakify(self);
    [vc setBtnBackBlock:^(NSArray<ZLPhotoModel *> *selectedModels, BOOL isOriginal) {
        @zl_strongify(self);
        [ZLPhotoManager markSelectModelInArr:self.arrDataSources selArr:selectedModels];
        [self.collectionView reloadData];
    }];
    return vc;
}

- (void)btnOriginalPhoto_Click:(id)sender
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    self.btnOriginalPhoto.selected = !self.btnOriginalPhoto.selected;
    nav.isSelectOriginalPhoto = self.btnOriginalPhoto.selected;
    self.labPhotosBytes.hidden = !nav.isSelectOriginalPhoto;
    self.labPhotosBytes.text = nil;
    if (nav.isSelectOriginalPhoto) {
        [self getOriginalImageBytes];
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
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    BOOL asc = !self.allowTakePhoto || configuration.sortAscending;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _beginSelect = !indexPath ? NO : ![cell isKindOfClass:ZLTakePhotoCell.class];
        
        if (_beginSelect) {
            NSInteger index = asc ? indexPath.row : indexPath.row-1;
            
            ZLPhotoModel *m = self.arrDataSources[index];
            _selectType = m.isSelected ? SlideSelectTypeCancel : SlideSelectTypeSelect;
            _beginSlideIndexPath = indexPath;
            
            if (!m.isSelected && [self canAddModel:m]) {
                if (configuration.editAfterSelectThumbnailImage &&
                    configuration.maxSelectCount == 1 &&
                    (configuration.allowEditImage || configuration.allowEditVideo)) {
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
            c.maskView.hidden = configuration.showSelectedMask ? !m.isSelected : YES;
            [self refreshCellIndex];
            [self refreshCellMaskView];
            [self resetBottomBtnsStatus:NO];
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
                        [self canAddModel:m]) {
                        m.selected = YES;
                    }
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
            c.maskView.hidden = configuration.showSelectedMask ? !m.isSelected : YES;
            [self refreshCellIndex];
            [self refreshCellMaskView];
            [self resetBottomBtnsStatus:NO];
        }
    } else if (pan.state == UIGestureRecognizerStateEnded ||
               pan.state == UIGestureRecognizerStateCancelled) {
        //清空临时属性及数组
        _selectType = SlideSelectTypeNone;
        [self.arrSlideIndexPath removeAllObjects];
        [self.dicOriSelectStatus removeAllObjects];
        [self resetBottomBtnsStatus:YES];
    }
}

- (BOOL)canAddModel:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration =nav.configuration;
    
    if (nav.arrSelectedModels.count >= configuration.maxSelectCount) {
        ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxSelectCountText), configuration.maxSelectCount);
        return NO;
    }
    if (nav.arrSelectedModels.count > 0) {
        if (configuration.mutuallyExclusiveSelectInMix &&
            model.type == ZLAssetMediaTypeVideo) {
            return NO;
        }
    }
    if (![ZLPhotoManager judgeAssetisInLocalAblum:model.asset]) {
        ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowseriCloudPhotoText));
        return NO;
    }
    if (model.type == ZLAssetMediaTypeVideo && GetDuration(model.duration) > configuration.maxVideoDuration) {
        ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxVideoDurationText), configuration.maxVideoDuration);
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
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    if (self.allowTakePhoto && ((configuration.sortAscending && indexPath.row >= self.arrDataSources.count) || (!configuration.sortAscending && indexPath.row == 0))) {
        ZLTakePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLTakePhotoCell" forIndexPath:indexPath];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = configuration.cellCornerRadio;
        if (configuration.showCaptureImageOnTakePhotoBtn) {
            [cell startCapture];
        }
        return cell;
    }
    
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    
    ZLPhotoModel *model;
    if (!self.allowTakePhoto || configuration.sortAscending) {
        model = self.arrDataSources[indexPath.row];
    } else {
        model = self.arrDataSources[indexPath.row-1];
    }

    @zl_weakify(self);
    __weak typeof(cell) weakCell = cell;
    __weak typeof(nav) weakNav = nav;
    cell.selectedBlock = ^(BOOL selected) {
        @zl_strongify(self);
        __strong typeof(weakCell) strongCell = weakCell;
        
        __weak typeof(weakNav) strongNav = weakNav;
        if (!selected) {
            //选中
            if ([self canAddModel:model]) {
                if (![self shouldDirectEdit:model]) {
                    model.selected = YES;
                    [strongNav.arrSelectedModels addObject:model];
                    strongCell.btnSelect.selected = YES;
                    [self setCell:strongCell indexLabelShow:YES index:strongNav.arrSelectedModels.count animate:YES];
                    [self shouldDirectEdit:model];
                }
            }
        } else {
            strongCell.btnSelect.selected = NO;
            model.selected = NO;
            for (ZLPhotoModel *m in weakNav.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [strongNav.arrSelectedModels removeObject:m];
                    break;
                }
            }
            [self refreshCellIndex];
        }
        [self refreshCellMaskView];
        [self resetBottomBtnsStatus:YES];
    };
    
    cell.allSelectGif = configuration.allowSelectGif;
    cell.allSelectLivePhoto = configuration.allowSelectLivePhoto;
    if (configuration.mutuallyExclusiveSelectInMix && configuration.maxSelectCount > 1) {
        cell.showSelectBtn = model.type < ZLAssetMediaTypeVideo;
    } else {
        cell.showSelectBtn = configuration.showSelectBtn;
    }
    cell.cornerRadio = configuration.cellCornerRadio;
    cell.indexLabel.backgroundColor = configuration.indexLabelBgColor;
    cell.showIndexLabel = NO;
    if (configuration.showSelectedIndex) {
        [nav.arrSelectedModels enumerateObjectsUsingBlock:^(ZLPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                [self setCell:cell indexLabelShow:YES index:idx+1 animate:NO];
                *stop = YES;
            }
        }];
    }
    
    [self setCellMaskView:cell isSelected:model.isSelected model:model];
    
    cell.model = model;
    
    return cell;
}

- (void)setCell:(ZLCollectionCell *)cell indexLabelShow:(BOOL)show index:(NSInteger)index animate:(BOOL)animate
{
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    if (!configuration.showSelectedIndex) {
        return;
    }
    cell.showIndexLabel = show;
    cell.index = index;
    if (animate) {
        [cell.indexLabel.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
}

- (void)refreshCellIndex {
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    if (!configuration.showSelectedIndex) {
        return;
    }
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    NSArray<NSIndexPath *> *visibleIndexPaths = self.collectionView.indexPathsForVisibleItems;
    [visibleIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UICollectionViewCell *c = [self.collectionView cellForItemAtIndexPath:obj];
        if ([c isKindOfClass:ZLTakePhotoCell.class]) {
            // 拍照cell return
            return;
        }
        ZLCollectionCell *cell = (ZLCollectionCell *)c;
        
        NSInteger row = obj.row;
        if (self.allowTakePhoto && !nav.configuration.sortAscending) {
            row = obj.row - 1;
        }
        
        ZLPhotoModel *m = self.arrDataSources[row];
        __block BOOL shouldShow = NO;
        __block NSInteger index = 0;
        [nav.arrSelectedModels enumerateObjectsUsingBlock:^(ZLPhotoModel * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop) {
            if ([obj1.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                index = idx1 + 1;
                shouldShow = YES;
                *stop = YES;
            }
        }];
        [self setCell:cell indexLabelShow:shouldShow index:index animate:NO];
    }];
}

- (void)refreshCellMaskView
{
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    if (!configuration.showSelectedMask && !configuration.showInvalidMask) {
        return;
    }
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    NSArray<NSIndexPath *> *visibleIndexPaths = self.collectionView.indexPathsForVisibleItems;
    [visibleIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UICollectionViewCell *c = [self.collectionView cellForItemAtIndexPath:obj];
        if ([c isKindOfClass:ZLTakePhotoCell.class]) {
            // 拍照cell return
            return;
        }
        ZLCollectionCell *cell = (ZLCollectionCell *)c;
        
        NSInteger row = obj.row;
        if (self.allowTakePhoto && !nav.configuration.sortAscending) {
            row = obj.row - 1;
        }
        
        ZLPhotoModel *m = self.arrDataSources[row];
        __block BOOL isSel = NO;
        [nav.arrSelectedModels enumerateObjectsUsingBlock:^(ZLPhotoModel * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop) {
            if ([obj1.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                isSel = YES;
                *stop = YES;
            }
        }];
        [self setCellMaskView:cell isSelected:isSel model:m];
    }];
}

- (void)setCellMaskView:(ZLCollectionCell *)cell isSelected:(BOOL)isSelected model:(ZLPhotoModel *)model {
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    cell.maskView.hidden = YES;
    cell.enableSelect = YES;
    if (isSelected) {
        cell.maskView.backgroundColor = configuration.selectedMaskColor;
        cell.maskView.hidden = !configuration.showSelectedMask;
    } else {
        NSInteger selCount = nav.arrSelectedModels.count;
        if (selCount < configuration.maxSelectCount && selCount > 0) {
            if (configuration.mutuallyExclusiveSelectInMix) {
                    cell.maskView.backgroundColor = configuration.invalidMaskColor;
                    cell.maskView.hidden = model.type != ZLAssetMediaTypeVideo;
                    cell.enableSelect = model.type != ZLAssetMediaTypeVideo;
            }
        } else if (selCount >= configuration.maxSelectCount) {
            cell.maskView.backgroundColor = configuration.invalidMaskColor;
            cell.maskView.hidden = NO;
            cell.enableSelect = NO;
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    if (self.allowTakePhoto && ((configuration.sortAscending && indexPath.row >= self.arrDataSources.count) || (!configuration.sortAscending && indexPath.row == 0))) {
        //拍照
        [self takePhoto];
        return;
    }
    ZLCollectionCell *cell = (ZLCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (!cell.enableSelect) {
        return;
    }
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !configuration.sortAscending) {
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
    ZLPhotoConfiguration *configuration = nav.configuration;
    //当前点击图片可编辑
    BOOL editImage = configuration.editAfterSelectThumbnailImage && configuration.allowEditImage && configuration.maxSelectCount == 1 && (model.type == ZLAssetMediaTypeImage || model.type == ZLAssetMediaTypeGif || model.type == ZLAssetMediaTypeLivePhoto);
    //当前点击视频可编辑
    BOOL editVideo = configuration.editAfterSelectThumbnailImage && configuration.allowEditVideo && model.type == ZLAssetMediaTypeVideo && configuration.maxSelectCount == 1 && round(model.asset.duration) >= configuration.maxEditVideoTime;
    //当前未选择图片 或 已经选择了一张并且点击的是已选择的图片
    BOOL flag = nav.arrSelectedModels.count == 0 || (nav.arrSelectedModels.count == 1 && [nav.arrSelectedModels.firstObject.asset.localIdentifier isEqualToString:model.asset.localIdentifier]);
    
    if (editImage && flag) {
        [nav.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    } else if (editVideo && flag) {
        [nav.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    }
    
    return configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo);
}

/**
 获取对应的vc
 */
- (UIViewController *)getMatchVCWithModel:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    if (nav.arrSelectedModels.count > 0) {
        ZLPhotoModel *sm = nav.arrSelectedModels.firstObject;
        if (configuration.mutuallyExclusiveSelectInMix &&
            ((model.type < ZLAssetMediaTypeVideo && sm.type == ZLAssetMediaTypeVideo) || (model.type == ZLAssetMediaTypeVideo && sm.type < ZLAssetMediaTypeVideo))) {
            return nil;
        }
    }
    
    NSArray *arr = [ZLPhotoManager getPhotoInResult:self.albumListModel.result allowSelectVideo:YES allowSelectImage:YES allowSelectGif:configuration.allowSelectGif allowSelectLivePhoto:configuration.allowSelectLivePhoto];
    
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
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = [nav configuration];
    
    if (![ZLPhotoManager haveCameraAuthority]) {
        NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoCameraAuthorityText), kAPPName];
        ShowAlert(message, self);
        return;
    }
    if (!configuration.allowSelectImage &&
        !configuration.allowRecordVideo) {
        ShowAlert(@"allowSelectImage与allowRecordVideo不能同时为NO", self);
        return;
    }
    BOOL canRecordFirstCondition = YES;
    if (configuration.mutuallyExclusiveSelectInMix && nav.arrSelectedModels.count > 0) {
        canRecordFirstCondition = NO;
    }
    if (configuration.useSystemCamera) {
        //系统相机拍照
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSArray *a1 = configuration.allowSelectImage?@[(NSString *)kUTTypeImage]:@[];
            NSArray *a2 = (canRecordFirstCondition&&configuration.allowSelectVideo && configuration.allowRecordVideo)?@[(NSString *)kUTTypeMovie]:@[];
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObjectsFromArray:a1];
            [arr addObjectsFromArray:a2];
            
            picker.mediaTypes = arr;
            picker.videoMaximumDuration = configuration.maxRecordDuration;
            [self showDetailViewController:picker sender:nil];
        }
    } else {
        if (![ZLPhotoManager haveMicrophoneAuthority]) {
            NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(ZLPhotoBrowserNoMicrophoneAuthorityText), kAPPName];
            ShowAlert(message, self);
            return;
        }
        ZLCustomCamera *camera = [[ZLCustomCamera alloc] init];
        camera.allowTakePhoto = configuration.allowSelectImage;
        camera.allowRecordVideo = canRecordFirstCondition && configuration.allowSelectVideo && configuration.allowRecordVideo;
        camera.sessionPreset = configuration.sessionPreset;
        camera.videoType = configuration.exportVideoType;
        camera.circleProgressColor = configuration.cameraProgressColor;
        camera.maxRecordDuration = configuration.maxRecordDuration;
        @zl_weakify(self);
        camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
            @zl_strongify(self);
            [self saveImage:image videoUrl:videoUrl];
        };
        [self showDetailViewController:camera sender:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSURL *url = [info valueForKey:UIImagePickerControllerMediaURL];
        [self saveImage:image videoUrl:url];
    }];
}

- (void)saveImage:(UIImage *)image videoUrl:(NSURL *)videoUrl
{
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    @zl_weakify(self);
    if (image) {
        [ZLPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            @zl_strongify(self);
            if (suc) {
                ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeImage duration:nil];
                [self handleDataArray:model];
            } else {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveImageErrorText));
            }
            [hud hide];
        }];
    } else if (videoUrl) {
        [ZLPhotoManager saveVideoToAblum:videoUrl completion:^(BOOL suc, PHAsset *asset) {
            @zl_strongify(self);
            if (suc) {
                ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeVideo duration:nil];
                model.duration = [ZLPhotoManager getDuration:asset];
                [self handleDataArray:model];
            } else {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserSaveVideoFailed));
            }
            [hud hide];
        }];
    }
}

- (void)handleDataArray:(ZLPhotoModel *)model
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    ZLPhotoConfiguration *configuration = nav.configuration;
    
    BOOL (^shouldSelect)(void) = ^BOOL() {
        if (model.type == ZLAssetMediaTypeVideo) {
            return (model.asset.duration <= configuration.maxVideoDuration);
        }
        return YES;
    };
    
    if (configuration.sortAscending) {
        [self.arrDataSources addObject:model];
    } else {
        [self.arrDataSources insertObject:model atIndex:0];
    }
    
    BOOL sel = shouldSelect();
    if (configuration.maxSelectCount > 1 && nav.arrSelectedModels.count < configuration.maxSelectCount && sel) {
        model.selected = sel;
        [nav.arrSelectedModels addObject:model];
    } else if (configuration.maxSelectCount == 1 && !nav.arrSelectedModels.count && sel) {
        if (![self shouldDirectEdit:model]) {
            model.selected = sel;
            [nav.arrSelectedModels addObject:model];
            [self btnDone_Click:nil];
            return;
        }
    }
    
    self.albumListModel = [ZLPhotoManager getCameraRollAlbumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage];
    [self.collectionView reloadData];
    [self scrollToBottom];
    [self resetBottomBtnsStatus:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)getOriginalImageBytes
{
    ZLImageNavigationController *nav = (ZLImageNavigationController *)self.navigationController;
    @zl_weakify(self);
    [ZLPhotoManager getPhotosBytesWithArray:nav.arrSelectedModels completion:^(NSString *photosBytes) {
        @zl_strongify(self);
        self.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
    }];
}

#pragma mark - UIViewControllerPreviewingDelegate
//!!!!: 3D Touch
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9.0)
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
    
    ZLPhotoConfiguration *configuration = [(ZLImageNavigationController *)self.navigationController configuration];
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !configuration.sortAscending) {
        index = indexPath.row - 1;
    }
    ZLPhotoModel *model = self.arrDataSources[index];
    vc.model = model;
    vc.allowSelectGif = configuration.allowSelectGif;
    vc.allowSelectLivePhoto = configuration.allowSelectLivePhoto;
    
    vc.preferredContentSize = [self getSize:model];
    
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9.0)
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

#pragma mark - ZLInteractiveAnimateProtocol
- (void)scrollToIndex:(NSInteger)index
{
    if (_isPreviewPush || index < 0 || index > self.arrDataSources.count-1) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

@end
