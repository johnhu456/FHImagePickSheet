//
//  FHImageTableViewCell.m
//  FHAlertController
//
//  Created by MADAO on 16/4/20.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import "FHImageTableViewCell.h"


@implementation FHImagePickCollectionView

/**Maybe some day will use this class*/

@end

NSString *const kImageCellReuseIdentifier = @"ImageCellReuseIdentifier";

@implementation FHImageTableViewCell

- (void)prepareForReuse
{
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
}

- (void)setCollectionView:(FHImagePickCollectionView *)collectionView
{
    _collectionView = collectionView;
    collectionView.frame = self.bounds;
    [self addSubview:_collectionView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // Key part, which will affect the animation
    _collectionView.frame = CGRectMake(-self.bounds.size.width, self.bounds.origin.y, self.bounds.size.width * 3, self.bounds.size.height);
    _collectionView.contentInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, self.bounds.size.width);
}

@end
