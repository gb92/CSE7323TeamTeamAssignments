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

-(void)getCurrentUserFitPoints:(userFitPointsBlock)callback
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
                
                callback(nil, error);
            }
            NSLog(@"Total Count:%ld", totalCount);
            
            if(totalCount<=0)
            {
                NSDictionary *item = @{@"userID":fbID,@"numFitPoints":@0};
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

-(void) getFriendsFitPoints:(userFriendsFitPoints) callback
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
                            if([friendID isEqualToString:[friends[j] valueForKey:@"userID"]])
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

-(void) updateCurrentUserFitPoints:(NSNumber *) fitPoints
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



@end
