//
//  ViewController.m
//  iSouvenir
//
//  Created by m2sar on 16/11/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

UIToolbar *toolbar;
UIBarButtonItem *add, *delete, *reload, *contact, *camera, *folder, *spFix, *spFlex;
CGSize sizeS;
ABPeoplePickerNavigationController* personPicker;
UIImagePickerController* picker;
UIAlertView *noCamera;
NSMutableArray *annoArr;
MKMapView *map;
MKPointAnnotation *selectedAnnotation;
UIPopoverController* pop;
UIImageView* imgView;
UIImageView* target;
UISegmentedControl* mode;
MKMapCamera* camera3D;
CLLocationManager* localM;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    toolbar = [[UIToolbar alloc] init];
    add = [[UIBarButtonItem alloc]
           initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
           target:self
           action:@selector(addAnnotation)];
    delete = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
              target:self
              action:@selector(deleteAnnotation)];
    reload = [[UIBarButtonItem alloc]
               initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
               target:self
               action:@selector(reload)];
    contact = [[UIBarButtonItem alloc]
               initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
               target:self
               action:@selector(selectContact)];
    camera = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
              target:self
              action:@selector(openCamera)];
    folder = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
              target:self
              action:@selector(selectPhoto)];
    spFix = [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
             target:self
             action:@selector(alloc)];
    [spFix setWidth: 20];
    spFlex = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
              target:self
              action:@selector(alloc)];
    [toolbar setItems: [NSArray arrayWithObjects: add, spFix, delete, spFlex, reload, spFlex,
                        contact, spFix, camera, spFix, folder, nil]];
    delete.enabled = false;
    contact.enabled = false;
    camera.enabled = false;
    folder.enabled = false;
	

    NSArray *segs = [[NSArray alloc] initWithObjects: @"3D",
                        NSLocalizedString(@"map", @""),
                        NSLocalizedString(@"satellite", @""),
                        NSLocalizedString(@"hybrid", @""), nil];
    mode = [[UISegmentedControl alloc] initWithItems:segs];
    [mode addTarget:self action:@selector(selectMode) forControlEvents:UIControlEventValueChanged];
	
    sizeS = [UIScreen mainScreen].bounds.size;
    annoArr = [[NSMutableArray alloc]init];
    personPicker = [[ABPeoplePickerNavigationController alloc] init];
    personPicker.peoplePickerDelegate = self;
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    noCamera = [[UIAlertView alloc] initWithTitle:@"Problem"
                                            message:@"can not open camera."
                                            delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    localM = [[CLLocationManager alloc]init];
    map = [[MKMapView alloc] init];
    map.mapType = MKMapTypeStandard;
    map.zoomEnabled = true;
    map.scrollEnabled = true;
    map.rotateEnabled = false;
    map.showsUserLocation = true;
    map.pitchEnabled = true;
    map.delegate = self;
    CLLocationCoordinate2D coord = {.latitude = 48.846013, .longitude = 2.355167}; //upmc coordinate
    MKCoordinateSpan span = {.latitudeDelta = 0.035, .longitudeDelta = 0.035};
    MKCoordinateRegion region = {coord, span};
    [map setRegion: region animated: true];
    
    CLLocationCoordinate2D from = {48.946013 , 2.355167};
    camera3D = [[MKMapCamera cameraLookingAtCenterCoordinate:coord fromEyeCoordinate:from eyeAltitude:70] retain];

    selectedAnnotation = [[MKPointAnnotation alloc] init];
    imgView = [[UIImageView alloc] init];
    imgView.image = nil;
    target = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"target"]];
    
    [self.view addSubview:map];
    [self.view addSubview:toolbar];
    [self.view addSubview:mode];
    [self.view addSubview:imgView];
	[self.view addSubview:target];

    [add release];
	[delete release];
	[reload release];
	[contact release];
	[camera release];
	[folder release];
	[spFix release];
	[spFlex release];
	[toolbar release];
	[mode release];
	[map release];
	[imgView release];
	[target release];
    
    [localM requestAlwaysAuthorization];
    [self redessine:sizeS];
}

