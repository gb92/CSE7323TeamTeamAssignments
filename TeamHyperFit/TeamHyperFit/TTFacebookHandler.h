//
//  TTFacebookHandler.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^userFitPointsBlock)(NSNumber* fitPoints, NSError* error);
typedef void (^userFriendsBlock) (NSArray * friends, NSError* error);
typedef void (^userFriendsFitPoints) (NSArray *friends, NSError * error);

@interface TTFacebookHandler : NSObject

-(void) getCurrentUserFitPoints:(userFitPointsBlock) callback;

-(void) getCurrentUserFriendsWithApp:(userFriendsBlock) callback;

-(void) getFriendsFitPoints:(userFriendsFitPoints) callback;

-(void) updateCurrentUserFitPoints:(NSNumber *) fitPoints;

-(void) addToCurrentUserFitPoints:(NSNumber *) fitPointsToAdd;

@end
