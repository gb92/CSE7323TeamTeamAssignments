//
//  TTGesture.m
//  Assignment6
//
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTGesture.h"

@implementation TTGesture

- (BOOL)isEqual:(id)object
{
	if (![object isKindOfClass:[TTGesture class]])
		return NO;
	
	TTGesture *otherGesture = (TTGesture *)object;
	
	if ([self.name isEqualToString:otherGesture.name])
		return YES;
	
	return NO;
}

@end
