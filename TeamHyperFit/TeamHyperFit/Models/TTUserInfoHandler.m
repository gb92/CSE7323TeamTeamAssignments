//
//  TTUserInfoHandler.m
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/8/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTUserInfoHandler.h"
#import "TTFacebookHandler.h"
#import "TTAppDelegate.h"
#import "TTA7ActivityHandler.h"

@interface TTUserInfoHandler()

@property (strong, nonatomic) TTA7ActivityHandler* a7ActivityHandler;

@end

@implementation TTUserInfoHandler

-(TFUserModel*)userInfo
{
    if(!_userInfo)
    {
        _userInfo = [[TFUserModel alloc] init];
    }
    
    return _userInfo;
}

-(TTFacebookHandler*)fbHandler
{
    if (!_fbHandler)
    {
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

#pragma mark -
#pragma View Controller Life Cycle

-(id)init
{
    self = [super init];
    if (self)
    {
        self.friendsInfo = [[NSMutableArray alloc] init];
        self.fbHandler.delegate = self;
        
        //! Register to the A7 realtime update.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivesStepsUpdate:)
                                                     name:@"stepsUpdate"
                                                   object:nil];

        //! Initialize all controlls with previous app state;
        //!
        [self setUserInfoToDefaultValue];
        [self retriveState];
        
    }
    
    return self;
}

-(void)dealloc
{
    [self saveState];
}

-(void)setUserInfoToDefaultValue
{
    self.userInfo.userID = @(0);
    self.userInfo.firstName = @"First Name";
    self.userInfo.lastName = @"Last Name";
    self.userInfo.fitPoints = @(0);
    self.userInfo.profileImage = [UIImage imageNamed:@"noone"];
    
    NSDictionary* fitPointsThisWeek = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @(0),@"Sunday",
                                       @(0),@"Monday",
                                       @(0),@"Tuesday",
                                       @(0),@"Wednesday",
                                       @(0),@"Thursday",
                                       @(0),@"Friday",
                                       @(0),@"Saturday",
                                       nil];
    
    NSNumber* goalThisWeek = @(5000);
    
    self.userInfo.userStatistics = [NSDictionary dictionaryWithObjectsAndKeys:
                                    fitPointsThisWeek,@"fitpointsThisWeek",
                                    goalThisWeek,@"goalThisWeek", nil];
}

-(void)retriveState
{
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    
    NSString *firstname = [defaults objectForKey:@"firstName"];
    
    if( firstname )
    {
        self.userInfo.firstName     = firstname;
        self.userInfo.lastName      = [defaults objectForKey:@"lastname"];
        self.userInfo.age           = [defaults integerForKey:@"age"];
        self.userInfo.fitPoints     = @([defaults integerForKey:@"fitpoints"]);
        self.userInfo.todaySteps    = @([defaults integerForKey:@"steps"]);
        
        NSData *imageData           = [defaults dataForKey:@"image"];
        self.userInfo.profileImage  = [UIImage imageWithData:imageData];
    }
}

-(void)saveState
{
    // Create instances of NSData
    UIImage *contactImage       = self.userInfo.profileImage;
    NSData *imageData           = UIImageJPEGRepresentation(contactImage, 100);
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.userInfo.firstName forKey:@"firstName"];
    [defaults setObject:self.userInfo.lastName forKey:@"lastname"];
    [defaults setInteger:self.userInfo.age forKey:@"age"];
    [defaults setInteger:[self.userInfo.todaySteps intValue] forKey:@"steps"];
    [defaults setInteger:[self.userInfo.fitPoints intValue] forKey:@"fitpoints"];
    [defaults setObject:imageData forKey:@"image"];
    
    [defaults synchronize];
    
    NSLog(@"Data saved");
}



#pragma mark -
#pragma notification center

- (void) receivesStepsUpdate:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"stepsUpdate"])
    {
        [self updateSteps];
    }
}


#pragma mark -
#pragma TTFacebookHandler Delegate

-(void)TTFacebookHandlerOnLoginSuccessfully:(id<FBGraphUser>)user
{
    NSLog(@"The loginview successfully fetched user data: %@", user);
    
    self.userInfo.firstName = [user objectForKey:@"first_name"];
    self.userInfo.lastName = [user objectForKey:@"last_name"];
    self.userInfo.gender = [user objectForKey:@"gender"];
    self.userInfo.userID = [user objectForKey:@"id"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=200&width=200", self.userInfo.userID ]];
        
        self.userInfo.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    });
    
}


-(void)TTFacebookHandlerOnLogoutSuccessfully
{
    NSLog(@"Log out!");
    //[self setUserInfoToDefaultValue];
}


