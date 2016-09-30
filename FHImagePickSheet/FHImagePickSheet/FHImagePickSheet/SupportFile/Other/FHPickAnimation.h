//
//  FHPickAnimation.h
//  FHAlertController
//
//  Created by MADAO on 16/4/20.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHPickAnimation : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithPresentController:(UIViewController *)presentController presenting:(BOOL)present;

@end
