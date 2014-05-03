//
//  TMStepCountViewController.h
//  TeamFit
//
//  Created by Chatchai Wangwiwiwattana on 2/26/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMSetGoalStepViewController.h"
#import "TMStepIndicaterView.h"

typedef enum SIActivityType : NSInteger
{

    SI_ACTIVITY_STILL,
    SI_ACTIVITY_WALKING,
    SI_ACTIVITY_RUNNING,
    SI_ACTIVITY_DRIVING

}SIActivityType;


@interface TMStepCountViewController : UIViewController <TMSetGoalStepViewControllerDelegate, TMSetIndicaterViewDelegate>

@end
