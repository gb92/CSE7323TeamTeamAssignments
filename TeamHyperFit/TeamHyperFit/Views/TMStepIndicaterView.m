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

static const int SI_LINE_WIDTH       = 30;
static const int SI_LINE_BG_WIDTH    = 40;
static const int SI_START_OFFSET     = 30;
static const int SI_ARC_PADDING      = 0;
static const int SI_GATE_PADDING     = 20;

@interface TMStepIndicaterView()<UIDynamicAnimatorDelegate>

@end

@implementation TMStepIndicaterView
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
    self.value = 0;
    
    self.defaultBounds = self.bounds;
    
    
    //! For testing
    self.barColor = [UIColor colorWithRed:(178.0f/255.0f) green:(218.0f/255.0f) blue:(89.0f/255.0f) alpha:1];
    
}

#pragma mark -- Touch Events

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate TMSetIndicaterViewPressed:self];
}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint location = [touch locationInView:touch.view];
//    
//    self.attachmentBehaviour.anchorPoint = location;
//    [self.attachmentBehaviour setLength:10];
//    [self.attachmentBehaviour setFrequency:1];
//    [self.attachmentBehaviour setDamping:10];
//}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator {
    
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    
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
    
    int valueToDraw = self.value;
    int maxValueToDraw = self.maxValue;
    
    if( maxValueToDraw < 0 ) maxValueToDraw = 0;
    
    if( valueToDraw > maxValueToDraw ) valueToDraw = maxValueToDraw;
    if( valueToDraw < 0 ) valueToDraw = 0;
    
    const float haftWidth = self.frame.size.width/2;
    const float haftHeight = self.frame.size.height/2;
    
    radius = haftWidth - SI_ARC_PADDING;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //! Draw Black Circle Background.
    
    CGContextSaveGState(ctx);
    
    CGContextAddArc(ctx, haftWidth, haftHeight, radius, ToRad(0), ToRad(360), 0);
    [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f] setFill];
    
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextRestoreGState(ctx);

    //! Draw Background of Gate.
    
    CGContextSaveGState(ctx);
    
    CGContextAddArc(ctx, haftWidth, haftHeight, radius - SI_GATE_PADDING,
                    ToRad( 90+SI_START_OFFSET ),
                    ToRad( (89-SI_START_OFFSET) ), 0);
    
    [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2f] setStroke];
    
    CGContextSetLineWidth(ctx, SI_LINE_BG_WIDTH / 2);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);
    
    //! Draw Gate.
    
    CGContextSaveGState(ctx);
    
    int targetAngle = (int)( (360 - (SI_START_OFFSET*2)) * ( 1.0f -  (valueToDraw/(float)maxValueToDraw) ) );
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius - SI_GATE_PADDING,
                    ToRad( 90+SI_START_OFFSET ),
                    ToRad( (90-SI_START_OFFSET) - targetAngle ) , 0);
    
    [self.barColor setStroke];
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 5, self.barColor.CGColor);
    
    CGContextSetLineWidth(ctx, SI_LINE_WIDTH / 2);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);
    
    const int kMinCenterTextSize = 40;
    const int kMaxCenterTextSize = 70;
    float textSizeRange = kMaxCenterTextSize - kMinCenterTextSize;
    
    int columnOfValue = [self getNumberOfColumnFromNumber:self.value];
    float textRatio = columnOfValue / 7.0f;
    
    int addTextSize = textSizeRange * (1.0f - textRatio);
    
    [self drawFontWithString:@"TODAY FIT POINTS" size:12 position:CGPointMake(haftWidth, haftHeight - 40 )];
    [self drawFontWithString:[NSString stringWithFormat:@"%d", (int)self.value] size:kMinCenterTextSize + addTextSize position:CGPointMake(haftWidth, haftHeight )];

    [self drawFontWithString:@"LAST WEEK" size:8 position:CGPointMake(haftWidth, haftHeight + 90 )];
    [self drawFontWithString:[NSString stringWithFormat:@"%d", (int)self.maxValue] size:12 position:CGPointMake(haftWidth, haftHeight + 100 )];
    
}

-(int)getNumberOfColumnFromNumber:(int)number
{

    NSString *textFromNumber = [NSString stringWithFormat:@"%d", number];
    
    return (uint)textFromNumber.length;
}

-(void)updateUI
{
    if( self.maxValue <= self.value )
    {
        [self.delegate TMSetIndicaterViewReachGoal:self];
    }
    
    [self setNeedsDisplay];
    
}



@end
