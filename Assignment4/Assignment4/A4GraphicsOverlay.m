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
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor=nil;
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    CGContextRef context= UIGraphicsGetCurrentContext();
    if(context != nil)
    {
        /*if(self.rectAroundFace.size.height>0 && self.rectAroundFace.size.width>0)
        {
            //CGContextSetBlendMode(context, )
            CGContextSetLineWidth(context, 2.0);
            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextAddRect(context, self.rectAroundFace);
            CGContextStrokePath(context);
            NSLog(@"Drawing Robot Face");
        }
        else
        {
            NSLog(@"rect around face is 0");
        }*/
        
        /*for(int i=0; i<self.faceRects.count; i++)
        {
            CGRect face=[self.faceRects[i] CGRectValue];
         
            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextAddRect(context, face);
            CGContextStrokePath(context);
        }*/
        
        CGContextSetLineWidth(context, 2.0);
        for(int i=0; i<self.faceRects.count;i++)
        {
            A4Face *face=self.faceRects[i];
            //[CGColorRef colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#>]
            
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
                CGContextAddRect(context, face.mouth);
                CGContextStrokePath(context);
                
                NSLog(@"isSmiling:%@",face.isSmiling?@"YES": @"NO");
                if(face.isSmiling)
                {
                    CGContextFillRect(context, face.mouth);
                }
            }
        }
    }
    else{
        NSLog(@"context is nil");
    }
}
- (void)drawRectOverFace:(CGRect)rect
{
/*    CGContextRef context= UIGraphicsGetCurrentContext();
    if(context != nil)
    {
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextAddRect(context, rect);
        CGContextStrokePath(context);
    }
    else{
        NSLog(@"context is nil");
    }
*/
    
    [self setNeedsDisplay];
}


@end
