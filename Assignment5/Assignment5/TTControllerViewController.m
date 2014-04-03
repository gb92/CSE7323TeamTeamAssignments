//
//  TTControllerViewController.m
//  Assignment5
//
//  Created by ch484-mac5 on 3/31/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import "TTControllerViewController.h"
#import "TTAppDelegate.h"

@interface TTControllerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;



@property (weak, nonatomic) IBOutlet UITextField *sendDataText;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) IBOutlet UISlider *servoSlider;

@end

@implementation TTControllerViewController

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
    
    [self.deviceNameLabel setText:self.deviceName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnDidBLEConnected:) name:@"BLEDidConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidDisconnect:) name:@"BLEDidDisconnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidUpdateRSSI:) name:@"BLEUpdateRSSI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (OnBLEDidReceiveData:) name:@"BLEReceievedData" object:nil];
     
    
    
    
}

-(BLE*)bleShield
{
    TTAppDelegate *appDelegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.bleShield;
}


#pragma mark - BLE Delegate

-(void)OnDidBLEConnected:(NSNotification *)notification
{
    NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
    
    NSLog(@"This view is recieved connected package");
    
    self.deviceNameLabel.text = deviceName;
    
    [self.onOffSwitch setEnabled:YES];
    [self.servoSlider setEnabled:YES];
    
}

-(void)OnBLEDidDisconnect:(NSNotification *)notification
{
    NSLog(@"Disconnected");
    
    [self.onOffSwitch setEnabled:NO];
    [self.servoSlider setEnabled:NO];
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
    }
    else if( dataPtr[0] == 1)
    {
        [self.onOffSwitch setOn:YES];
    
        if( dataPtr[1] == 0 )
        {
            self.temperatureLabel.text = [NSString stringWithFormat:@"%d C", dataPtr[2]];
        }
        else if( dataPtr[1] == 1 )
        {
            self.lightLabel.text = [NSString stringWithFormat:@"%d light", dataPtr[2]];
        }
    }
    
}

- (IBAction)OnChangeSlider:(UISlider *)sender
{
    
    UInt8 buf[2] = {0, 0};
    
    if( [self.bleShield.activePeripheral isConnected])
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
    }
}

- (IBAction)OnSwitchChange:(UISwitch *)sender
{
    
    UInt8 buf[2] = {0, 0};
    
    if( [self.bleShield.activePeripheral isConnected])
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

- (IBAction)BLEShieldSend:(id)sender
{
    /*
    NSString *s;
    NSData *d;
    
    if (self.sendDataText.text.length > 16)
        s = [self.sendDataText.text substringToIndex:16];
    else
        s = self.sendDataText.text;
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [self.bleShield write:d];
  
  */

}


@end
