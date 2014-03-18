//
//  TMUIHeartrateIndicator.m
//  TeamFit
//
//  Created by Mark Wang on 3/17/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMUIHeartrateIndicator.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

const float kLineWidth = 3.0;
const int kContainerPadding = 30;
const int kProgressBarPadding = 10;
const int kProgressBarLineWidth = 10;

@interface TMUIHeartrateIndicator()
@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) UIColor *progressBartintColor;
@end


@implementation TMUIHeartrateIndicator
{
    float haftWidth;
    float haftHeight;
}

-(UIColor*)progressBartintColor
{
    if(!_progressBartintColor)
    {
        _progressBartintColor = self.window.tintColor;
    }
    
    return  _progressBartintColor;
}

-(UIColor*)tintColor
{
    if(!_tintColor)
    {
        _tintColor = self.window.tintColor;
    }
    
    return  _tintColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self heartRateInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self heartRateInit];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    haftWidth = self.frame.size.width/2;
    haftHeight = self.frame.size.height/2;
    
    [self drawCircleOutline:context];
    [self drawProgressBar:context];
    [self drawInnerCircle:context];

}

-(void)drawProgressBar:(CGContextRef) context
{
    CGContextSaveGState(context);
    
    float radius = haftWidth - kContainerPadding - kProgressBarPadding;
    
    CGContextAddArc(context, haftWidth, haftHeight, radius, 0, M_PI, 0);
    
    [self.progressBartintColor setStroke];
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, kProgressBarLineWidth);
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

-(void)drawCircleOutline:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    float radius = haftWidth - kContainerPadding;
    
    CGContextAddArc(context, haftWidth, haftHeight, radius, 0, M_PI * 2, 0);
    
    [self.tintColor setStroke];
    
    CGContextSetLineWidth(context, kLineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);

    CGFloat dotRadius = 5.0;
    CGFloat lengths[2];
    lengths[0] = 10;
    lengths[1] = dotRadius;
    
    CGContextSetLineDash(context, 0.0, lengths, 2);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextRestoreGState(context);
}

-(void)drawInnerCircle:(CGContextRef)context
{
    CGContextSaveGState(context);
    

    float radius = haftWidth - kContainerPadding - ( kProgressBarPadding * 2 ) - kProgressBarLineWidth/2;
    
    CGContextAddArc(context, haftWidth, haftHeight, radius, 0, M_PI * 2, 0);
    
    [self.tintColor setFill];
    
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}


-(void)heartRateInit
{
    self.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.progressBartintColor = [ UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7];
}

@end
