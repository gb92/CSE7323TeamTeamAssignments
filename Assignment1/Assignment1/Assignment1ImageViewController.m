//
//  Assignment1ImageViewController.m
//  Assignment1
//
//  Created by Gavin Benedict on 2/4/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import "Assignment1ImageViewController.h"

@interface Assignment1ImageViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;


@end

@implementation Assignment1ImageViewController

-(UIImage *)image{
    if(!_image) _image = [UIImage imageNamed:self.imageName];
    
    return _image;
}

-(UIImageView *)imageView{
    if(!_imageView) self.imageView= [[UIImageView alloc] initWithImage:self.image];
    
    return _imageView;
}

-(NSString *) imageName{
    if(!_imageName) _imageName=@"SMULogo";
    
    return _imageName;
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
    
    [self.imageScrollView addSubview:self.imageView];
    self.imageScrollView.contentSize = self.image.size;
    self.imageScrollView.minimumZoomScale= 0.1;
    self.imageScrollView.delegate=self;
    
    self.title=self.imageName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

@end
