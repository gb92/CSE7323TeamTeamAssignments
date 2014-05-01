//
//  TTInfoViewController.m
//  TeamHyperFit
//
//  Created by ch484-mac7 on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTInfoViewController.h"
#import "TTCaptureScreenShot.h"

@interface TTInfoViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;

@end

@implementation TTInfoViewController

- (IBAction)dismissButtonPress:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
//    CGRect startFrame = self.contentContainerView.frame;
//    startFrame.origin.y = self.view.frame.size.height;
//    
//    [UIView animateWithDuration:0.3
//                          delay:0
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         self.contentContainerView.frame = startFrame;
//                     }
//                     completion:^(BOOL finish){
//                         
//                     [self dismissViewControllerAnimated:YES completion:nil];
//                         
//                     }];
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
}

-(void)viewWillAppear:(BOOL)animated
{
    self.image = [TTCaptureScreenShot screenshot];
    self.backgroundImage.image = self.image;
    
    [self performSelectorInBackground:@selector(blurBG) withObject:nil ];

}
-(void)viewDidLayoutSubviews
{
//    CGRect startFrame = self.contentContainerView.frame;
//    startFrame.origin.y = self.view.frame.size.height;
//    
//    [self.contentContainerView setFrame:startFrame];
}

-(void)runNoteAnimation
{
    CGRect endFrame = self.contentContainerView.frame;
    endFrame.origin.y = 50;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.contentContainerView.frame = endFrame;
                     }
                     completion:nil];

}

-(void)blurBG
{
    self.image = [TTCaptureScreenShot blur:self.image];
    self.backgroundImage.image = self.image;
}

-(void)setContentViewFinalLocatiion
{
    CGRect endFrame = self.contentContainerView.frame;
    endFrame.origin.y = 50;
    self.contentContainerView.frame = endFrame;
}

-(void)viewDidAppear:(BOOL)animated
{
//    [self performSelector:@selector(runNoteAnimation) withObject:nil afterDelay:0.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
