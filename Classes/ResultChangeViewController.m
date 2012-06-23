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
#import "MoreResultsCell.h"
#import "ResultSegmentedCell.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "MoreOtherResultsViewController.h"
#import "MoreBloodResultsViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ResultChangeViewController
@synthesize resultsDate = _resultsDate;
@synthesize results = _results;
@synthesize record = _record;
@synthesize vlHIV = _vlHIV;
@synthesize vlHepC = _vlHepC;
@synthesize cd4 = _cd4;
@synthesize cd4Percent = _cd4Percent;
@synthesize glucose = _glucose;
@synthesize ldl = _ldl;
@synthesize hdl = _hdl;
@synthesize cholesterol = _cholesterol;
@synthesize weight = _weight;
@synthesize systole = _systole;
@synthesize diastole = _diastole;
@synthesize changeDateCell = _changeDateCell;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithResults:(Results *)storedResults withMasterRecord:(iStayHealthyRecord *)masterRecord{
    self = [super initWithNibName:@"ResultChangeViewController" bundle:nil];
    if (self) {
        self.results = storedResults;
        self.record = masterRecord;
        self.vlHIV = [NSNumber numberWithFloat:-1.0];
        self.vlHepC = [NSNumber numberWithFloat:-1.0];
        self.cd4 = [NSNumber numberWithFloat:-1.0];
        self.cd4Percent = [NSNumber numberWithFloat:-1.0];
        self.glucose = [NSNumber numberWithFloat:-1.0];
        self.cholesterol = [NSNumber numberWithFloat:-1.0];
        self.hdl = [NSNumber numberWithFloat:-1.0];
        self.ldl = [NSNumber numberWithFloat:-1.0];
        self.weight = [NSNumber numberWithFloat:-1.0];
        self.systole = [NSNumber numberWithFloat:-1.0];
        self.diastole = [NSNumber numberWithFloat:-1.0];
        self.resultsDate = [NSDate date];

        if (nil != self.results.ViralLoad) {
            self.vlHIV = self.results.ViralLoad;
        }
        if (nil != self.results.CD4) {
            self.cd4 = self.results.CD4;
        }        
        if (nil != self.results.CD4Percent) {
            self.cd4Percent = self.results.CD4Percent;            
        }
        if (nil != self.results.HepCViralLoad) {
            self.vlHepC = self.results.HepCViralLoad;
        }
        if (nil != self.results.ResultsDate) {
            self.resultsDate = self.results.ResultsDate;
        }
        if (nil != self.results.Glucose) {
            self.glucose = self.results.Glucose;
        }
        if (nil != self.results.TotalCholesterol) {
            self.cholesterol = self.results.TotalCholesterol;
        }
        if (nil != self.results.HDL) {
            self.hdl = self.results.HDL;
        }
        if (nil != self.results.LDL) {
            self.ldl = self.results.LDL;
        }
        if (nil != self.results.Weight) {
            self.weight = self.results.Weight;
        }
        if (nil != self.results.Systole) {
            self.systole = self.results.Systole;
        }
        if (nil != self.results.Diastole) {
            self.diastole = self.results.Diastole;
        }
        else {
        }
    }
    return self;
}



