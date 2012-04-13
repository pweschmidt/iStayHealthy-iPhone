//
//  OtherMedicationChangeViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OtherMedicationChangeViewController.h"
#import "OtherMedication.h"
#import "DosageCell.h"
#import "iStayHealthyRecord.h"
#import "Utilities.h"

@implementation OtherMedicationChangeViewController
@synthesize otherMed,record,name, number, unit;


- (id)initWithOtherMedication:(OtherMedication *)_other withMasterRecord:(iStayHealthyRecord *)masterRecord{
    self = [super initWithNibName:@"OtherMedicationChangeViewController" bundle:nil];
    if (self) {
        self.otherMed = _other;
        self.record = masterRecord;
        self.name = self.otherMed.Name;
        self.number = self.otherMed.Dose;
        self.unit = self.otherMed.Unit;
        if (nil == self.unit) {
            self.unit = @"mg";
        }
    }
    return self;
}



- (void)dealloc
{
//    [otherMed release];
//    [record release];
    self.name = nil;
    self.number = nil;
    self.unit = nil;
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

	self.navigationItem.title = NSLocalizedString(@"Edit Med",@"Edit Med");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                            target:self action:@selector(showAlertView:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                            target:self action:@selector(save:)] autorelease];	
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (IBAction) save:					(id) sender{
    NSManagedObjectContext *context = [self.otherMed managedObjectContext];
    self.otherMed.Dose = self.number;
    self.otherMed.Name = self.name;
    self.otherMed.Unit = self.unit;
    self.otherMed.UID = [Utilities GUID];
    self.record.UID = [Utilities GUID];
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

/**
 remove the medication from the database - only called after user confirms that we 
 really want to delete it
 */
- (void) removeSQLEntry{
    [record removeOtherMedicationsObject:otherMed];
    NSManagedObjectContext *context = otherMed.managedObjectContext;
    [context deleteObject:otherMed];
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
        case 100:
            self.number = [self valueFromString:valueString];
            break;
    }
}
- (void)setUnitString:(NSString *)unitString{
    self.unit = unitString;
}

- (NSNumber *)valueFromString:(NSString *)string{
    if ([string isEqualToString:@""]) {
        return [NSNumber numberWithFloat:-1.0];            
    }
    return [NSNumber numberWithFloat:[string floatValue]];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (1 == indexPath.section) {
        return 80;
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
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
        [[clinicCell title]setText:NSLocalizedString(@"Name", @"Name")];
        [[clinicCell valueField]setText:self.name];
        [[clinicCell valueField]setTextColor:[UIColor lightGrayColor]];
        [clinicCell setTag:10];
        return clinicCell;
    }
    
    if (1 == indexPath.section) {
        NSString *identifier = @"DosageCell";
        DosageCell *doseCell = (DosageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == doseCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"DosageCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[DosageCell class]]) {
                    doseCell = (DosageCell *)currentObject;
                    break;
                }
            }  
            [doseCell setDelegate:self];            
        }
        
        [[doseCell valueField]setText:[NSString stringWithFormat:@"%2.2f",[self.otherMed.Dose floatValue]]];
        NSString *unitString = self.otherMed.Unit;
        if ([unitString isEqualToString:@"[g]"]) {
            [[doseCell segmentedControl]setSelectedSegmentIndex:0];
        }
        else if([unitString isEqualToString:@"[mg]"]){
            [[doseCell segmentedControl]setSelectedSegmentIndex:1];            
        }
        else if([unitString isEqualToString:@"[ml]"]){
            [[doseCell segmentedControl]setSelectedSegmentIndex:2];            
        }
        else {
            [[doseCell segmentedControl]setSelectedSegmentIndex:3];            
        }
            
        [[doseCell valueField]setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [doseCell setTag:100];
        return  doseCell;
    }
    
    return nil;
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
