//
//  TTGraphView.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/25/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTGraphView.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

const int kPaddingLeft      = 10;
const int kPaddingRight     = 10;
const int kPaddingBottom    = 10;
const int kPaddingTop       = 10;

const int kGraphPadding     = 10;

const int kDotSize          = 3;
const int kLineWidth        = 2;


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
    
    return YES;
}


-(void)calGraphPointsWithData:(NSArray*) data canvas:(CGRect) canvas pointsOut:(CGPoint*) pointsOut numberOfColum:(NSNumber*)numberOfColum
{
    NSInteger dataSize = ([data count] < [numberOfColum intValue])? [data count]: [numberOfColum intValue];
    
    NSNumber *max = @(1);
    
    //! Search max value only in range of number of columns.
    for ( int i=0; i<dataSize; i++ )
    {
        assert( [data[i] isKindOfClass:[NSNumber class]] );
        
        if( [data[i] isKindOfClass:[NSNumber class]] )
        {
            if (max < data[i])
            {
                max = data[i];
            }
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
            pointsOut[i].y =  (int) ( [data[i] floatValue] / [max floatValue] * (canvas.size.height-( 2*kGraphPadding) ) );
            
            pointsOut[i].y = canvas.size.height - pointsOut[i].y + canvas.origin.y - kGraphPadding;
        }
    }
    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
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
    }
}

-(void) drawGraphFrame:(CGContextRef) context
{
    CGContextSaveGState(context);
    
    CGPoint framePoints[3];
    framePoints[0] = CGPointMake( kPaddingLeft, kPaddingTop );
    framePoints[1] = CGPointMake( kPaddingLeft, self.bounds.size.height - kPaddingBottom );
    framePoints[2] = CGPointMake( self.bounds.size.width - kPaddingRight,
                                  self.bounds.size.height - kPaddingBottom );
    
    CGContextAddLines(context, framePoints, 3);
    
    CGContextSetLineCap(context, kCGLineCapSquare );
    CGContextSetLineWidth(context, 2.0f);
    
    [[UIColor whiteColor] setStroke];
    
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextRestoreGState(context);
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
