//
//  TTActivitySelectionContentViewController.m
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 5/2/14.
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

#pragma mark -
#pragma mark ViewController Life Cycle.

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(void)startSession
{

    TTSessionViewController* sessionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SessionView"];
    [self presentViewController:sessionVC animated:YES completion:^{}];

}


@end
