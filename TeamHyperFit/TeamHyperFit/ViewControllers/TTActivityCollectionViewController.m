//
//  TTActivityCollectionViewController.m
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/2/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTActivityCollectionViewController.h"
#import "TTActivityCollectionViewCell.h"

@interface TTActivityCollectionViewController ()

@end

@implementation TTActivityCollectionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    TTActivityCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ActivityCell" forIndexPath:indexPath];
    
    cell.activityNameLabel.text = @"TestActivity";
    cell.activityImageView.image = [UIImage imageNamed:@"situpBigIcon"];
    
    return cell;
}


@end
