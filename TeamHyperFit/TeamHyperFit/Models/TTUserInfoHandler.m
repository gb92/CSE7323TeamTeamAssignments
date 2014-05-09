//
//  TTUserInfoHandler.m
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/8/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTUserInfoHandler.h"
#import "TTFacebookHandler.h"

#import "TTA7ActivityHandler.h"

@interface TTUserInfoHandler()

@property (nonatomic, strong) TTFacebookHandler* fbHandler;
@property (strong, nonatomic) TTA7ActivityHandler* a7ActivityHandler;

@end

@implementation TTUserInfoHandler

-(TTFacebookHandler*)fbHandler
{
    if (!_fbHandler) {
        _fbHandler = [[TTFacebookHandler alloc] init];
    }
    
    return _fbHandler;
}

-(TTA7ActivityHandler*)a7ActivityHandler
{
    if (!_a7ActivityHandler) {
        _a7ActivityHandler = [[TTA7ActivityHandler alloc]init];
        
    }
    
    return _a7ActivityHandler;
}

-(id)init
{
    self = [super init];
    if (self)
    {

#warning These are fake data, please Change it.
        
        self.userInfo = [[TFUserModel alloc] init];
        self.userInfo.userID = @(123456);
        self.userInfo.username = @"MARK USER NAME";
        self.userInfo.firstName = @"Chatchai";
        self.userInfo.lastName = @"Wangwiwattana";
        self.userInfo.middleName = @"Mark";
        self.userInfo.fitPoints = @(45698);
        self.userInfo.goalFitPoints = @(50000);
        //self.userInfo.calories = @(23125);
        
        NSDictionary* fitPointsThisWeek = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(10000),@"Sunday",
                                           @(30000),@"Monday",
                                           @(2000),@"Tuesday",
                                           @(0),@"Wednesday",
                                           @(50000),@"Thursday",
                                           @(0),@"Friday",
                                           @(0),@"Saturday",
                                           nil];
        
        NSNumber* goalThisWeek = @(50000);
        
        self.userInfo.userStatistics = [NSDictionary dictionaryWithObjectsAndKeys:
                                         fitPointsThisWeek,@"fitpointsThisWeek",
                                         goalThisWeek,@"goalThisWeek", nil];
    }
    
    return self;
}

-(void)requestInfoFromServer:(void(^)(NSError* error)) onFinish
{
    if( !self.userInfo.isDirty )
    {
        //[self.fbHandler getCurrentUserFitPoints:^(NSNumber *fitPoints, NSError *error){
        [self.fbHandler getCurrentUserInformationWithFitPoints:^(TFUserModel *userInformation, NSError *error){
            
            if( !error )
            {
                self.userInfo.userID=userInformation.userID;
                self.userInfo.fitPoints = userInformation.fitPoints;
            }
            
            if(onFinish != nil)
                onFinish( error );
            /*
            [self.fbHandler updateCurrentUserDailySteps:@(32) withDate:[NSDate date] withUserID:self.userInfo.userID];
            
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
            
            [components setHour:-[components hour]];
            [components setMinute:-[components minute]];
            [components setSecond:-[components second]];
            NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
            
            [components setHour:-24];
            [components setMinute:0];
            [components setSecond:0];
            NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
            
            [components setHour: 24];
            NSDate *tomorrow=[cal dateByAddingComponents:components toDate:today options:0];
            
            [self.fbHandler getUserSteps:yesterday  to:tomorrow forIDs:@[self.userInfo.userID] response:^(NSArray *usersSteps, NSError *error) {
                //do something
            }];
             */
            
            TTUserActivity *tempActivity=[[TTUserActivity alloc]init];
            tempActivity.userID=userInformation.userID;
            tempActivity.activity=jumpingJacks;
            tempActivity.numRepetitions=@(32);
            
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
            
            [components setHour:0];
            [components setMinute:-10];
            [components setSecond:-22];
            NSDate *start=[cal dateByAddingComponents:components toDate:[NSDate date] options:0];
            [components setMinute:-8];
            [components setSecond:-31];
            NSDate *end=[cal dateByAddingComponents:components toDate:[NSDate date] options:0];
            
            tempActivity.startTime=start;
            tempActivity.endTime=end;
            
            [self.fbHandler addUserActivity:tempActivity];
           
        }];
    }
    else
    {
        NSLog(@"The object is dirty. Please sync info to server first.");
    }
    

}

-(void)syncInfoToServer:(void(^)(NSError* error)) onFinish
{
#warning Vulnerable to get Attack!
    //! It is bad to do this, it vernerable for hacking.!!!!
    [self.fbHandler updateCurrentUserFitPoints: self.userInfo.fitPoints onFinish:^(NSError* error)
     {
         if( !error )
         {
             self.userInfo.isDirty = NO;
         }
         
         if(onFinish != nil)
             onFinish(error);
         
     }];
    
}

-(void)updateUserInfo:(void(^)( TFUserModel*, NSError* error)) onFinish
{
    //! ----- Get Step info from A7 handler----------------
    //!
    [self.a7ActivityHandler queryNumberOfStepsFromDay:0 toDay:-1 withHandler:^(NSInteger numberOfStep, NSError *error)
    {
        if(!error)
        {
            self.userInfo.todaySteps = @(numberOfStep);
        }
    }];
    
    //! ----- Sync User Info -------------------------------
    //!
    if( self.userInfo.isDirty )
    {
        [self syncInfoToServer:^(NSError* error)
         {
             if( !error )
             {
                 [self requestInfoFromServer:nil];
             }
         }];
    }
    else
    {
        [self requestInfoFromServer:nil];
    }
    
    
    //! ----- Get Friends Info -------------------------------
    //!
    [self.fbHandler getFriendsFitPoints:^(NSArray *friends, NSError *error) {
        if(!error)
        {
            if( [friends count] > 0 )
            {
                NSLog(@"s : %@", [friends[0] objectForKey:@"name"] );
            }
        }
        
        if(onFinish != nil)
            onFinish(self.userInfo, error);
    }];
    
}

@end
