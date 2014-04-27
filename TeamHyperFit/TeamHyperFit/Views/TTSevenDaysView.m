//
//  TTSevenDaysView.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTSevenDaysView.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

static const int SI_LINE_WIDTH = 5;
static const int SI_START_OFFSET = 20;
static const int SI_ARC_PADDING = 0;
static const int SI_GATE_PADDING = 3;

@interface TTSevenDaysView()

@property(nonatomic) float value;
@property(nonatomic) float maxValue;

@end

@implementation TTSevenDaysView
{
    int radius;
}

-(UIColor*)barColor
{
    if (_barColor == nil) {
        _barColor = [UIColor grayColor];
    }
    
    return _barColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if( self )
    {
        [self initialize];
    }
    
    return self;
}

-(void)initialize
{
    [self setOpaque:NO];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0 ];
    self.maxValue = 100;
    
    //! For testing
    self.value = 100;
    self.barColor = [UIColor colorWithRed:(178.0f/255.0f) green:(218.0f/255.0f) blue:(89.0f/255.0f) alpha:1];
}


-(void)drawFontWithString:(NSString*)text size:(int) size position:(CGPoint) point
{
    
    
    NSMutableAttributedString *displayText = [[NSMutableAttributedString alloc] initWithString:text];
    
    [displayText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size] range:NSMakeRange(0, text.length)];
    
    [displayText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, text.length)];
    
    [displayText addAttribute:NSStrokeColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, text.length)];
    
    [displayText addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:-3] range:NSMakeRange(0, text.length)];
    
    CGRect boundOfText = [displayText boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    [displayText drawAtPoint:CGPointMake(point.x - boundOfText.size.width/2, point.y - boundOfText.size.height / 2)];
    
    
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    radius = self.frame.size.width / 2 - SI_ARC_PADDING;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(0), ToRad(360), 0);
    [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f] setFill];
    
    
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextRestoreGState(ctx);
    
    /* Draw Gate */
    
    CGContextSaveGState(ctx);
    
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius - SI_GATE_PADDING,
                    ToRad(90+SI_START_OFFSET),
                    ToRad( (90-SI_START_OFFSET - (319 * ( 1.0 -  (self.value/self.maxValue) ) ) ) ) , 0);
    
    [self.barColor setStroke];
    
    //CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 2, self.barColor.CGColor);
    
    CGContextSetLineWidth(ctx, SI_LINE_WIDTH / 2);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);

    [self drawFontWithString:self.text size:radius/1.5f position:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 )];
    
}


-(void)updateUI
{
    
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
