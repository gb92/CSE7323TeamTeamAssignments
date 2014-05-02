//
//  TTActivitySelectionContentViewController.m
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/2/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTActivitySelectionContentViewController.h"

@interface TTActivitySelectionContentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
