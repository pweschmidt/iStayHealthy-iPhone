//
//  ProcedureAddViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProcedureAddViewController.h"
#import "iStayHealthyRecord.h"
#import "Procedures.h"
#import "SetDateCell.h"
#import "ClinicAddressCell.h"
#import "Utilities.h"
#import "GeneralSettings.h"

@implementation ProcedureAddViewController
@synthesize dateCell, startDate, record, name, illness;

/**
 dealloc
 */
- (void)dealloc {
    /*
	[dateCell release];
	[startDate release];
	[record release];
     */
    self.dateCell = nil;
    self.startDate = nil;
    self.name = nil;
    self.illness = nil;
    [super dealloc];
}

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord{
    self = [super initWithNibName:@"ProcedureAddViewController" bundle:nil];
    if (self) {
        self.record = masterrecord;
        self.startDate = [NSDate date];
        self.name = @"";
        self.illness = @"";
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
	self.navigationItem.title = NSLocalizedString(@"Illness/Surgery",nil);
    
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                              target:self action:@selector(cancel:)] autorelease];
    
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                               target:self action:@selector(save:)] autorelease];	
	
}


/**
 upon save the name of the drug and start date get saved to the data base. view is then dismissed
 @id
 */
- (IBAction) save: (id) sender{
	NSError *error = nil;
    NSManagedObjectContext *context = [record managedObjectContext];
    Procedures *procedures = [NSEntityDescription insertNewObjectForEntityForName:@"Procedures" inManagedObjectContext:context];
    [record addProceduresObject:procedures];
    procedures.Date = self.startDate;
    procedures.Name = self.name;
    procedures.Illness = self.illness;
    procedures.UID = [Utilities GUID];
    self.record.UID = [Utilities GUID];
    
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
        case 11:
            self.illness = valueString;
            break;
    }
}
- (void)setUnitString:(NSString *)unitString{
    //nothing to do
}



#pragma mark -
#pragma mark datepicker code
/**
 brings up a new view to change the date
 */
- (void)changeStartDate{
	NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",nil), nil]autorelease];
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
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
	self.dateCell.value.text = timestamp;
	self.startDate = datePicker.date;
}




#pragma mark - Table view data source

/**
 number of sections is 2
 @return NSInteger = 2
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

/**
 number of rows is 1 for the first section (DateLabel) and 2 for the rest
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    }
    else 
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
        [[_dateCell value]setText:[formatter stringFromDate:self.startDate]];
        [_dateCell setTag:indexPath.row];
        [[_dateCell title]setText:NSLocalizedString(@"Set Date", @"Set Date")];
        [[_dateCell title]setTextColor:TEXTCOLOUR];
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
        if (0 == indexPath.row) {
            [[clinicCell title]setText:NSLocalizedString(@"Surgery", @"Surgery")];
            [[clinicCell valueField]setText:NSLocalizedString(@"Enter Name", @"Enter Name")];
            [[clinicCell valueField]setTextColor:[UIColor lightGrayColor]];
        }
        if (1 == indexPath.row) {
            [[clinicCell title]setText:NSLocalizedString(@"Illness", @"Illness")];
            [[clinicCell valueField]setText:NSLocalizedString(@"Enter Name", @"Enter Name")];
            [[clinicCell valueField]setTextColor:[UIColor lightGrayColor]];
        }
        [clinicCell setTag:10 + indexPath.row];
        return clinicCell;
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
