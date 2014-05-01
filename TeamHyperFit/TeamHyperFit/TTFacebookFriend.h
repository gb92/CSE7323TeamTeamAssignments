//
//  TTFacebookFriend.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 5/1/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTFacebookFriend : NSObject

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *profilePictureURL;
@property BOOL hasFitPointsValue;
@property (strong, nonatomic) NSNumber *currentFitPointsValue;

@end
