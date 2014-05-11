//
//  TFGestureRecognizer.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    TM_MODEL_SVM,
    TM_MODEL_KNN
    
} TTModelMode;


@class TFGestureRecognizer;

@protocol TFGestureRecognizerDelegate <NSObject>

-(void)TFGestureRecognizerDidDetectBegin:(TFGestureRecognizer*) sender;
-(void)TFGestureRecognizerDidDetectEnd:(TFGestureRecognizer*) sender;

@end

@interface TFGestureRecognizer : NSObject

@property (weak, nonatomic)id<TFGestureRecognizerDelegate> delegate;

@property (strong, nonatomic) NSNumber *modelDataSetID;
@property (nonatomic) TTModelMode gestureModelMode;

-(id) initWithModelDSID:(NSNumber *)modelDSID;

-(void) startGestureCapture;
-(void) stopGestureCapture;

-(void) startTrainingGestureCapture;
-(void) uploadTrainingData:(NSInteger) datasetID withLabel:(NSString *) label;

-(void)makeTrainingPrediction:(NSInteger) datasetID;

-(void)trainModel:(NSInteger) datasetID;
-(void)clearGesturePredictedData;

@property (strong, nonatomic) NSString *log;

-(NSString*)printGestureResult;

@end

