//
//  TTActivityCollectionViewCell.h
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 5/2/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTActivityCollectionViewCell : UICollectionViewCell

@property (nonatomic) NSUInteger itemIndex;

@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;

@end
