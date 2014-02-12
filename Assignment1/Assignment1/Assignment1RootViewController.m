//
//  Assignment1RootViewController.m
//  Assignment1
//
//  Created by Gavin Benedict on 1/29/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import "Assignment1RootViewController.h"
#import "Assignment1ImageViewController.h"

@interface Assignment1RootViewController ()<UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController* pageViewController;
@property (strong, nonatomic) NSArray *pageContent;



@end

@implementation Assignment1RootViewController


-(UIPageViewController *) pageViewController
{
    if(!_pageViewController)
    {
        _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        _pageViewController.dataSource = self;
    }

    return _pageViewController;
}


-(NSArray *) pageContent
{
    if(!_pageContent)
    {
        _pageContent=@[@"SMULogo",@"meow",@"badsimulator"];
    }
    return _pageContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIViewController *firstViewController=(UIViewController *)[self createViewControllerFromIndex:0];
    
    NSArray *viewControllers =@[firstViewController];
    
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO completion:nil];
    
    self.pageViewController.view.frame = CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height-95);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}


-(NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageContent count];

}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

-(UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index= ((Assignment1ImageViewController *) viewController).pageIndex;
    
    if(index == NSNotFound)
    {
        NSLog(@"Index not found in after");
        return nil;
    }
    
    index++;
    
    if(index == [self.pageContent count]){
        return nil;
    }
    
    return [self createViewControllerFromIndex:index];
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    // get index from the current view controller
    NSUInteger index = ((Assignment1ImageViewController*) viewController).pageIndex;
    
    if((index==0) || (index==NSNotFound))
    {
        return nil;
    }
    
    index--;
    
    return [self createViewControllerFromIndex:index];
}

-(UIViewController *) createViewControllerFromIndex:(NSUInteger) index{
    if(index >= [self.pageContent count])
        return nil;
    
    Assignment1ImageViewController *VC =[self.storyboard instantiateViewControllerWithIdentifier: @"ImageViewController"];
    
    VC.imageName=self.pageContent[index];
    VC.pageIndex=index;
    
    return VC;
}
@end