- (void) addAnnotation
{
    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    annotation.title = [NSString stringWithFormat: @"%@ %lu", @"Contact ", annoArr.count+1];
    annotation.subtitle = NSLocalizedString(@"noContact", @"");
    CGPoint pos = CGPointMake(sizeS.width/2, sizeS.height/2);
    if (imgView.image != nil) {
        if (sizeS.width < sizeS.height) {
            pos = CGPointMake(sizeS.width/2, sizeS.height/4);
        }
        else{
            pos = CGPointMake(sizeS.width/4, sizeS.height/2);
        }
    }
    CLLocationCoordinate2D coordinate = [map convertPoint: pos toCoordinateFromView: map];
    annotation.coordinate = coordinate;
    [map addAnnotation:annotation];
	UIImageView* iv_temp = [[UIImageView alloc]init];
	iv_temp.image = nil;
    NSArray* arr_temp = [[NSArray alloc] initWithObjects: annotation, iv_temp, nil]; 
    [annoArr addObject:arr_temp];
	
	[annotation release];
    [iv_temp release];
	[arr_temp release];
}

- (void) deleteAnnotation
{
    for (int i=0; i<annoArr.count; i++) {
		MKPointAnnotation* anno_temp = [[annoArr objectAtIndex:i] objectAtIndex:0];
		
        if (anno_temp == selectedAnnotation) 
		{                 
			[annoArr removeObjectAtIndex: i];
			break;               
        }
    }
    [map removeAnnotation: selectedAnnotation];
    selectedAnnotation = nil;
    delete.enabled = false;
    contact.enabled = false;
    camera.enabled = false;
    folder.enabled = false;
    imgView.image = nil;
    [self redessine:sizeS];
}		

- (void) reload
{
    CLLocationCoordinate2D coord = {.latitude = 48.846013, .longitude = 2.355167}; //upmc coordinate
    if(map.userLocationVisible)
    {
        if ([localM locationServicesEnabled])
        {
            [localM requestAlwaysAuthorization];
            CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
            if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
            {
                coord = map.userLocation.location.coordinate;
                MKCoordinateSpan span = {.latitudeDelta = 0.035, .longitudeDelta = 0.035};
                MKCoordinateRegion region = {coord, span};
                [map setRegion: region animated: true];
            }
           
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Problem"
                                        message:@"Localisation indisponible."
                                        delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil]show];
        }
    }
}

- (void) selectContact
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        pop = [[UIPopoverController alloc] initWithContentViewController: personPicker];
        pop.popoverContentSize = CGSizeMake(400, 600);
        [pop presentPopoverFromBarButtonItem: contact permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
    }
    else
    {
        [self presentViewController:personPicker animated:true completion:NULL];
    }
}

- (void) openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            pop = [[UIPopoverController alloc] initWithContentViewController: picker];
            pop.popoverContentSize = CGSizeMake(400, 600);
            [pop presentPopoverFromBarButtonItem: camera permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
        }
        else
        {
            [self presentViewController:picker animated: true completion:nil];
        }
    }
    else
    {
        [noCamera show];
    }
}

- (void) selectPhoto
{
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        pop = [[UIPopoverController alloc] initWithContentViewController: picker];
        pop.popoverContentSize = CGSizeMake(400, 600);
        [pop presentPopoverFromBarButtonItem: folder permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
    }
    else
    {
        [self presentViewController:picker animated: true completion: nil];
    }
}


- (void) selectMode
{
    NSInteger index = mode.selectedSegmentIndex;
    switch (index)
    {
        case 0:
            //3D
            map.showsBuildings = true;
            CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
            
            if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
            {
                map.camera = camera3D; //restore??
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Problem"
                                            message:@"map 3D indisponible."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]show];
            }
            break;
            
        case 1:
            map.mapType = MKMapTypeStandard;
            break;
            
        case 2:
            map.mapType = MKMapTypeSatellite;
            break;
            
        case 3:
            map.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
{
    NSString* firstName = (__bridge NSString*)ABRecordCopyValue(person,	kABPersonFirstNameProperty);
    NSString* lastName = (__bridge NSString*)ABRecordCopyValue(person,	kABPersonLastNameProperty);
    selectedAnnotation.subtitle = [NSString stringWithFormat:@"%@ %@" ,firstName, lastName];
    
    [peoplePicker dismissViewControllerAnimated:true completion:nil];
    [pop dismissPopoverAnimated: true]; //2 ensemble?

}


- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        if(!img) img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        for (int i=0; i<annoArr.count; i++)
		{
			MKPointAnnotation* anno_temp = [[annoArr objectAtIndex:i] objectAtIndex:0];
			UIImageView* iv_temp = [[annoArr objectAtIndex:i] objectAtIndex:1];
			
            if (anno_temp == selectedAnnotation) 
			{
                iv_temp.image = img;
                break;
            }
        }
        
        imgView.image = img;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [pop dismissPopoverAnimated: true];
    [self redessine:sizeS];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [pop dismissPopoverAnimated: true];
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    selectedAnnotation = view.annotation;
    for (int i=0; i<annoArr.count; i++)
	{
		MKPointAnnotation* anno_temp = [[annoArr objectAtIndex:i] objectAtIndex:0];
		UIImageView* iv_temp = [[annoArr objectAtIndex:i] objectAtIndex:1];
		
        if (anno_temp == selectedAnnotation) 
		{
            if (iv_temp.image != nil) 
			{
               imgView.image = iv_temp.image;
            }            
            break;
        }
    }
    
    delete.enabled = true;
    contact.enabled = true;
    camera.enabled = true;
    folder.enabled = true;
    
    [self redessine:sizeS];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self redessine:size];
}


- (void) redessine: (CGSize) size
{
    sizeS = size;
    CGFloat w = size.width;
    CGFloat h = size.height;
    
    target.frame = CGRectMake(w/2-20, h/2-20, 40, 40); //use scale ??
    BOOL hasImg = false;
    for (int i=0; i<annoArr.count; i++)
	{
		MKPointAnnotation* anno_temp = [[annoArr objectAtIndex:i] objectAtIndex:0];
		UIImageView* iv_temp = [[annoArr objectAtIndex:i] objectAtIndex:1];
		
        if (anno_temp == selectedAnnotation) 
		{
            if(iv_temp.image != nil)
			{
                hasImg = true;
            }
            break;
        }
    }
    if(w < h)
    {
        if(hasImg)
        {
            map.frame = CGRectMake(0, 0, w, h/2);
            imgView.hidden = false;
            target.frame = CGRectMake(w/2-15, h/4-15, 30, 30);
        }
        else
        {
            map.frame = CGRectMake(0, 0, w, h-50);
            imgView.hidden = true;
            target.frame = CGRectMake(w/2-15, h/2-15, 30, 30);
        }
        imgView.frame = CGRectMake(0, h/2+10, w, h/2-50);
        mode.frame = CGRectMake(40, 40, w-80, 40);
        toolbar.frame = CGRectMake(0, h-40, w, 40);
    }
    else
    {
        if(hasImg)
        {
            map.frame = CGRectMake(0, 0, w/2, h-30);
            imgView.hidden = false;
            mode.frame = CGRectMake(20, 20, w/2-40, 20);
            target.frame = CGRectMake(w/4-15, h/2-15, 30, 30);
        }
        else
        {
            map.frame = CGRectMake(0, 0, w, h-30);
            imgView.hidden = true;
            mode.frame = CGRectMake(30, 30, w-60, 30);
            target.frame = CGRectMake(w/2-15, h/2-15, 30, 30);
        }
        imgView.frame = CGRectMake(w/2+10, 0, w/2-10, h-30);
        toolbar.frame = CGRectMake(0, h-30, w, 30);
    }
    
    if (imgView.image == nil) {
        imgView.hidden = true;
    }
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        if (pop.popoverVisible == true)
        {
            [pop dismissPopoverAnimated: true];
        }
    }
  
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
