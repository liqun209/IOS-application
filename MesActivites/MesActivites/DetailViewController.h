//
//  Header.h
//  MesActivites
//
//  Created by m2sar on 23/11/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

#ifndef MesActivites_Header_h
#define MesActivites_Header_h
#import "ActivityViewController.h"

@import UIKit;
@import MobileCoreServices;

@interface DetailViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISplitViewControllerDelegate>

- (void) setSection: (NSInteger)s row: (NSInteger)r;
- (void) setActivityViewController: (UIViewController*)a;
@end


#endif
