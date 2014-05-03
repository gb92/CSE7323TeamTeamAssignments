//
//  TTTransitionerViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/2/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTTransitionerViewController.h"
#import "TTMainViewController.h"
#import "TTStatusViewController.h"
#import "TTFriendRankingViewController.h"


@interface TTTransitionerViewController () <UIPageViewControllerDataSource,TTMainViewControllerDelegate, TTFriendRankingViewControllerDelegate, TTStatusViewControllerDelegate >

@property (nonatomic) NSUInteger currentViewIndex;

@property (strong, nonatomic) UIPageViewController          *pageViewController;
@property (strong, nonatomic) TTStatusViewController        *statusViewController;
@property (strong, nonatomic) TTMainViewController          *mainViewController;
@property (strong, nonatomic) TTFriendRankingViewController *friendViewController;

@end

@implementation TTTransitionerViewController

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

    //! Initial all 3 views
    self.statusViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StatView"];
    self.statusViewController.delegate = self;

    self.mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TodayStateView"];
    self.mainViewController.delegate = self;
    
    self.friendViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsView"];
    self.friendViewController.delegate = self;
    

    //! Init page view.
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPageView"];
    self.pageViewController.dataSource = self;
    [self.pageViewController setViewControllers:@[self.mainViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark TTMainViewDelegate
-(void)TTMainViewControllerOnFriendsButtonPressed:(TTMainViewController*) view
{
    [self.pageViewController setViewControllers:@[self.friendViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)TTMainViewControllerOnStatButtonPressed:(TTMainViewController*) view
{
    [self.pageViewController setViewControllers:@[self.statusViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

#pragma mark -
#pragma mark TTFriendsDelegate

-(void)TTFriendRankingViewControllerCloseButtonPressed:(TTFriendRankingViewController *)view
{
    [self.pageViewController setViewControllers:@[self.mainViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

#pragma mark -
#pragma mark TTStatusDelegate

-(void)TTStatusViewControllerOnCloseButtonPressed:(TTStatusViewController *)view
{
    [self.pageViewController setViewControllers:@[self.mainViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}


#pragma mark -
#pragma mark UIPageViewDataSource

-(UIViewController*)getViewControllerAtIndex:(NSInteger)index
{
    UIViewController *returnVC = nil;
    switch (index) {
        case 0:
            returnVC = self.statusViewController;
            break;
        case 1:
            returnVC = self.mainViewController;
            break;
        case 2:
            returnVC = self.friendViewController;
            break;
        default:
            break;
    }
    
    return returnVC;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = -1;
    
    if( [viewController isKindOfClass:[TTMainViewController class]])
    {
        index = 2;
    }
    else if ([viewController isKindOfClass:[TTStatusViewController class]])
    {
        index = 1;
    }

    return [self getViewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = -1;
    
    if( [viewController isKindOfClass:[TTMainViewController class]])
    {
        index = 0;
    }
    else if ([viewController isKindOfClass:[TTFriendRankingViewController class]])
    {
        index = 1;
    }

    return [self getViewControllerAtIndex:index];
}


@end
