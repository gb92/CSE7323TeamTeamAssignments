//
//  TTFriendTableViewCell.m
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTFriendTableViewCell.h"

@implementation TTFriendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    [self performSelector:@selector(runNoteAnimation) withObject:nil afterDelay:0.1];
//    
//    return self;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void)runNoteAnimation
//{
//    CGRect endFrame = self.frame;
//    endFrame.origin.x = 50;
//    
//    [UIView animateWithDuration:0.3
//                          delay:0
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         self.frame = endFrame;
//                     }
//                     completion:nil];
//}

@end
