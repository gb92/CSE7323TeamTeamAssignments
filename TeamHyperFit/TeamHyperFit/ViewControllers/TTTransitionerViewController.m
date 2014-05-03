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
@property (strong, nonatomic) UIPageViewController *pageViewController;
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
    
    //! Begin with Main Day State View
    self.currentViewIndex = 1;
    
    UIViewController* startView = [self getViewControllerAtIndex:self.currentViewIndex];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPageView"];
    self.pageViewController.dataSource = self;
    [self.pageViewController setViewControllers:@[startView] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
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
    UIViewController* friendVC = [self getViewControllerAtIndex:2];
    
    [self.pageViewController setViewControllers:@[friendVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)TTMainViewControllerOnStatButtonPressed:(TTMainViewController*) view
{
    UIViewController* statVC = [self getViewControllerAtIndex:0];
    
    [self.pageViewController setViewControllers:@[statVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

#pragma mark -
#pragma mark TTFriendsDelegate

-(void)TTFriendRankingViewControllerCloseButtonPressed:(TTFriendRankingViewController *)view
{
    UIViewController* mainVC = [self getViewControllerAtIndex:1];
    
    [self.pageViewController setViewControllers:@[mainVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

#pragma mark -
#pragma mark TTStatusDelegate

-(void)TTStatusViewControllerOnCloseButtonPressed:(TTStatusViewController *)view
{
    UIViewController* mainVC = [self getViewControllerAtIndex:1];
    
    [self.pageViewController setViewControllers:@[mainVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}


#pragma mark -
#pragma mark UIPageViewDataSource

-(UIViewController*)getViewControllerAtIndex:(NSInteger)index
{
    UIViewController *returnVC = nil;
    switch (index) {
        case 0:
            returnVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StatView"];
            ((TTStatusViewController*)returnVC ).delegate = self;
            break;
        case 1:
            returnVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TodayStateView"];
            ((TTMainViewController*)returnVC ).delegate = self;
            break;
        case 2:
            returnVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsView"];
            ((TTFriendRankingViewController*)returnVC ).delegate = self;
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
