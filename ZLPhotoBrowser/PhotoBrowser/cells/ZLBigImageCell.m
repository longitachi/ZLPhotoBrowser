//
//  ZLBigImageCell.m
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLBigImageCell.h"

@implementation ZLBigImageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)showIndicator
{
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
}

- (void)hideIndicator
{
    [self.indicator stopAnimating];
}

@end
