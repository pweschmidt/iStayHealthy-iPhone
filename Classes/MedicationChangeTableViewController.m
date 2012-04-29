//
//  MedicationChangeTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedicationChangeTableViewController.h"
#import "MissedMedication.h"
#import "Medication.h"
#import "iStayHealthyRecord.h"
#import "Utilities.h"
#import "GeneralSettings.h"
#import "SideEffects.h"
#import "SetDateCell.h"

@implementation MedicationChangeTableViewController
@synthesize date, record, selectedMedication, isMissed, effectString,effectIsSet, dateCell, medName;
@synthesize missedDate, effectDate, state, missedSwitchCell, effectSwitchCell;
@synthesize missedDateCell, effectDateCell;
/**
 init - loads NIB file and sets the master SQL record
 */
- (id)initWithMasterRecord:(iStayHealthyRecord *)masterRecord withMedication:(Medication *)medication{
    self = [super initWithNibName:@"MedicationChangeTableViewController" bundle:nil];
    if (self) {
        self.record = masterRecord;
        self.selectedMedication = medication;
        self.isMissed = NO;
        self.effectIsSet = NO;
        self.date = self.selectedMedication.StartDate;
        if (nil == self.date) {
            self.date = [NSDate date];
        }
        self.effectString = @"";
        self.medName = medication.Name;
        self.missedDate = [NSDate date];
        self.effectDate = [NSDate date];
        self.state = CHANGEDATE;
    }
    return self;
}


- (void)dealloc
{
    self.dateCell = nil;
    self.date = nil;
    self.effectString = nil;
    self.effectDate = nil;
    self.missedDate = nil;
    self.missedSwitchCell = nil;
    self.effectSwitchCell = nil;
    self.missedDateCell = nil;
    self.effectDateCell = nil;
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
    self.navigationItem.title = self.medName;
//	self.navigationItem.title = NSLocalizedString(@"Manage HIV Drugs",@"Manage HIV Drugs");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                            target:self action:@selector(showAlertView:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                            target:self action:@selector(save:)] autorelease];	
}

- (void)viewDidUnload
{
    self.dateCell = nil;
    self.date = nil;
    self.effectString = nil;
    self.effectDate = nil;
    self.missedDate = nil;
    self.missedSwitchCell = nil;
    self.effectSwitchCell = nil;
    [super viewDidUnload];
}

/**
 save the changes and/or dismiss
 */
