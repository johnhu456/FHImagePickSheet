//
//  FHImagePickSheetController.h
//  FHImagePickSheet
//
//  Created by MADAO on 16/4/15.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHPickActionCell.h"

@class FHImagePickSheetController;
@protocol FHImagePickSheetDelegate <NSObject>
@optional

/**
 Called when the FHImagePickSheetController is displayed
 */
- (void)imagePickSheetDidFinishShow:(FHImagePickSheetController *)pickSheetController;

/**
 Called when the FHImagePickSheetController is hided
 */
- (void)imagePickSheetDidFinishHide:(FHImagePickSheetController *)pickSheetController;

@end

@interface FHImagePickSheetController : UIViewController

@property (nonatomic, weak) id<FHImagePickSheetDelegate> pickSheetDelegate;

/**
 The Tableview that displays the photo selection cell and button cells,You can modify the color and other properties, do not arbitrarily modify the frame property.
 */
@property (nonatomic, strong) UITableView *actionTableView;
/**
 The height of the photo selection cell in preview status,default is 150;
 */
@property (nonatomic, assign) CGFloat previewPhotoHeight;
/**
 The height of the photo selection cell in selected status,default is 240;
 */
@property (nonatomic, assign) CGFloat selectedPhotoHeight;

/**
  The height of the action cell,default is 44;
 */
@property (nonatomic, assign) CGFloat actionCellHeight;

/**
 
 Creates the FHImagePickSheetController with a specific set of FHPickSheetAction

 @param action The actions used to display choice

 @return FHImagePickSheetControlleo object
 */
- (instancetype)initWithActions:(NSArray *)actions;

/**
 Add Actions

 @param action
 */
- (void)addPickSheetAction:(FHPickSheetAction *)action;


/**
 Get the image you selected

 @param handle callbck，the imageArray contains UIImage objects.
 */
- (void)fetchSelectedImageWithCompleteHandle:(void(^)(NSArray *imageArray))handle;

@end

