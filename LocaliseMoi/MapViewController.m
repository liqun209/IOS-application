//
//  MapViewController.m
//  LocaliseMoi
//
//  Created by m2sar on 09/12/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//
#import "MapViewController.h"
@implementation MapViewController
@synthesize place;
@synthesize map;
@synthesize arrHistory;

UITextField *place;
MKMapView *map;
CLLocationManager* localM;
UISegmentedControl* mode;
NSURL *url;
NSURLRequest *request;
NSURLConnection *connection;
NSMutableData *webData;
UIAlertView *alertConn;
UIAlertView *alertParse;
NSXMLParser *parser;
double latitude;
double longitude;
BOOL isLatitude;
BOOL isLongitude;
BOOL isLocation;
BOOL isFirst;
UILocalNotification *notification;
UIApplication *app;
HistoryViewController *hvc;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    localM = [[CLLocationManager alloc]init];
    [localM requestAlwaysAuthorization];
    self.navigationItem.title = @"Localisation";
    
    place = [[UITextField alloc] init];
    place.placeholder = @"Entrer une adresse de lieu à rechercher";
    place.backgroundColor = [UIColor whiteColor];
    place.delegate = self;
    
    NSArray *segs = [[NSArray alloc] initWithObjects: @"Carte", @"Satellite", @"Hybride", nil];
    mode = [[UISegmentedControl alloc] initWithItems:segs];
    [mode addTarget:self action:@selector(selectMode) forControlEvents:UIControlEventValueChanged];

    map = [[MKMapView alloc] init];
    NSUserDefaults *preference = [NSUserDefaults standardUserDefaults];
    BOOL isSatellite = [preference boolForKey:@"is_satellite"];
    map.mapType = isSatellite ? MKMapTypeSatellite : MKMapTypeStandard;
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
    
    alertConn = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                           message:@"Verifiez votre connection"
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    alertParse = [[UIAlertView alloc] initWithTitle:@"Probleme XML"
                                            message:@"Le fichier XML est mal forme"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[dirs objectAtIndex:0] stringByAppendingPathComponent:@"save"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        arrHistory = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];//tableView reload?
    }
    else
    {
        arrHistory = [[NSMutableArray alloc] init];
    }
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Localisation"
                                                    image:[UIImage imageNamed:@"icone-terre"]
                                                      tag:0];
    notification = [[UILocalNotification alloc]init];
    app = [UIApplication sharedApplication];
    
    // [self.view addSubview:locLabel];
    [self.view addSubview:place];
    [self.view addSubview:map];
    [self.view addSubview:mode];
    
    [place release];
    [mode release];
    [map release];
    
    [self redessine:[[UIScreen mainScreen] bounds].size];
}

- (void) viewDidAppear:(BOOL)animated
{
    UIUserNotificationSettings *authorization = [app currentUserNotificationSettings];
    if(authorization.types == UIUserNotificationTypeNone)
    {
        [[[UIAlertView alloc] initWithTitle:@"Probleme authorization"
                                    message:@"Notifications désactivées"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void) setHistoryViewController: (UIViewController*) h
{
    hvc = (HistoryViewController*)h;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *s = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?address=%@&sensor=false", place.text];
    s = [s stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    url = [NSURL URLWithString: s];
    NSLog(@"%@",url);
    request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:true];
    webData = [[NSMutableData alloc] init];
           
    [request release];
    [place resignFirstResponder];
    return true;
}


- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    isLatitude = false;
    isLongitude = false;
    isLocation = false;
    isFirst = true;
    parser = [[NSXMLParser alloc] initWithData:webData];
    parser.delegate = self;
    [parser parse];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [alertConn show];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
	qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    if([elementName  isEqual: @"location"])
    {
        isLocation = true;
    }
    else if([elementName  isEqual: @"lat"])
    {
        isLatitude = true;
    }
    else if([elementName  isEqual: @"lng"])
    {
        isLongitude = true;
    }
    
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(isLocation)
    {
        if (string.doubleValue == 0.0) {
            return;
        }
        
        if(isLatitude)
        {
            latitude = string.doubleValue;
        }
        else if(isLongitude)
        {
            longitude = string.doubleValue;
        }
    }
}

- (void)parser:(NSXMLParser *)parser
	didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
	qualifiedName:(NSString *)qName
{
    if ([elementName  isEqual: @"lat"]) {
        isLatitude = false;
    }
    if ([elementName  isEqual: @"lng"]) {
        isLongitude = false;
    }
    
    if (!isLatitude && !isLongitude && isLocation)
    {
        if([elementName  isEqual: @"location"] && isFirst)
        {
            isLocation = false;
            CLLocationCoordinate2D coord = {.latitude = latitude, .longitude = longitude};
            NSLog(@"%f %f", latitude, longitude);
            MKCoordinateSpan span = {.latitudeDelta = 0.0035, .longitudeDelta = 0.0035};
            MKCoordinateRegion region = {coord, span};
            [map setRegion: region animated: true];
            
            NSArray* item = [[NSArray alloc] initWithObjects: place.text,
                             [[NSNumber alloc] initWithDouble:latitude],
                             [[NSNumber alloc] initWithDouble:longitude], nil];
            [arrHistory addObject:item];
            [item release];
            
            [self sendNotification:place.text];
            [hvc.tableView reloadData];
            isFirst = false;
        }

    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [alertParse show];
}


- (void) sendNotification:(NSString*)message
{
    notification.hasAction = YES;
    notification.alertAction = @"Alert of changing place";
    notification.alertBody = [NSString stringWithFormat:@"Move to %@", message];
    [app presentLocalNotificationNow:notification];
}

- (void) selectMode
{
    NSInteger index = mode.selectedSegmentIndex;
    switch (index)
    {
        case 0:
            map.mapType = MKMapTypeStandard;
            break;
            
        case 1:
            map.mapType = MKMapTypeSatellite;
            break;
            
        case 2:
            map.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

- (void)splitViewController:(UISplitViewController *)svc
    willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    if(displayMode == UISplitViewControllerDisplayModePrimaryHidden)
    {
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
        [self.navigationItem setLeftItemsSupplementBackButton: true];
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

- (void) redessine: (CGSize)size
{
    CGFloat w = size.width;
    CGFloat h = size.height;
    
    place.frame = CGRectMake(0, 30, w, h/7);
    map.frame = CGRectMake(0, 20+h/7, w, h-h/7-40);
    mode.frame = CGRectMake(w/2-w/4, h/7+40, w/2, h/15);
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ||
       [[UIScreen mainScreen] scale] == 3.0)
    {
        if (w<h) {
            map.frame = CGRectMake(0, 20+h/7, w, h-h/7);
             mode.frame = CGRectMake(w/2-w/4, h/7+40, w/2, h/15);
        } else {
            map.frame = CGRectMake(0, 20+h/7, w, h-h/7);
            mode.frame = CGRectMake(10, 80, w/3, h/15);
        }

    }
}


@end