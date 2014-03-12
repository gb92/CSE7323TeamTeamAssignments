//
//  A4GraphicsOverlay.h
//  Assignment4
//
//  Created by ch484-mac7 on 3/12/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A4GraphicsOverlay : UIView

@property(nonatomic) CGRect rectAroundFace;
@property(strong, nonatomic) NSArray *faceRects;


-(void) drawRectOverFace:(CGRect) rect;


@end
