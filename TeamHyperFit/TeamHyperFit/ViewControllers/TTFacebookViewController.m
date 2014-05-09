//
//  TTFacebookViewController.m
//  TeamHyperFit
//
//  Created by ch484-mac5 on 5/7/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTFacebookViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TTCircleImageView.h"
#import "TTUserInfoHandler.h"
#import "TTAppDelegate.h"

@interface TTFacebookViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *facebookButton;
@property (weak, nonatomic) IBOutlet TTCircleImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastnameLabel;

@property (strong, nonatomic) TTUserInfoHandler *userInfoHandler;

@end

@implementation TTFacebookViewController



-(TTUserInfoHandler *)userInfoHandler
{
    if (!_userInfoHandler) {
        _userInfoHandler = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userInforHandler;
    }
    
    return _userInfoHandler;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.facebookButton.delegate = self.userInfoHandler.fbHandler;
    
    [self.userInfoHandler.userInfo addObserver:self forKeyPath:@"firstName" options:NSKeyValueObservingOptionNew context:nil];
    [self.userInfoHandler.userInfo addObserver:self forKeyPath:@"lastName" options:NSKeyValueObservingOptionNew context:nil];
    [self.userInfoHandler.userInfo addObserver:self forKeyPath:@"profileImage" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:@"firstName"])
    {
        self.nameLabel.text = self.userInfoHandler.userInfo.firstName;
    }
    else if( [keyPath isEqualToString:@"lastName"])
    {
        self.lastnameLabel.text = self.userInfoHandler.userInfo.lastName;
    }
    else if( [keyPath isEqualToString:@"profileImage"])
    {
        self.imageView.image = self.userInfoHandler.userInfo.profileImage;
        [self.imageView setNeedsDisplay];
    }
}

-(void)dealloc
{
    [self.userInfoHandler.userInfo removeObserver:self forKeyPath:@"firstName"];
    [self.userInfoHandler.userInfo removeObserver:self forKeyPath:@"lastName"];
    [self.userInfoHandler.userInfo removeObserver:self forKeyPath:@"profileImage"];
    
}

//#pragma mark -
//#pragma Facebook Delegation
//
//-(void) TTFacebookHandlerOnLoginSuccessfully
//{
//    //! Get from Facebook handler.
//    self.imageView.image = self.userInfoHandler.userInfo.profileImage;
//    self.nameLabel.text = self.userInfoHandler.userInfo.firstName;
//    self.lastnameLabel.text = self.userInfoHandler.userInfo.lastName;
//    [self.imageView setNeedsDisplay];
//}
//
//-(void)TTFacebookHandlerOnLogoutSuccessfully
//{
//    self.imageView.image = [UIImage imageNamed:@"noone"];
//    self.nameLabel.text = @"";
//    self.lastnameLabel.text = @"";
//    [self.imageView setNeedsDisplay];
//}


@end
