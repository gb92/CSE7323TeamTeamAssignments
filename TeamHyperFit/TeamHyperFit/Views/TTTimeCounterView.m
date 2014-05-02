//
//  TMStepIndicaterView.m
//  TeamFit
//
//  Created by Mark Wang on 2/26/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTTimeCounterView.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

static const int SI_LINE_WIDTH      = 20;
static const int SI_ARC_PADDING     = 0;
static const int SI_GATE_PADDING    = 10;

@interface TTTimeCounterView()

@property(nonatomic) NSInteger currentTime;
@property(nonatomic,readwrite) BOOL isStarted;

@end

@implementation TTTimeCounterView
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
    
    //! Set default time.
    self.timeSeconds = 30;
    self.currentTime = self.timeSeconds;
    
}


#pragma mark -- Drawing

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

    [self drawFontWithString:[NSString stringWithFormat:@"%ld", (long)self.currentTime] size:80 position:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 )];
    [self drawFontWithString:@"secondes" size:15 position:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 50 )];
    
    /* Draw Gate */
    if (self.isStarted)
    {

        CGContextSaveGState(ctx);
        
        CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius - SI_GATE_PADDING,
                        ToRad( 90 ),
                        ToRad( (360 * ( 1.0 -  (self.currentTime/(float)self.timeSeconds) ) ) + 89 ) , 0);
        
        [self.barColor setStroke];
        
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 2, self.barColor.CGColor);
        
        CGContextSetLineWidth(ctx, SI_LINE_WIDTH / 2);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        
        CGContextDrawPath(ctx, kCGPathStroke);
        
        CGContextRestoreGState(ctx);
    }
        
    
}

-(void)updateUI
{
    [self setNeedsDisplay];
}

#pragma mark -- Actions

-(void)timeSeconds:(NSInteger)value
{
    if( value < 0 )
    {
        _timeSeconds = 0;
    }
    else
    {
        _timeSeconds = value;
    }
    
    // Clamp current value to max value
    if( value < _timeSeconds ) _timeSeconds = value;

    [self updateUI];
}

-(void)start
{
    if (!self.isStarted)
    {
        self.barColor = [UIColor colorWithRed:(178.0f/255.0f) green:(218.0f/255.0f) blue:(89.0f/255.0f) alpha:1];
        
        self.isStarted = YES;
        [self.delegate TTTimeCounterDidStarted:self];
        [self timeUpdate];
        
    }
}

-(void)stop
{
    if (self.isStarted)
    {
        self.barColor = [UIColor grayColor];
        
        self.isStarted = NO;
        [self.delegate TTTimeCounterDidStoped:self];
        
        [self updateUI];
    }
}

-(void)reset
{
    if (self.isStarted) {
        self.isStarted = NO;
        self.currentTime = self.timeSeconds;
    }
}

-(void)timeUpdate
{
    if (self.isStarted) {
        
        self.currentTime--;
        
        if( self.currentTime < 0 )
        {
            [self reset];
            [self.delegate TTTimeCounterDidFinshed:self];
            
        }
        else
        {
            [self performSelector:@selector(timeUpdate) withObject:nil afterDelay:1];
        }
        
        [self updateUI];
    }
}

@end
