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

@property (nonatomic) NSInteger sunFitPoints;
@property (nonatomic) NSInteger monFitPoints;
@property (nonatomic) NSInteger tueFitPoints;
@property (nonatomic) NSInteger wenFitPoints;
@property (nonatomic) NSInteger thuFitPoints;
@property (nonatomic) NSInteger friFitPoints;
@property (nonatomic) NSInteger satFitPoints;

@property (nonatomic) NSMutableArray *gesturesPoints;

/*"male" , "female"*/
@property (nonatomic, strong) NSString *gender;
@property (nonatomic) NSInteger age;

@property (nonatomic) BOOL isDirty;

@property (nonatomic, strong) NSNumber *goalFitPoints;

 
@end
