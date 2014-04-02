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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnDidBLEConnected:) name:@"BLEDidConnected" object:nil];
}

-(BLE*)bleShield
{
    TTAppDelegate *appDelegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.bleShield;
}


#pragma mark - BLE Delegate

-(void)OnDidBLEConnected:(NSNotification *)notification
{
    //TTAppDelegate *postingObject = [notification object];
    NSString *string = [[notification userInfo]
                        objectForKey:@"String"];
    
    NSLog(@"View connectedkdkdkdkdkdksdfsdfsdfsdfsdfsdfsdfdsf %@", string);
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    self.recivedDataLabel.text = s;
    
    NSLog(@"recived data in TTControllerViewController.h");
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
