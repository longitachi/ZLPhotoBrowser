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

///////////////////////////////////////////////////
// git 地址： https://github.com/longitachi/ZLPhotoBrowser
// 喜欢的朋友请去给个star，莫大的支持，谢谢
///////////////////////////////////////////////////
@interface ViewController ()
{
//    ZLPhotoActionSheet *actionSheet;
}

@property (nonatomic, strong) NSArray<ZLSelectPhotoModel *> *lastSelectMoldels;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *arrDataSources;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initCollectionView];
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
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZLCollectionCell" bundle:kZLPhotoBrowserBundle] forCellWithReuseIdentifier:@"ZLCollectionCell"];
}

- (IBAction)btnSelectPhotoPreview:(id)sender
{
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 2;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 20;
    weakify(self);
    [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:self.lastSelectMoldels completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels) {
        strongify(weakSelf);
        strongSelf.arrDataSources = selectPhotos;
        strongSelf.lastSelectMoldels = selectPhotoModels;
        [strongSelf.collectionView reloadData];
        NSLog(@"%@", selectPhotos);
    }];
}

- (IBAction)btnSelectPhotoLibrary:(id)sender {
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 2;
    weakify(self);
    [actionSheet showPhotoLibraryWithSender:self lastSelectPhotoModels:self.lastSelectMoldels completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels) {
        strongify(weakSelf);
        strongSelf.arrDataSources = selectPhotos;
        strongSelf.lastSelectMoldels = selectPhotoModels;
        [strongSelf.collectionView reloadData];
        NSLog(@"%@", selectPhotos);
    }];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    cell.btnSelect.hidden = YES;
    cell.imageView.image = _arrDataSources[indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLCollectionCell *cell = (ZLCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [ZLShowBigImage showBigImage:cell.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
