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

-(void) resetWeekDayData
{
    self.userInfo.sunFitPoints = 0;
    self.userInfo.monFitPoints = 0;
    self.userInfo.tueFitPoints = 0;
    self.userInfo.wenFitPoints = 0;
    self.userInfo.thuFitPoints = 0;
    self.userInfo.friFitPoints = 0;
    self.userInfo.satFitPoints = 0;
}

-(void) resetGesturesPoints
{
    for (int i=0; i < [self.userInfo.gesturesPoints count]; i++)
    {
        self.userInfo.gesturesPoints[i] = 0;
    }
}

-(void)setUserInfoToDefaultValue
{
    self.userInfo.gesturesPoints = [[NSMutableArray alloc] initWithArray:@[@(0),@(0),@(0),@(0)]];
    self.userInfo.userID = @(0);
    self.userInfo.firstName = @"First Name";
    self.userInfo.lastName = @"Last Name";
    self.userInfo.fitPoints = @(0);
    self.userInfo.goalFitPoints = @(10000);
    self.userInfo.profileImage = [UIImage imageNamed:@"noone"];
    
    [self resetWeekDayData];
}

-(void)retriveState
{
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    
    NSString *firstname = [defaults objectForKey:@"firstName"];
    
    if( firstname )
    {
        self.userInfo.firstName     = firstname;
        self.userInfo.lastName      = [defaults objectForKey:@"lastname"];
        self.userInfo.age           = [defaults integerForKey:@"age"];
        self.userInfo.fitPoints     = @([defaults integerForKey:@"fitpoints"]);
        self.userInfo.todaySteps    = @([defaults integerForKey:@"steps"]);
        self.userInfo.goalFitPoints = @([defaults integerForKey:@"goalFitpoints"]);
        self.userInfo.userID        = @([[defaults stringForKey:@"userID"] integerValue]);
        
        self.userInfo.sunFitPoints = [defaults integerForKey:@"sunFitPoints"];
        self.userInfo.monFitPoints = [defaults integerForKey:@"monFitPoints"];
        self.userInfo.tueFitPoints = [defaults integerForKey:@"tueFitPoints"];
        self.userInfo.wenFitPoints = [defaults integerForKey:@"wenFitPoints"];
        self.userInfo.thuFitPoints = [defaults integerForKey:@"thuFitPoints"];
        self.userInfo.friFitPoints = [defaults integerForKey:@"friFitPoints"];
        self.userInfo.satFitPoints = [defaults integerForKey:@"satFitPoints"];
        
        for (int i=0; i < [self.userInfo.gesturesPoints count]; i++)
        {
            self.userInfo.gesturesPoints[i] = @([defaults integerForKey:[NSString stringWithFormat:@"gesturesPoints%d",i]]);
        }
        
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
    [defaults setInteger:[self.userInfo.goalFitPoints intValue] forKey:@"goalFitpoints"];
    [defaults setObject:[NSString stringWithFormat:@"%ld",[self.userInfo.userID integerValue]] forKey:@"userID"];
    
    [defaults setInteger:self.userInfo.sunFitPoints forKey:@"sunFitPoints"];
    [defaults setInteger:self.userInfo.monFitPoints forKey:@"monFitPoints"];
    [defaults setInteger:self.userInfo.tueFitPoints forKey:@"tueFitPoints"];
    [defaults setInteger:self.userInfo.wenFitPoints forKey:@"wenFitPoints"];
    [defaults setInteger:self.userInfo.thuFitPoints forKey:@"thuFitPoints"];
    [defaults setInteger:self.userInfo.friFitPoints forKey:@"friFitPoints"];
    [defaults setInteger:self.userInfo.satFitPoints forKey:@"satFitPoints"];

    for (int i=0; i < [self.userInfo.gesturesPoints count]; i++)
    {
        [defaults setInteger:[self.userInfo.gesturesPoints[i] intValue] forKey:[NSString stringWithFormat:@"gesturesPoints%d",i]];
    }
    
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

-(NSDate*) getTodayAtMidNight
{
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags= NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:now];
    long timeToRemove=-1*([components hour]*60*60 + [components minute]*60 + [components second]);
    
    NSDate *today = [NSDate dateWithTimeInterval:timeToRemove sinceDate:now];
    
    return today;
}

-(NSDate*) getTheDayBeforeToday:(int) numberOfDays
{
    
    NSDate *today = [self getTodayAtMidNight];
    
    NSDate *timeFromDay = [NSDate dateWithTimeInterval:-(60*60*24*numberOfDays) sinceDate:today];
    
    
    return timeFromDay;
}

//! begin at Sunder = 1 to Saturnday at 7
-(NSDate*) getDateFromWeekDay:(int) weekDayNumber
{
   
   NSDate *today = [NSDate date];
   NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
   [gregorian setLocale:[NSLocale currentLocale]];
   
   NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
   
   [nowComponents setWeekday:weekDayNumber];
   [nowComponents setWeek: [nowComponents week]];
   [nowComponents setHour:0]; //8a.m.
   [nowComponents setMinute:0];
   [nowComponents setSecond:0];
   
   NSDate *beginningOfWeek = [gregorian dateFromComponents:nowComponents];
    
    return beginningOfWeek;
}

-(NSInteger)getWeekdayFromDate:(NSDate*) date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];

    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [weekdayComponents weekday];
    
    return weekday;
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
            NSMutableArray* ids = [[NSMutableArray alloc] init];
            for( TTFriendModel* friend in self.friendsInfo)
            {
                [ids addObject:friend.userID];
            }
            
            if( [ids count] > 0 )
            {
                //! Get Steps From Each Friends
                [self.fbHandler getUserSteps:[self getTheDayBeforeToday:1] to:[self getTodayAtMidNight] forIDs:ids response:^(NSArray *userSteps, NSError *error)
                 {
                     
                     if (!error)
                     {

                         for (int j = 0; j<[userSteps count] ; j++ )
                         {
                             
                             NSArray *stepsInfo = [userSteps[j] objectForKey:@"steps"];
                             
                             for( int i=0; i<[stepsInfo count]; i++ )
                             {
                                 TTFriendModel* thisFriend = [self.friendsInfo objectAtIndex:j];
                                 
                                 thisFriend.todaySteps = @( [thisFriend.todaySteps intValue] + (int)[[stepsInfo[i] objectForKey:@"steps"] intValue] );
                                 
                             }
                         }
                         
                         
                         //! Get Fit Points From Each Friends
                         [self.fbHandler getFitPoints:[self getTheDayBeforeToday:1] to:[self getTodayAtMidNight] forIDs:ids response:^(NSArray *usersFitPoints, NSError *error)
                          {
                              
                              if (!error)
                              {
                                  
                                  for (int j = 0; j<[usersFitPoints count] ; j++ )
                                  {
                                      
                                      NSArray *stepsInfo = [usersFitPoints[j] objectForKey:@"fitPoints"];
                                      
                                      for( int i=0; i<[stepsInfo count]; i++ )
                                      {
                                          TTFriendModel* thisFriend = [self.friendsInfo objectAtIndex:j];
                                          
                                          thisFriend.fitPoints = @( [thisFriend.fitPoints intValue] + (int)[[stepsInfo[i] objectForKey:@"fitPoints"] intValue] );
                                          
                                      }
                                  }
                                  
                              }
                              
                              callback( error );
                              
                          }];

                         
                     }
                     
                 }];
                
                
            }
        
        
    }];
    
    return;
    
