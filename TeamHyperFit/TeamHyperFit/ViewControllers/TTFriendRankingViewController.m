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

#import "UIScrollView+GifPullToRefresh.h"

@interface TTFriendRankingViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;

@property (strong, nonatomic) TTUserInfoHandler *userInfoHandler;

@property (weak, nonatomic) IBOutlet TTCircleImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UITableView *friendTableView;
@property (weak, nonatomic) IBOutlet UILabel *fitpoitLabel;

@end

@implementation TTFriendRankingViewController

-(TTUserInfoHandler *)userInfoHandler
{
    if (!_userInfoHandler) {
        _userInfoHandler = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userInforHandler;
    }
    
    return _userInfoHandler;
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
    
    [self setupPullToRefresh];
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

-(void)setupPullToRefresh
{
    NSMutableArray *TwitterMusicDrawingImgs = [NSMutableArray array];
    NSMutableArray *TwitterMusicLoadingImgs = [NSMutableArray array];
    for (int i  = 0; i <= 27; i++) {
        NSString *fileName = [NSString stringWithFormat:@"sun_00%03d.png",i];
        [TwitterMusicDrawingImgs addObject:[UIImage imageNamed:fileName]];
    }
    
    for (int i  = 28; i <= 109; i++) {
        NSString *fileName = [NSString stringWithFormat:@"sun_00%03d.png",i];
        [TwitterMusicLoadingImgs addObject:[UIImage imageNamed:fileName]];
    }
    
    [self.containerScrollView addPullToRefreshWithDrawingImgs:TwitterMusicDrawingImgs andLoadingImgs:TwitterMusicLoadingImgs andActionHandler:^{
        
        [self updateInfo];
        [self reloadFriendList];
        
        [self.containerScrollView performSelector:@selector(didFinishPullToRefresh) withObject:nil afterDelay:3];
        
    }];
    
    self.containerScrollView.alwaysBounceVertical = YES;
    
}

-(void)reloadFriendList
{
    [self.userInfoHandler updateFriendsInfo:^(NSError *error)
     {
         [self.friendTableView reloadData];
         [self.containerScrollView performSelector:@selector(didFinishPullToRefresh) withObject:nil afterDelay:0];
     }];
}

-(void)updateInfo
{
    self.fitpoitLabel.text = [NSString stringWithFormat:@"%d", [self.userInfoHandler.userInfo.fitPoints intValue] + [self.userInfoHandler.userInfo.todaySteps intValue] ];
    self.userPhotoImageView.image = self.userInfoHandler.userInfo.profileImage;

    if( [self.userInfoHandler.friendsInfo count] <= 0 )
    {
        [self reloadFriendList];
    }
}

#pragma mark -
#pragma mark Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userInfoHandler.friendsInfo count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    TTFriendModel* friend = ((TTFriendModel*)self.userInfoHandler.friendsInfo[indexPath.row]);
    
    cell.nameLabel.text = friend.firstName;
    cell.fitPointLabel.text = [NSString stringWithFormat:@"%d", [friend.fitPoints intValue]];
    cell.photoCircularImageView.image = friend.profileImage;
    
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
