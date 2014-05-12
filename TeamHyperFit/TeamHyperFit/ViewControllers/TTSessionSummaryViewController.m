//
//  TTSessionSummaryViewController.m
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/8/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTSessionSummaryViewController.h"
#import "TTHeartRateGraph.h"

@interface TTSessionSummaryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *rapsNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *fitpointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet TTHeartRateGraph *heartRateView;

@property (weak, nonatomic) IBOutlet UILabel *warningView;

@end

@implementation TTSessionSummaryViewController

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
    
    self.activityNameLabel.text = self.activityName;
    self.activityImageView.image = [UIImage imageNamed:self.activityImageName];
    self.fitpointsLabel.text = [NSString stringWithFormat:@"%ld", self.numberRaps * 100];
    self.rapsNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)self.numberRaps];
    
    if ([self.heartRateData count] > 0)
    {
        self.heartRateView.data = [NSArray arrayWithArray:self.heartRateData];
        self.heartRateView.dataLabel = [NSArray arrayWithArray:self.heartRateZone];
    }
    else
    {
        [self.warningView setHidden:YES];
    }
    
    #warning Please Remove This Test code.
    //! Only for testing.
    self.logTextArea.text = self.log;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseButtonPressed:(UIButton *)sender
{
    [self.delegate TTSessionSummaryViewControllerOnCloseButtonPressed:self];
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
