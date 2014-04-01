//
//  TTControllerViewController.m
//  Assignment5
//
//  Created by ch484-mac5 on 3/31/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import "TTControllerViewController.h"

@interface TTControllerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recivedDataLabel;
@property (weak, nonatomic) IBOutlet UITextField *sendDataText;

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
    self.bleShield.delegate = self;
}

-(BLE*)bleShield
{
    if(!_bleShield)
    {
#pragma warning "this view should not construct ble by itself"
        
//        _bleShield = [[BLE alloc]init];
//        [_bleShield controlSetup];
    }
    
    return _bleShield;
}

#pragma mark - BLE Delegate

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    self.recivedDataLabel.text = s;
    
    NSLog(@"recived data in TTControllerViewController.h");
}

NSTimer *rssiTimer;

-(void) readRSSITimer:(NSTimer *)timer
{
    [self.bleShield readRSSI];

}

- (void) bleDidDisconnect
{
    [rssiTimer invalidate];
    NSLog(@"Disconected in TTControllerViewController.h");
}

-(void) bleDidConnect
{
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
    
    NSLog(@"connected in TTControllerViewController.h");
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
    //self.labelRSSI.text = rssi.stringValue;
}

- (IBAction)BLEShieldSend:(id)sender
{
    NSString *s;
    NSData *d;
    
    if (self.sendDataText.text.length > 16)
        s = [self.sendDataText.text substringToIndex:16];
    else
        s = self.sendDataText.text;
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.bleShield write:d];
}


@end
