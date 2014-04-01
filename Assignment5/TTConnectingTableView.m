//
//  TTConnectingTableView.m
//  Assignment5
//
//  Created by ch484-mac5 on 3/26/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import "TTConnectingTableView.h"
#import "TTControllerViewController.h"

@interface TTConnectingTableView ()


@end

@implementation TTConnectingTableView

-(void)scanForDevices
{
    if( bleShield.activePeripheral )
    {
        if( bleShield.activePeripheral.isConnected )
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
        }
    }
    
    if( bleShield.peripherals )
    {
        bleShield.peripherals = nil;
    }
    
    [bleShield findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(OnFinishedScaningDevices:) userInfo:nil repeats:NO];
}

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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(scanForDevices) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
    

//    [self.refreshControl beginRefreshing];
//    [self scanForDevices];
}



-(void) OnFinishedScaningDevices:(NSTimer *)timer
{

    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLE Delegate

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    // Recieve Data
}

NSTimer *rssiTimer;

-(void) readRSSITimer:(NSTimer *)timer
{
    [bleShield readRSSI];
}

- (void) bleDidDisconnect
{
    [rssiTimer invalidate];
}

-(void) bleDidConnect
{
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
    //self.labelRSSI.text = rssi.stringValue;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [bleShield.peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CBPeripheral* aPeripheral = [bleShield.peripherals objectAtIndex:indexPath.row];
    
    NSString* pName = aPeripheral.name ;
    NSString* pUUID = aPeripheral.identifier.UUIDString;
    
    [cell.textLabel setText: pName ];
    [cell.detailTextLabel setText:pUUID];
    
    
    return cell;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [((TTControllerViewController*)segue.destinationViewController).macAddressLabel setText:@"Hey"];
    
    TTControllerViewController* CVC = segue.destinationViewController;
    CVC.CVCData = @"Data from Table View";
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    NSLog(@"Attemp to connect to peripherals %ld", (long)indexPath.row);
    
    CBPeripheral *aPeripheral = [bleShield.peripherals objectAtIndex:indexPath.row];
    
    [bleShield connectPeripheral:aPeripheral ];
    
    // If successfully -> move to the next view controller.
    // if not -> alert Error message!
}

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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
