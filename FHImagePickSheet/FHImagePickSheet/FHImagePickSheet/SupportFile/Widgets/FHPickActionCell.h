//
//  FHActionCell.h
//  FHAlertController
//
//  Created by MADAO on 16/4/15.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FHPickActionBlock)();

/**
 An Action class that contains information such as title, targets, and so on.
 Used to describe the display of FHActionCell and handle click events.
 */
@interface FHPickSheetAction : NSObject

@property (nonatomic, copy) FHPickActionBlock actionHandler;

@property (nonatomic, strong) NSString *buttonTitle;

@property (nonatomic, strong) NSAttributedString *attributedButtonTitle;   //Its setting invalidates the ‘buttonTitle’ property.

@property (nonatomic, strong) UIColor *buttonTitleColor;

- (instancetype)initWithTitle:(NSString *)actionTitle andActionHandler:(FHPickActionBlock)handler;

@end

extern NSString *const kActionCellReuseIdentifier;

@interface FHPickActionCell : UITableViewCell

@property (nonatomic, weak) FHPickSheetAction *action;

- (instancetype)initWithAction:(FHPickSheetAction *)action;

@end
