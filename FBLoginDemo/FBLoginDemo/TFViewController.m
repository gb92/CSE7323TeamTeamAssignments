//
//  TFViewController.m
//  FBLoginDemo
//
//  Created by Gavin Benedict on 4/23/14.
//  Copyright (c) 2014 TeamFit. All rights reserved.
//

#import "TFViewController.h"
#import "TFAppDelegate.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>


@interface TFViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *FacebookLoginView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePic;

@property (weak, nonatomic) MSClient *client;
@property (strong, nonatomic) NSString *fbId;

@end

@implementation TFViewController

- (MSClient *) client
{
    if(_client == nil)
    {
        _client=[(TFAppDelegate *) [[UIApplication sharedApplication] delegate] client];
    }
    return _client;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.FacebookLoginView.delegate=self;
    
    if([FBSession activeSession] != nil)
    {
        [self getUserId];
    }
     
    /*MSTable *demoTable=[self.client tableWithName:@"demotable"];
    NSDictionary *data=@{@"column": @"This is some data, yay!!!"};
    [demoTable insert:data completion:^(NSDictionary *item, NSError *error) {
        NSLog(error);
    }];*/
    
    /*
    [self.client loginWithProvider:@"facebook" controller:self animated:true completion:^(MSUser *user, NSError *error) {
        NSLog(@"%d",user.userId);
    }];
     */
    

    /*
    NSString * accessToken=[FBSession activeSession].accessTokenData.accessToken;
    [self.client loginWithProvider:@"facebook" token:@{@"access_token":accessToken}  completion:^(MSUser *user, NSError *error) {
        if (error) {
            NSLog(@"Error calling login: %@", error);
            return;
        }
        NSLog(@"Logged in as %@", user.userId);
        
        MSTable *table = [self.client tableWithName:@"FitPoints"];
        NSDictionary *item = @{@"userID":user.userId,@"numFitPoints":@30};
        [table insert:item completion:^(NSDictionary *item, NSError *error) {
            if (error) {
                NSLog(@"Error inserting item: %@", error);
                return;
            }
            NSLog(@"Inserted: %@", item);
        }];
    }];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"loginViewFetchedUserInfo called");
    
    //[self.profilePic setProfileID:user.id];
    //self.profilePic.profileID=user.id;
    //[self getUserId];
    
    [self getFriendsList];
}

-(void)getUserId
{
    NSLog(@"Get User Id");
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"fb result: %@", result);
        
        NSDictionary *meDictionary=(NSDictionary *) result;
        
        self.fbId=[meDictionary valueForKey:@"id"];
        [self.profilePic setProfileID:self.fbId];
        NSLog(@"FB ID: %@", self.fbId);
        
        //[self postDataToMobileService];
        
    }];
    
}

-(void) getFriendsList
{
    NSString *query=@"Select name, uid, pic_small from user where is_app_user = 1 and uid in (select uid2 from friend where uid1 = me()) order by concat(first_name,last_name) asc";
    NSDictionary *params=@{@"q":query};
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Result: %@", result);
            
            NSDictionary *res=(NSDictionary *) result;
            
            NSArray *friends=[res valueForKey:@"data"];
            
            NSLog(@"Array Size: %ld", friends.count);
            
            for(int i=0; i<friends.count; i++)
            {
                NSLog(@"Friend Name: %@",[friends[i] valueForKey:@"name"]);
                self.profilePic.profileID=[friends[i] valueForKey:@"uid"];
            }
        }
    }];
}
-(void) postDataToMobileService
{
    
    if(self.client.currentUser == nil)
    {
        NSString * accessToken=[FBSession activeSession].accessTokenData.accessToken;
        [self.client loginWithProvider:@"facebook" token:@{@"access_token":accessToken}  completion:^(MSUser *user, NSError *error) {
            if (error) {
                NSLog(@"Error calling login: %@", error);
                return;
            }
            NSLog(@"Logged in as %@", user.userId);
        }];
    }
    
    MSTable *table = [self.client tableWithName:@"FitPoints"];
    
    MSQuery *query=[table query];
    query.includeTotalCount=YES;
    query.parameters=@{@"userID":self.fbId};
    
    [query readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
        if (error) {
            NSLog(@"Error reading item: %@", error);
            return;
        }
        NSLog(@"Total Count:%ld", totalCount);
        
        if(totalCount<=0)
        {
            NSDictionary *item = @{@"userID":self.fbId,@"numFitPoints":@30};
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
            [item setValue:@31 forKey:@"numFitPoints"];
            
            [table update:item completion:^(NSDictionary *item, NSError *error) {
                if(error){
                    NSLog(@"Error updating item %@", error);
                    return;
                }
                NSLog(@"Updated: %@", item);
            }];
        }
    }];
    

}
@end
