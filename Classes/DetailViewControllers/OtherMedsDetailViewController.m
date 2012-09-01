//
//  OtherMedsDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import "OtherMedsDetailViewController.h"
#import "OtherMedication.h"
#import "iStayHealthyRecord.h"
#import "Utilities.h"
#import "SetDateCell.h"
#import "GradientButton.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "DosageCell.h"

@interface OtherMedsDetailViewController ()
@property BOOL isEdit;
@end

@implementation OtherMedsDetailViewController
@synthesize startDate = _startDate;
@synthesize record = _record;
@synthesize otherMeds = _otherMeds;
@synthesize setDateCell = _setDateCell;
@synthesize isEdit = _isEdit;
@synthesize name = _name;
@synthesize number = _number;
@synthesize unit = _unit;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithOtherMedication:(OtherMedication *)otherMeds
             withMasterRecord:(iStayHealthyRecord *)masterRecord
{
    self = [super initWithNibName:@"OtherMedsDetailViewController" bundle:nil];
    if (nil != self)
    {
        self.isEdit = YES;
        self.record = masterRecord;
        self.otherMeds = otherMeds;
        self.startDate = otherMeds.StartDate;
    }
    return self;
}
- (id)initWithRecord:(iStayHealthyRecord *)masterrecord
{
    self = [super initWithNibName:@"OtherMedsDetailViewController" bundle:nil];
    if (nil != self)
    {
        self.isEdit = NO;
        self.record = masterrecord;
        self.startDate = [NSDate date];
    }
    return self;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isEdit)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Med",@"Edit Med");
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Add Other Drugs",nil);
    }
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) save:					(id) sender
{
	NSError *error = nil;
    NSManagedObjectContext *context = nil;
    if (self.isEdit)
    {
        context = [self.otherMeds managedObjectContext];
        self.otherMeds.StartDate = self.startDate;
        self.otherMeds.Dose = self.number;
        self.otherMeds.Name = self.name;
        self.otherMeds.Unit = self.unit;
        self.otherMeds.UID = [Utilities GUID];
        self.record.UID = [Utilities GUID];
    }
    else
    {
        context = [self.record managedObjectContext];
        OtherMedication *medication = [NSEntityDescription insertNewObjectForEntityForName:@"OtherMedication" inManagedObjectContext:context];
        [self.record addOtherMedicationsObject:medication];
        self.record.UID = [Utilities GUID];
        medication.UID = [Utilities GUID];
        medication.StartDate = self.startDate;
        medication.Name = self.name;
        medication.Dose = self.number;
        medication.Unit = self.unit;        
    }
    
    
    if (![context save:&error]) {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel:				(id) sender
{
    [self dismissModalViewControllerAnimated:YES];
}

/**
 brings up a new view to change the date
 */
- (void)changeStartDate{
	NSString *title =  @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set", nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeDate;
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
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    self.setDateCell.value.text = timestamp;
	self.startDate = datePicker.date;
}

- (void)removeSQLEntry
{
    [self.record removeOtherMedicationsObject:self.otherMeds];
    NSManagedObjectContext *context = self.otherMeds.managedObjectContext;
    [context deleteObject:self.otherMeds];
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
    if (0 == indexPath.section) {
        return 60;
    }
    if (2 == indexPath.section) {
        return 80;
    }
    return 48;
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.isEdit && 2 == section)
    {
        return 90;
    }
    else
    {
        return 10;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = nil;
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    if (self.isEdit && 2 == section)
    {
        CGRect deleteFrame = CGRectMake(10, 45, tableView.bounds.size.width - 20 , 37);
        GradientButton *deleteButton = [[GradientButton alloc] initWithFrame:deleteFrame colour:Red title:NSLocalizedString(@"Delete", @"Delete")];
        [deleteButton addTarget:self action:@selector(showAlertView:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:deleteButton];
    }
    
    return footerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd MMM YY";
        
        NSString *identifier = @"SetDateCell";
        SetDateCell *dateCell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == dateCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[SetDateCell class]]) {
                    dateCell = (SetDateCell *)currentObject;
                    break;
                }
            }
        }
        [[dateCell value]setText:[formatter stringFromDate:self.startDate]];
        [dateCell setTag:indexPath.row];
        dateCell.labelImageView.image = [UIImage imageNamed:@"appointments.png"];
        self.setDateCell = dateCell;
        return dateCell;
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
        if (self.isEdit)
        {
            clinicCell.valueField.text = self.otherMeds.Name;
        }
        else
        {
            clinicCell.valueField.text = NSLocalizedString(@"Enter Name", @"Enter Name");
        }
        clinicCell.title.text = NSLocalizedString(@"Name", @"Name");
        clinicCell.valueField.textColor = [UIColor lightGrayColor];
        clinicCell.tag = 10;
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
        doseCell.segmentedControl.selectedSegmentIndex = 1;
        doseCell.valueField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        doseCell.tag = 100;
        return  doseCell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            [self changeStartDate];
        }
    }
}

@end
