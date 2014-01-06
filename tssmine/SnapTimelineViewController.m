//
//  SnapTimelineViewController.m
//  tssmine
//
//  Created by Bob Cao on 6/1/14.
//  Copyright (c) 2014 Bob Cao. All rights reserved.
//

#import "SnapTimelineViewController.h"

@interface SnapTimelineViewController ()

@end

@implementation SnapTimelineViewController

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
    
    //adding Title
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Snaps";
    //adding right button for photo taking
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    navItem.rightBarButtonItem = rightButton;
    //adding all items to navigation bar
    _snapTimelineNavigationBar.items = @[ navItem ];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//********** TAKE PICTURE **********
-(void)takePicture:(id)sender
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
	//Use camera if device has one otherwise use photo library
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	else
	{
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
    
    [imagePicker setDelegate:self];
	//Show image picker
	[self presentModalViewController:imagePicker animated:YES];
}

//********** RECEIVE PICTURE **********
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//Get image
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
	//Take image picker off the screen (required)
	[self dismissModalViewControllerAnimated:YES];
}
@end