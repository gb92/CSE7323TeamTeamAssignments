//
//  TTControllerViewController.h
//  Assignment5
//
//  Created by ch484-mac5 on 3/31/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTControllerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@property (strong, nonatomic) NSString *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *macAddressLabel;

@property( strong, nonatomic )NSString *CVCData;

@end
