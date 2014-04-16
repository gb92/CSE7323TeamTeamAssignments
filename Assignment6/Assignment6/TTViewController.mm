//
//  TTViewController.m
//  Assignment6
//
//  Created by install on 4/10/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTViewController.h"
#import "GestureTrainner.h"

@interface TTViewController ()



@end

@implementation TTViewController
{
    GestureTrainner *gTrainner;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    gTrainner = new GestureTrainner();
    
    float t1[2] = {0,0};
    float t2[2] = {10,10};
    float t3[2] = {20,20};
    float t4[2] = {30,30};
    
    gTrainner->addTrainningVector( t1, 1);
    gTrainner->addTrainningVector( t2, 1);
    gTrainner->addTrainningVector( t3, 2);
    gTrainner->addTrainningVector( t4, 2);
    
    gTrainner->fit();
    
    float t5[2] = {30,30};
    
    int r = gTrainner->predict( t5 );
    
    NSLog(@"r = %d", r );
}

-(void)dealloc
{
    if(gTrainner)
    {
        delete gTrainner;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
