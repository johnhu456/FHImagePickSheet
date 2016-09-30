//
//  PreviewCheckView.m
//  FHAlertController
//
//  Created by MADAO on 16/4/22.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import "FHPreviewMarkView.h"

@interface FHPreviewMarkView()

@property (nonatomic, strong) UIButton *btnCheckMark;

@end

@implementation FHPreviewMarkView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _btnCheckMark  = [[UIButton alloc] initWithFrame:self.bounds];
        _btnCheckMark.selected = NO;
        _btnCheckMark.tintColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;
        _selected = NO;
        [_btnCheckMark setImage:[[UIImage imageNamed:@"PreviewSupplementaryView-Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_btnCheckMark setImage:[[UIImage imageNamed:@"PreviewSupplementaryView-Checkmark-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    }
    return self;
}

- (void)didMoveToSuperview
{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.btnCheckMark];
    [self resetButtonImage];
}

- (void)resetButtonImage
{
    [self.btnCheckMark setSelected:_selected];
    if (self.isSelected) {
        self.btnCheckMark.backgroundColor = [UIColor blueColor];
    }
    else
    {
        self.btnCheckMark.backgroundColor = [UIColor clearColor];
    }
}
-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self resetButtonImage];
}

- (void)drawRect:(CGRect)rect
{
    self.btnCheckMark.layer.cornerRadius = 11;
    self.btnCheckMark.layer.masksToBounds = YES;
}
@end
