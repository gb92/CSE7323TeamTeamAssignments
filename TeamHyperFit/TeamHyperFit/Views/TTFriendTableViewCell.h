//
//  TTFriendTableViewCell.h
//  TeamHyperFit
//
//  Created by ch484-mac7 on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCircleImageView.h"

@interface TTFriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fitPointLabel;
@property (weak, nonatomic) IBOutlet TTCircleImageView *photoCircularImageView;


@end
