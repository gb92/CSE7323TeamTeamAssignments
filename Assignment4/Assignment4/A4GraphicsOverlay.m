//
//  A4GraphicsOverlay.m
//  Assignment4
//
//  Created by ch484-mac7 on 3/12/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import "A4GraphicsOverlay.h"
#import "A4Face.h"

@implementation A4GraphicsOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=nil;
        //self.transform=CGAffineTransformMakeRotation(M_PI);
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor=nil;
        //self.transform=CGAffineTransformMakeRotation(M_PI);
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    CGContextRef context= UIGraphicsGetCurrentContext();
    if(context != nil)
    {
        
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextAddRect(context, self.frame);
        CGContextStrokePath(context);
        
        CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
        CGContextAddRect(context,([UIApplication sharedApplication].delegate).window.bounds);
        CGContextStrokePath(context);

        for(int i=0; i<self.faceRects.count;i++)
        {
            A4Face *face=self.faceRects[i];
            
            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextAddRect(context, face.face);
            CGContextStrokePath(context);
            
            if(face.hasLeftEye)
            {
                CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
                
                CGContextAddRect(context, face.leftEye);
                CGContextStrokePath(context);
                NSLog(@"isLeftEyeClosed:%@",face.isLeftEyeClosed?@"YES": @"NO");
                if(face.isLeftEyeClosed)
                {
                    CGContextFillRect(context, face.leftEye);
                }
            }
            if(face.hasRightEye)
            {
                CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
                
                CGContextAddRect(context, face.rightEye);
                CGContextStrokePath(context);
                NSLog(@"isRightEyeClosed:%@",face.isRightEyeClosed?@"YES": @"NO");
                if(face.isRightEyeClosed)
                {
                    CGContextFillRect(context, face.rightEye);
                }
            }
            if(face.hasMouth)
            {
                CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
                
                //CGRect modMouth=CGRectMake(self.frame.size.height-face.mouth.origin.x,self.frame.size.width-face.mouth.origin.y,face.mouth.size.width,face.mouth.size.height);
                CGContextAddRect(context, face.mouth);
                CGContextStrokePath(context);
                
                NSLog(@"isSmiling:%@",face.isSmiling?@"YES": @"NO");
                if(face.isSmiling)
                {
                    CGContextFillRect(context, face.mouth);
                }
            }
        }
        CGAffineTransform transform=CGAffineTransformMakeRotation(M_PI_2);
        //transform=CGAffineTransformConcat(transform, CGAffineTransformMakeScale(1.0, 1.0));
        [self setTransform:transform];
    }
    else{
        NSLog(@"context is nil");
    }
}



@end
