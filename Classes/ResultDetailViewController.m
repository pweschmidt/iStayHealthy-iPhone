//
//  ResultDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultDetailViewController.h"
#import "iStayHealthyRecord.h"
#import "Results.h"
#import "Utilities.h"
#import "SetDateCell.h"
#import "ResultValueCell.h"
#import "ResultSegmentedCell.h"
#import "GeneralSettings.h"

@implementation ResultDetailViewController
@synthesize resultsDate, setDateCell;
@synthesize record;
@synthesize vlHIV,vlHepC, cd4, cd4Percent;
#pragma mark -
#pragma mark View lifecycle


- (id)initWithRecord:(iStayHealthyRecord *)masterrecord{
    self = [super initWithNibName:@"ResultDetailViewController" bundle:nil];
    if (self) {
        self.record = masterrecord;
        self.resultsDate = [NSDate date];
        self.vlHIV = [NSNumber numberWithFloat:-1.0];
        self.cd4 = [NSNumber numberWithFloat:-1.0];
        self.cd4Percent = [NSNumber numberWithFloat:-1.0];
        self.vlHepC = [NSNumber numberWithFloat:-1.0];
    }
    return self;
}



/**
 loads/sets up the view
 */

- (void)viewDidLoad {
    [super viewDidLoad];
#ifdef APPDEBUG
    NSString *translated = NSLocalizedString(@"Add Results", @"Add Results");
    NSLog(@"ResultDetailViewController::viewDidLoad Add Results == %@",translated);
#endif
	self.navigationItem.title = NSLocalizedString(@"Add Results", @"Add Results");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                            target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                            target:self action:@selector(save:)] autorelease];	
}


#pragma mark -
#pragma mark actions

/**
 when clicked it saves the entries for CD4 and Viral load to the database. then the view is dismissed
 @id
 */
- (IBAction) save: (id) sender{
	NSManagedObjectContext *context = [record managedObjectContext];
	Results *result = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:context];
	[record addResultsObject:result];
    record.UID = [Utilities GUID];
    result.UID = [Utilities GUID];
    result.ResultsDate = self.resultsDate;
    result.ViralLoad = self.vlHIV;
    result.HepCViralLoad = self.vlHepC;
    result.CD4 = self.cd4;
    result.CD4Percent = self.cd4Percent;
    
	NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

/**
 dismisses the view without saving
 @id 
 */
- (IBAction) cancel: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark datepicker code
/**
 brings up a new view to change the date
 */
- (void)changeResultsDate{
	NSString *title =  @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set", nil), nil]autorelease];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
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
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"dd MMM YY";
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    self.setDateCell.value.text = timestamp;
	self.resultsDate = datePicker.date;
}


#pragma mark -
#pragma mark ResultValueCell delegate method
- (void)setValueString:(NSString *)valueString withTag:(int)tag{
#ifdef APPDEBUG
    NSLog(@"ResultDetailViewController setValueString %@ with tag %d",valueString, tag);
#endif
    NSNumber *number = [self valueFromString:valueString];
    switch (tag) {
        case 10:
            self.vlHIV = number;
            break;
        case 11:
            self.vlHepC = number;
            break;
        case 100:
            self.cd4 = number;
            break;
        case 101:
            self.cd4Percent = number;
            break;
    }
}

- (NSNumber *)valueFromString:(NSString *)string{
    if ([string isEqualToString:NSLocalizedString(@"undetectable",@"undetectable")]) {
        return [NSNumber numberWithFloat:0.0];
    }
    if ([string isEqualToString:@""]) {
        return [NSNumber numberWithFloat:-1.0];            
    }
    return [NSNumber numberWithFloat:[string floatValue]];
}


#pragma mark -
#pragma mark Table view data source
/**
 @return 2 sections
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

/**
 @return 2 rows for section 0, 1 for section 1 (resultsdate)
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (0 == section) {
		return 1;
	}
    return 2;
}

/**
 for viralload we get more height as with have a togglebutton in there
 @tableView
 @indexPath
 @return height as CGFloat
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (2 == indexPath.section) {
        return 80;
    }
	return 48.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
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
        [[dateCell value]setText:[formatter stringFromDate:self.resultsDate]];
        [dateCell setTag:indexPath.row];
        [[dateCell title]setText:NSLocalizedString(@"Set Date", @"Set Date")];
        [[dateCell title]setTextColor:TEXTCOLOUR];
        self.setDateCell = dateCell;
        return dateCell;
    }
    if (1 == indexPath.section) {
        int tag = indexPath.row + 100;

        NSString *identifier = @"ResultValueCell";
        ResultValueCell *resultCell = (ResultValueCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == resultCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ResultValueCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[ResultValueCell class]]) {
                    resultCell = (ResultValueCell *)currentObject;
                    break;
                }
            } 
            [resultCell setDelegate:self];
        }
        [[resultCell title]setTextColor:TEXTCOLOUR];
        int row = indexPath.row;
        switch (row) {
            case 0:
                [[resultCell title]setText:NSLocalizedString(@"CD4 Count", @"CD4 Count")];
                break;
            case 1:
                [[resultCell title]setText:NSLocalizedString(@"CD4 %", @"CD4 %")];
                break;
        }
        [resultCell setTag:tag];
        return resultCell;        
    }
    if (2 == indexPath.section) {
        int tag = 10 + indexPath.row;
        
        NSString *identifier = @"ResultSegmentedCell";    
        ResultSegmentedCell *segCell = (ResultSegmentedCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == segCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ResultSegmentedCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[ResultSegmentedCell class]]) {
                    segCell = (ResultSegmentedCell *)currentObject;
                    break;
                }
            }  
            [segCell setDelegate:self];
        }
        int row = indexPath.row;
        switch (row) {
            case 0:
                [[segCell title]setText:NSLocalizedString(@"Viral Load",@"Viral Load")];
                [[segCell title]setTextColor:TEXTCOLOUR];
                [[segCell switchControl]setOn:FALSE];
                break;
            case 1:
                [[segCell title]setText:NSLocalizedString(@"Viral Load HepC",@"Viral Load HepC")];
                [[segCell title]setTextColor:TEXTCOLOUR];
                [[segCell valueField]setEnabled:FALSE];
                [[segCell switchControl]setOn:TRUE];
                break;
        }
        
        [[segCell query]setText:NSLocalizedString(@"undetectable?",@"undetectable?")];
        [[segCell query]setTextColor:TEXTCOLOUR];
        [segCell setTag:tag];
        return segCell;        
    }
    
    return nil;
}


#pragma mark -
#pragma mark Table view delegate
/**
 when the date row (section 1) is selected the datepicker will come up
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	if (0 == indexPath.section) {
		[self changeResultsDate];
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
 unloads view
 */
- (void)viewDidUnload {
    self.resultsDate = nil;
    self.setDateCell = nil;
    self.cd4 = nil;
    self.cd4Percent = nil;
    self.vlHIV = nil;
    self.vlHepC = nil;
	[super viewDidUnload];
}

/**
 dealloc
 */
- (void)dealloc {
    self.resultsDate = nil;
    self.setDateCell = nil;
    self.cd4 = nil;
    self.cd4Percent = nil;
    self.vlHIV = nil;
    self.vlHepC = nil;
    /*
	[resultsDate release];
	[record release];
    [setDateCell release];
    [cd4 release];
    [cd4Percent release];
    [vlHIV release];
    [vlHepC release];
     */
    [super dealloc];
}


@end

