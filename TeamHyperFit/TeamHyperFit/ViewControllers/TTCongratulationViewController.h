//
//  TTCongratulationView.h
//  TeamHyperFit
//
//  Created by Mark Wang on 5/6/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTCongratulationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong,nonatomic) UIImage* image;


@property (nonatomic) NSInteger fitPoints;

@end
