//
//  TTActivityCollectionViewController.h
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 5/2/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTActivityCollectionViewController;

@protocol TTActivityCollectionDelegate <NSObject>
-(void)TTActivityCollectionCellDidSelectedAtIndex:(NSInteger) itemIndex;
@end


@interface TTActivityCollectionViewController : UICollectionViewController

@property (weak,nonatomic) id<TTActivityCollectionDelegate> delegate;

@end
