//
//  TTConnectingTableView.m
//  Assignment5
//
//  Created by ch484-mac5 on 3/26/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import "TTConnectingTableView.h"
#import "TTAppDelegate.h"


@interface TTConnectingTableView ()

@property (nonatomic, strong) NSString* activeDeviceName;

@end

@implementation TTConnectingTableView

-(BLE*)bleShield
{
    TTAppDelegate *appDelegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.bleShield;
}

-(void)scanForDevices
{
    if( self.bleShield.activePeripheral )
    {
        if( self.bleShield.activePeripheral.isConnected )
        {
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
        }
    }
    
    if( self.bleShield.peripherals )
    {
        self.bleShield.peripherals = nil;
    }
    
    [self.bleShield findBLEPeripherals:2];
    
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

    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(scanForDevices) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

}

-(void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bleShield.peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", indexPath.row);
    static NSString *CellIdentifier = @"Cell2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];


    CBPeripheral* aPeripheral = [self.bleShield.peripherals objectAtIndex:indexPath.row];
    
    self.activeDeviceName = aPeripheral.name ;
    NSString* pUUID = aPeripheral.identifier.UUIDString;
    
    [cell.textLabel setText: self.activeDeviceName ];
    [cell.detailTextLabel setText:pUUID];

    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    NSLog(@"Attemp to connect to peripherals %ld", (long)indexPath.row);
    
    CBPeripheral *aPeripheral = [self.bleShield.peripherals objectAtIndex:indexPath.row];
    
    [self.bleShield connectPeripheral:aPeripheral ];
    
    // If successfully -> move to the next view controller.
    // if not -> alert Error message!
}
@end
