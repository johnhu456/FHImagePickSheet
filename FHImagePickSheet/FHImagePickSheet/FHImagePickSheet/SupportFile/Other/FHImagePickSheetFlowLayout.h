//
//  FHImagePickSheetFlowLayout.h
//  FHImagePickSheet
//
//  Created by MADAO on 16/4/18.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHImagePickSheetFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) NSIndexPath *centerIndexPath;

@property (nonatomic, assign) BOOL showPreview;

@end
