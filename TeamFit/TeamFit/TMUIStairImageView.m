//
//  TMUIStairImageView.m
//  TeamFit
//
//  Created by Mark Wang on 2/28/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMUIStairImageView.h"

@interface TMUIStairImageView()

@property (strong, nonatomic) CALayer* gateLayer;
@property (strong, nonatomic) CALayer* frontBgLayer;

@end

@implementation TMUIStairImageView
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        // Create layers.
        UIImage *gateImage = [UIImage imageNamed:@"activeRing"];
        CGImageRef gateImageRef = [gateImage CGImage];
        
        self.gateLayer = [[CALayer alloc] init];
        [self.gateLayer setBounds:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)];
        [self.gateLayer setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [self.gateLayer setZPosition:10];
        [self.gateLayer setContents:(__bridge id)(gateImageRef)];
        [self.gateLayer setContentsGravity:kCAGravityResizeAspect];
        //[self.gateLayer setContentsRect:CGRectMake(-0.1, -0.1, 1.2, 1.2)];
        [self.gateLayer setOpacity:0.0f];
        
        [[self layer] addSublayer:self.gateLayer];
    
        
        /**----------------------------------------------------------------------------------------**/
        
        UIImage *frontBgImage = [UIImage imageNamed:@"circleFront"];
        CGImageRef frontBgImageRef = [frontBgImage CGImage];
        
        self.frontBgLayer = [[CALayer alloc] init];
        [self.frontBgLayer setFrame:self.frame];
        [self.frontBgLayer setBounds:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)];
        [self.frontBgLayer setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [self.frontBgLayer setZPosition:1];
        [self.frontBgLayer setContents:(__bridge id) frontBgImageRef ];
        
        [[self layer] addSublayer:self.frontBgLayer];
        

    }
    
    return self;
}

-(CABasicAnimation*)createOpacityAnimationFrom:(float) fromValue To:(float) toValue withDuration:(float)duration
{
    
    CABasicAnimation *resultAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [resultAnimation setFromValue:[NSNumber numberWithFloat:fromValue]];
    [resultAnimation setToValue:[NSNumber numberWithFloat:toValue]];
    [resultAnimation setDuration:duration];
    
    return resultAnimation;
}


-(void)createGateAnimation
{
    CATransform3D rotationTransform = CATransform3DMakeRotation(M_PI/2, 0, 0, 1);
    
    CABasicAnimation *gateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [gateAnimation setToValue:[NSValue valueWithCATransform3D:rotationTransform]];
    [gateAnimation setDuration:1.0/4.0];
    [gateAnimation setCumulative:YES];
    [gateAnimation setRepeatCount: INT_MAX];
    
    [self.gateLayer addAnimation:gateAnimation forKey:@"rotation"];
    
}

-(void)playFrontBgAppearAnimation
{
 
    CABasicAnimation *frontAppearAnimation = [self createOpacityAnimationFrom:0.0 To:1.0 withDuration:0.5];
    [self.frontBgLayer setOpacity:1.0];
    [self.frontBgLayer addAnimation:frontAppearAnimation forKey:@"opacity"];
}

-(void)playFrontBgDisappearAnimation
{
    
    CABasicAnimation *frontAppearAnimation = [self createOpacityAnimationFrom:1.0 To:0.0 withDuration:0.5];
    [self.frontBgLayer setOpacity:0.0];
    [self.frontBgLayer addAnimation:frontAppearAnimation forKey:@"opacity"];
}

-(void)activate
{
    
    if (! [self.gateLayer animationForKey:@"rotation"] ) {
                [self createGateAnimation];
    }

    CABasicAnimation* appearAnimation = [self createOpacityAnimationFrom:0.0 To:1.0 withDuration:0.5];
    [self.gateLayer addAnimation:appearAnimation forKey:@"opacity"];
    [self.gateLayer setOpacity:1.0];
    [self resumeLayer:self.gateLayer];
    
    
    [self playFrontBgDisappearAnimation];
}

-(void)deactivate
{

    CABasicAnimation* disappearAnimation = [self createOpacityAnimationFrom:1.0 To:0.0 withDuration:0.5];
    [self.gateLayer addAnimation:disappearAnimation forKey:@"opacity"];
    [self.gateLayer setOpacity:0.0];
    
    [self playFrontBgAppearAnimation];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
