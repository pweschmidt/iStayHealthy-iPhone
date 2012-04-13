//
//  ProcedureChangeViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProcedureChangeViewController.h"
#import "Procedures.h"
#import "Utilities.h"
#import "iStayHealthyRecord.h"

@implementation ProcedureChangeViewController
@synthesize record, procedures, name, illness;

- (id)initWithProcedure:(Procedures *)_procs withMasterRecord:(iStayHealthyRecord *)masterRecord{
    self = [super initWithNibName:@"ProcedureChangeViewController" bundle:nil];
    if (self) {
        self.procedures = _procs;
        self.record = masterRecord;
        self.name = self.procedures.Name;
        self.illness = self.procedures.Illness;
    }
    return self;
    
}

- (void)dealloc
{
    self.name = nil;
    self.illness = nil;
    /*
    [procedures release];
    [record release];
     */
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Edit Illness/Surgery",@"Edit Illness/Surgery");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                              target:self action:@selector(showAlertView:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                               target:self action:@selector(save:)] autorelease];	
}


- (IBAction) save:					(id) sender{
    NSManagedObjectContext *context = [procedures managedObjectContext];
    self.record.UID = [Utilities GUID];
    self.procedures.UID = [Utilities GUID];
    self.procedures.Illness = self.illness;
    self.procedures.Name = self.name;
    NSError *error = nil;
    if (![context save:&error]) {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }                
 	[self dismissModalViewControllerAnimated:YES];
}

/**
 shows the Alert view when user clicks the Trash button
 */
- (IBAction) showAlertView:			(id) sender{
    UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil]autorelease];
    
    [alert show];    
}

/**
 if user really wants to delete the entry call removeSQLEntry
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")]) {
        [self removeSQLEntry];
    }
}


- (void) removeSQLEntry{
    [record removeProceduresObject:procedures];
    NSManagedObjectContext *context = procedures.managedObjectContext;
    [context deleteObject:procedures];
    NSError *error = nil;
    if (![context save:&error]) {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ClinicAddressCellDelegate Protocol implementation
- (void)setValueString:(NSString *)valueString withTag:(int)tag{
    switch (tag) {
        case 10:
            self.name = valueString;
            break;
        case 11:
            self.illness = valueString;
            break;
    }
}
- (void)setUnitString:(NSString *)unitString{
    //nothing to do
}



#pragma mark - Table view data source

/**
 number of sections is 2
 @return NSInteger = 2
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

/**
 number of rows is 1 for the first section (DateLabel) and 2 for the rest
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ClinicAddressCell";
    ClinicAddressCell *clinicCell = (ClinicAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == clinicCell) {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicAddressCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[ClinicAddressCell class]]) {
                clinicCell = (ClinicAddressCell *)currentObject;
                break;
            }
        } 
        [clinicCell setDelegate:self];
    }
    if (0 == indexPath.row) {
        [[clinicCell title]setText:NSLocalizedString(@"Surgery", @"Surgery")];
        [[clinicCell valueField]setText:self.name];
        [[clinicCell valueField]setTextColor:[UIColor blackColor]];
    }
    if (1 == indexPath.row) {
        [[clinicCell title]setText:NSLocalizedString(@"Illness", @"Illness")];
        [[clinicCell valueField]setText:self.illness];
        [[clinicCell valueField]setTextColor:[UIColor blackColor]];
    }
    [clinicCell setTag:10 + indexPath.row];
    return clinicCell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