//! Bref: only use for unblock load profile from facebook loging delegation.
-(void)downloadProfile
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=200&width=200", self.userInfo.userID ]];
    
    self.userInfo.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

#pragma mark -
#pragma friends

-(void)updateFriendsInfo:(void(^)( NSError* error )) callback
{
    [self.friendsInfo removeAllObjects];
    
    [self.fbHandler getCurrentUserFriendsWithApp:^(NSArray *friends, NSError *error)
    {
        for ( NSDictionary *friend in friends)
        {
            TTFriendModel *friendObj = [[TTFriendModel alloc] init];
            friendObj.firstName = [friend objectForKey:@"name"];
            friendObj.userID = [friend objectForKey:@"uid"];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=200&width=200", friendObj.userID ]];
                
            friendObj.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            
            
            [self.friendsInfo addObject:friendObj];
            
        }
        
        callback( error );
        
        
    }];
    

    
    NSDate* now = [NSDate date];
    NSArray *ids = @[self.userInfo.userID];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags= NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:now];
    
    long timeToRemove=-1*([components hour]*60*60 + [components minute]*60 + [components second]);
    
    NSDate *today = [NSDate dateWithTimeInterval:timeToRemove sinceDate:now];
    
    NSDate *timeToDay = [NSDate dateWithTimeInterval:-(60*60*24*2) sinceDate:today];

    
    [self.fbHandler getUserSteps:timeToDay to:now forIDs:ids response:^(NSArray *usersFitPoints, NSError *error) {
       
        NSLog(@">>>>%@", usersFitPoints[0]);
        
    }];
    
//    [self.fbHandler updateCurrentUserDailySteps:@(5000) withDate:today withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
//    
//        [self.fbHandler updateCurrentUserDailySteps:@(3000) withDate:[NSDate dateWithTimeInterval:-(60*60*24*1) sinceDate:today] withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
//    
//        [self.fbHandler updateCurrentUserDailySteps:@(2000) withDate:[NSDate dateWithTimeInterval:-(60*60*24*2) sinceDate:today] withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
//    
//        [self.fbHandler updateCurrentUserDailySteps:@(1000) withDate:[NSDate dateWithTimeInterval:-(60*60*24*3) sinceDate:today] withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
//    
//    
//    [self.fbHandler updateCurrentUserDailySteps:@(3000) withDate:today withUserID:@"10201988014288633"];
//    
//    [self.fbHandler updateCurrentUserDailySteps:@(4000) withDate:[NSDate dateWithTimeInterval:-(60*60*24*1) sinceDate:today] withUserID:@"10201988014288633"];
//    
//    [self.fbHandler updateCurrentUserDailySteps:@(6000) withDate:[NSDate dateWithTimeInterval:-(60*60*24*2) sinceDate:today] withUserID:@"10201988014288633"];
//    
//    [self.fbHandler updateCurrentUserDailySteps:@(2000) withDate:[NSDate dateWithTimeInterval:-(60*60*24*3) sinceDate:today] withUserID:@"10201988014288633"];
//    
//    
//    [self.fbHandler updateFitPoints:@(1500) withDate:today withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
//    
//    [self.fbHandler updateFitPoints:@(3000) withDate:[NSDate dateWithTimeInterval:-(60*60*24*1) sinceDate:today] withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
//    
//    [self.fbHandler updateFitPoints:@(2500) withDate:[NSDate dateWithTimeInterval:-(60*60*24*2) sinceDate:today] withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
//    
//    [self.fbHandler updateFitPoints:@(100) withDate:[NSDate dateWithTimeInterval:-(60*60*24*3) sinceDate:today] withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
//    
//    [self.fbHandler updateFitPoints:@(3000) withDate:today withUserID:@"10201988014288633"];
//    
//    [self.fbHandler updateFitPoints:@(5000) withDate:[NSDate dateWithTimeInterval:-(60*60*24*1) sinceDate:today] withUserID:@"10201988014288633"];
//    
//    [self.fbHandler updateFitPoints:@(2500) withDate:[NSDate dateWithTimeInterval:-(60*60*24*2) sinceDate:today] withUserID:@"10201988014288633"];
//    
//    [self.fbHandler updateFitPoints:@(4400) withDate:[NSDate dateWithTimeInterval:-(60*60*24*3) sinceDate:today] withUserID:@"10201988014288633"];
    
    
}

#pragma mark -
#pragma Request From Server
//!------------------------------------------------------------------------------------

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

-(void)updateSteps
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
}

-(void)updateUserInfo:(void(^)( TFUserModel*, NSError* error)) onFinish
{
    [self updateSteps];
    
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
    
    [self saveState];
}

@end
