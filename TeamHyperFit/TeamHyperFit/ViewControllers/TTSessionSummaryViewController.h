//
//  TTSessionSummaryViewController.h
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/8/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTViewController.h"

@class TTSessionSummaryViewController;

@protocol TTSessionSummaryViewControllerDelegate <NSObject>

-(void)TTSessionSummaryViewControllerOnCloseButtonPressed:(TTSessionSummaryViewController*)sender;

@end

@interface TTSessionSummaryViewController : TTViewController

@property (weak, nonatomic) id<TTSessionSummaryViewControllerDelegate> delegate;


@property (strong, nonatomic) NSString *activityName;
@property (strong, nonatomic) NSString *activityImageName;
@property (nonatomic) NSInteger numberRaps;

//! Only For Testing
#warning Please Remove This Testing Code.
@property (weak, nonatomic) IBOutlet UITextView *logTextArea;
@property (strong, nonatomic) NSString *log;

@end
