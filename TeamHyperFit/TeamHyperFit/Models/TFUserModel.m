//
//  TFUserModel.m
//  TeamFitModels
//
//  Created by Gavin Benedict on 4/23/14.
//  Copyright (c) 2014 TeamFit. All rights reserved.
//

#import "TFUserModel.h"


@interface TFUserModel()


@end

@implementation TFUserModel

-(id)init
{
    self = [super init];
    if (self)
    {
        //Init code here.
    }
    
    return self;
}

-(void)requestInfoFromServer:(void(^)(NSError* error)) onFinish
{
    if( !self.isDirty )
    {
        [self.fbHandler getCurrentUserFitPoints:^(NSNumber *fitPoints, NSError *error){
            if( !error )
            {
                self.fitPoints = fitPoints;
            }
            
            onFinish( error );
            
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
    [self.fbHandler updateCurrentUserFitPoints: self.fitPoints onFinish:^(NSError* error)
     {
         if( !error )
         {
             self.isDirty = NO;
         }
         
         onFinish(error);
     
     }];
    
}

-(void)updateUserInfo:(void(^)(NSError* error)) onFinish
{
    if( self.isDirty )
    {
        [self syncInfoToServer:^(NSError* error){
        
            if( !error )
            {
                [self requestInfoFromServer:^(NSError *error) {
                    onFinish(error);
                }];
            }
            else
            {
                NSLog(@"error in TTFacebook Update user Info : %@", error);
            }
        }];
    }
    else
    {
        [self requestInfoFromServer:^(NSError *error) {
            onFinish(error);
        }];
    }
    /*

    [self.fbHandler getFriendsFitPoints:^(NSArray *friends, NSError *error) {
        if(!error)
        {
            if( [friends count] > 0 )
            {
                NSLog(@"s : %@", [friends[0] objectForKey:@"name"] );
            }
        }
        
    }];
    
     */
}

@end
