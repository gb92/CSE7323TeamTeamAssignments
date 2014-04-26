//
//  TTActionTableViewCell.h
//  TeamHyperFit
//
//  Created by Mark Wang on 4/25/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTActionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *actionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRepsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *actionImageView;

@end
