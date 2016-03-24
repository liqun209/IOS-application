//
//  ViewController.h
//  iSouvenir
//
//  Created by m2sar on 16/11/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

@import Foundation;
@import MapKit;
@import UIKit;
@import AddressBookUI;
@import CoreLocation;
#import <MobileCoreServices/UTCoreTypes.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,MKMapViewDelegate, ABPeoplePickerNavigationControllerDelegate, CLLocationManagerDelegate>


@end

