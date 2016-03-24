//
//  ActivityViewController.h
//  MesActivites
//
//  Created by m2sar on 23/11/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

#ifndef MesActivites_ActivityViewController_h
#define MesActivites_ActivityViewController_h
#import "DetailViewController.h"
@import Foundation;
@import UIKit;

@interface ActivityViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (assign) NSDictionary* dataDict;

- (void) setDetailViewController: (UIViewController*)d;
- (void) setSplitViewController: (UISplitViewController*) s;

@end

#endif
