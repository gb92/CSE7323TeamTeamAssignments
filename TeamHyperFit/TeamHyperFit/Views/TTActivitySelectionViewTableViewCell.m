//
//  TTActivitySelectionViewTableViewCell.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/5/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTActivitySelectionViewTableViewCell.h"

@implementation TTActivitySelectionViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
