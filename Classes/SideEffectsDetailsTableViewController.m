//
//  SideEffectsDetailsTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 03/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SideEffectsDetailsTableViewController.h"
#import "iStayHealthyRecord.h"
#import "Medication.h"
#import "SideEffects.h"

@interface SideEffectsDetailsTableViewController ()
@property (nonatomic, strong) iStayHealthyRecord *record;
@property (nonatomic, strong) Medication *hivMedication;
@property (nonatomic, strong) NSArray *effects;
@property (nonatomic, strong)NSMutableDictionary *stateDictionary;
@end

@implementation SideEffectsDetailsTableViewController
@synthesize record = _record;
@synthesize hivMedication = _hivMedication;
@synthesize effects = _effects;
@synthesize sideEffectsDelegate = _sideEffectsDelegate;
@synthesize stateDictionary = _stateDictionary;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithMasterRecord:(iStayHealthyRecord *)masterRecord withMedication:(Medication *)medication{
    self = [super initWithNibName:@"SideEffectsDetailsTableViewController" bundle:nil];
    if (self) {
        self.record = masterRecord;
        self.hivMedication = medication;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CommonSideEffects" ofType:@"plist"];
    NSString *medName = self.hivMedication.Name;
    NSDictionary *tmpDict = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:medName];
    if (tmpDict) 
    {
        self.effects = [tmpDict objectForKey:@"Effects"];
        if (nil == self.effects) {
            self.effects = [NSArray array];
        }
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return [self.effects count];
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) 
    {
        NSString *key = [NSString stringWithFormat:@"%d",indexPath.row];
        BOOL isChecked = !([[self.stateDictionary objectForKey:key] boolValue]);
        NSNumber *checked = [NSNumber numberWithBool:isChecked];
        [self.stateDictionary setObject:checked forKey:key];
        
        UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        if (isChecked) {
            [self.sideEffectsDelegate addSideEffect:[self.effects objectAtIndex:indexPath.row]];
        }
        else {
            [self.sideEffectsDelegate removeSideEffect:[self.effects objectAtIndex:indexPath.row]];                
        }
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        
        
    }
}

@end