//    NSDate *today = [NSDate date];
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    [gregorian setLocale:[NSLocale currentLocale]];
//    
//    NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
//    
//    [nowComponents setWeekday:1]; //Monday
//    [nowComponents setWeek: [nowComponents week]-1]; //Next week
//    [nowComponents setHour:0]; //8a.m.
//    [nowComponents setMinute:0];
//    [nowComponents setSecond:0];
//    
//    NSDate *beginningOfWeek = [gregorian dateFromComponents:nowComponents];
//
//    

    
    //Backup?
//    [self.fbHandler getUserSteps:beginningOfWeek to:now forIDs:ids response:^(NSArray *usersFitPoints, NSError *error)
//    {
//       
//        NSLog(@">>>>%@", usersFitPoints[0]);
//        
//        NSArray *stepsInfo = [usersFitPoints[0] objectForKey:@"steps"];
//        
//        for( int i=0; i<[stepsInfo count]; i++ )
//        {
//            NSDictionary *dateNSteps = stepsInfo[i];
//            
//            NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:[dateNSteps objectForKey:@"date" ]];
//            NSInteger weekday = [weekdayComponents weekday];
//            
//            NSLog(@"Day : %ld (%ld steps)", (long)weekday, [[dateNSteps objectForKey:@"steps"] integerValue] );
//        
//        }
//        
//    }];
    


    
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
        [self.fbHandler getFitPoints:[self getTheDayBeforeToday:1] to:[self getTodayAtMidNight] forIDs:@[[NSString stringWithFormat:@"%@", self.userInfo.userID]] response:^(NSArray *usersFitPoints, NSError *error) {
            
            if( !error )
            {
                if( [usersFitPoints count] > 0)
                {
                    NSArray *theFitPoint = [usersFitPoints[0] objectForKey:@"fitPoints" ];
                    for (int i=0; i<[theFitPoint count]; i++)
                    {
                        self.userInfo.fitPoints = [theFitPoint[i] objectForKey:@"fitPoints"];
                    }
                }
                
                //! Get Weekly Stat;
                [self.fbHandler getFitPoints:[self getDateFromWeekDay:1] to:[self getTodayAtMidNight] forIDs:@[[NSString stringWithFormat:@"%@", self.userInfo.userID]] response:^(NSArray *usersFitPoints, NSError *error) {
                    
                    if( !error )
                    {
                        if( [usersFitPoints count] > 0)
                        {
                            [self resetWeekDayData];
                            
                            NSArray *theFitPoint = [usersFitPoints[0] objectForKey:@"fitPoints" ];
                            for (int i=0; i<[theFitPoint count]; i++)
                            {
                                NSDate* theDate = [theFitPoint[i] objectForKey:@"date"];
                                NSInteger weekDay = [self getWeekdayFromDate:theDate];
                                int thisFitPoints = [[theFitPoint[i] objectForKey:@"fitPoints"] intValue];
                                switch (weekDay) {
                                    case 1:
                                        self.userInfo.sunFitPoints = thisFitPoints;
                                        break;
                                    case 2:
                                        self.userInfo.monFitPoints = thisFitPoints;
                                        break;
                                    case 3:
                                        self.userInfo.tueFitPoints = thisFitPoints;
                                        break;
                                    case 4:
                                        self.userInfo.wenFitPoints = thisFitPoints;
                                        break;
                                    case 5:
                                        self.userInfo.thuFitPoints = thisFitPoints;
                                        break;
                                    case 6:
                                        self.userInfo.friFitPoints = thisFitPoints;
                                        break;
                                    case 7:
                                        self.userInfo.satFitPoints = thisFitPoints;
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }
                        
                        //! Get Steps Stat;
                        [self.fbHandler getUserSteps:[self getDateFromWeekDay:1] to:[self getTodayAtMidNight] forIDs:@[[NSString stringWithFormat:@"%@", self.userInfo.userID]] response:^(NSArray *usersSteps, NSError *error) {
                            
                            if( !error )
                            {
                                if( [usersSteps count] > 0)
                                {
                                    
                                    NSArray *theSteps = [usersSteps[0] objectForKey:@"steps" ];
                                    for (int i=0; i<[theSteps count]; i++)
                                    {
                                        NSDate* theDate = [theSteps[i] objectForKey:@"date"];
                                        NSInteger weekDay = [self getWeekdayFromDate:theDate];
                                        int numberOfSteps =  [[theSteps[i] objectForKey:@"steps"] intValue];
                                        
                                        switch (weekDay) {
                                            case 1:
                                                self.userInfo.sunFitPoints += numberOfSteps;
                                                break;
                                            case 2:
                                                self.userInfo.monFitPoints += numberOfSteps;
                                                break;
                                            case 3:
                                                self.userInfo.tueFitPoints += numberOfSteps;
                                                break;
                                            case 4:
                                                self.userInfo.wenFitPoints += numberOfSteps;
                                                break;
                                            case 5:
                                                self.userInfo.thuFitPoints += numberOfSteps;
                                                break;
                                            case 6:
                                                self.userInfo.friFitPoints += numberOfSteps;
                                                break;
                                            case 7:
                                                self.userInfo.satFitPoints += numberOfSteps;
                                                break;
                                            default:
                                                break;
                                        }
                                    }
                                }
                            }
                            
                            if (onFinish)
                            {
                                onFinish(error);
                            }
                            
                        }];

                        
                    }

                }];

            }
            
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
    
    [self.fbHandler updateFitPoints:self.userInfo.fitPoints withDate:[self getTodayAtMidNight] withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID] callback:^(NSError *error) {
        
        [self.fbHandler updateCurrentUserDailySteps:self.userInfo.todaySteps withDate:[self getTodayAtMidNight] withUserID:[NSString stringWithFormat:@"%@",self.userInfo.userID]];
        
        if (onFinish) {
            onFinish(error);
        }
        
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

    [self syncInfoToServer:^(NSError* error)
     {
         if( !error )
         {
             [self requestInfoFromServer:nil];
         }
     }];

    
    [self saveState];
}

@end
