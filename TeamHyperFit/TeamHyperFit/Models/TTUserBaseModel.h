//
//  TTUserBaseModel.h
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/8/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTUserBaseModel : NSObject

@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;

@property (strong, nonatomic) NSNumber *fitPoints;
@property (strong, nonatomic) NSNumber *todaySteps;

@end
