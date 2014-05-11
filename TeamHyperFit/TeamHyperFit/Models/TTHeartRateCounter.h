//
//  TTHeartRateCounter.h
//  TeamHyperFit
//
//  Created by ch484-mac7 on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTGender) {
    TTGenderMale = 0,
    TTGenderFemale = 1
};

@interface TTHeartRateCounter : NSObject

-(void)start;
-(void)stop;
-(NSNumber*)getHeartRate;
-(BOOL)isStated;
- (NSString *)heartRateZoneForGender:(TTGender)gender atAge:(NSUInteger)age;

@end
