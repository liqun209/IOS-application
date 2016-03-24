//
//  HistoryViewController.m
//  LocaliseMoi
//
//  Created by m2sar on 09/12/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//
#import "HistoryViewController.h"
@implementation HistoryViewController

MapViewController* mvc;
UIBarButtonItem *edit, *save, *done;
UITabBarController *tbc;

- (id) initWithStyle: (UITableViewStyle) style
{
    [super initWithStyle:style];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.navigationItem.title = @"History";
    edit = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
            target:self
            action:@selector(editHistory)];
    done = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
            target:self
            action:@selector(editHistory)];
    save = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemSave
            target:self
            action:@selector(saveHistory)];
    
    self.navigationItem.leftBarButtonItem = edit;
    self.navigationItem.rightBarButtonItem = save;
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"History"
                                                    image:[UIImage imageNamed:@"icone-terre"]
                                                      tag:1];
    return self;
}

- (void) setMapViewController: (UIViewController*) m
{
    mvc = (MapViewController*)m;
}

- (void) setTabBarController: (UITabBarController*) t
{
    tbc = t;
}


- (void) editHistory
{
    if(self.tableView.editing)
    {
        [self.tableView setEditing:false animated:true];
        self.navigationItem.leftBarButtonItem = edit;
    }
    else
    {
        [self.tableView setEditing:true animated:true];
        self.navigationItem.leftBarButtonItem = done;
    }
}

- (void) saveHistory
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[dirs objectAtIndex:0] stringByAppendingPathComponent:@"save"];
    BOOL success = [NSKeyedArchiver archiveRootObject:mvc.arrHistory toFile:path];
    if(!success)
    {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Probleme save"
                                                    message:@"save failed"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [a show];
        [a release];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellId = @"cellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Adresse %ld", (long)indexPath.row];
    cell.detailTextLabel.text = [[mvc.arrHistory objectAtIndex:indexPath.row] objectAtIndex:0];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section
{
    return [mvc.arrHistory count];
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [mvc.arrHistory removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    NSArray *arrFrom = [[mvc.arrHistory objectAtIndex:fromIndexPath.row] retain];
    [mvc.arrHistory removeObjectAtIndex:fromIndexPath.row];
    [mvc.arrHistory insertObject:arrFrom atIndex:toIndexPath.row];
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tbc.selectedViewController = [tbc.viewControllers objectAtIndex:0];
    mvc.place.text = [[mvc.arrHistory objectAtIndex:indexPath.row] objectAtIndex:0];
    [mvc sendNotification:mvc.place.text];
    
    double latitude = [[[mvc.arrHistory objectAtIndex:indexPath.row] objectAtIndex:1] doubleValue];
    double longitude = [[[mvc.arrHistory objectAtIndex:indexPath.row] objectAtIndex:2] doubleValue];
    CLLocationCoordinate2D coord = {.latitude = latitude, .longitude = longitude};
    MKCoordinateSpan span = {.latitudeDelta = 0.035, .longitudeDelta = 0.035};
    MKCoordinateRegion region = {coord, span};
    [mvc.map setRegion: region animated: true];
}

@end
