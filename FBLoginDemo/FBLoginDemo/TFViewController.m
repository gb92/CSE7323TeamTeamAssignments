//
//  TFViewController.m
//  FBLoginDemo
//
//  Created by Gavin Benedict on 4/23/14.
//  Copyright (c) 2014 TeamFit. All rights reserved.
//

#import "TFViewController.h"
#import "TFAppDelegate.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@interface TFViewController ()
@property (weak, nonatomic) MSClient *client;
@end

@implementation TFViewController

- (MSClient *) client
{
    if(_client == nil)
    {
        _client=[(TFAppDelegate *) [[UIApplication sharedApplication] delegate] client];
    }
    return _client;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    MSTable *demoTable=[self.client tableWithName:@"demotable"];
    NSDictionary *data=@{@"column": @"This is some data, yay!!!"};
    [demoTable insert:data completion:^(NSDictionary *item, NSError *error) {
        NSLog(error);
    }];
    [self.client loginWithProvider:@"facebook" controller:self animated:true completion:^(MSUser *user, NSError *error) {
        NSLog(@"%d",user.userId);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
