//
//  TTSessionViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTSessionViewController.h"

@interface TTSessionViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeBigButton;
@property (weak, nonatomic) IBOutlet UILabel *centerNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)closeButton:(UIButton *)sender;

@end

@implementation TTSessionViewController

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
    
    self.centerNumberLabel.hidden = YES;
    self.closeBigButton.hidden = YES;
    
    
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

- (IBAction)closeButton:(UIButton *)sender
{
    
}
@end
