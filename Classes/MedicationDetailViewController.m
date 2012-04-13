//
//  MedicationDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedicationDetailViewController.h"
#import "DateLabelCell.h"
#import "EditableTableCell.h"
#import "iStayHealthyRecord.h"
#import "Medication.h"

@implementation MedicationDetailViewController
@synthesize startDate, medsPicker, record, dateLabelCell, otherCombiDrugCell, availableMeds;
@synthesize combiTablets, proteaseInhibitors, nRTInihibtors, nNRTInhibitors, integraseInhibitors, entryInhibitors;
#pragma mark -
#pragma mark View lifecycle

/**
 load/setup the view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
#ifdef APPDEBUG
	NSLog(@"MedicationDetailViewController: viewDidLoad ENTERING");
#endif
	self.navigationItem.title = @"Add Combi Drug";
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																							target:self action:@selector(save:)] autorelease];	

#ifdef APPDEBUG
	NSLog(@"MedicationDetailViewController: opening the Meds List");
#endif
	NSString *path = [[NSBundle mainBundle] pathForResource:@"HIVMedications" ofType:@"plist"];
	NSMutableArray *tmpMedList = [[NSMutableArray alloc]initWithContentsOfFile:path];
#ifdef APPDEBUG
	NSLog(@"MedicationDetailViewController: opening the Meds List");
#endif
	self.availableMeds = tmpMedList;
#ifdef APPDEBUG
	NSLog(@"MedicationDetailViewController: getting the date");
#endif
	self.startDate = [NSDate date];
#ifdef APPDEBUG
	NSLog(@"MedicationDetailViewController: setting the row in the picker");
#endif
	[medsPicker selectRow:0 inComponent:0 animated:NO];	
	[tmpMedList release];
}

/**
 Saves the medication name, start date, drug name to SQL database. then dismisses the view
 @id sender
 */
- (IBAction) save: (id) sender{
	NSManagedObjectContext *context = [record managedObjectContext];
	Medication *medication = [NSEntityDescription insertNewObjectForEntityForName:@"Medication" inManagedObjectContext:context];
	[record addMedicationsObject:medication];
	NSArray *selectedMeds = (NSArray *)[self.availableMeds objectAtIndex:[medsPicker selectedRowInComponent:0]];
	NSString *name = (NSString *)[selectedMeds objectAtIndex:1];
	NSString *drug = (NSString *)[selectedMeds objectAtIndex:0];
	
	medication.Name = name;
	medication.Drug = drug;
	medication.MedicationForm = (NSString *)[selectedMeds objectAtIndex:2];
	medication.StartDate = self.startDate;
	
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
 no save: dismisses the view
 @id sender
 */
- (IBAction) cancel: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark datepicker code
/**
 brings up a new view to change the date
 */
- (void)changeStartDate{
	NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Set", nil];
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
	self.dateLabelCell.dateLabel.text = timestamp;
	self.startDate = datePicker.date;
	[actionSheet release];
}

#pragma mark -
#pragma mark Table view data source

/**
 1 section
 @tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

/**
 2 rows
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

/**
 cell height is 48.0
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 48.0;
}

/**
 configure/setup the cells
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Configurable Cell";
	if ( 0 == indexPath.row) {
		EditableTableCell *cell = (EditableTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[EditableTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.editableCellLabel.text = @"Drug Name";
		cell.editableCellTextField.text = @"not listed below";
		cell.editableCellTextField.keyboardType = UIKeyboardTypeDefault;
		self.otherCombiDrugCell = cell;
		return (UITableViewCell *)cell;
	}
	else {
		DateLabelCell *cell = (DateLabelCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (nil == cell) {
			cell = [[[DateLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.cellLabel.text = @"Start Date";
		self.dateLabelCell = cell;
		return (UITableViewCell *)cell;
	}	
}




#pragma mark -
#pragma mark Table view delegate
/**
 when resultsDate row is selected bring up the action sheet with the datepicker
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	if (1 == indexPath.row) {
		[self changeStartDate];
	}
}

#pragma mark -
#pragma mark pickerView implementation methods

/**
 only 1 component shown (medication name)
 @pickerView
 */
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

/**
 returns the number of components in the pickerView
 @pickerView
 @component
 */
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
#ifdef APPDEBUG
	NSLog(@"MedicationDetailViewController: pickerView. Number of rows is %d", [self.availableMeds count]);
#endif
	return [self.availableMeds count];
}

/** 
 @pickerView
 @row
 @component
 @return text to be displayed
 */
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
	NSArray *medDescription = (NSArray *)[self.availableMeds objectAtIndex:row];
	NSString *text = (NSString *)[medDescription objectAtIndex:1];
	if ([text hasPrefix:@"("]) {
		text = (NSString *)[medDescription objectAtIndex:0];
	}
#ifdef APPDEBUG
	NSLog(@"Selected Meds is %@",text);
#endif
	return text;	
}


#pragma mark -
#pragma mark Memory management
/**
 handle memory warning
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 unload view
 */
- (void)viewDidUnload {
}

/**
 dealloc
 */
- (void)dealloc {
	[startDate release];
	[record release];
	[dateLabelCell release];
	[medsPicker release];
	[otherCombiDrugCell release];
	[availableMeds release];
    [combiTablets release];
    [proteaseInhibitors release];
    [nRTInihibtors release];
    [nNRTInhibitors release];
    [integraseInhibitors release];
    [entryInhibitors release];
    [super dealloc];
}


@end

