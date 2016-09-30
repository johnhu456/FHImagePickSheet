//
//  FHImagePickCollectionViewCell.m
//  FHImagePickSheet
//
//  Created by MADAO on 16/4/19.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import "FHImagePickCollectionViewCell.h"

@interface FHImagePickCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageVIew;

@end

@implementation FHImagePickCollectionViewCell

- (void)awakeFromNib {
    self.imageVIew.userInteractionEnabled = NO;
    [super awakeFromNib];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageVIew.image = image;
}

- (void)prepareForReuse
{
    self.imageVIew.image = nil;
}

-(void)layoutSubviews
{
    self.imageVIew.frame = self.bounds;
}

@end
