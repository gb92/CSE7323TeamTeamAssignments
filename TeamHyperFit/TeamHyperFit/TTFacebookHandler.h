//
//  TTFacebookHandler.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Models/TTUserActivity.h"
#import "Models/TFUserModel.h"
#import <FacebookSDK/FacebookSDK.h>

typedef void (^userInformationBlock)(TFUserModel* userInformation, NSError *error);
typedef void (^userFitPointsBlock)(NSNumber *fitPoints, NSError *error);
typedef void (^userInformationFitPointsBlock)(TFUserModel* userInformation, NSError *error);
typedef void (^userFriendsBlock) (NSArray *friends, NSError *error);
typedef void (^userFriendsFitPointsBlock) (NSArray *friends, NSError *error);
typedef void (^userActivitiesBlock) (NSArray *userActivities, NSError *error);

typedef void (^fitPointsBlock) (NSArray *usersFitPoints, NSError *error);
typedef void (^stepsBlock) (NSArray *usersSteps, NSError *error);


@protocol TTFacebookHandlerDelegate <NSObject>

-(void)TTFacebookHandlerOnLoginSuccessfully:(id<FBGraphUser>)user;
-(void)TTFacebookHandlerOnLogoutSuccessfully;

@end




@interface TTFacebookHandler : NSObject <FBLoginViewDelegate>

@property (weak, nonatomic) id<TTFacebookHandlerDelegate> delegate;
@property (nonatomic) BOOL isLogin;


-(void) getProfileImageByID:(NSNumber*)ID callback:(void(^)( UIImage* image, NSError* error )) callback;
-(void) getUserInfoToUserModel:(TFUserModel*) outUserModel;

-(id)init;

//-------------------------------------------------

-(void) getCurrentUserInformation:(userInformationBlock) callback; //complete

-(void) getCurrentUserFitPoints:(userFitPointsBlock) callback; //complete

-(void) getCurrentUserInformationWithFitPoints:(userInformationFitPointsBlock) callback; //complete

-(void) getCurrentUserFriendsWithApp:(userFriendsBlock) callback; //complete

-(void) getFriendsFitPoints:(userFriendsFitPointsBlock) callback; //complete

-(void) updateCurrentUserFitPoints:(NSNumber *) fitPoints onFinish:(void(^)(NSError*)) onFinishedBlock; //complete

-(void) addToCurrentUserFitPoints:(NSNumber *) fitPointsToAdd;//complete

-(void) getUserSteps: (NSDate *)fromDate to:(NSDate *) toDate forIDs:(NSArray *)userIDs response:(stepsBlock) callback; //complete

-(void) getFitPoints: (NSDate *)fromDate to:(NSDate *)toDate forIDs:(NSArray *) userIDs  response:(fitPointsBlock) callback; //complete

-(void) addUserActivity:(TTUserActivity *) activity;

-(void) getUserActivities:(NSString*)userID from:(NSDate *) fromDate to:(NSDate*)toDate response:(userActivitiesBlock) callback;

-(void) updateCurrentUserDailySteps:(NSNumber*) steps withDate:(NSDate*) day withUserID:(NSString *) userID;

-(void) updateFitPoints:(NSNumber *)fitPoints withDate:(NSDate *)day withUserID:(NSString *)userID;


@end
