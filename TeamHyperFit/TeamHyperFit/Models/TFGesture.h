//
//  TFGesture.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFGesture : NSObject

-(id)initWithName:(NSString*)name imageName:(NSString*) imageName;
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *imageName;

@end
