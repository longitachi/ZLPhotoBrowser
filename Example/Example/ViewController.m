//
//  ViewController.m
//  ZLPhotoBrowser
//
//  Created by long on 15/12/1.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ViewController.h"
#import "ImageCell.h"
#import "YYFPSLabel.h"
#import <Photos/Photos.h>
#import <ZLPhotoBrowser/ZLPhotoBrowser.h>

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
    
    //以下参数为自定义参数，均可不设置，有默认值
    actionSheet.configuration.sortAscending = self.sortSegment.selectedSegmentIndex==0;
    actionSheet.configuration.allowSelectImage = self.selImageSwitch.isOn;
    actionSheet.configuration.allowSelectGif = self.selGifSwitch.isOn;
    actionSheet.configuration.allowSelectVideo = self.selVideoSwitch.isOn;
    actionSheet.configuration.allowSelectLivePhoto = self.selLivePhotoSwitch.isOn;
    actionSheet.configuration.allowForceTouch = self.allowForceTouchSwitch.isOn;
    actionSheet.configuration.allowEditImage = self.allowEditSwitch.isOn;
    actionSheet.configuration.allowEditVideo = self.allowEditVideoSwitch.isOn;
    actionSheet.configuration.allowSlideSelect = self.allowSlideSelectSwitch.isOn;
    actionSheet.configuration.allowMixSelect = self.mixSelectSwitch.isOn;
    actionSheet.configuration.allowDragSelect = self.allowDragSelectSwitch.isOn;
    //设置相册内部显示拍照按钮
    actionSheet.configuration.allowTakePhotoInLibrary = self.takePhotoInLibrarySwitch.isOn;
    //设置在内部拍照按钮上实时显示相机俘获画面
    actionSheet.configuration.showCaptureImageOnTakePhotoBtn = self.showCaptureImageSwitch.isOn;
    //设置照片最大预览数
    actionSheet.configuration.maxPreviewCount = self.previewTextField.text.integerValue;
    //设置照片最大选择数
    actionSheet.configuration.maxSelectCount = self.maxSelCountTextField.text.integerValue;
    actionSheet.configuration.maxVideoSelectCountInMix = 3;
    actionSheet.configuration.minVideoSelectCountInMix = 1;
    //设置允许选择的视频最大时长
    actionSheet.configuration.maxVideoDuration = self.maxVideoDurationTextField.text.integerValue;
    //设置照片cell弧度
    actionSheet.configuration.cellCornerRadio = self.cornerRadioTextField.text.floatValue;
    //单选模式是否显示选择按钮
    //    actionSheet.configuration.showSelectBtn = YES;
    //是否在选择图片后直接进入编辑界面
    actionSheet.configuration.editAfterSelectThumbnailImage = self.editAfterSelectImageSwitch.isOn;
    //是否保存编辑后的图片
    //    actionSheet.configuration.saveNewImageAfterEdit = NO;
    //设置编辑比例
    //    actionSheet.configuration.clipRatios = @[GetClipRatio(7, 1)];
    //是否在已选择照片上显示遮罩层
    actionSheet.configuration.showSelectedMask = self.maskSwitch.isOn;
//    actionSheet.configuration.showSelectedIndex = NO;
    //颜色，状态栏样式
    //    actionSheet.configuration.previewTextColor = [UIColor brownColor];
    //    actionSheet.configuration.selectedMaskColor = [UIColor purpleColor];
    //    actionSheet.configuration.navBarColor = [UIColor orangeColor];
    //    actionSheet.configuration.navTitleColor = [UIColor blackColor];
    //    actionSheet.configuration.bottomBtnsNormalTitleColor = kRGB(80, 160, 100);
    //    actionSheet.configuration.bottomBtnsDisableBgColor = kRGB(190, 30, 90);
    //    actionSheet.configuration.bottomViewBgColor = [UIColor blackColor];
    //    actionSheet.configuration.statusBarStyle = UIStatusBarStyleDefault;
    //是否允许框架解析图片
    actionSheet.configuration.shouldAnialysisAsset = self.allowAnialysisAssetSwitch.isOn;
    //框架语言
    actionSheet.configuration.languageType = self.languageSegment.selectedSegmentIndex;
    //自定义多语言
    //    actionSheet.configuration.customLanguageKeyValue = @{@"ZLPhotoBrowserCameraText": @"没错，我就是一个相机"};
    //自定义图片
    //    actionSheet.configuration.customImageNames = @[@"zl_navBack"];
    
    //是否使用系统相机
    //    actionSheet.configuration.useSystemCamera = YES;
    //    actionSheet.configuration.sessionPreset = ZLCaptureSessionPreset1920x1080;
    //    actionSheet.configuration.exportVideoType = ZLExportVideoTypeMp4;
    //    actionSheet.configuration.allowRecordVideo = NO;
    //    actionSheet.configuration.maxRecordDuration = 5;
