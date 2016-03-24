//
//  MapViewController.h
//  LocaliseMoi
//
//  Created by m2sar on 09/12/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

#ifndef LocaliseMoi_MapViewController_h
#define LocaliseMoi_MapViewController_h
@import Foundation;
@import CoreLocation;
@import UIKit;
@import MapKit;
#import "HistoryViewController.h"

@interface MapViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSXMLParserDelegate, UISplitViewControllerDelegate, MKMapViewDelegate>
@property (assign) NSMutableArray *arrHistory;
@property (assign) UITextField *place;
@property (assign) MKMapView *map;
- (void) sendNotification:(NSString*)message;
- (void) setHistoryViewController: (UIViewController*) h;
@end
#endif
