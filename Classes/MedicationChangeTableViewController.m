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
#import "MoreResultsCell.h"

@implementation MedicationChangeTableViewController
@synthesize date, record, selectedMedication, isMissed, effectString,effectIsSet, dateCell;
@synthesize missedDate, effectDate, state, missedSwitchCell, effectSwitchCell;
@synthesize missedDateCell, effectDateCell, effectsCell;
@synthesize effectSwitch, missedSwitch, dateChanged;
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
        self.dateChanged = NO;
        self.date = self.selectedMedication.StartDate;
        if (nil == self.date) {
            self.date = [NSDate date];
        }
        self.effectString = @"";
        medName = medication.Name;
        self.missedDate = [NSDate date];
        self.effectDate = [NSDate date];
        self.state = CHANGEDATE;
    }
    return self;
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
    self.navigationItem.title = medName;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                            target:self action:@selector(showAlertView:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                            target:self action:@selector(save:)];	
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
    self.effectsCell = nil;
    self.effectSwitch = nil;
    self.missedSwitch = nil;
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
        [self.record addMissedMedicationsObject:missedMed];
        self.record.UID = [Utilities GUID];
        
        missedMed.MissedDate = self.missedDate;   
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
        self.record.UID = [Utilities GUID];
        effects.SideEffectDate = self.effectDate;
        effects.Name = self.selectedMedication.Name;
        effects.SideEffect = self.effectString;
        if (![context save:&error]) {
#ifdef APPDEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        }
    }
    if (self.dateChanged) {
        self.record.UID = [Utilities GUID];
        self.selectedMedication.StartDate = self.date;
        self.selectedMedication.UID = [Utilities GUID];
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
    
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

- (IBAction)switchSideEffects:(id)sender{
    if (self.effectSwitch.isOn) {
        self.effectIsSet = YES;
    }
    else {
        self.effectIsSet = NO;
    }
    [self.tableView reloadData];
}

- (IBAction)switchMissedDose:(id)sender{
    if (self.missedSwitch.isOn) {
        self.isMissed = YES;
    }
    else {
        self.isMissed = NO;
    }
    [self.tableView reloadData];
}



- (void)setValueString:(NSString *)valueString withTag:(int)tag{
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
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",@"Set"), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
    if (self.state == CHANGEDATE) {
        datePicker.date = self.date;
    }
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];
}

/**
 sets the label and resultsdate to the one selected
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
#ifdef APPDEBUG
    NSLog(@"MedicationChangeTableViewController:actionSheet buttonIndex == %d",buttonIndex);
#endif	
    
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    switch (self.state) {
        case CHANGEDATE:
            self.date = datePicker.date;
            self.dateChanged = YES;
            self.dateCell.value.text = timestamp;
            break;
        case EFFECTSDATE:
            self.effectDate = datePicker.date;
            self.effectDateCell.value.text = timestamp;
            break;
        case MISSEDDATE:
            self.missedDate = datePicker.date;
            self.missedDateCell.value.text = timestamp;
            break;
    }
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
        if (self.effectIsSet) {
            return 3;
        }
        else {
            return 1;
        }
    }
    else {
        if (self.isMissed) {
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        return NSLocalizedString(@"Treatment Start Date", @"Treatment Start Date");
    }
    if (1 == section) {
        return NSLocalizedString(@"Side Effects", @"Side Effects");
    }
    if (2 == section) {
        return NSLocalizedString(@"Missed", @"Missed");
    }
    return @"";
}

/**
 configure the cells
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
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
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+12.0, 112.0, 22.0);
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            label.textColor = TEXTCOLOUR;
            label.textAlignment = UITextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:15.0];
            
            CGRect frameSwitch = CGRectMake(215.0, 10.0, 94.0, 27.0);
            UISwitch *switchEnabled = [[UISwitch alloc] initWithFrame:frameSwitch];
            [switchEnabled addTarget:self action:@selector(switchSideEffects:) forControlEvents:UIControlEventValueChanged];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
                switchEnabled.onTintColor = TINTCOLOUR;
            }
            cell.accessoryView = switchEnabled;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [label setText:NSLocalizedString(@"Side Effects", @"Side Effects")];
            [cell addSubview:label];
            self.effectSwitchCell = cell;
            self.effectSwitch = switchEnabled;
            [self.effectSwitch setOn:self.effectIsSet];
            return cell;
        }
        if (1 == indexPath.row && self.effectIsSet) {
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
        if (2 == indexPath.row && self.effectIsSet) {
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
            self.effectsCell = cell;
            return cell;
        }
    }
    if (2 == indexPath.section) {
        if (0 == indexPath.row) {
            NSString *identifier = @"SwitcherCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+12.0, 112.0, 22.0);
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            label.textColor = TEXTCOLOUR;
            label.textAlignment = UITextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:15.0];
            
            CGRect frameSwitch = CGRectMake(215.0, 10.0, 94.0, 27.0);
            UISwitch *switchEnabled = [[UISwitch alloc] initWithFrame:frameSwitch];
            [switchEnabled addTarget:self action:@selector(switchMissedDose:) forControlEvents:UIControlEventValueChanged];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
                switchEnabled.onTintColor = TINTCOLOUR;
            }
            [switchEnabled setOn:self.isMissed];
            cell.accessoryView = switchEnabled;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [label setText:NSLocalizedString(@"Missed?", @"Missed?")];
            [cell addSubview:label];
            
            self.missedSwitch = switchEnabled;
            [self.missedSwitch setOn:self.isMissed];
            self.missedSwitchCell = cell;
            return cell;        
        }
        if (1 == indexPath.row && self.isMissed) {
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
        self.state = CHANGEDATE;
        [self changeDate];
    }
    if (1 == indexPath.section && 1 == indexPath.row) {
        self.state = EFFECTSDATE;
        [self changeDate];
    }
    if (2 == indexPath.section && 1 == indexPath.row) {
        self.state = MISSEDDATE;
        [self changeDate];
    }
}

@end
