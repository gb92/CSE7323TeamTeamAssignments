//
//  TTStatusViewController.h
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/25/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTStatusViewController;

@protocol TTStatusViewControllerDelegate <NSObject>

-(void) TTStatusViewControllerOnCloseButtonPressed:(TTStatusViewController*) view;

@end

@interface TTStatusViewController : UIViewController

@property (weak, nonatomic) id<TTStatusViewControllerDelegate> delegate;

@end
