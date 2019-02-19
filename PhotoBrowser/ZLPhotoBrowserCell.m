//
//  ZLPhotoBrowserCell.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLPhotoBrowserCell.h"
#import "ZLPhotoModel.h"
#import "ZLPhotoManager.h"
#import "ZLDefine.h"

@interface ZLPhotoBrowserCell ()

@property (nonatomic, copy) NSString *identifier;

@end

@implementation ZLPhotoBrowserCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setModel:(ZLAlbumListModel *)model
{
    _model = model;
    
    if (self.cornerRadio > .0) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.cornerRadio;
    }
    
    zl_weakify(self);
    
    self.identifier = model.headImageAsset.localIdentifier;
    [ZLPhotoManager requestImageForAsset:model.headImageAsset size:CGSizeMake(GetViewHeight(self)*2.5, GetViewHeight(self)*2.5) progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        zl_strongify(weakSelf);
        
        if ([strongSelf.identifier isEqualToString:model.headImageAsset.localIdentifier]) {
            strongSelf.headImageView.image = image?:GetImageWithName(@"zl_defaultphoto");
        }
    }];
    
    self.labTitle.text = model.title;
    self.labCount.text = [NSString stringWithFormat:@"(%ld)", model.count];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
