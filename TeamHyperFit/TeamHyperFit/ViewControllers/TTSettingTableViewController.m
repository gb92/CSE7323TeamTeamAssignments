//
//  TTSettingTableViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/5/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTSettingTableViewController.h"
#import "TTAppDelegate.h"

#import <FacebookSDK/FacebookSDK.h>

@interface TTSettingTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *activitySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;

@end

@implementation TTSettingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.activitySwitch setOn:((TTAppDelegate*)[UIApplication sharedApplication].delegate).activitySessionMode];
    
    FBSession *currentSession=[FBSession activeSession];
    if(currentSession.state == FBSessionStateOpen)
    {
        [self.facebookSwitch setOn:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onCloseButtonPressed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onActivitySelectionChanged:(UISwitch *)sender
{
    ((TTAppDelegate*)[UIApplication sharedApplication].delegate).activitySessionMode = sender.isOn;
}
- (IBAction)onFacebookSwitchChanged:(UISwitch *)sender
{
    if([self.facebookSwitch isOn])
    {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"facebookView"];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
