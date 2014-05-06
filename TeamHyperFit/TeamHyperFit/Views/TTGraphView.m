//
//  TTGraphView.m
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/25/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTGraphView.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

const int kPaddingLeft      = 10;
const int kPaddingRight     = 10;
const int kPaddingBottom    = 20;
const int kPaddingTop       = 10;

const int kGraphPadding     = 10;

const int kDotSize          = 3;
const int kLineWidth        = 2;

@interface TTGraphView()

@property (nonatomic) NSInteger maxOfData;
@property (nonatomic) NSInteger minOfData;

@end

@implementation TTGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if ( ![self initialize] )
        {
            return nil;
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        if ( ![self initialize] )
        {
            return nil;
        }
    }
    return self;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        if ( ![self initialize] )
        {
            return nil;
        }
    }
    return self;
}

-(BOOL) initialize
{
    self.numberOfColumn = @(7);
    self.isShowPointNumber = NO;
    
    return YES;
}

#pragma mark -
#pragma Event Handling

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate TTGraphViewDidPressed:self];
}

#pragma mark -

-(NSInteger)getDataToDrawSize
{
    return ([self.data count] < [self.numberOfColumn intValue])? [self.data count]: [self.numberOfColumn intValue];
}

-(NSInteger)getGraphGab
{
     return ( (self.bounds.size.width - kPaddingLeft ) - (kGraphPadding*2) ) / ([self.numberOfColumn intValue]-1);
}

-(void)minMaxSearch:(NSArray*)data dataSize:(NSInteger) dataSize outMax:(NSNumber**) outMax outMin:(NSNumber**) outMin
{
    NSNumber *max = @(-1111111);
    NSNumber *min = @(9999999);
    
    //! Search max value only in range of number of columns.
    for ( int i=0; i<dataSize; i++ )
    {
        assert( [data[i] isKindOfClass:[NSNumber class]] );
        
        if( [data[i] isKindOfClass:[NSNumber class]] )
        {
            if ([max floatValue] < [data[i] floatValue])
            {
                max = data[i];
            }
            if ([min floatValue] > [data[i] floatValue])
            {
                min = data[i];
            }
        }
        else
        {
            NSLog(@"%@ is not kind of class.", data[i] );
        }
    }
    
    *outMax = max;
    *outMin = min;
}

-(void)calGraphPointsWithData:(NSArray*) data canvas:(CGRect) canvas pointsOut:(CGPoint*) pointsOut numberOfColum:(NSNumber*)numberOfColum
{
    NSInteger dataSize = [self getDataToDrawSize];
    
    NSNumber* max;
    NSNumber* min;
    
    [self minMaxSearch:data dataSize:dataSize outMax:&max outMin:&min];
    self.maxOfData = [max intValue];
    self.minOfData = [min intValue];
    
    //! Search max value only in range of number of columns.
    for ( int i=0; i<dataSize; i++ )
    {
        assert( [data[i] isKindOfClass:[NSNumber class]] );
        
        if( [data[i] isKindOfClass:[NSNumber class]] )
        {
            if ([max floatValue] < [data[i] floatValue])
            {
                max = data[i];
            }
        }
        else
        {
            NSLog(@"%@ is not kind of class.", data[i] );
        }
    }
    
    //! Make sure max is not Zero
    if (max == 0)
    {
        max = @(0.0001f);
    }
    
    int pointGap = ( canvas.size.width - (kGraphPadding*2) ) / ([numberOfColum intValue]-1);
    
    //! Normalize data to size of this view.
    for ( int i=0; i<dataSize; i++ )
    {
        assert( [self.data[i] isKindOfClass:[NSNumber class]] );
        
        if( [self.data[i] isKindOfClass:[NSNumber class]] )
        {
            pointsOut[i].x = ( pointGap * i ) + canvas.origin.x + kGraphPadding ;
            pointsOut[i].y =  (int) ( [data[i] floatValue] / [max floatValue] * (canvas.size.height - (2*kGraphPadding)) );
            
            pointsOut[i].y = canvas.size.height - pointsOut[i].y;
        }
    }
    
}