#pragma mark - required
    //如果调用的方法没有传sender，则该属性必须提前赋值
    actionSheet.sender = self;
    //记录上次选择的图片
    actionSheet.arrSelectedAssets = self.rememberLastSelSwitch.isOn&&self.maxSelCountTextField.text.integerValue>1 ? self.lastSelectAssets : nil;
    
    @zl_weakify(self);
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        @zl_strongify(self);
        self.arrDataSources = images;
        self.isOriginal = isOriginal;
        self.lastSelectAssets = assets.mutableCopy;
        self.lastSelectPhotos = images.mutableCopy;
        [self.collectionView reloadData];
        NSLog(@"image:%@", images);
        //解析图片
        if (!self.allowAnialysisAssetSwitch.isOn) {
            [self anialysisAssets:assets original:isOriginal];
        }
    }];
    
    actionSheet.selectImageRequestErrorBlock = ^(NSArray<PHAsset *> * _Nonnull errorAssets, NSArray<NSNumber *> * _Nonnull errorIndex) {
        NSLog(@"图片解析出错的索引为: %@, 对应assets为: %@", errorIndex, errorAssets);
    };
    
    actionSheet.cancleBlock = ^{
        NSLog(@"取消选择图片");
    };
    
    return actionSheet;
}

- (void)anialysisAssets:(NSArray<PHAsset *> *)assets original:(BOOL)original
{
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    //该hud自动15s消失，请使用自己项目中的hud控件
    [hud show];
    
    @zl_weakify(self);
    [ZLPhotoManager anialysisAssets:assets original:original completion:^(NSArray<UIImage *> *images) {
        @zl_strongify(self);
        [hud hide];
        self.arrDataSources = images;
        self.lastSelectPhotos = images.mutableCopy;
        [self.collectionView reloadData];
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

- (IBAction)showCamera:(id)sender
{
    ZLCustomCamera *camera = [[ZLCustomCamera alloc] init];
    
    @zl_weakify(self);
    camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
        @zl_strongify(self);
        [self saveImage:image videoUrl:videoUrl];
    };
    
    [self showDetailViewController:camera sender:nil];
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
                self.arrDataSources = @[image];
                self.lastSelectPhotos = @[image].mutableCopy;
                self.lastSelectAssets = @[asset].mutableCopy;
                [self.collectionView reloadData];
            } else {
                ZLLoggerDebug(@"图片保存失败");
            }
            [hud hide];
        }];
    } else if (videoUrl) {
        [ZLPhotoManager saveVideoToAblum:videoUrl completion:^(BOOL suc, PHAsset *asset) {
            @zl_strongify(self);
            if (suc) {
                [ZLPhotoManager requestImageForAsset:asset size:CGSizeMake(300, 300) progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
                    @zl_strongify(self);
                    if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                        return;
                    }
                    self.arrDataSources = @[image];
                    self.lastSelectPhotos = @[image].mutableCopy;
                    self.lastSelectAssets = @[asset].mutableCopy;
                    [self.collectionView reloadData];
                    [hud hide];
                }];
            } else {
                ZLLoggerDebug(@"视频保存失败");
                [hud hide];
            }
        }];
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
    NSArray *arrNetImages = @[GetDictForPreviewPhoto([NSURL URLWithString:@"http://i4.chuimg.com/e71fbe7ecebb11e9b33002420a001066_720w_1280h.mp4"], ZLPreviewPhotoTypeURLVideo),
                              GetDictForPreviewPhoto([NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842025734.jpg"], ZLPreviewPhotoTypeURLImage),
                              GetDictForPreviewPhoto([NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842034354.jpg"], ZLPreviewPhotoTypeURLImage),
                              GetDictForPreviewPhoto([NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1514184259027&di=a2e54cf2d5affe17acdaf1fbf19ff0af&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201212%2F25%2F20121225173302_wTjN8.jpeg"], ZLPreviewPhotoTypeURLImage),
                              GetDictForPreviewPhoto([NSURL URLWithString:@"http://i4.chuimg.com/956b3172a2e111e9b17402420a00105a_720w_1280h.mp4"], ZLPreviewPhotoTypeURLVideo),
                              GetDictForPreviewPhoto([NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566386966005&di=adba0acdc81f732d75a1cc5a47f36c46&imgtype=0&src=http%3A%2F%2Fmsp.baidu.com%2Fv1%2Fmediaspot%2F968f19dc612b9e6d2f84a5149cd38b17.gif"], ZLPreviewPhotoTypeURLImage)];
    [[self getPas] previewPhotos:arrNetImages index:0 hideToolBar:NO complete:^(NSArray * _Nonnull photos) {
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
