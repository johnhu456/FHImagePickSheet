//
//  ViewController.m
//  FHImagePickSheet
//
//  Created by MADAO on 16/9/30.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import "ViewController.h"
#import "ViewController.h"
#import "FHImagePickSheetController.h"
#import "FHPickAnimation.h"

@interface ViewController ()<FHImagePickSheetDelegate,UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) FHImagePickSheetController *pickSheetController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pickSheetController = [[FHImagePickSheetController alloc] init];
    //    self.pickSheetController.actionCellHeight = 60;
    //    self.pickSheetController.previewPhotoHeight = 30;
    //    self.pickSheetController.selectedPhotoHeight =100;
    __weak typeof(self.pickSheetController) pickSheet = self.pickSheetController;
    
    //    self.pickSheetController = [[FHImagePickSheetController alloc] init];
    FHPickSheetAction * action3 = [[FHPickSheetAction alloc] initWithTitle:@"action1" andActionHandler:^{
        [pickSheet fetchSelectedImageWithCompleteHandle:^(NSArray *imageArray) {
            NSLog(@"%@",imageArray);
        }];
    }];
    FHPickSheetAction * action4 = [[FHPickSheetAction alloc] initWithTitle:@"action2" andActionHandler:^{
        NSLog(@"2");
    }];
    [self.pickSheetController addPickSheetAction:action3];
    [self.pickSheetController addPickSheetAction:action4];
    self.pickSheetController.pickSheetDelegate = self;
}

- (IBAction)handleShowPickSheetButton:(id)sender {
    [self presentViewController:self.pickSheetController animated:YES completion:nil];
}

- (void)imagePickSheetDidFinishHide:(FHImagePickSheetController *)pickSheetController
{
    NSLog(@"HIDE");
}

- (void)imagePickSheetDidFinishShow:(FHImagePickSheetController *)pickSheetController
{
    NSLog(@"SHOW");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
