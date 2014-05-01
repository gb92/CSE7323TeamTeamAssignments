//
//  TTFriendRankingViewController.m
//  TeamHyperFit
//
//  Created by ch484-mac7 on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTFriendRankingViewController.h"
#import "TTCircleImageView.h"
#import "TTFriendTableViewCell.h"

@interface TTFriendRankingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet TTCircleImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UITableView *friendTableView;

@end

@implementation TTFriendRankingViewController

- (IBAction)onCloseButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --Table View Datasource

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

@end
