//
//  ViewController.m
//  ZLPhotoBrowser
//
//  Created by long on 15/12/1.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ViewController.h"
#import "ZLPhotoActionSheet.h"
#import "ZLDefine.h"
#import "ImageCell.h"
#import "YYFPSLabel.h"
#import <Photos/Photos.h>
#import "ZLPhotoModel.h"
#import "ZLPhotoManager.h"
#import "ZLProgressHUD.h"
#import "ZLPhotoConfiguration.h"

///////////////////////////////////////////////////
// git 地址： https://github.com/longitachi/ZLPhotoBrowser
// 喜欢的朋友请去给个star，谢谢
///////////////////////////////////////////////////
@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegment;
@property (weak, nonatomic) IBOutlet UISwitch *selImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selGifSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selVideoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *takePhotoInLibrarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *rememberLastSelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showCaptureImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selLivePhotoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allowForceTouchSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allowEditSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mixSelectSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *editAfterSelectImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *maskSwitch;
@property (weak, nonatomic) IBOutlet UITextField *previewTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxSelCountTextField;
@property (weak, nonatomic) IBOutlet UITextField *cornerRadioTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxVideoDurationTextField;
@property (weak, nonatomic) IBOutlet UISwitch *allowSlideSelectSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allowEditVideoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allowDragSelectSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allowAnialysisAssetSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *languageSegment;



@property (nonatomic, strong) NSMutableArray<UIImage *> *lastSelectPhotos;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *lastSelectAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *arrDataSources;

@property (nonatomic, assign) BOOL isOriginal;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    YYFPSLabel *label = [[YYFPSLabel alloc] initWithFrame:CGRectMake(kViewWidth - 100, 30, 100, 30)];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [self initCollectionView];
    
//    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)initCollectionView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((width-9)/4, (width-9)/4);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:NSClassFromString(@"ImageCell") forCellWithReuseIdentifier:@"ImageCell"];
}

- (ZLPhotoActionSheet *)getPas
{
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    
#pragma mark - 参数配置 optional，可直接使用 defaultPhotoConfiguration
    ZLPhotoConfiguration *configuration = [ZLPhotoConfiguration defaultPhotoConfiguration];
    //以下参数为自定义参数，均可不设置，有默认值
    configuration.sortAscending = self.sortSegment.selectedSegmentIndex==0;
    configuration.allowSelectImage = self.selImageSwitch.isOn;
    configuration.allowSelectGif = self.selGifSwitch.isOn;
    configuration.allowSelectVideo = self.selVideoSwitch.isOn;
    configuration.allowSelectLivePhoto = self.selLivePhotoSwitch.isOn;
    configuration.allowForceTouch = self.allowForceTouchSwitch.isOn;
    configuration.allowEditImage = self.allowEditSwitch.isOn;
    configuration.allowEditVideo = self.allowEditVideoSwitch.isOn;
    configuration.allowSlideSelect = self.allowSlideSelectSwitch.isOn;
    configuration.allowMixSelect = self.mixSelectSwitch.isOn;
    configuration.allowDragSelect = self.allowDragSelectSwitch.isOn;
    //设置相册内部显示拍照按钮
    configuration.allowTakePhotoInLibrary = self.takePhotoInLibrarySwitch.isOn;
    //设置在内部拍照按钮上实时显示相机俘获画面
    configuration.showCaptureImageOnTakePhotoBtn = self.showCaptureImageSwitch.isOn;
    //设置照片最大预览数
    configuration.maxPreviewCount = self.previewTextField.text.integerValue;
    //设置照片最大选择数
    configuration.maxSelectCount = self.maxSelCountTextField.text.integerValue;
    //设置允许选择的视频最大时长
    configuration.maxVideoDuration = self.maxVideoDurationTextField.text.integerValue;
    //设置照片cell弧度
    configuration.cellCornerRadio = self.cornerRadioTextField.text.floatValue;
    //单选模式是否显示选择按钮
//    configuration.showSelectBtn = YES;
    //是否在选择图片后直接进入编辑界面
    configuration.editAfterSelectThumbnailImage = self.editAfterSelectImageSwitch.isOn;
    //设置编辑比例
//    configuration.clipRatios = @[GetClipRatio(1, 1)];
    //是否在已选择照片上显示遮罩层
    configuration.showSelectedMask = self.maskSwitch.isOn;
    //颜色，状态栏样式
//    configuration.selectedMaskColor = [UIColor purpleColor];
//    configuration.navBarColor = [UIColor orangeColor];
//    configuration.navTitleColor = [UIColor blackColor];
//    configuration.bottomBtnsNormalTitleColor = kRGB(80, 160, 100);
//    configuration.bottomBtnsDisableBgColor = kRGB(190, 30, 90);
//    configuration.bottomViewBgColor = [UIColor blackColor];
//    configuration.statusBarStyle = UIStatusBarStyleDefault;
    //是否允许框架解析图片
    configuration.shouldAnialysisAsset = self.allowAnialysisAssetSwitch.isOn;
    //框架语言
    configuration.languageType = self.languageSegment.selectedSegmentIndex;
    //是否使用系统相机
//    configuration.useSystemCamera = YES;
//    configuration.sessionPreset = ZLCaptureSessionPreset1920x1080;
//    configuration.exportVideoType = ZLExportVideoTypeMp4;
    
    actionSheet.configuration = configuration;
    
#pragma mark - required
    //如果调用的方法没有传sender，则该属性必须提前赋值
    actionSheet.sender = self;
    //记录上次选择的图片
    actionSheet.arrSelectedAssets = self.rememberLastSelSwitch.isOn&&self.maxSelCountTextField.text.integerValue>1 ? self.lastSelectAssets : nil;
    
    zl_weakify(self);
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        zl_strongify(weakSelf);
        strongSelf.arrDataSources = images;
        strongSelf.isOriginal = isOriginal;
        strongSelf.lastSelectAssets = assets.mutableCopy;
        strongSelf.lastSelectPhotos = images.mutableCopy;
        [strongSelf.collectionView reloadData];
        NSLog(@"image:%@", images);
        //解析图片
        if (!strongSelf.allowAnialysisAssetSwitch.isOn) {
            [strongSelf anialysisAssets:assets original:isOriginal];
        }
    }];
    
    return actionSheet;
}

