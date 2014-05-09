//
//  TTFacebookHandler.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTFacebookHandler.h"
#import "TTAppDelegate.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <FacebookSDK/FacebookSDK.h>


@interface TTFacebookHandler()

@property (weak, nonatomic) MSClient *client;
@property (strong, nonatomic) NSString *fbID;

@property (strong, nonatomic) NSDateFormatter* dateFormat;

@property (strong, nonatomic) NSDateFormatter* dateWithTimeFormat;

@end

@implementation TTFacebookHandler

-(MSClient *) client
{
    if(_client == nil)
    {
        TTAppDelegate *appDelegate=(TTAppDelegate *)[[UIApplication sharedApplication]delegate];
        
        _client=appDelegate.msClient;
    }
    return _client;
}

-(NSDateFormatter *) dateFormat
{
    if(_dateFormat == nil)
    {
        _dateFormat=[[NSDateFormatter alloc] init];
        [_dateFormat setDateFormat:@"yyyy-MM-dd"];
        [_dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    }
    return _dateFormat;
}

-(NSDateFormatter *) dateWithTimeFormat
{
    if(_dateWithTimeFormat == nil)
    {
        _dateWithTimeFormat=[[NSDateFormatter alloc]init];
        [_dateWithTimeFormat setDateFormat:@"yyyy-MM-dd mm:ss"];
        [_dateWithTimeFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    }
    return _dateWithTimeFormat;
}

-(void)getCurrentUserInformation:(userInformationBlock)callback
{
    NSLog(@"Begin getCurrentUserInformation");
    FBSession *session=[[FBSession alloc]init];
    
    NSLog(@"Session current state: %u", session.state);
    //NSLog(@"Session FBSessionStateOpen: %u", FBSessionStateOpen);
    
    if(session.state == FBSessionStateCreated || session.state == FBSessionStateCreatedTokenLoaded)
    {
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if(FB_ISSESSIONOPENWITHSTATE(status)) {
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if(error)
                    {
                        NSLog(@"Error while fetching current user information: %@", error);
                        callback(nil, error);
                        return;
                    }
                    NSLog(@"Fetch Current User Results: %@", result);
                    
                    NSDictionary *userMe=(NSDictionary *)result;
                    
                    TFUserModel *userInformation=[[TFUserModel alloc] init];
                    userInformation.userID=[userMe valueForKeyPath:@"id"];
                    userInformation.firstName=[userMe valueForKeyPath:@"first_name"];
                    userInformation.lastName=[userMe valueForKeyPath:@"last_name"];
                    
                    callback(userInformation, error);
                }];

            }
        }];

    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(error)
        {
            NSLog(@"Error while fetching current user information: %@", error);
            callback(nil, error);
            return;
        }
        NSLog(@"Fetch Current User Results: %@", result);
        
        NSDictionary *userMe=(NSDictionary *)result;
        
        TFUserModel *userInformation=[[TFUserModel alloc] init];
        userInformation.userID=[userMe valueForKeyPath:@"id"];
        userInformation.firstName=[userMe valueForKeyPath:@"first_name"];
        userInformation.lastName=[userMe valueForKeyPath:@"last_name"];
        
        callback(userInformation, error);
    }];
}

-(void)getCurrentUserFitPoints:(userFitPointsBlock)callback
{
    
    [self getCurrentUserInformation:^(TFUserModel *userInformation, NSError *error) {
        if( error )
        {
            NSLog(@"%@", error);
        }
        else if(userInformation != nil)
        {
            MSTable *table = [self.client tableWithName:@"FitPoints"];
            
            MSQuery *query=[table query];
            query.includeTotalCount=YES;
            query.parameters=@{@"userID":userInformation.userID};
            
            [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                
                if (error) {
                    NSLog(@"Error reading item: %@", error);
                    return;
                    
                    callback(nil, error);
                }
                NSLog(@"Total Count:%ld", totalCount);
                
                if(totalCount<=0)
                {
                    NSDictionary *item = @{@"userID":userInformation.userID,@"numFitPoints":@0};
                    [table insert:item completion:^(NSDictionary *item, NSError *error) {
                        if (error) {
                            NSLog(@"Error inserting item: %@", error);
                            callback(nil, error);
                            return;
                        }
                        NSLog(@"Inserted: %@", item);
                        callback(@0, nil);
                    }];
                    
                    
                }
                else if(totalCount>0)
                {
                    NSDictionary *item = (NSDictionary *)items[0];
                    NSNumber *fitPoints=[item valueForKey:@"numFitPoints"];
                    
                    callback(fitPoints, nil);
                }
            }];
        }
        else
        {
            NSLog(@"Both UserInformation and Error are nil...");
        }
    }];
}

