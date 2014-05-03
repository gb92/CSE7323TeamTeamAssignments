//
//  TTMainViewController.h
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTMainViewController;

@protocol TTMainViewControllerDelegate <NSObject>

-(void) TTMainViewControllerOnStatButtonPressed:(TTMainViewController*) view;
-(void) TTMainViewControllerOnFriendsButtonPressed:(TTMainViewController*) view;

@end

@interface TTMainViewController : UIViewController

@property (weak, nonatomic) id<TTMainViewControllerDelegate> delegate;

@end
