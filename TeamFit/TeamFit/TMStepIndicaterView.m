//
//  TMStepIndicaterView.m
//  TeamFit
//
//  Created by Mark Wang on 2/26/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMStepIndicaterView.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

static const int SI_LINE_WIDTH = 40;
static const int SI_START_OFFSET = 20;
static const int SI_ARC_PADDING = 40;

@interface TMStepIndicaterView()

@property(nonatomic) float value;
@property(nonatomic) float maxValue;

@end

@implementation TMStepIndicaterView
{
    int radius;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
        self.maxValue = 100;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if( self )
    {
        [self setOpaque:NO];
        self.maxValue = 100;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    radius = self.frame.size.height / 2 - SI_ARC_PADDING;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(90+SI_START_OFFSET), ToRad(90-SI_START_OFFSET), 0);
    [[UIColor whiteColor] setStroke];
    
    CGContextSetLineWidth(ctx, SI_LINE_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);

    /* Draw Gate */
    
    CGContextSaveGState(ctx);
    
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius,
                    ToRad(90+SI_START_OFFSET),
                    ToRad( (90-SI_START_OFFSET - (319 * ( 1.0 -  (self.value/self.maxValue) ) ) ) ) , 0);
    
    [[UIColor grayColor] setStroke];
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 2, [UIColor grayColor].CGColor);
    
    CGContextSetLineWidth(ctx, SI_LINE_WIDTH / 2);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);

}

-(void)updateUI
{
    if( self.maxValue <= self.value )
    {
        [self.delegate TMSetIndicaterViewReachGoal:self];
    }
    
    [self setNeedsDisplay];
    
}

-(void)setStepValue:(float)value
{
    if( value < 0 )
    {
        self.value = 0;
    }
    else if( value > self.maxValue)
    {
        self.value = self.maxValue;
    }
    else
    {
        self.value = value;
    }
    
    [self updateUI];
}

-(void)setMaxValue:(float)value
{
    if( value < 0 )
    {
        _maxValue = 0;
    }
    else
    {
        _maxValue = value;
    }
    
    // Clamp current value to max value
    if( value < _value ) _value = value;
    
    [self updateUI];
}



@end
