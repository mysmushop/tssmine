//
//  ShopSliderViewController.m
//  mySMU
//
//  Created by Bob Cao on 1/3/14.
//  Copyright (c) 2014 Bob Cao. All rights reserved.
//

#import "ShopSliderViewController.h"

@interface ShopSliderViewController ()

@end

@implementation ShopSliderViewController

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
    [self.sliderImageView setImage:self.sliderImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
