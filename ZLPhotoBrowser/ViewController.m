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


@property (nonatomic, strong) NSMutableArray<UIImage *> *lastSelectPhotos;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *lastSelectAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *arrDataSources;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    YYFPSLabel *label = [[YYFPSLabel alloc] initWithFrame:CGRectMake(kViewWidth - 100, 30, 100, 30)];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [self initCollectionView];
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
    
#pragma optional
    //以下参数为自定义参数，均可不设置，有默认值
    actionSheet.sortAscending = self.sortSegment.selectedSegmentIndex==0;
    actionSheet.allowSelectImage = self.selImageSwitch.isOn;
    actionSheet.allowSelectGif = self.selGifSwitch.isOn;
    actionSheet.allowSelectVideo = self.selVideoSwitch.isOn;
    actionSheet.allowSelectLivePhoto = self.selLivePhotoSwitch.isOn;
    actionSheet.allowForceTouch = self.allowForceTouchSwitch.isOn;
    actionSheet.allowEditImage = self.allowEditSwitch.isOn;
    actionSheet.allowEditVideo = self.allowEditVideoSwitch.isOn;
    actionSheet.allowSlideSelect = self.allowSlideSelectSwitch.isOn;
    actionSheet.allowMixSelect = self.mixSelectSwitch.isOn;
    //设置相册内部显示拍照按钮
    actionSheet.allowTakePhotoInLibrary = self.takePhotoInLibrarySwitch.isOn;
    //设置在内部拍照按钮上实时显示相机俘获画面
    actionSheet.showCaptureImageOnTakePhotoBtn = self.showCaptureImageSwitch.isOn;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = self.previewTextField.text.integerValue;
    //设置照片最大选择数
    actionSheet.maxSelectCount = self.maxSelCountTextField.text.integerValue;
    //设置允许选择的视频最大时长
    actionSheet.maxVideoDuration = self.maxVideoDurationTextField.text.integerValue;
    //设置照片cell弧度
    actionSheet.cellCornerRadio = self.cornerRadioTextField.text.floatValue;
    //单选模式是否显示选择按钮
    actionSheet.showSelectBtn = YES;
    //是否在选择图片后直接进入编辑界面
    actionSheet.editAfterSelectThumbnailImage = self.editAfterSelectImageSwitch.isOn;
    //设置编辑比例
//    actionSheet.clipRatios = @[GetClipRatio(4, 3)];
    //是否在已选择照片上显示遮罩层
    actionSheet.showSelectedMask = self.maskSwitch.isOn;
    //遮罩层颜色
//    actionSheet.selectedMaskColor = [UIColor orangeColor];
#pragma required
    //如果调用的方法没有传sender，则该属性必须提前赋值
    actionSheet.sender = self;
    
    actionSheet.arrSelectedAssets = self.rememberLastSelSwitch.isOn&&self.maxSelCountTextField.text.integerValue>1 ? self.lastSelectAssets : nil;
    
    weakify(self);
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        strongify(weakSelf);
        strongSelf.arrDataSources = images;
        strongSelf.lastSelectAssets = assets.mutableCopy;
        strongSelf.lastSelectPhotos = images.mutableCopy;
        [strongSelf.collectionView reloadData];
        NSLog(@"image:%@", images);
    }];
    
    return actionSheet;
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
    [[self getPas] previewSelectedPhotos:self.lastSelectPhotos assets:self.lastSelectAssets index:indexPath.row];
}

- (IBAction)btnPreviewNetImageClick:(id)sender
{
    NSArray *arrNetImages = @[[NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842038745.jpg"],
                              [NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842025734.jpg"],
                              [NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842029339.jpg"],
                              [NSURL URLWithString:@"http://pic.962.net/up/2013-11/20131111660842034354.jpg"],
                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1504756336591&di=56a3c8866c95891cbb9c43f907b4f954&imgtype=0&src=http%3A%2F%2Ff5.topitme.com%2F5%2Fa0%2F42%2F111173677859242a05o.jpg"],
                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1504756368444&di=7e1a2d1fc8aeea41220b1dc56dfc0012&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201605%2F10%2F20160510182555_KQ8FH.thumb.700_0.jpeg"]];
    [[self getPas] previewPhotos:arrNetImages index:0 complete:^(NSArray * _Nonnull photos) {
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
