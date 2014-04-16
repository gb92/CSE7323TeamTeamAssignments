//
//  TTGesture.m
//  Assignment6
//
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTGesture.h"
#import "Constants.h"

@implementation TTGesture

- (void)uploadToServer
{
//	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//	
//	manager.requestSerializer = [AFJSONRequestSerializer new];
//	manager.responseSerializer = [AFHTTPResponseSerializer new];
//	
//	NSString *url = apiBaseUrl;
//	
//	NSDictionary *parameters = @{
//								 @"name" : self.name
//								 };
//	
//	[manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		
//		NSLog(@"JSON: %@", responseObject);
//		[[NSNotificationCenter defaultCenter] postNotificationName:kAssignment6_Notification_UploadGestureSucceeded object:nil];
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		
//		NSLog(@"Error: %@", error);
//		[[NSNotificationCenter defaultCenter] postNotificationName:kAssignment6_Notification_UploadGestureFailed object:nil];
//		
//	}];
}

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