-(void) getCurrentUserInformationWithFitPoints:(userInformationFitPointsBlock)callback
{
    [self getCurrentUserInformation:^(TFUserModel *userInformation, NSError *error) {
        if( error )
        {
            NSLog(@"Error Getting Current User Information: %@", error);
        }
        else if(userInformation != nil)
        {
            MSTable *table = [self.client tableWithName:@"FitPoints"];
            
            MSQuery *query=[table query];
            query.includeTotalCount=YES;
            query.parameters=@{@"userID":userInformation.userID};
            
            [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                
                if (error) {
                    NSLog(@"Error reading item: %@", error);
                    return;
                    
                    callback(userInformation, error);
                }
                NSLog(@"Total Count:%ld", totalCount);
                
                if(totalCount<=0)
                {
                    NSDictionary *item = @{@"userID":userInformation.userID,@"numFitPoints":@0};
                    [table insert:item completion:^(NSDictionary *item, NSError *error) {
                        if (error) {
                            NSLog(@"Error inserting item: %@", error);
                            callback(nil, error);
                            return;
                        }
                        NSLog(@"Inserted: %@", item);
                        
                        userInformation.fitPoints=0;
                        
                        callback(userInformation, nil);
                    }];
                    
                    
                }
                else if(totalCount>0)
                {
                    NSDictionary *item = (NSDictionary *)items[0];
                    NSNumber *fitPoints=[item valueForKey:@"numFitPoints"];
                    
                    userInformation.fitPoints=fitPoints;
                    callback(userInformation, error);
                }
            }];
        }
        else
        {
            NSLog(@"Both UserInformation and Error are nil...");
        }
    }];
}

-(void) getCurrentUserFriendsWithApp:(userFriendsBlock)callback
{
    NSString *query=@"Select name, uid, pic_small from user where is_app_user = 1 and uid in (select uid2 from friend where uid1 = me()) order by concat(first_name,last_name) asc";
    NSDictionary *params=@{@"q":query};
    
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            callback(result, error);
        }
        else
        {
            NSLog(@"Result: %@", result);
            NSDictionary *res=(NSDictionary *) result;
            NSArray *friends=[res valueForKey:@"data"];
            callback(friends, error);
        }
    }];

}

-(void) getFriendsFitPoints:(userFriendsFitPointsBlock) callback
{
    NSString *query=@"Select name, uid, pic_small from user where is_app_user = 1 and uid in (select uid2 from friend where uid1 = me()) order by concat(first_name,last_name) asc";
    NSDictionary *params=@{@"q":query};
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            callback(result, error);
        }
        else
        {
            NSLog(@"Result: %@", result);
            NSDictionary *res=(NSDictionary *) result;
            NSArray *friends=[res valueForKey:@"data"];
            
            MSTable *table = [self.client tableWithName:@"FitPoints"];
            
            MSQuery *query=[table query];
            query.includeTotalCount=YES;
            //query.parameters=@{@"userID":fbID};
            
            [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
                
                if (error) {
                    NSLog(@"Error reading item: %@", error);
                    return;
                }
                NSLog(@"Total Count:%ld", totalCount);
                
                if(totalCount<=0)
                {
                    //this really
                    callback(nil, error);
                }
                else if(totalCount>0)
                {
                    NSMutableArray *friendsWithFitPoints=[[NSMutableArray alloc] init];
                    for(int i=0; i< totalCount; i++)
                    {
                        NSString *friendID=[items[i] valueForKey:@"userID"];
                        NSNumber *friendFitPoints=[items[i] valueForKey:@"numFitPoints"];
                        
                        //linear search... not good
                        
                        for(int j=0; j< [friends count]; j++)
                        {
                            if([friendID isEqualToString:[friends[j] valueForKey:@"uid"]])
                            {
                                NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:friends[j]];
                                [dict setValue:friendFitPoints forKey:@"numFitPoints"];
                                [friendsWithFitPoints addObject:dict];
                            }
                        }
                    }
                    
                    callback(friendsWithFitPoints, error);
                }
                
            }];
            
            //callback(friends, error);
        }
    }];
}

