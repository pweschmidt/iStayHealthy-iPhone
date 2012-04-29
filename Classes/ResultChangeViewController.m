//
//  ResultChangeViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 14/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultChangeViewController.h"
#import "Results.h"
#import "iStayHealthyRecord.h"
#import "Utilities.h"
#import "SetDateCell.h"
#import "ResultValueCell.h"
#import "ResultSegmentedCell.h"
#import "GeneralSettings.h"

@implementation ResultChangeViewController
@synthesize results, record;
@synthesize cd4,cd4Percent,vlHIV,vlHepC, resultsDate, changeDateCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithResults:(Results *)_results withMasterRecord:(iStayHealthyRecord *)masterRecord{
    self = [super initWithNibName:@"ResultChangeViewController" bundle:nil];
    if (self) {
        self.results = _results;
        self.record = masterRecord;
        self.vlHIV = [NSNumber numberWithFloat:-1.0];
        self.vlHepC = [NSNumber numberWithFloat:-1.0];
        self.cd4 = [NSNumber numberWithFloat:-1.0];
        self.cd4Percent = [NSNumber numberWithFloat:-1.0];

        if (nil != results.ViralLoad) {
            self.vlHIV = results.ViralLoad;
        }
        if (nil != results.CD4) {
            self.cd4 = results.CD4;
        }        
        if (nil != results.CD4Percent) {
            self.cd4Percent = results.CD4Percent;            
        }
        if (nil != results.HepCViralLoad) {
            self.vlHepC = results.HepCViralLoad;
        }
        if (nil != results.ResultsDate) {
            self.resultsDate = results.ResultsDate;
        }
        else {
            self.resultsDate = [NSDate date];
        }
    }
    return self;
}


- (void)dealloc
{
    /*
    [results release];
    [record release];
    [cd4 release];
    [cd4Percent release];
    [vlHIV release];
    [vlHepC release];
     */
    self.cd4 = nil;
    self.cd4Percent = nil;
    self.vlHIV = nil;
    self.vlHepC = nil;
    self.resultsDate = nil;
    self.changeDateCell = nil;
    [super dealloc];
}

- (IBAction) save:					(id) sender{
	NSManagedObjectContext *context = [results managedObjectContext];
    results.ResultsDate = self.resultsDate;
    results.CD4 = self.cd4;
    results.CD4Percent = self.cd4Percent;
    results.ViralLoad = self.vlHIV;
    results.HepCViralLoad = self.vlHepC;
    results.UID = [Utilities GUID];
    record.UID = [Utilities GUID];
    
	NSError *error = nil;
	if (![context save:&error]) {
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		abort();
	}
	
	[self dismissModalViewControllerAnimated:YES];
    
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
    datePicker.date = self.resultsDate;
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
	self.resultsDate = datePicker.date;
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
    [record removeResultsObject:results];
    NSManagedObjectContext *context = results.managedObjectContext;
    [context deleteObject:results];
    NSError *error = nil;
    if (![context save:&error]) {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Edit Result",@"Edit Result");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                            target:self action:@selector(showAlertView:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                            target:self action:@selector(save:)] autorelease];	
}

- (void)viewDidUnload
{
    self.cd4 = nil;
    self.cd4Percent = nil;
    self.vlHIV = nil;
    self.vlHepC = nil;
    self.resultsDate = nil;
    self.changeDateCell = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (0 == section) {
		return 1;
	}
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (2 == indexPath.section) {
        return 80;
    }
	return 48.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        [[dateCell title]setText:NSLocalizedString(@"Change", @"Change")];
        [[dateCell title]setTextColor:TEXTCOLOUR];
        self.changeDateCell = dateCell;
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
                if (0 < [self.cd4 intValue]) {
                    [[resultCell valueField]setText:[NSString stringWithFormat:@"%d",[self.cd4 intValue]]];
                    [[resultCell valueField]setTextColor:[UIColor blackColor]];
                }
                break;
            case 1:
                [[resultCell title]setText:NSLocalizedString(@"CD4 %", @"CD4 %")];
                if (0 < [self.cd4Percent floatValue]) {
                    [[resultCell valueField]setText:[NSString stringWithFormat:@"%2.1f",[self.cd4Percent floatValue]]];
                    [[resultCell valueField]setTextColor:[UIColor blackColor]];
                }
                break;
        }
        [resultCell setTag:tag];
        return resultCell;        
    }
    if (2 == indexPath.section) {
        int tag = indexPath.row + 10;
        
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
                [[segCell query]setText:NSLocalizedString(@"undetectable?",@"undetectable?")];
                [[segCell query]setTextColor:TEXTCOLOUR];
                if (40 <= [self.vlHIV intValue]) {
                    [[segCell valueField]setText:[NSString stringWithFormat:@"%d",[self.vlHIV intValue]]];
                    [[segCell valueField]setTextColor:[UIColor blackColor]];
                    [[segCell switchControl]setOn:FALSE];
                }
                if(0 <= [self.vlHIV intValue] && 40 > [self.vlHIV intValue]){
                    [[segCell valueField]setTextColor:[UIColor blackColor]];
                    [[segCell valueField]setText:NSLocalizedString(@"undetectable",@"undetectable")];
                    [[segCell valueField]setEnabled:NO];
                    [[segCell switchControl]setOn:TRUE];
                }
                if(0 > [self.vlHIV intValue]){
                    [[segCell valueField]setEnabled:YES];
                    [[segCell switchControl]setOn:FALSE];
                }
                break;
            case 1:
                [[segCell title]setText:NSLocalizedString(@"Viral Load HepC",@"Viral Load HepC")];
                [[segCell title]setTextColor:TEXTCOLOUR];
                [[segCell query]setText:NSLocalizedString(@"undetectable?",@"undetectable?")];
                [[segCell query]setTextColor:TEXTCOLOUR];
                if (40 <= [self.vlHepC intValue]) {
                    [[segCell valueField]setText:[NSString stringWithFormat:@"%d",[self.vlHepC intValue]]];
                    [[segCell valueField]setTextColor:[UIColor blackColor]];
                    [[segCell switchControl]setOn:FALSE];
                }
                if(0 <= [self.vlHepC intValue] && 40 > [self.vlHepC intValue]){
                    [[segCell valueField]setTextColor:[UIColor blackColor]];
                    [[segCell valueField]setText:NSLocalizedString(@"undetectable",@"undetectable")];
                    [[segCell valueField]setEnabled:NO];
                    [[segCell switchControl]setOn:TRUE];
                }
                if(0 > [self.vlHepC intValue]){
                    [[segCell valueField]setEnabled:NO];
                    [[segCell switchControl]setOn:TRUE];
                }
                break;
        }
        [segCell setTag:tag];
        return segCell;        
    }
    return nil;    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	if (0 == indexPath.section) {
		[self changeResultsDate];
	}
}

@end
