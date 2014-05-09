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

-(id)init
{
    self = [super init];
    if (self)
    {
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
        self.userInfo.fitPoints     = @([defaults integerForKey:@"fitPoints"]);
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


- (void) receivesStepsUpdate:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"stepsUpdate"])
    {
        [self updateSteps];
    }
}

-(void)downloadProfileImage
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=200&width=200", self.userInfo.userID ]];
    
    self.userInfo.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
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
    
    [self performSelectorInBackground:@selector(downloadProfileImage) withObject:nil];
	
}


-(void)TTFacebookHandlerOnLogoutSuccessfully
{
    NSLog(@"Log out!");
    //[self setUserInfoToDefaultValue];
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