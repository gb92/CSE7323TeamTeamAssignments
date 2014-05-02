//
//  TTActivitySelectionContainerViewController.m
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/2/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTActivitySelectionContainerViewController.h"
#import "TTActivitySelectionContentViewController.h"
#import "TTActivityCollectionViewController.h"

#import "TTAppDelegate.h"
#import "TFGesture.h"

@interface TTActivitySelectionContainerViewController ()<UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController* pageViewContoller;
@property (strong, nonatomic) TTActivityCollectionViewController* collectionViewController;

@property (strong, nonatomic) NSArray* gestures;

@end

@implementation TTActivitySelectionContainerViewController

-(NSArray*)gestures
{
    if (!_gestures) {
        _gestures = ((TTAppDelegate*)[[UIApplication sharedApplication]delegate]).gestures;
    }
    
    return _gestures;
}

#pragma mark -- View Controller Life Cycle.

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.pageViewContoller = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityPageView"];
    self.pageViewContoller.dataSource = self;
    
    TTActivitySelectionContentViewController *startingPage = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingPage];
    [self.pageViewContoller setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewContoller.view.frame = CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height - (170+70));
    
    [self addChildViewController:_pageViewContoller];
    [self.view addSubview:_pageViewContoller.view];
    [self.pageViewContoller didMoveToParentViewController:self];
    
    //----------------------------------------------------------------
    
    self.collectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityCollection"];
    
    self.collectionViewController.view.frame = CGRectMake(0,self.view.frame.size.height - 170, self.view.frame.size.width, 170);
    
    [self addChildViewController:_collectionViewController];
    [self.view addSubview:_collectionViewController.view ];
    [self.collectionViewController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Contoller
-(TTActivitySelectionContentViewController*)viewControllerAtIndex:(NSUInteger) index
{
    if (([self.gestures count] == 0) || (index >= [self.gestures count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TTActivitySelectionContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityContent"];
    pageContentViewController.pageIndex = index;
    
    pageContentViewController.activityImageName = ((TFGesture*)self.gestures[index]).imageName;
    pageContentViewController.activityName = ((TFGesture*)self.gestures[index]).name;
    
    return pageContentViewController;
}

#pragma mark -- Page view Datasource

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TTActivitySelectionContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TTActivitySelectionContentViewController*) viewController).pageIndex;
    
    index ++;
    
    if(index == [self.gestures count])
    {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.gestures count];
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
