//
//  ActivityViewController.m
//  MesActivites
//
//  Created by m2sar on 23/11/2015.
//  Copyright (c) 2015 m2sar. All rights reserve
//

#import <Foundation/Foundation.h>
#import "ActivityViewController.h"
#import "DetailViewController.h"

@implementation ActivityViewController
@synthesize dataDict;

UISplitViewController* svc;
DetailViewController* dvc;
UIBarButtonItem *edit, *add, *done;

- (id) initWithStyle: (UITableViewStyle) style
{
    [super initWithStyle:style];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSectionFooterHeight:30.0];
    //nav bar
    self.navigationItem.title = @"Liste de taches";
    edit = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
            target:self
            action:@selector(editBtn)];
    done = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
            target:self
            action:@selector(editBtn)];
    add = [[UIBarButtonItem alloc]
           initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
           target:self
           action:@selector(addCell)];
    self.navigationItem.leftBarButtonItem = edit;
    self.navigationItem.rightBarButtonItem = add;
    
    //data structure
    dataDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                [[NSMutableArray alloc] init], @"Vacances",
                [[NSMutableArray alloc] init], @"Personnel",
                [[NSMutableArray alloc] init], @"Urgent",
                [[NSMutableArray alloc] init], @"Aujourd'hui",nil];
    
    return self;
}

- (void) setSplitViewController: (UISplitViewController*) s
{
    svc = s;
}

- (void) setDetailViewController: (UIViewController*) d;
{
    dvc = (DetailViewController*)d;
}

//Edit or not
- (void) editBtn
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

//add item
- (void) addCell
{
   // NSMutableArray* cell = [[[NSMutableArray init] alloc] addObjectsFromArray: @[@"Nouvelle tache", @0, [[UIImageView alloc] init]]];
    NSMutableArray* item = [[NSMutableArray alloc] init];
    [item addObject: @"Nouvelle tache"];
    [item addObject: @0];
    UIImageView* tmp = [[UIImageView alloc] init];
    [item addObject: tmp];
    
    [[dataDict objectForKey: @"Aujourd'hui"] addObject: item];
    [self.tableView reloadData];
    [tmp release];
}

//table item
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellId = @"cellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    NSArray *keys = [dataDict allKeys];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if ([[dataDict objectForKey: keys[section]] count] > 0) {
        NSMutableArray* item = [[dataDict objectForKey: keys[section]] objectAtIndex: row]; //NSMutableArray [text, priority, imageView]
        cell.textLabel.text = [item objectAtIndex: 0];
        cell.detailTextLabel.text = [NSString stringWithFormat: @"Priorite actuelle: %@", [item objectAtIndex: 1]];
        NSString* strTmp = [NSString stringWithFormat:@"prio-%@",[item objectAtIndex: 1]];
        cell.imageView.image = [UIImage imageNamed:strTmp];
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-tableview-cell"]];
    
    return cell;
}

//section header footer

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
     NSArray *keys = [dataDict allKeys];
    return keys[section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-header"]];
    header.textLabel.textColor = [UIColor whiteColor];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fond-alu"]];
}


//sum section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataDict count];
}

//num rows for section
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [dataDict allKeys];
    return [[dataDict objectForKey: keys[section]] count];
}

//row can edit
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//after delete or insert
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [dataDict allKeys];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[dataDict objectForKey: keys[section]] removeObjectAtIndex: row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert) //redondance with addCell?
    {
        //NSMutableArray* cell = [[[NSMutableArray init] alloc] addObjectsFromArray: @[@"Nouvelle tache", @0, [[UIImageView alloc] init]]];
        NSMutableArray* cell = [[NSMutableArray alloc] init];
        [cell addObject: @"Nouvelle tache"];
        [cell addObject: @0];
        [cell addObject: [[UIImageView alloc] init]];
        [[dataDict objectForKey: keys[section]] addObject: cell];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade]; //last position???
    }
    
    [self.tableView reloadData];
}

//can move
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

//after move
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    NSInteger fromSection = [fromIndexPath section];
    NSInteger fromRow = [fromIndexPath row];
    NSInteger toSection = [toIndexPath section];
    NSInteger toRow = [toIndexPath row];
    
    NSArray *keys = [dataDict allKeys];
    NSMutableArray* item = [[[dataDict objectForKey: keys[fromSection]] objectAtIndex: fromRow] retain];
    [[dataDict objectForKey: keys[fromSection]] removeObjectAtIndex: fromRow];
    [[dataDict objectForKey: keys[toSection]] insertObject: item atIndex: toRow];
    
    [self.tableView reloadData];
}

//after select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [dvc setSection: indexPath.section row: indexPath.row];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ||
       [[UIScreen mainScreen] scale] == 3.0)
    {
        svc.preferredDisplayMode =  UISplitViewControllerDisplayModeAutomatic;
        [dvc.navigationItem setLeftBarButtonItem: [svc displayModeButtonItem]];
        [dvc.navigationItem setLeftItemsSupplementBackButton: true];
    }
    else
    {
        [self.navigationController pushViewController:dvc animated:YES];
    }
}
@end
