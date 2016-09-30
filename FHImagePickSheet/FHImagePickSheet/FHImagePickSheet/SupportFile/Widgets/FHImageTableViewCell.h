//
//  FHImageTableViewCell.h
//  FHAlertController
//
//  Created by MADAO on 16/4/20.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHImagePickCollectionView : UICollectionView

//@property (nonatomic, assign) BOOL preview;

@end


extern NSString *const kImageCellReuseIdentifier;

@interface FHImageTableViewCell : UITableViewCell

@property (nonatomic, strong) FHImagePickCollectionView *collectionView;

@end
