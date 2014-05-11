//
//  TTSettingModel.h
//  TeamHyperFit
//
//  Created by Mark Wang on 5/10/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    TM_MODEL_SVM,
    TM_MODEL_KNN
    
} TTModelMode;

@interface TTSettingModel : NSObject

@property (nonatomic) TTModelMode gestureModelMode;
@property (nonatomic) NSInteger datasetID;
@property (nonatomic) BOOL isHeartRateEnable;

@end
