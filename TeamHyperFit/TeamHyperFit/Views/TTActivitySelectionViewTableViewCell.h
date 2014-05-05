//
//  TTActivitySelectionViewTableViewCell.h
//  TeamHyperFit
//
//  Created by Mark Wang on 5/5/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTActivitySelectionViewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;

@end
