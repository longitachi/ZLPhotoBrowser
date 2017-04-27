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
#import "ZLDefine.h"
#import "ZLCollectionCell.h"
#import "YYFPSLabel.h"
#import <Photos/Photos.h>
#import "ZLShowGifViewController.h"
#import "ZLShowVideoViewController.h"
#import "ZLPhotoModel.h"

///////////////////////////////////////////////////
// git 地址： https://github.com/longitachi/ZLPhotoBrowser
// 喜欢的朋友请去给个star，谢谢
///////////////////////////////////////////////////
@interface ViewController () <UITextFieldDelegate>
{
//    ZLPhotoActionSheet *actionSheet;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegment;
@property (weak, nonatomic) IBOutlet UISwitch *selImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selGifSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selVideoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *takePhotoInLibrarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *rememberLastSelSwitch;
@property (weak, nonatomic) IBOutlet UITextField *previewTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxSelCountTextField;

@property (nonatomic, strong) NSMutableArray<UIImage *> *lastSelectPhotos;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *lastSelectAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *arrDataSources;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
    [self.collectionView registerClass:NSClassFromString(@"ZLCollectionCell") forCellWithReuseIdentifier:@"ZLCollectionCell"];
}

- (ZLPhotoActionSheet *)getPas
{
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    actionSheet.sortAscending = self.sortSegment.selectedSegmentIndex==0;
    actionSheet.allowSelectImage = self.selImageSwitch.isOn;
    actionSheet.allowSelectGif = self.selGifSwitch.isOn;
    actionSheet.allowSelectVideo = self.selVideoSwitch.isOn;
    actionSheet.allowTakePhotoInLibrary = self.takePhotoInLibrarySwitch.isOn;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = self.previewTextField.text.integerValue;
    //设置照片最大选择数
    actionSheet.maxSelectCount = self.maxSelCountTextField.text.integerValue;
    
    actionSheet.sender = self;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (PHAsset *asset in self.lastSelectAssets) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            [arr addObject:asset];
        }
    }
    actionSheet.arrSelectedAssets = self.rememberLastSelSwitch.isOn ? arr : nil;
    
    weakify(self);
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        strongify(weakSelf);
        strongSelf.arrDataSources = images;
        strongSelf.lastSelectAssets = assets.mutableCopy;
        strongSelf.lastSelectPhotos = images.mutableCopy;
        [strongSelf.collectionView reloadData];
        NSLog(@"image:%@", images);
    }];
    [actionSheet setSelectGifBlock:^(UIImage * _Nonnull gif, PHAsset * _Nonnull asset) {
        strongify(weakSelf);
        strongSelf.arrDataSources = @[gif];
        strongSelf.lastSelectAssets = @[asset].mutableCopy;
        [strongSelf.collectionView reloadData];
        NSLog(@"gif:%@", gif);
    }];
    [actionSheet setSelectVideoBlock:^(UIImage * _Nonnull coverImage, PHAsset * _Nonnull asset) {
        strongify(weakSelf);
        strongSelf.arrDataSources = @[coverImage];
        strongSelf.lastSelectAssets = @[asset].mutableCopy;
        [strongSelf.collectionView reloadData];
        NSLog(@"video cover image:%@", coverImage);
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
    ZLPhotoActionSheet *actionSheet = [self getPas];
    
    if (preview) {
        [actionSheet showPreviewAnimated:YES];
    } else {
        [actionSheet showPhotoLibrary];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    cell.btnSelect.hidden = YES;
    cell.videoImageView.hidden = YES;
//    cell.topView.hidden = YES;
    cell.imageView.image = _arrDataSources[indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.lastSelectAssets[indexPath.row];
    if (self.selGifSwitch.isOn && [[asset valueForKey:@"filename"] containsString:@"GIF"]) {
        //gif预览
        ZLShowGifViewController *vc = [[ZLShowGifViewController alloc] init];
        ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeGif duration:nil];
        vc.model = model;
        [self showDetailViewController:vc sender:self];
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        //视频预览
        ZLShowVideoViewController *vc = [[ZLShowVideoViewController alloc] init];
        ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeVideo duration:nil];
        vc.model = model;
        [self showDetailViewController:vc sender:self];
    } else {
        //image预览
        [[self getPas] previewSelectedPhotos:self.lastSelectPhotos assets:self.lastSelectAssets index:indexPath.row];
    }
}

- (IBAction)valueChanged:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    if (s == self.selImageSwitch) {
        if (!s.isOn) {
            [self.selGifSwitch setOn:NO animated:YES];
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
