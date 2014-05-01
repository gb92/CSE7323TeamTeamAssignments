//
//  TTCaptureScreenShot.h
//  TeamHyperFit
//
//  Created by ch484-mac7 on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTCaptureScreenShot : NSObject
+(UIImage *)screenshot;
+(UIImage*)screenshotBlur;
+(UIImage*) blur:(UIImage*)theImage;
@end
