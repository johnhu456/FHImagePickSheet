//
//  PreviewCheckView.h
//  FHAlertController
//
//  Created by MADAO on 16/4/22.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
A button to show if the image is marked
 */
@interface FHPreviewMarkView : UICollectionReusableView

@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (void)resetButtonImage;

@end
