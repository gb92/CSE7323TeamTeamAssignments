//
//  TMUIHeartrateIndicator.m
//  TeamFit
//
//  Created by Chatchai Wangwiwiwattana on 3/17/14.
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
@property (strong, nonatomic) UIColor *progressBarTintColor;


@property (nonatomic) float min;
@property (nonatomic) float max;
@property (nonatomic) float value;

@property (nonatomic) float heartRate;
@end


@implementation TMUIHeartrateIndicator
{
    float haftWidth;
    float haftHeight;
}

-(UIColor*)progressBarTintColor
{
    if(!_progressBarTintColor)
    {
        _progressBarTintColor = self.window.tintColor;
    }
    
    return  _progressBarTintColor;
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
    [self drawHeartRateNumber:context];
    //[self drawGraph:context];
    [self drawInnerCircle:context];

}

-(void)drawGraph:(CGContextRef) context
{
    CGContextSaveGState(context);
    
    //@TODO Add later if I have time.
    
    CGContextRestoreGState(context);
}

-(void)drawHeartRateNumber:(CGContextRef) context
{
    CGContextSaveGState(context);


    NSString *heartRateString = [NSString stringWithFormat:@"%.0f",self.heartRate];

    NSMutableAttributedString *displayText = [[NSMutableAttributedString alloc] initWithString:heartRateString];
    
    [displayText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:80.0] range:NSMakeRange(0, heartRateString.length)];
    
    [displayText addAttribute:NSForegroundColorAttributeName value:self.progressBarTintColor range:NSMakeRange(0, heartRateString.length)];
    
    [displayText addAttribute:NSStrokeColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, heartRateString.length)];
    
    [displayText addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:-3] range:NSMakeRange(0, heartRateString.length)];
    
    CGRect boundOfText = [displayText boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    [displayText drawAtPoint:CGPointMake(haftWidth - boundOfText.size.width/2, haftHeight - boundOfText.size.height / 2)];
    
    
    CGContextRestoreGState(context);
}

-(void)drawProgressBar:(CGContextRef) context
{
    CGContextSaveGState(context);
    
    float radius = haftWidth - kContainerPadding - kProgressBarPadding;
    
    CGContextAddArc(context, haftWidth, haftHeight, radius, M_PI_2 , ToRad( 360 * (self.value / self.max) ) + M_PI_2, 0);
    
    [self.progressBarTintColor setStroke];
    
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
    

    float radius = haftWidth - kContainerPadding - ( kProgressBarPadding * 2 );
    
    CGContextAddArc(context, haftWidth, haftHeight, radius, 0, M_PI * 2, 0);
    
    [self.tintColor setFill];
    
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}


-(void)heartRateInit
{
    self.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    self.progressBarTintColor = [ UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:0.8 ];
    
    self.value = 0;
    self.min = 0;
    self.max = 100;

    
    
    self.heartRate = 0;
    [self increaseValue];
}


-(void)increaseValue
{
    if( self.value < self.max)
    {
        
        self.value += 1;
        
        self.heartRate = self.value;
        
        [self performSelector:@selector(increaseValue) withObject:nil afterDelay:0.01];
        [self setNeedsDisplay];
        
    }

}
@end
