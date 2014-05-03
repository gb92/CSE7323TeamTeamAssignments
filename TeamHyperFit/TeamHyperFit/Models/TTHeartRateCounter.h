//
//  TTHeartRateCounter.h
//  TeamHyperFit
//
//  Created by Rita on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTHeartRateCounter : NSObject

-(void)start;
-(void)stop;
-(NSNumber*)getHeartRate;
-(BOOL)isStated;

@end
