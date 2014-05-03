//
//  TTActivitySelectionContentViewController.m
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/2/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTActivitySelectionContentViewController.h"
#import "TTSessionViewController.h"

@interface TTActivitySelectionContentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tabGestureRecognizer;

@end

@implementation TTActivitySelectionContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityImageView.image = [UIImage imageNamed:self.activityImageName];
    self.activityNameLabel.text = self.activityName;
    
    [self.tabGestureRecognizer addTarget:self action:@selector(startSession)];
}

-(void)startSession
{
    NSLog(@"Start Session %lu", (unsigned long)self.pageIndex);

    TTSessionViewController* sessionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SessionView"];
    [self presentViewController:sessionVC animated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
