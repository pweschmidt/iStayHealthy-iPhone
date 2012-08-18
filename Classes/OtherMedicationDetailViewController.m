//
//  OtherMedicationDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OtherMedicationDetailViewController.h"
#import "iStayHealthyRecord.h"
#import "OtherMedication.h"
#import "SetDateCell.h"
#import "Utilities.h"
#import "GeneralSettings.h"

@implementation OtherMedicationDetailViewController
@synthesize dateCell, name, number, unit, record, startDate;


- (id)initWithRecord:(iStayHealthyRecord *)masterrecord{
    self = [super initWithNibName:@"OtherMedicationDetailViewController" bundle:nil];
    if (self) {
        self.record = masterrecord;
        self.name = @"";
        self.unit = @"";
        self.startDate = [NSDate date];
        self.number = [NSNumber numberWithFloat:-1.0];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle
/**
 loads/sets up the view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Add Other Drugs",nil);
    
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                            target:self action:@selector(cancel:)];
     
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                            target:self action:@selector(save:)];	
	
}


/**
 upon save the name of the drug and start date get saved to the data base. view is then dismissed
 @id
 */
- (IBAction) save: (id) sender{
	NSError *error = nil;
    NSManagedObjectContext *context = [record managedObjectContext];
    OtherMedication *medication = [NSEntityDescription insertNewObjectForEntityForName:@"OtherMedication" inManagedObjectContext:context];
    [record addOtherMedicationsObject:medication];
    record.UID = [Utilities GUID];
    medication.UID = [Utilities GUID];
    medication.StartDate = self.startDate;
    medication.Name = self.name;
    medication.Dose = self.number;
    medication.Unit = self.unit;
    
    if (![context save:&error]) {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
	[self dismissModalViewControllerAnimated:YES];
}

/**
 dismiss view without saving
 @id
*/
- (IBAction) cancel: (id) sender{
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


#pragma mark -
#pragma mark datepicker code
/**
 brings up a new view to change the date
 */
- (void)changeStartDate{
	NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
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
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
	self.dateCell.value.text = timestamp;
	self.startDate = datePicker.date;
}



#pragma mark -
#pragma mark Table view data source

/**
 number of sections is 2
 @return NSInteger = 2
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

/**
 number of rows is 1 for the first section (DateLabel) and 2 for the rest
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) {
        return 60;
    }
    if (2 == indexPath.section) {
        return 80;
    }
    return 48;
}

/**
 loads/sets up the cells
 @tableView
 @indexPath
 @return UITableViewCell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
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
        [[_dateCell value]setText:[formatter stringFromDate:self.startDate]];
        [_dateCell setTag:indexPath.row];
        _dateCell.labelImageView.image = [UIImage imageNamed:@"appointments.png"];
        self.dateCell = _dateCell;
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
        [[clinicCell valueField]setText:NSLocalizedString(@"Enter Name", @"Enter Name")];
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
        [[doseCell segmentedControl]setSelectedSegmentIndex:1];
        [[doseCell valueField]setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [doseCell setTag:100];
        return  doseCell;
    }
    
    return nil;
}



#pragma mark -
#pragma mark Table view delegate
/**
 when date cell is selected the datepicker will show up
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            [self changeStartDate];
        }
    }
}


#pragma mark -
#pragma mark Memory management
/**
 handles memory warnings
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 unload view
 */
- (void)viewDidUnload {
    self.dateCell = nil;
    self.name = nil;
    self.number = nil;
    self.unit = nil;
    self.startDate = nil;
	[super viewDidUnload];
}

/**
 dealloc
 */


@end

