//
//  Assignment1AddFavoriteWordController.m
//  Assignment1
//
//  Created by Gavin Benedict on 2/4/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import "Assignment1AddFavoriteWordController.h"
#import "Assignment1AppDelegate.h"
#import "FavoriteWord.h"

@interface Assignment1AddFavoriteWordController ()
@property (weak, nonatomic) IBOutlet UITextField *favoriteWordTextField;
@property (weak, nonatomic) IBOutlet UITextField *numTimesUsedTextField;
@property (weak, nonatomic) IBOutlet UIStepper *myStepper;
@property (nonatomic) int prevStepValue;

@end

@implementation Assignment1AddFavoriteWordController

- (IBAction)cancelButtonPressed:(id)sender {
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)addWordPressed:(id)sender {
    NSLog(@"Add word button pressed\n");
    Assignment1AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    
    FavoriteWord *favWord=[NSEntityDescription insertNewObjectForEntityForName:@"FavoriteWord" inManagedObjectContext:appDelegate.managedObjectContext];
    NSLog(@"Got Favorite Word\n");
    
    favWord.favoriteWord=self.favoriteWordTextField.text;
    favWord.numTimesUsedPerDay=self.numTimesUsedTextField.text;
    
    NSLog(@"Set Values\n");
    NSError *error;
    if (![appDelegate.managedObjectContext save:&error]) {
        NSLog(@"save database failed: %@", [error localizedDescription]);
    }
    
    NSLog(@"All the way through...\n");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    //[self.navigationController popViewControllerAnimated:YES];

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)stepperClicked:(id)sender {
    int dif=(int)self.myStepper.value-self.prevStepValue;
    
    int currentVal=[self.numTimesUsedTextField.text intValue];
    
    currentVal+=dif;
    
    self.numTimesUsedTextField.text=[NSString stringWithFormat:@"%d",currentVal];
    
    self.prevStepValue=(int)self.myStepper.value;
    
}

@end
