//
//  A4Face.h
//  Assignment4
//
//  Created by ch484-mac7 on 3/12/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A4Face:NSObject

@property (nonatomic) CGRect face;
@property (nonatomic) CGRect rightEye;
@property (nonatomic) CGRect leftEye;
@property (nonatomic) CGRect mouth;

@property BOOL hasRightEye;
@property BOOL hasLeftEye;
@property BOOL hasMouth;

@property BOOL isSmiling;
@property BOOL isRightEyeClosed;
@property BOOL isLeftEyeClosed;

@end
