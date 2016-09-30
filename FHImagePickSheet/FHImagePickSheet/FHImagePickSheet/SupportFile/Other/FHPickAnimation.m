//
//  FHPickAnimation.m
//  FHAlertController
//
//  Created by MADAO on 16/4/20.
//  Copyright © 2016年 MADAO. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "FHPickAnimation.h"

#import "FHImagePickSheetController.h"

@interface FHPickAnimation ()

@property (nonatomic, weak) FHImagePickSheetController *presentController;

@property (nonatomic, assign) BOOL presenting;

@end

@implementation FHPickAnimation

- (instancetype)initWithPresentController:(FHImagePickSheetController *)presentController presenting:(BOOL)present
{
    if (self = [super init]) {
        self.presentController = presentController;
        self.presenting = present;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.presenting) {
        [self presentAnimation:transitionContext];
    }
    else{
        [self dismissAnimaton:transitionContext];
    }
}

- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containView = [transitionContext containerView];
    [containView addSubview:self.presentController.view];
    self.presentController.view.alpha = 0.0;
    CGFloat originY = self.presentController.actionTableView.frame.origin.y;
    self.presentController.actionTableView.frame = CGRectMake(0, containView.frame.size.height, self.presentController.actionTableView.frame.size.width, self.presentController.actionTableView.frame.size.height);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.presentController.view.alpha = 1.0;
        self.presentController.actionTableView.frame = CGRectMake(0, originY, self.presentController.actionTableView.frame.size.width, self.presentController.actionTableView.frame.size.height);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
}

- (void)dismissAnimaton:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containView = [transitionContext containerView];
    [containView addSubview:self.presentController.view];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.presentController.actionTableView.frame = CGRectMake(0, containView.frame.size.height, self.presentController.actionTableView.frame.size.width, self.presentController.actionTableView.frame.size.height);
        self.presentController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];

}
@end