- (void)anialysisAssets:(NSArray<PHAsset *> *)assets original:(BOOL)original
{
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    //该hud自动15s消失，请使用自己项目中的hud控件
    [hud show];
    
    zl_weakify(self);
    [ZLPhotoManager anialysisAssets:assets original:original completion:^(NSArray<UIImage *> *images) {
        zl_strongify(weakSelf);
        [hud hide];
        strongSelf.arrDataSources = images;
        [strongSelf.collectionView reloadData];
        NSLog(@"%@", images);
    }];
}

- (IBAction)btnSelectPhotoPreview:(id)sender
{
    [self showWithPreview:YES];
}

- (IBAction)btnSelectPhotoLibrary:(id)sender
{
    [self showWithPreview:NO];
}

- (void)showWithPreview:(BOOL)preview
{
    ZLPhotoActionSheet *a = [self getPas];
    
    if (preview) {
        [a showPreviewAnimated:YES];
    } else {
        [a showPhotoLibrary];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.imageView.image = _arrDataSources[indexPath.row];
    PHAsset *asset = self.lastSelectAssets[indexPath.row];
    cell.playImageView.hidden = !(asset.mediaType == PHAssetMediaTypeVideo);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[self getPas] previewSelectedPhotos:self.lastSelectPhotos assets:self.lastSelectAssets index:indexPath.row isOriginal:self.isOriginal];
}

- (IBAction)btnPreviewNetImageClick:(id)sender
{
    NSArray *arrNetImages = @[[NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842038745.jpg"],
                              [NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842025734.jpg"],
                              [NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842029339.jpg"],
                              [NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842034354.jpg"],
                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1504756336591&di=56a3c8866c95891cbb9c43f907b4f954&imgtype=0&src=http%3A%2F%2Ff5.topitme.com%2F5%2Fa0%2F42%2F111173677859242a05o.jpg"],
                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1504756368444&di=7e1a2d1fc8aeea41220b1dc56dfc0012&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201605%2F10%2F20160510182555_KQ8FH.thumb.700_0.jpeg"]];
    [[self getPas] previewPhotos:arrNetImages index:0 hideToolBar:YES complete:^(NSArray * _Nonnull photos) {
        NSLog(@"%@", photos);
    }];
}

- (IBAction)valueChanged:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    if (s == self.selImageSwitch) {
        if (!s.isOn) {
            [self.selGifSwitch setOn:NO animated:YES];
            [self.selLivePhotoSwitch setOn:NO animated:YES];
            [self.allowEditSwitch setOn:NO animated:YES];
            [self.selVideoSwitch setOn:YES animated:YES];
        }
    } else if (s == self.selGifSwitch) {
        if (s.isOn) {
            [self.selImageSwitch setOn:YES animated:YES];
        }
    } else if (s == self.selVideoSwitch) {
        if (!s.isOn) {
            [self.selImageSwitch setOn:YES animated:YES];
        }
    } else if (s == self.selLivePhotoSwitch) {
        if (s.isOn) {
            [self.selImageSwitch setOn:YES animated:YES];
        }
    } else if (s == self.allowEditSwitch || s == self.allowEditVideoSwitch) {
        if (!self.allowEditSwitch.isOn && !self.allowEditVideoSwitch.isOn) {
            [self.editAfterSelectImageSwitch setOn:NO animated:YES];
        }
    }
}

#pragma mark - text field delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _previewTextField) {
        NSString *str = textField.text;
        textField.text = str.integerValue > 50 ? @"50" : str;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