-(void) updateCurrentUserFitPoints:(NSNumber *) fitPoints onFinish:(void(^)(NSError*)) onFinishedBlock
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"fb result: %@", result);
        
        NSDictionary *meDictionary=(NSDictionary *) result;
        
        NSString *fbID=[meDictionary valueForKey:@"id"];
        
        
        NSLog(@"FB ID: %@", fbID);
        MSTable *table = [self.client tableWithName:@"FitPoints"];
        
        MSQuery *query=[table query];
        query.includeTotalCount=YES;
        query.parameters=@{@"userID":fbID};
        
        [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            
            if (error) {
                NSLog(@"Error reading item: %@", error);
                return;
            }
            
            NSLog(@"Total Count:%ld", totalCount);
            
            if(totalCount<=0)
            {
                NSDictionary *item = @{@"userID":fbID,@"numFitPoints": fitPoints};
                [table insert:item completion:^(NSDictionary *item, NSError *error) {
                    
                    onFinishedBlock( error );
                    
                    if (error) {
                        NSLog(@"Error inserting item: %@", error);
                        return;
                    }
                    NSLog(@"Inserted: %@", item);
                    
                    
                }];
            }
            else if(totalCount>0)
            {
                NSDictionary *item = (NSDictionary *)items[0];
                [item setValue:fitPoints forKey:@"numFitPoints"];
                
                [table update:item completion:^(NSDictionary *item, NSError *error) {
                    
                    onFinishedBlock( error );
                    
                    if(error){
                        NSLog(@"Error updating item %@", error);
                        return;
                    }
                    NSLog(@"Updated: %@", item);
                }];
            }
        }];
    }];

}

-(void) addToCurrentUserFitPoints:(NSNumber *)fitPointsToAdd
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"fb result: %@", result);
        
        NSDictionary *meDictionary=(NSDictionary *) result;
        
        NSString *fbID=[meDictionary valueForKey:@"id"];
        
        
        NSLog(@"FB ID: %@", fbID);
        MSTable *table = [self.client tableWithName:@"FitPoints"];
        
        MSQuery *query=[table query];
        query.includeTotalCount=YES;
        query.parameters=@{@"userID":fbID};
        
        [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
            
            if (error) {
                NSLog(@"Error reading item: %@", error);
                return;
            }
            NSLog(@"Total Count:%ld", totalCount);
            
            if(totalCount<=0)
            {
                NSDictionary *item = @{@"userID":fbID,@"numFitPoints": fitPointsToAdd};
                [table insert:item completion:^(NSDictionary *item, NSError *error) {
                    if (error) {
                        NSLog(@"Error inserting item: %@", error);
                        return;
                    }
                    NSLog(@"Inserted: %@", item);
                }];
            }
            else if(totalCount>0)
            {
                NSDictionary *item = (NSDictionary *)items[0];
                NSNumber* currentFitPoints=[item valueForKey:@""];
                [item setValue:fitPointsToAdd forKey:@"numFitPoints"];
                
                [table update:item completion:^(NSDictionary *item, NSError *error) {
                    if(error){
                        NSLog(@"Error updating item %@", error);
                        return;
                    }
                    NSLog(@"Updated: %@", item);
                }];
            }
        }];
    }];

}

