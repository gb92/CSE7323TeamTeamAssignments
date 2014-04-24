//
//  TFUserModel.h
//  TeamFitModels
//
//  Created by Gavin Benedict on 4/23/14.
//  Copyright (c) 2014 TeamFit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFUserModel : NSObject

@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSNumber *fitPoints;
@property (strong, nonatomic) NSDictionary *userStatistics;

 
@end
