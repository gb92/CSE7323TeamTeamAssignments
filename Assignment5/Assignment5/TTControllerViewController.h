//
//  TTControllerViewController.h
//  Assignment5
//
//  Created by ch484-mac5 on 3/31/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface TTControllerViewController : UIViewController <BLEDelegate>

@property (strong, nonatomic) NSString *deviceName;

@property (strong, nonatomic) BLE *bleShield;

@end
