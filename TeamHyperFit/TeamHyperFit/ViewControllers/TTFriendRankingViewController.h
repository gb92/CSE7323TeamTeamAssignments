//
//  TTFriendRankingViewController.h
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTFriendRankingViewController;

@protocol TTFriendRankingViewControllerDelegate <NSObject>

-(void) TTFriendRankingViewControllerCloseButtonPressed:(TTFriendRankingViewController*) view;

@end

@interface TTFriendRankingViewController : UIViewController

@property (weak, nonatomic) id<TTFriendRankingViewControllerDelegate> delegate;

@end
