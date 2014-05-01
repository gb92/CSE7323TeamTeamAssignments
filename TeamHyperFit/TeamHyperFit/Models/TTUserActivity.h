//
//  TTUserActivity.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 5/1/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    jumpingJacks,
    pushUps,
    sitUps
} HyperFitActivity;

@interface TTUserActivity : NSObject

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSNumber *numRepetitions;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property HyperFitActivity activity;

+(NSString *) activityString:(HyperFitActivity) activity;
+(HyperFitActivity) activityFromString:(NSString *)activityString;

@end