- (IBAction) save:					(id) sender{
	NSManagedObjectContext *context = [self.results managedObjectContext];
    self.results.ResultsDate = self.resultsDate;
    self.results.CD4 = self.cd4;
    self.results.CD4Percent = self.cd4Percent;
    self.results.ViralLoad = self.vlHIV;
    self.results.HepCViralLoad = self.vlHepC;
    self.results.Systole = self.systole;
    self.results.Diastole = self.diastole;
    self.results.Weight = self.weight;
    self.results.Glucose = self.glucose;
    self.results.TotalCholesterol = self.cholesterol;
    self.results.HDL = self.hdl;
    self.results.LDL = self.ldl;
    self.results.UID = [Utilities GUID];
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
        case 1000:
            self.glucose = number;
            break;
        case 1001:
            self.cholesterol = number;
            break;
        case 1002:
            self.hdl = number;
            break;
        case 1003:
            self.ldl = number;
            break;
        case 100000:
            self.weight = number;
            break;
        case 11000:
            self.systole = number;
            break;
        case 12000:
            self.diastole = number;
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
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set", nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
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
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    self.changeDateCell.value.text = timestamp;
	self.resultsDate = datePicker.date;
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


- (void) removeSQLEntry{
    [self.record removeResultsObject:self.results];
    NSManagedObjectContext *context = self.results.managedObjectContext;
    [context deleteObject:self.results];
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
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                            target:self action:@selector(showAlertView:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                            target:self action:@selector(save:)];	
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (0 == section) {
		return 1;
	}
    else if(1 == section){
        return 2;
    }
    else if(2 == section){
        return 2;
    }
    else{
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (2 == indexPath.section) {
        return 69;
    }
    else if (2 > indexPath.section ){
        return 48;
    }
    else {
        return 44;
    }
    
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
        [[resultCell inputTitle]setTextColor:TEXTCOLOUR];
        int row = indexPath.row;
        switch (row) {
            case 0:
                [[resultCell inputTitle]setText:NSLocalizedString(@"CD4 Count", @"CD4 Count")];
                if (0 < [self.cd4 intValue]) {
                    [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%d",[self.cd4 intValue]]];
                    [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                }
                break;
            case 1:
                [[resultCell inputTitle]setText:NSLocalizedString(@"CD4 %", @"CD4 %")];
                if (0 < [self.cd4Percent floatValue]) {
                    [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.cd4Percent floatValue]]];
                    [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                }
                break;
        }
        resultCell.colourCodeView.layer.cornerRadius = 5;
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
        segCell.colourCodeView.layer.cornerRadius = 5;
        int row = indexPath.row;
        switch (row) {
            case 0:
                [[segCell inputTitle]setText:NSLocalizedString(@"Viral Load",@"Viral Load")];
                [[segCell inputTitle]setTextColor:TEXTCOLOUR];
                [[segCell query]setText:NSLocalizedString(@"undetectable?",@"undetectable?")];
                [[segCell query]setTextColor:TEXTCOLOUR];
                if (40 <= [self.vlHIV intValue]) {
                    [[segCell inputValueField]setText:[NSString stringWithFormat:@"%d",[self.vlHIV intValue]]];
                    [[segCell inputValueField]setTextColor:[UIColor blackColor]];
                    [[segCell switchControl]setOn:FALSE];
                }
                if(0 <= [self.vlHIV intValue] && 40 > [self.vlHIV intValue]){
                    [[segCell inputValueField]setTextColor:[UIColor blackColor]];
                    [[segCell inputValueField]setText:NSLocalizedString(@"undetectable",@"undetectable")];
                    [[segCell inputValueField]setEnabled:NO];
                    [[segCell switchControl]setOn:TRUE];
                }
                if(0 > [self.vlHIV intValue]){
                    [[segCell inputValueField]setEnabled:YES];
                    [[segCell switchControl]setOn:FALSE];
                }
                break;
            case 1:
                [[segCell inputTitle]setText:NSLocalizedString(@"Viral Load HepC",@"Viral Load HepC")];
                [[segCell inputTitle]setTextColor:TEXTCOLOUR];
                [[segCell query]setText:NSLocalizedString(@"undetectable?",@"undetectable?")];
                [[segCell query]setTextColor:TEXTCOLOUR];
                if (40 <= [self.vlHepC intValue]) {
                    [[segCell inputValueField]setText:[NSString stringWithFormat:@"%d",[self.vlHepC intValue]]];
                    [[segCell inputValueField]setTextColor:[UIColor blackColor]];
                    [[segCell switchControl]setOn:FALSE];
                }
                if(0 <= [self.vlHepC intValue] && 40 > [self.vlHepC intValue]){
                    [[segCell inputValueField]setTextColor:[UIColor blackColor]];
                    [[segCell inputValueField]setText:NSLocalizedString(@"undetectable",@"undetectable")];
                    [[segCell inputValueField]setEnabled:NO];
                    [[segCell switchControl]setOn:TRUE];
                }
                if(0 > [self.vlHepC intValue]){
                    [[segCell inputValueField]setEnabled:NO];
                    [[segCell switchControl]setOn:TRUE];
                }
                break;
        }
        [segCell setTag:tag];
        return segCell;        
    }
    if (3 == indexPath.section) {
        NSString *identifier = @"MoreResultsCell";
        MoreResultsCell *moreResultsCell = (MoreResultsCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == moreResultsCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"MoreResultsCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[MoreResultsCell class]]) {
                    moreResultsCell = (MoreResultsCell *)currentObject;
                    break;
                }
            } 
        }
        moreResultsCell.moreTitleLabel.textColor = TEXTCOLOUR;
        moreResultsCell.hasMoreLabel.text = @"";
        moreResultsCell.colourCodeView.layer.cornerRadius = 5;
        if (0 == indexPath.row) 
        {
            moreResultsCell.moreTitleLabel.text = @"More Blood Results";
            moreResultsCell.colourCodeView.backgroundColor = DARK_RED;
        }
        else 
        {
            moreResultsCell.moreTitleLabel.text = @"More Other Results";
            moreResultsCell.colourCodeView.backgroundColor = DARK_GREEN;
        }
        return moreResultsCell;
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
    if (3 == indexPath.section) 
    {
        if (0 == indexPath.row) 
        {
            NSArray *keys = [NSArray arrayWithObjects:@"glucose", @"cholesterol", @"hdl", @"ldl", nil];
            NSArray *values = [NSArray arrayWithObjects:self.glucose, self.cholesterol, self.hdl, self.ldl, nil];
            NSDictionary *resultsDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
            MoreBloodResultsViewController *bloodController = [[MoreBloodResultsViewController alloc] initWithResults:resultsDictionary];
            [bloodController setResultDelegate:self];
            [self.navigationController pushViewController:bloodController animated:YES];
        }
        else 
        {
            NSArray *keys = [NSArray arrayWithObjects:@"weight", @"systole", @"diastole", nil];
            NSArray *values = [NSArray arrayWithObjects:self.weight, self.systole, self.diastole,nil];
            NSDictionary *resultsDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
            MoreOtherResultsViewController *otherController = [[MoreOtherResultsViewController alloc] initWithResults:resultsDictionary systoleTag:11000 diastoleTag:12000];
            [otherController setResultDelegate:self];
            [self.navigationController pushViewController:otherController animated:YES];
        }
    }
}

#pragma mark - delegate methods

- (void)setResultString:(NSString *)valueString forTag:(NSInteger)tag{
    [self setValueString:valueString withTag:tag];
}


@end
