//
//  FHActionCell.m
//  FHAlertController
//
//  Created by MADAO on 16/4/15.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import "FHPickActionCell.h"

@interface FHPickSheetAction()

@end

@implementation FHPickSheetAction

- (instancetype)initWithTitle:(NSString *)actionTitle
             andActionHandler:(FHPickActionBlock)handler{
    if (self = [super init]){
        self.buttonTitle = actionTitle;
        self.actionHandler = handler;
    }
    return self;
}
@end


NSString *const kActionCellReuseIdentifier = @"ActionCellReuseIdentifier";

@interface FHPickActionCell ()

@end

@implementation FHPickActionCell

- (UIWindow *)getCurrentWindow{
    return [UIApplication sharedApplication].windows.lastObject;
}

- (instancetype)initWithAction:(FHPickSheetAction *)action{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier: kActionCellReuseIdentifier]) {
        self.action = action;
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self getCurrentWindow].frame.size.width, self.bounds.size.height)];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
    return self;
}
- (void)setAction:(FHPickSheetAction *)action
{
    _action = action;
    if (_action.attributedButtonTitle != nil){
        self.textLabel.attributedText = _action.attributedButtonTitle;
    }
    else{
        self.textLabel.text = action.buttonTitle;
    }
    self.textLabel.textColor = _action.buttonTitleColor;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
