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
    
    weakify(self);
    [ZLPhotoManager requestImageForAsset:model.headImageAsset size:CGSizeMake(GetViewWidth(self)*3, GetViewHeight(self)*3) completion:^(UIImage *image, NSDictionary *info) {
        strongify(weakSelf);
        strongSelf.headImageView.image = image;
    }];
    
    self.labTitle.text = model.title;
    self.labCount.text = [NSString stringWithFormat:@"(%ld)", model.count];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
