//
//  TTMotionCaptureViewController.h
//  Assignment6
//
//  Created by install on 4/10/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTGesture;

@protocol TTMotionCaptureDelegate <NSObject>
- (void)didCaptureNewMotion:(TTGesture *)capturedGesture;
@end

@interface TTMotionCaptureViewController : UIViewController
@property (nonatomic, weak) id<TTMotionCaptureDelegate> delegate;
@property (strong,nonatomic) NSNumber *dsid;
@property int GID;
@end
