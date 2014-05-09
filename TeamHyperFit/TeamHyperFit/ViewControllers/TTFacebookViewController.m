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
@property (strong, nonatomic) FBProfilePictureView *profPicView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastnameLabel;


@property (strong, nonatomic) TTUserInfoHandler *userInfoHandler;

@end

@implementation TTFacebookViewController

-(FBProfilePictureView*) profPicView
{
    if(_profPicView == nil)
    {
        _profPicView=[[FBProfilePictureView alloc] initWithFrame:CGRectMake(20, 20, 200, 200)];
        [self.view addSubview:_profPicView];
    }
    return _profPicView;
}

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

    self.facebookButton.delegate=self;
    
    FBSession *currentSession=[FBSession activeSession];
    
    if(currentSession.state == FBSessionStateOpen)
    {
        //! Get from Facebook handler.
        self.imageView.image = [UIImage imageNamed:@"noone"];
        self.nameLabel.text = self.userInfoHandler.userInfo.firstName;
        self.lastnameLabel.text = self.userInfoHandler.userInfo.lastName;
    }
    else
    {
        self.imageView.image = [UIImage imageNamed:@"noone"];
        self.nameLabel.text = @"";
        self.lastnameLabel.text = @"";
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//fbloginview delegate

-(void) loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"The loginview threw an error: %@", error);
    
    NSString *alertMessage, *alertTitle;
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
}

-(void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"The loginview successfully fetched user data: %@", user);
    self.profPicView.profileID=user.id;
}
@end
