//
//  TTFacebookHandler.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Models/TTUserActivity.h"

typedef void (^userFitPointsBlock)(NSNumber *fitPoints, NSError *error);
typedef void (^userFriendsBlock) (NSArray *friends, NSError *error);
typedef void (^userFriendsFitPointsBlock) (NSArray *friends, NSError *error);
typedef void (^userActivitiesBlock) (NSArray *userActivities, NSError *error);

@interface TTFacebookHandler : NSObject

-(void) getCurrentUserFitPoints:(userFitPointsBlock) callback;

-(void) getCurrentUserFriendsWithApp:(userFriendsBlock) callback;

-(void) getFriendsFitPoints:(userFriendsFitPointsBlock) callback;

-(void) getCurrentUserActivities:(userActivitiesBlock) callback;

-(void) getCurrentUserDailyStepCount;

-(void) getCurrentUserHourlyStepHourly;

-(void) getCurrentUserDailyCalorieCount;

-(void) updateCurrentUserFitPoints:(NSNumber *) fitPoints onFinish:(void(^)(NSError*)) onFinishedBlock;

-(void) addToCurrentUserFitPoints:(NSNumber *) fitPointsToAdd;

-(void) addUserActivity:(TTUserActivity *) activity;

-(void) updateCurrentUserHourlySteps:(NSNumber*) steps withDate:(NSDate*) hour;

-(void) updateCurrentUserCalorieCount:(NSNumber*) calories withDate:(NSDate*) day;

@end