#pragma mark -
#pragma mark Drawing Helper Functions

typedef enum
{
    TTG_CENTER,
    TTG_LEFT,
    TTG_RIGHT
    
} TTGTextAlign;

-(void)drawFontWithString:(NSString*)text size:(int) size position:(CGPoint) point align:(TTGTextAlign) align
{
    
    NSMutableAttributedString *displayText = [[NSMutableAttributedString alloc] initWithString:text];
    
    [displayText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:size] range:NSMakeRange(0, text.length)];
    
    [displayText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, text.length)];
    
    [displayText addAttribute:NSStrokeColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, text.length)];
    
    [displayText addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:-3] range:NSMakeRange(0, text.length)];
    
    CGRect boundOfText = [displayText boundingRectWithSize:CGSizeMake(200, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    switch (align) {
        case TTG_CENTER:
            [displayText drawAtPoint:CGPointMake(point.x - boundOfText.size.width/2, point.y - boundOfText.size.height / 2)];
            break;
        case TTG_LEFT:
            [displayText drawAtPoint:CGPointMake(point.x, point.y - boundOfText.size.height / 2)];
            break;
        case TTG_RIGHT:
            [displayText drawAtPoint:CGPointMake(point.x - boundOfText.size.width/2, point.y - boundOfText.size.height / 2)];
            break;
        default:
            [displayText drawAtPoint:CGPointMake(point.x - boundOfText.size.width/2, point.y - boundOfText.size.height / 2)];
            break;
    }
    
    
    
}

-(void) drawLine:(CGContextRef) context points:(CGPoint*)points pointSize:(int)pointSize withColor:(UIColor*) color lineWidth:(float) lineWidth
{
    //! Draw Inner Lines
    CGContextSaveGState(context);
    
    CGContextAddLines(context, points, pointSize);
    
    CGContextSetLineCap(context, kCGLineCapSquare );
    CGContextSetLineWidth(context, lineWidth);
    
    [color setStroke];
    
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Drawing


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self drawFontWithString:@"FIT POINTS" size:10 position:CGPointMake(kPaddingLeft+10, kPaddingTop) align:TTG_LEFT];
    
    [self drawGraphFrame:ctx];
    
    if (self.data)
    {
        int canvasWidth = self.bounds.size.width - (kPaddingRight+kPaddingLeft);
        int canvasHight = self.bounds.size.height - (kPaddingTop+kPaddingBottom);
        
        CGRect canvasRect = CGRectMake( kPaddingLeft, kPaddingTop, canvasWidth, canvasHight);
        
        CGPoint graphPoints[[self.numberOfColumn intValue]];
        
        NSInteger dataSize = ([self.data count] < [self.numberOfColumn intValue])? [self.data count]: [self.numberOfColumn intValue];
        
        [self calGraphPointsWithData:self.data canvas:canvasRect pointsOut:graphPoints numberOfColum:self.numberOfColumn ];
        
        [self drawGraphLine:ctx points:graphPoints numberOfPoints:dataSize ];
        
        if (self.isShowPointNumber)
        {
            [self drawNumberAtEachPoint:graphPoints numberOfPoints:dataSize];
        }
    }
}

