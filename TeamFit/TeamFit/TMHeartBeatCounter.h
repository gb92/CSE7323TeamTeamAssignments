//
//  TMHeartBeatCounter.h
//  TeamFit
//
//  Created by ch484-mac5 on 3/19/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMHeartBeatCounter : NSObject

-(void)setMeanOfRedValue:(float)redValue green:(float)greenValue blue:(float)blueValue;
@property (nonatomic) float heartRate;

-(std::vector<float>) getMaximumValueList;
-(std::vector<float>) getMeanOfRedValue;

@end

