//
//  TTUserActivity.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 5/1/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTUserActivity.h"



@implementation TTUserActivity


+(NSString *)activityString:(HyperFitActivity)activity
{
    switch (activity)
    {
        case jumpingJacks:
            return @"Jumping Jacks";
            break;
        case pushUps:
            return @"Push Ups";
            break;
        case sitUps:
            return @"Sit Ups";
            break;
        default:
            return @"Whoopsies"; //this shouldn't happen...
            break;
    }
}

+(HyperFitActivity) activityFromString:(NSString *)activityString
{
    if([activityString isEqualToString:[TTUserActivity activityString:jumpingJacks]])
    {
        return jumpingJacks;
    }
    else if([activityString isEqualToString:[TTUserActivity activityString:pushUps]])
    {
        return pushUps;
    }
    else if([activityString isEqualToString:[TTUserActivity activityString:sitUps]])
    {
        return sitUps;
    }
    else
    {
        return -1;
    }
}

@end
