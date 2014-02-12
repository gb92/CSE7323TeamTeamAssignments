//
//  Assignment1ProgrammaticViewController.m
//  Assignment1
//
//  Created by Gavin Benedict on 2/5/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import "Assignment1ProgrammaticViewController.h"
#import "Assignment1AppDelegate.h"
#import "FavoriteWord.h"

@interface Assignment1ProgrammaticViewController ()

@property (nonatomic, strong) UILabel *myProgrammaticLabel;
@property (nonatomic, strong) NSTimer *myTimer;

@property (nonatomic, strong) NSArray *myFavoriteWords;

@end

@implementation Assignment1ProgrammaticViewController


-(UILabel *) myProgrammaticLabel
{
    if(!_myProgrammaticLabel)
    {
        _myProgrammaticLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 20)];
        [_myProgrammaticLabel setTextColor:[UIColor blackColor]];
        [_myProgrammaticLabel setBackgroundColor:[UIColor clearColor]];
        
    }
    return _myProgrammaticLabel;
    
}

-(NSArray *) myFavoriteWords
{
    if(!_myFavoriteWords)
    {
        Assignment1AppDelegate* appDelegate= [UIApplication sharedApplication].delegate;
        
        _myFavoriteWords=[appDelegate getAllFavoriteWordsFromModel];
    }
    return _myFavoriteWords;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.view addSubview:self.myProgrammaticLabel];
    [self.myProgrammaticLabel setText:@"Team Team's awesome label"];
    
    self.myTimer=[NSTimer scheduledTimerWithTimeInterval:5
                                             target:self
                                           selector:@selector(timeFiredEventHandler)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.myTimer forMode:NSRunLoopCommonModes];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeSystem];
    
    [button setTitle:@"Cool Button" forState:UIControlStateNormal];
    button.frame=CGRectMake(100.0, 300.0, 250.0, 20);
    
    [self.view addSubview:button];
    
    UISlider *slider=[[UISlider alloc]init];
    
    slider.frame=CGRectMake(100.0, 200.0, 50.0, 20.0);
    
    [self.view addSubview:slider];
    
    
}

-(void) timeFiredEventHandler
{
    [self.myProgrammaticLabel setText:@"The timer fired"];
    
    if([self.myFavoriteWords count]>0)
    {
        NSInteger randomIndex=arc4random()%[self.myFavoriteWords count];
        
        FavoriteWord *randomFavorite=(FavoriteWord *)self.myFavoriteWords[randomIndex];
        
        [self.myProgrammaticLabel setText:[NSString stringWithFormat:@"5 second fav word: %@", randomFavorite.favoriteWord]];
    }
    else{
        [self.myProgrammaticLabel setText:@"You have no favorite words"];
    }
}
@end