-(void) drawGraphFrame:(CGContextRef) context
{
    
    CGPoint framePoints[3];
    framePoints[0] = CGPointMake( kPaddingLeft, kPaddingTop );
    framePoints[1] = CGPointMake( kPaddingLeft, self.bounds.size.height - kPaddingBottom );
    framePoints[2] = CGPointMake( self.bounds.size.width - kPaddingRight,
                                  self.bounds.size.height - kPaddingBottom );
    
    float haftOfGraphCanvas = ( (self.bounds.size.height - kPaddingBottom - kGraphPadding - kGraphPadding - kPaddingTop) / 2 ) + kGraphPadding + kPaddingTop;
    
    CGPoint midLine[2];
    midLine[0] = CGPointMake( kPaddingLeft, haftOfGraphCanvas );
    midLine[1] = CGPointMake( self.bounds.size.width - kPaddingRight,
                             haftOfGraphCanvas );
    
    CGPoint topLine[2];
    topLine[0] = CGPointMake( kPaddingLeft, kPaddingTop);
    topLine[1] = CGPointMake( self.bounds.size.width - kPaddingRight,
                             kPaddingTop );
    
    //! Draw Frame Lines
    [self drawLine:context points:framePoints pointSize:3 withColor:[UIColor whiteColor] lineWidth:2.0f];
    //! Draw a Mid Line
    [self drawLine:context points:midLine pointSize:2 withColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3] lineWidth:1];
    //! Draw a Top Line
    //[self drawLine:context points:topLine pointSize:2 withColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3] lineWidth:1];
    
//    const int kLeftAxeOffest = 35;
//    
//    [self drawFontWithString:[NSString stringWithFormat:@"%ld", (long)self.minOfData] size:10 position: CGPointMake(framePoints[1].x - kLeftAxeOffest, framePoints[1].y) align:TTG_LEFT];
//    [self drawFontWithString:[NSString stringWithFormat:@"%ld", (long)(self.maxOfData - self.minOfData) / 2] size:10 position: CGPointMake(framePoints[1].x - kLeftAxeOffest, haftOfGraphCanvas) align:TTG_LEFT];
//    [self drawFontWithString:[NSString stringWithFormat:@"%ld", (long)self.maxOfData] size:10 position: CGPointMake(framePoints[1].x - kLeftAxeOffest, kPaddingTop ) align:TTG_LEFT];
//    

    NSArray* dayText = @[@"su",@"mo",@"tu",@"we",@"th",@"fr",@"st"];
    NSInteger pointGap = [self getGraphGab];
    
    for( int i=0; i< 7; i++ )
    {
        [self drawFontWithString:dayText[i] size:10 position:CGPointMake( (pointGap*i)+kPaddingLeft +kGraphPadding,
                                                                         self.bounds.size.height - kPaddingBottom + 10) align:TTG_CENTER];
    }
    
}

-(void) drawNumberAtEachPoint:(CGPoint*) points numberOfPoints:(NSInteger) numberOfPoints
{
    if (numberOfPoints <= [self.data count])
    {
        for ( int i=0; i < (int)numberOfPoints; i++ )
        {
            [self drawFontWithString:[NSString stringWithFormat:@"%d", [self.data[i] intValue] ] size:10 position:CGPointMake(points[i].x, points[i].y - 12) align:TTG_CENTER];
        }
    }
    
}

-(void) drawGraphLine:(CGContextRef) context points:(CGPoint*) points numberOfPoints:(NSInteger) numberOfPoints
{
    
    CGContextSaveGState(context);
    
    CGContextAddLines(context, points, (int)numberOfPoints);
    
    CGContextSetLineCap(context, kCGLineCapSquare );
    
    CGContextSetLineWidth(context, kLineWidth);
    
    [[UIColor whiteColor] setStroke];
    
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextRestoreGState(context);
    
    
    // Draw Dots
    for ( int i=0; i < (int)numberOfPoints; i++ )
    {
        [self drawDot:context point:points[i]];
    }
}


-(void) drawDot:(CGContextRef) context point:(CGPoint) point
{
    CGContextSaveGState(context);
    
    CGContextAddArc(context, point.x, point.y, kDotSize, 0, ToRad(360), 0);
    
    [[UIColor whiteColor] setFill];
    
    CGContextDrawPath(context, kCGPathEOFill);
    
    CGContextRestoreGState(context);
}

@end
