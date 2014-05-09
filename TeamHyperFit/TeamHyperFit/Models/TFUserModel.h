//
//  TFUserModel.h
//  TeamFitModels
//
//  Created by Gavin Benedict on 4/23/14.
//  Copyright (c) 2014 TeamFit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTUserBaseModel.h"

@interface TFUserModel : TTUserBaseModel

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSNumber *fitPoints;
@property (strong, nonatomic) NSNumber *goalFitPoints;
//@property (strong, nonatomic) NSNumber *calories;
@property (strong, nonatomic) NSDictionary *userStatistics;

@property (nonatomic) BOOL isDirty;

 
@end
