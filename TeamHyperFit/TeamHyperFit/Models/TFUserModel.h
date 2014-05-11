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


@property (strong, nonatomic) NSDictionary *userStatistics;

/*"male" , "female"*/
@property (nonatomic, strong) NSString *gender;
@property (nonatomic) NSInteger age;

@property (nonatomic) BOOL isDirty;

@property (nonatomic, strong) NSNumber *goalFitPoints;

 
@end
