//
//  TTControllerTableViewController.m
//  Assignment5
//
//  Created by Mark Wang on 4/3/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import "TTControllerTableViewController.h"
#import "TTAppDelegate.h"
#import "BLE.h"

@interface TTControllerTableViewController ()

@property (strong, nonatomic) NSString *deviceName;
@property (strong, nonatomic, readonly) BLE *bleShield;

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightIconlabel;

@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) IBOutlet UISlider *servoSlider;
@property (weak, nonatomic) IBOutlet UILabel *roofAngleLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *temperatureCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *lightCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *roofCell;

@property (nonatomic) BOOL isDeviceReady;

@end

@implementation TTControllerTableViewController

-(BLE*)bleShield
{
    TTAppDelegate *appDelegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.bleShield;
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
    
    if (self.bleShield.activePeripheral)
    {
        [self.deviceNameLabel setText:self.bleShield.activePeripheral.name];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnDidBLEConnected:) name:@"BLEDidConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidDisconnect:) name:@"BLEDidDisconnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidUpdateRSSI:) name:@"BLEUpdateRSSI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (OnBLEDidReceiveData:) name:@"BLEReceievedData" object:nil];
    
    self.isDeviceReady = YES;
    [self disableSensors];
}

-(void)enableSensors
{
    if( !self.isDeviceReady )
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.roofCell.backgroundColor = [UIColor whiteColor];
            self.lightCell.backgroundColor = [UIColor whiteColor];
            self.temperatureCell.backgroundColor = [UIColor whiteColor];
        }];
        [self.servoSlider setEnabled:YES];
        self.isDeviceReady = YES;
    }
}

-(void)disableSensors
{
    if( self.isDeviceReady )
    {
        UIColor *disableColor =[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.roofCell.backgroundColor = disableColor;
            self.lightCell.backgroundColor = disableColor;
            self.temperatureCell.backgroundColor = disableColor;
            
        }];
        [self.servoSlider setEnabled:NO];
        self.isDeviceReady = NO;
    }
}

#pragma mark - BLE Delegate

-(void)OnDidBLEConnected:(NSNotification *)notification
{
    NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
    
    [self.deviceNameLabel setText:deviceName];
    
    NSLog(@"This view is recieved connected package");
}

-(void)OnBLEDidDisconnect:(NSNotification *)notification
{
    NSLog(@"Disconnected");
    
}

-(void)OnBLEDidUpdateRSSI:(NSNotification *)notification
{
    NSNumber* rssi = [[notification userInfo]
                      objectForKey:@"RSSI"];
    NSLog(@"Updated RSSI%@", rssi);
    
}


-(void)OnBLEDidReceiveData:(NSNotification *)notification
{
    NSData* mydata = [[notification userInfo]
                      objectForKey:@"data"];
    
    unsigned char *dataPtr = (unsigned char*)mydata.bytes;
    
    if( dataPtr[0] == 0 )
    {
        [self.onOffSwitch setOn:NO];
        [self disableSensors];
    }
    else if( dataPtr[0] == 1)
    {
        [self.onOffSwitch setOn:YES];
        [self enableSensors];
        
        self.temperatureLabel.text = [NSString stringWithFormat:@"%d°", dataPtr[1]];
        self.lightLabel.text = [NSString stringWithFormat:@"%d", dataPtr[2]];
        
        float map = (dataPtr[2] / 300.0f);
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.lightIconlabel setTextColor:[UIColor colorWithRed:(1.0-map) green:0.0 blue:0.0 alpha:1.0]];
        }];
        
    }
    
}

- (IBAction)OnChangeSlider:(UISlider *)sender
{
    
    UInt8 buf[2] = {0, 0};
    
    if( self.bleShield.activePeripheral)
    {
        /*
         0 = Servo
         1 = Motor
         2 = LED
         */
        buf[0] = 0;
        
        
        buf[1] = (UInt8)self.servoSlider.value;
        
        
        NSData *data = [[NSData alloc] initWithBytes:buf length:2];
        
        [self.bleShield write:data];
        
        self.roofAngleLabel.text = [NSString stringWithFormat:@"%.0f°", self.servoSlider.value ];
    }
}

- (IBAction)OnSwitchChange:(UISwitch *)sender
{
    
    UInt8 buf[2] = {0, 0};
    
    if( self.bleShield.activePeripheral)
    {
        /*
         0 = Servo
         1 = Motor
         2 = LED
         */
        buf[0] = 2;
        
        
        if( [self.onOffSwitch isOn])
        {
            buf[1] = 1;
        }
        
        NSData *data = [[NSData alloc] initWithBytes:buf length:2];
        
        [self.bleShield write:data];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

@end
