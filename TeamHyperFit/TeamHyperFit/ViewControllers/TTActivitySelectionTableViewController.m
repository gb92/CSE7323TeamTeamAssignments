//
//  TTActivitySelectionTableViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/5/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTActivitySelectionTableViewController.h"
#import "TTActivitySelectionViewTableViewCell.h"
#import "TFGesture.h"
#import "TTAppDelegate.h"
#import "TTSessionViewController.h"


@interface TTActivitySelectionTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *activityTableView;

@property (strong, nonatomic) NSArray* gestures;

@end

@implementation TTActivitySelectionTableViewController


-(NSArray*)gestures
{
    if (!_gestures) {
        _gestures = ((TTAppDelegate*)[[UIApplication sharedApplication]delegate]).gestures;
    }
    
    return _gestures;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.activityTableView.dataSource = self;
    self.activityTableView.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onCloseButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.gestures count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTActivitySelectionViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
    
    cell.activityNameLabel.text = ((TFGesture*)self.gestures[indexPath.row]).name;
    cell.activityImageView.image = [UIImage imageNamed:((TFGesture*)self.gestures[indexPath.row]).imageName];

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    TTActivitySelectionViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
    
    
    TTSessionViewController* sessionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SessionView"];
    
    sessionVC.activityName = ((TFGesture*)self.gestures[indexPath.row]).name;
    sessionVC.activityImageName = ((TFGesture*)self.gestures[indexPath.row]).imageName;
    [self.navigationController pushViewController:sessionVC animated:YES];
     
}

//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}



//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}
//
//
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(indexPath.row == 0)
//    {
//        return  UITableViewCellEditingStyleNone;
//    }
//    else if(indexPath.row == 1)
//    {
//        return  UITableViewCellEditingStyleInsert;
//    }
//    else
//    {
//        
//        return UITableViewCellEditingStyleDelete;
//    }
//}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
