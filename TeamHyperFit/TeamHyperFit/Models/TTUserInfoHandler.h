//
//  TTUserInfoHandler.h
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/8/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFUserModel.h"
#import "TTFriendModel.h"
#import "TTFacebookHandler.h"

@interface TTUserInfoHandler : NSObject <TTFacebookHandlerDelegate>

@property (strong, nonatomic) TFUserModel *userInfo;
@property (strong, nonatomic) NSMutableArray *friendsInfo;
@property (nonatomic, strong) TTFacebookHandler* fbHandler;

-(void)updateUserInfo:(void(^)( TFUserModel*, NSError* error)) onFinish;

-(void)updateFriendsInfo:(void(^)( NSError* error )) callback;
@end