- (IBAction) save:					(id) sender{
    NSManagedObjectContext *context = [record managedObjectContext];
    NSError *error = nil;
    if (self.isMissed) {
        MissedMedication *missedMed = [NSEntityDescription insertNewObjectForEntityForName:@"MissedMedication" inManagedObjectContext:context];
        [record addMissedMedicationsObject:missedMed];
        record.UID = [Utilities GUID];
        
        missedMed.MissedDate = self.date;   
        missedMed.Name = selectedMedication.Name;
        missedMed.Drug = selectedMedication.Drug;
        missedMed.UID = [Utilities GUID];
        if (![context save:&error]) {
#ifdef APPDEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        }
        
    }
    if (self.effectIsSet) {
        SideEffects *effects = [NSEntityDescription insertNewObjectForEntityForName:@"SideEffects" inManagedObjectContext:context];
        [record addSideeffectsObject:effects];
        effects.SideEffectDate = self.date;
        effects.SideEffect = self.effectString;
        if (![context save:&error]) {
#ifdef APPDEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        }
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
    [record removeMedicationsObject:selectedMedication];
    NSManagedObjectContext *context = selectedMedication.managedObjectContext;
    [context deleteObject:selectedMedication];
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
 sets the switch BOOL variable
 */
- (void)setMissed:(BOOL)isOn{
    self.isMissed = isOn;
}

- (void)setValueString:(NSString *)valueString withTag:(int)tag{
    self.effectIsSet = YES;
    self.effectString = valueString;
}
- (void)setUnitString:(NSString *)unitString{
    //nothing to do here
}



/**
 changes the start date for this medication
 */
- (void)changeDate{
	NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",@"Set"), nil]autorelease];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];
}

/**
 sets the label and resultsdate to the one selected
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"dd MMM YY";
#ifdef APPDEBUG
    NSLog(@"MedicationChangeTableViewController:actionSheet buttonIndex == %d",buttonIndex);
#endif	
    
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    
    self.date = datePicker.date;
    self.dateCell.value.text = timestamp;
}


#pragma mark - Table view data source
/**
 3 sections in the table
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

/**
 each section has 1 row
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 1;
    }
    else if (1 == section) {
        if (self.effectSwitchCell.selected) {
            return 3;
        }
        else {
            return 1;
        }
    }
    else {
        if (self.missedSwitchCell.selected) {
            return 2;
        }
        else {
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48.0;
}


/**
 configure the cells
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"dd MMM YY";
    if (0 == indexPath.section) {        
        NSString *identifier = @"SetDateCell";
        SetDateCell *_dateCell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == _dateCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[SetDateCell class]]) {
                    _dateCell = (SetDateCell *)currentObject;
                    break;
                }
            }  
        }
        [[_dateCell value]setText:[formatter stringFromDate:self.date]];
        [_dateCell setTag:indexPath.row];
        [[_dateCell title]setText:NSLocalizedString(@"Change", @"Change")];
        [[_dateCell title]setTextColor:TEXTCOLOUR];
        self.dateCell= _dateCell;
        return _dateCell;
    }
    if (1 == indexPath.section) {
        if (0 == indexPath.row) {
            NSString *identifier = @"SwitcherCell";
            SwitcherCell *cell = (SwitcherCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (nil == cell) {
                NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SwitcherCell" owner:self options:nil];
                for (id currentObject in cellObjects) {
                    if ([currentObject isKindOfClass:[SwitcherCell class]]) {
                        cell = (SwitcherCell *)currentObject;
                        break;
                    }
                } 
                [cell setDelegate:self];
            }
            [[cell label]setText:@"Side Effect"];
            [[cell switcher]setOn:FALSE];
            self.effectSwitchCell = cell;
            return cell;
        }
        if (1 == indexPath.row) {
            NSString *identifier = @"SetDateCell";
            SetDateCell *_dateCell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (nil == _dateCell) {
                NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell" owner:self options:nil];
                for (id currentObject in cellObjects) {
                    if ([currentObject isKindOfClass:[SetDateCell class]]) {
                        _dateCell = (SetDateCell *)currentObject;
                        break;
                    }
                }  
            }
            [[_dateCell value]setText:[formatter stringFromDate:self.effectDate]];
            [_dateCell setTag:indexPath.row];
            [[_dateCell title]setText:NSLocalizedString(@"Set Date", @"Set Date")];
            [[_dateCell title]setTextColor:TEXTCOLOUR];
            self.effectDateCell= _dateCell;
            return _dateCell;
        }
        if (2 == indexPath.row) {
            NSString *identifier = @"ClinicAddressCell";
            ClinicAddressCell *cell = (ClinicAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (nil == cell) {
                NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicAddressCell" owner:self options:nil];
                for (id currentObject in cellObjects) {
                    if ([currentObject isKindOfClass:[ClinicAddressCell class]]) {
                        cell = (ClinicAddressCell *)currentObject;
                        break;
                    }
                }  
                [cell setDelegate:self];
            }
            [[cell title]setText:NSLocalizedString(@"Side Effects",@"Side Effects")];
            [[cell valueField]setText:NSLocalizedString(@"Enter Effects",@"Enter Effects")];
            return cell;
        }
    }
    if (2 == indexPath.section) {
        if (0 == indexPath.row) {
            NSString *identifier = @"SwitcherCell";
            SwitcherCell *cell = (SwitcherCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (nil == cell) {
                NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SwitcherCell" owner:self options:nil];
                for (id currentObject in cellObjects) {
                    if ([currentObject isKindOfClass:[SwitcherCell class]]) {
                        cell = (SwitcherCell *)currentObject;
                        break;
                    }
                } 
                [cell setDelegate:self];
            }
            [[cell switcher]setOn:FALSE];
            self.missedSwitchCell = cell;
            return cell;        
        }
        if (1 == indexPath.row) {
            NSString *identifier = @"SetDateCell";
            SetDateCell *_dateCell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (nil == _dateCell) {
                NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell" owner:self options:nil];
                for (id currentObject in cellObjects) {
                    if ([currentObject isKindOfClass:[SetDateCell class]]) {
                        _dateCell = (SetDateCell *)currentObject;
                        break;
                    }
                }  
            }
            [[_dateCell value]setText:[formatter stringFromDate:self.missedDate]];
            [_dateCell setTag:indexPath.row];
            [[_dateCell title]setText:NSLocalizedString(@"Set Date", @"Set Date")];
            [[_dateCell title]setTextColor:TEXTCOLOUR];
            self.missedDateCell= _dateCell;
            return _dateCell;
        }
    }
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section && 0 == indexPath.row) {
        [self changeDate];
        self.state = CHANGEDATE;
    }
}

@end
