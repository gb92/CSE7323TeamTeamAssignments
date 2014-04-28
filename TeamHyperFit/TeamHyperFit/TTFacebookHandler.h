//
//  TTFacebookHandler.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTFacebookHandler : NSObject

-(NSNumber *) getCurrentUserFitPoints;

-(NSArray *) getFriendsFitPoints;

-(void) updateCurrentUserFitPoints;

@end
