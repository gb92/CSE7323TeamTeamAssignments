//
//  TTFriendRankingViewController.m
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTFriendRankingViewController.h"
#import "TTCircleImageView.h"
#import "TTFriendTableViewCell.h"

#import "TFUserModel.h"
#import "TTAppDelegate.h"

@interface TTFriendRankingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TFUserModel* userModel;

@property (weak, nonatomic) IBOutlet TTCircleImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UITableView *friendTableView;

@end

@implementation TTFriendRankingViewController

-(TFUserModel*)userModel
{
    if (!_userModel) {
        _userModel = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userModel;
    }
    
    return _userModel;
}

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
	// Do any additional setup after loading the view.
    
    self.userPhotoImageView.image = [UIImage imageNamed:@"markImg"];
    
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Event Handling

- (IBAction)onCloseButtonPressed:(id)sender
{
    [self.delegate TTFriendRankingViewControllerCloseButtonPressed:self];
}

#pragma mark -

-(void)updateInfo
{
#pragma waning It is not yet impremented.
}

#pragma mark -
#pragma mark Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    cell.nameLabel.text = @"Chatchai W.";
    cell.fitPointLabel.text = @"9,874,512";
    cell.photoCircularImageView.image = [UIImage imageNamed:@"markImg"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = cell.frame;
    frame.origin.x = 50;
    cell.frame = frame;
    cell.alpha = 0.0f;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = cell.frame;
        frame.origin.x = 0;
        cell.frame = frame;
        cell.alpha = 1.0f;
    }];
    
}

@end
