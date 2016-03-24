//
//  HistoryViewController.h
//  LocaliseMoi
//
//  Created by m2sar on 09/12/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

#ifndef LocaliseMoi_HistoryViewController_h
#define LocaliseMoi_HistoryViewController_h
#import "MapViewController.h"
@import UIKit;

@interface HistoryViewController: UITableViewController <UITableViewDelegate, UITableViewDataSource>
- (void) setMapViewController: (UIViewController*) m;
- (void) setTabBarController: (UITabBarController*) t;
@end

#endif
