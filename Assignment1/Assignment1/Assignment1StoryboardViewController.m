//
//  Assignment1StoryboardViewController.m
//  Assignment1
//
//  Created by Gavin Benedict on 2/5/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import "Assignment1StoryboardViewController.h"

@interface Assignment1StoryboardViewController ()

@end

@implementation Assignment1StoryboardViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateFromSegmentedControl:(id)sender {
    
    NSString *selectedText =[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]];
    if([selectedText compare:@"Yellow"] == 0)
    {
        [self.view setBackgroundColor:[UIColor yellowColor]];
    }
    else if([selectedText compare:@"Red"] == 0)
    {
        [self.view setBackgroundColor:[UIColor redColor]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
