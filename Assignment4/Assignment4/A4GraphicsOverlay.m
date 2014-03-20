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
        //CGContextTranslateCTM(context, 0, self.bounds.size.height);
        //CGContextScaleCTM(context, 1.0f, -1.0f);
        
        CGFloat scaleX=self.imageSize.size.width/self.bounds.size.width;
        CGFloat scaleY=self.imageSize.size.height/self.bounds.size.height;
        
        UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
        
//        if(orientation == UIInterfaceOrientationLandscapeLeft)
//        {
//            CGContextRotateCTM(context, M_PI);
//            CGContextTranslateCTM(context, 0, -1*self.bounds.size.width);
//        }
        
        CGContextSetLineWidth(context, 2.0);

        
//        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
//        CGContextAddRect(context, self.bounds);
//        CGContextStrokePath(context);
//        
//        CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
//        CGContextAddRect(context,([UIApplication sharedApplication].delegate).window.bounds);
//        CGContextStrokePath(context);

        for(int i=0; i<self.faceRects.count;i++)
        {
            A4Face *face=self.faceRects[i];
            if(orientation==UIInterfaceOrientationPortrait)
            {
                CGRect 
            }
            else
            {
                CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
                CGContextAddRect(context, face.face);
                CGContextStrokePath(context);
            }

            if(face.hasLeftEye)
            {
                CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//                CGRect scaledLeftEye;
//                if(orientation==UIInterfaceOrientationPortrait)
//                {
//                 scaledLeftEye=CGRectMake(face.leftEye.origin.y*scaleX, face.leftEye.origin.x*scaleY, face.leftEye.size.width*scaleX, face.leftEye.size.height*scaleY);
//                }
//                else if(orientation == UIInterfaceOrientationLandscapeLeft)
//                {
//                    scaledLeftEye=CGRectMake(face.leftEye.origin.x*scaleY, face.leftEye.origin.y*scaleX, face.leftEye.size.width*scaleX, face.leftEye.size.height*scaleY);
//                }
//                else
//                {
//                    scaledLeftEye=CGRectMake(face.leftEye.origin.x*scaleY, face.leftEye.origin.y*scaleX, face.leftEye.size.width*scaleX, face.leftEye.size.height*scaleY);
//                }
                
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
        
        //CGAffineTransform transform=CGAffineTransformMakeRotation(M_PI_2);
        //transform=CGAffineTransformConcat(transform, CGAffineTransformMakeScale(1.0, 1.0));
        //[self setTransform:transform];
    }
    else{
        NSLog(@"context is nil");
    }
}



@end
