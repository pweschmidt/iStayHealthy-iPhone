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
#import "SetDateCell.h"
#import "Utilities.h"
#import "GeneralSettings.h"

@implementation OtherMedicationChangeViewController
@synthesize otherMed,record,name, number, unit, changeDate, changeDateCell;


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
        self.changeDate = self.otherMed.StartDate;
    }
    return self;
}



- (void)dealloc
{
    self.changeDate = nil;
    self.name = nil;
    self.number = nil;
    self.unit = nil;
    self.changeDateCell = nil;
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
    self.changeDate = nil;
    self.name = nil;
    self.number = nil;
    self.unit = nil;
    self.changeDateCell = nil;
    [super viewDidUnload];
}

- (IBAction) save:					(id) sender{
    NSManagedObjectContext *context = [self.otherMed managedObjectContext];
    self.otherMed.StartDate = self.changeDate;
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
 brings up a new view to change the date
 */
- (void)changeStartDate{
	NSString *title =  @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set", nil), nil]autorelease];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.date = self.changeDate;
	[actionSheet addSubview:datePicker];
}

/**
 sets the label and resultsdate to the one selected
 @actionSheet
 @buttonIndex
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"dd MMM YY";	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    self.changeDateCell.value.text = timestamp;
	self.changeDate = datePicker.date;
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (2 == indexPath.section) {
        return 80;
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        formatter.dateFormat = @"dd MMM YY";
        
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
        [[_dateCell value]setText:[formatter stringFromDate:self.changeDate]];
        [_dateCell setTag:indexPath.row];
        [[_dateCell title]setText:NSLocalizedString(@"Change", @"Change")];
        [[_dateCell title]setTextColor:TEXTCOLOUR];
        self.changeDateCell = _dateCell;
        return _dateCell;
    }
    if (1 == indexPath.section) {
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
    
    if (2 == indexPath.section) {
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
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            [self changeStartDate];
        }
    }
}

@end
