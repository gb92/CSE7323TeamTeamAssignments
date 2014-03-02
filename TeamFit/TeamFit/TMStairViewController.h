//
//  TMStairViewController.h
//  TeamFit
//
//  Created by Mark Wang on 2/28/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMStairSettingViewController.h"

@interface TMStairViewController : UIViewController<TMStairSettingViewControllerDelegate>

@property(nonatomic)BOOL isActivated;

@end
