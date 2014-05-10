//
//  TFGestureRecognizer.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFGestureRecognizer : NSObject

@property (nonatomic, assign)id delegate;

@property (strong, nonatomic) NSNumber *modelDataSetID;


-(id) initWithModelDSID:(NSNumber *)modelDSID;

-(void) startGestureCapture;
-(void) stopGestureCapture;

-(void) startTrainingGestureCapture;
-(void) uploadTrainingData:(NSInteger) datasetID withLabel:(NSString *) label;

-(void)makeTrainingPrediction:(NSInteger) datasetID;

-(void)trainModel:(NSInteger) datasetID;

@property (strong, nonatomic) NSString *log;

@end
