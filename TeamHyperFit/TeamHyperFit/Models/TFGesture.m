//
//  TFGesture.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TFGesture.h"

@implementation TFGesture

-(id)initWithName:(NSString*)name imageName:(NSString*) imageName
{
    self = [self init];
    
    if (self) {
        self.name = name;
        self.imageName = imageName;
    }
    return self;
}

@end