-(void) getUserSteps:(NSDate *)fromDate to:(NSDate *)toDate forIDs:(NSArray *)userIDs response:(stepsBlock)callback
{
    MSTable *table= [self.client tableWithName:@"StepsTaken"];
    [table readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
        if(error)
        {
            NSLog(@"Error while retrieving user step information: %@",error);
            callback(nil, error);
            return;
        }
        
        NSMutableArray *userStepsToReturn=[[NSMutableArray alloc] init];
        for(int i=0; i<[userIDs count]; i++)
        {
            NSMutableDictionary *dict= [[NSMutableDictionary alloc]init];
            [dict setObject:userIDs[i] forKey:@"userID"];
            [dict setObject:[[NSMutableArray alloc] init] forKey:@"steps"];
            [userStepsToReturn addObject:dict];
        }
        
        for(int i=0; i<[items count]; i++)
        {
            NSDictionary *currentItem=(NSDictionary *)items[i];
            NSString *userID=[currentItem valueForKey:@"userID"];
            
            if([userIDs containsObject:userID])
            {
                NSDate *dayOfSteps=[self.dateFormat dateFromString:[currentItem valueForKey:@"date"]];
                NSNumber *numSteps=(NSNumber *)[currentItem valueForKey:@"numSteps"];
                if([[toDate earlierDate:[fromDate laterDate:dayOfSteps]] isEqual:dayOfSteps])
                {
                    //the steps are recorded in the correct date range
                    NSUInteger index=[userIDs indexOfObject:userID];
                    NSDictionary* userSteps=(NSDictionary *)userStepsToReturn[index];
                    
                    NSMutableArray *stepsWithDates=(NSMutableArray *)[userSteps valueForKey:@"steps"];
                    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                    [dict setObject:dayOfSteps forKey:@"date"];
                    [dict setObject:numSteps forKey:@"steps"];
                    [stepsWithDates addObject:dict];
                }
            
            }
        }
        NSLog(@"userStepsToReturn: %@", userStepsToReturn);
        callback(userStepsToReturn, error);
    }];
}

//adds steps to current step value in database for day
-(void) updateCurrentUserDailySteps:(NSNumber *)steps withDate:(NSDate *)day withUserID:(NSString *)userID
{
    NSString* dateString=[self.dateFormat stringFromDate:day];
    
    MSTable *table= [self.client tableWithName:@"StepsTaken"];
    MSQuery *query=[table query];
    
    
    query.includeTotalCount=YES;
    query.parameters=@{@"userID":userID,
                       @"date":dateString};
    
    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
       if(totalCount >0)
       {
           NSDictionary *item=(NSDictionary *)items[0];
           NSNumber* numSteps=[item valueForKey:@"numSteps"];
           
           NSNumber* updatedSteps=[NSNumber numberWithInt:([numSteps intValue]+ [steps intValue])];
           
           [item setValue:updatedSteps forKey:@"numSteps"];
           
           [table update:item completion:^(NSDictionary *item, NSError *error)
           {
               if(error)
               {
                   NSLog(@"Error while Updating Steps: %@", error);
               }
           }];
       }
       else
       {
           NSDictionary *item=@{@"userID":userID,
                                @"date":dateString,
                                @"numSteps":steps};
           [table insert:item completion:^(NSDictionary *item, NSError *error)
           {
               if(error)
               {
                   NSLog(@"Error while Updating Steps: %@", error);
               }
           }];
       }
    }];
    
}

-(void) addUserActivity:(TTUserActivity *)activity
{
    MSTable *table=[self.client tableWithName:@"Activities"];
    
    NSString *activityString=[TTUserActivity activityString:activity.activity];
    
    NSDictionary *item=@{@"userID": activity.userID,
                         @"activity":activityString,
                         @"startTime":[self.dateWithTimeFormat stringFromDate:activity.startTime],
                         @"endTime":[self.dateWithTimeFormat stringFromDate:activity.endTime],
                         @"numRepetitions":activity.numRepetitions};
    [table insert:item completion:^(NSDictionary *item, NSError *error) {
        if(error)
        {
            NSLog(@"Error while inserting activity:%@", error);
        }
    }];
    
}

-(void) getCurrentUserActivities:(NSDate *)fromDate to:(NSDate *)toDate response:(userActivitiesBlock)callback
{
    
}
@end
