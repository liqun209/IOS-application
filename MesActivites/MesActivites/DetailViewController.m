//
//  @interface DetailViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate>  DetailViewController.m
//  MesActivites
//
//  Created by m2sar on 23/11/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailViewController.h"

@implementation DetailViewController
UILabel* titleLabel;
UILabel* prioLabel;
UISegmentedControl* seg;
UITextField* title;
int prio;
UIImageView* imgV;
ActivityViewController* avc;
NSInteger section;
NSInteger row;
NSMutableArray* item;
UIPopoverController* pop;
UIImagePickerController* imagePicker;
UIBarButtonItem *camera;



- (id) init
{
    [super init];
    [self setView: [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]]];
    self.view.backgroundColor = UIColor.grayColor;
    titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Title: ";
    prioLabel = [[UILabel alloc] init];
    prioLabel.text = @"Priority: ";
    seg = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects: @"1", @"2", @"3", @"4", nil]];
    [seg addTarget:self action:@selector(changePriority) forControlEvents:UIControlEventValueChanged];
    title = [[UITextField alloc] init];
    title.delegate = self;
    imgV = [[UIImageView alloc] init];
    camera = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                               target:self
                               action:@selector(openCamera)];
    self.navigationItem.rightBarButtonItem = camera;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    [self.view addSubview: titleLabel];
    [self.view addSubview: prioLabel];
    [self.view addSubview: seg];
    [self.view addSubview: title];
    [self.view addSubview: imgV];
    
    [titleLabel release];
    [prioLabel release];
    [seg release];
    [title release];
    [imgV release];
    [self redessine:[[UIScreen mainScreen] bounds].size];
    return self;
}

- (void) setActivityViewController: (UIViewController*)a;
{
    avc = (ActivityViewController*)a;
}

- (void) setSection: (NSInteger)s row: (NSInteger)r
{
    section = s;
    row = r;
    
    //dataDict public !
    
    NSArray *keys = [avc.dataDict allKeys];
    item = [[avc.dataDict objectForKey: keys[section]] objectAtIndex: row];
    title.text = [item objectAtIndex: 0];
    seg.selectedSegmentIndex = (NSInteger)[item objectAtIndex: 1];
    imgV.image = [[item objectAtIndex: 2] image];
}

//finish text, update title
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [item replaceObjectAtIndex: 0 withObject: title.text]; //change dataDict ???
    [avc.tableView reloadData];
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [item replaceObjectAtIndex: 0 withObject: title.text]; //change dataDict ???
    [avc.tableView reloadData];
    [textField resignFirstResponder];
    
    return true;
}

//seg value change
- (void)changePriority
{
    [item replaceObjectAtIndex: 1 withObject: [NSNumber numberWithLong:seg.selectedSegmentIndex]];
    [avc.tableView reloadData];
}

//take photo
- (void) openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            pop = [[UIPopoverController alloc] initWithContentViewController: imagePicker];
            pop.popoverContentSize = CGSizeMake(400, 600);
            [pop presentPopoverFromBarButtonItem: camera permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
        }
        else
        {
            [self presentViewController:imagePicker animated: true completion:nil];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Problem"
                                    message:@"can not open camera."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

//save photo
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        if(!img) img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        imgV.image = img;
        [item replaceObjectAtIndex: 2 withObject: img];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [pop dismissPopoverAnimated: true];
    
    [avc.tableView reloadData]; //tableView public???
    //[self redessine:sizeS];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [pop dismissPopoverAnimated: true];
}

//split
- (void)splitViewController:(UISplitViewController *)svc
    willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    if(displayMode == UISplitViewControllerDisplayModePrimaryHidden)
    {
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return true;
}

//???
- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad &&
       [[UIScreen mainScreen] scale] == 3.0)
    {
        self.navigationItem.leftBarButtonItem = nil;
        return UISplitViewControllerDisplayModeAllVisible;
    }
    else
    {
        return UISplitViewControllerDisplayModePrimaryOverlay;
    }
}

- (void) redessine: (CGSize)size
{
    CGFloat w = size.width;
    CGFloat h = size.height;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ||
       [[UIScreen mainScreen] scale] == 3.0)
    {
        CGFloat y = 60;
        titleLabel.frame = CGRectMake(10, y, w/10, h/15);
        title.frame = CGRectMake(20+w/10, y, w-w/10-20, h/15);
        y += h/15;
        prioLabel.frame = CGRectMake(10, y, w/2, h/15);
        y += h/15+15;
        seg.frame = CGRectMake(10, y, w/3*2, h/15);
        y += h/15+15;
        imgV.frame = CGRectMake(10, y, w/3*2, h-y-10);
    }
    else
    {
        if (w < h)
        {
            CGFloat y = 60;
            titleLabel.frame = CGRectMake(10, y, w/10, h/15);
            title.frame = CGRectMake(20+w/10, y, w-w/10-20, h/15);
            y += h/15;
            prioLabel.frame = CGRectMake(10, y, w/2, h/15);
            y += h/15+15;
            seg.frame = CGRectMake(10, y, w-20, h/15);
            y += h/15+15;
            imgV.frame = CGRectMake(10, y, w-20, h-y-10);
            
        } else
        {
            CGFloat y = 35;
            titleLabel.frame = CGRectMake(5, y, w/10, h/15);
            title.frame = CGRectMake(5+w/5, y, w/2-w/10, h/15);
            y += h/15;
            prioLabel.frame = CGRectMake(5, y, w/2, h/15);
            y += h/15+15;
            seg.frame = CGRectMake(5, y, w/2-10, h/15);
            y += h/15+15;
            imgV.frame = CGRectMake(w/2, 30, w/2-5, h-40);
        }

    }
   }

- (BOOL) shouldAutorotate{
    return true;
}

- (NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self redessine:size];
}

@end