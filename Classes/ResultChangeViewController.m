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
@synthesize hemoglobulin = _hemoglobulin;
@synthesize whiteCells = _whiteCells;
@synthesize redCells = _redCells;
@synthesize platelets = _platelets;
@synthesize resultsSegmentControl = _resultsSegmentControl;


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
        self.hemoglobulin = [NSNumber numberWithFloat:-1.0];
        self.whiteCells = [NSNumber numberWithFloat:-1.0];
        self.redCells = [NSNumber numberWithFloat:-1.0];
        self.platelets = [NSNumber numberWithFloat:-1.0];

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
        if (nil != self.results.Hemoglobulin) {
            self.hemoglobulin = self.results.Hemoglobulin;
        }
        if (nil != self.results.WhiteBloodCellCount) {
            self.whiteCells = self.results.WhiteBloodCellCount;
        }
        if (nil != self.results.PlateletCount) {
            self.platelets = self.results.PlateletCount;
        }
//        if (nil != self.results.RedBloodCellCount) {
//            self.redCells = self.results.RedBloodCellCount;
//        }
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
    self.results.Hemoglobulin = self.hemoglobulin;
    self.results.WhiteBloodCellCount = self.whiteCells;
    self.results.PlateletCount = self.platelets;
    self.results.UID = [Utilities GUID];
    //self.results.RedBloodCellCount = self.redCells;
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
        case 1004:
            self.hemoglobulin = number;
            break;
        case 1005:
            self.whiteCells = number;
            break;
        case 1006:
            self.redCells = number;
            break;
        case 1007:
            self.platelets = number;
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
    NSArray *segmentArray = [NSArray arrayWithObjects:NSLocalizedString(@"HIV Results", nil), NSLocalizedString(@"Blood Results", nil), NSLocalizedString(@"Other Results", nil), nil];
    
    self.resultsSegmentControl = [[UISegmentedControl alloc] initWithItems:segmentArray];
    
    CGFloat width = self.tableView.bounds.size.width;
    CGFloat segmentWidth = width - 2 * 20;
    self.resultsSegmentControl.frame = CGRectMake(20, 3, segmentWidth, 30);
    self.resultsSegmentControl.tintColor = TINTCOLOUR;
    self.resultsSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.resultsSegmentControl.selectedSegmentIndex = 0;
    [self.resultsSegmentControl addTarget:self action:@selector(indexDidChangeForSegment) forControlEvents:UIControlEventValueChanged];
}

- (void)indexDidChangeForSegment{
    [self.tableView reloadData];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (0 == section) {
		return 1;
	}
    else if(1 == section){
        if (0 == self.resultsSegmentControl.selectedSegmentIndex) {
            return 2;
        }
        else if (1 == self.resultsSegmentControl.selectedSegmentIndex)
        {
            return 4;
        }
        else{
            return 1;
        }
    }
    else{
        if (0 == self.resultsSegmentControl.selectedSegmentIndex) {
            return 2;
        }
        else if (1 == self.resultsSegmentControl.selectedSegmentIndex)
        {
            return 4;
        }
        else{
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) {
        return 44;
    }
    else{
        if (0 == self.resultsSegmentControl.selectedSegmentIndex && 2 == indexPath.section) {
            return 69;
        }
        else{
            return 48;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (1 == section) {
        return 40;
    }
    else
        return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = nil;
    if (1 == section) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
        [headerView addSubview:self.resultsSegmentControl];
    }
    else{
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    }
    return headerView;
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
        int tag = 0;
        
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
        if (0 == self.resultsSegmentControl.selectedSegmentIndex) {
            tag = indexPath.row + 100;
            resultCell.colourCodeView.backgroundColor = DARK_YELLOW;
            resultCell.colourCodeView.layer.cornerRadius = 5;
            switch (row) {
                case 0:
                    resultCell.inputTitle.text = NSLocalizedString(@"CD4 Count", @"CD4 Count");
                    if (0 < [self.cd4 intValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%d",[self.cd4 intValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    resultCell.inputValueKind = INTEGERINPUT;
                    break;
                case 1:
                    resultCell.inputTitle.text = NSLocalizedString(@"CD4 %", @"CD4 %");
                    if (0 < [self.cd4Percent floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.cd4Percent floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    resultCell.inputValueKind = FLOATINPUT;
                    break;
            }
        }
        else if (1 == self.resultsSegmentControl.selectedSegmentIndex){
            tag = indexPath.row + 1000;
            resultCell.colourCodeView.backgroundColor = DARK_RED;
            resultCell.colourCodeView.layer.cornerRadius = 5;
            switch (row) {
                case 0:
                    resultCell.inputTitle.text = NSLocalizedString(@"Glucose", @"Glucose");
                    resultCell.inputValueKind = INTEGERINPUT;
                    if (0 < [self.glucose floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.glucose floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    break;
                case 1:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"Total Cholesterol", @"Total Cholesterol");
                    resultCell.inputValueKind = FLOATINPUT;
                    if (0 < [self.cholesterol floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.cholesterol floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    break;
                }
                case 2:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"HDL", @"HDL");
                    resultCell.inputValueKind = FLOATINPUT;
                    if (0 < [self.hdl floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.hdl floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    break;
                }
                case 3:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"LDL", @"LDL");
                    resultCell.inputValueKind = FLOATINPUT;
                    if (0 < [self.ldl floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.ldl floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    break;
                }
            }
        }
        else{
            tag = indexPath.row + 100000;
            resultCell.colourCodeView.backgroundColor = DARK_GREEN;
            resultCell.colourCodeView.layer.cornerRadius = 5;
            resultCell.inputTitle.text = NSLocalizedString(@"Weight", @"Weight");
            if (0 < [self.weight floatValue]) {
                [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.weight floatValue]]];
                [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
            }
            resultCell.inputValueKind = FLOATINPUT;
            resultCell.tag = tag;
        }
        return resultCell;        
    }
    if (2 == indexPath.section) {
        
        if (0 == self.resultsSegmentControl.selectedSegmentIndex) {
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
            segCell.inputValueKind = INTEGERINPUT;
            segCell.inputTitle.textColor = TEXTCOLOUR;
            segCell.query.text = NSLocalizedString(@"undetectable?",@"undetectable?");
            segCell.query.textColor = TEXTCOLOUR;
            segCell.colourCodeView.backgroundColor = DARK_BLUE;
            segCell.colourCodeView.layer.cornerRadius = 5;
            segCell.tag = tag;
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
            return segCell;
        }
        else if (1 == self.resultsSegmentControl.selectedSegmentIndex){
            int tag = indexPath.row + 1004;
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
            resultCell.inputTitle.textColor = TEXTCOLOUR;
            resultCell.colourCodeView.backgroundColor = DARK_RED;
            resultCell.colourCodeView.layer.cornerRadius = 5;
            resultCell.tag = tag;
            int row = indexPath.row;
            switch (row) {
                case 0:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"Hemoglobulin", @"Hemoglobulin");
                    resultCell.inputValueKind = FLOATINPUT;
                    if (0 < [self.hemoglobulin floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.hemoglobulin floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    break;
                }
                case 1:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"White Blood Cells", @"White Blood Cells");
                    resultCell.inputValueKind = FLOATINPUT;
                    if (0 < [self.whiteCells floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.whiteCells floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    break;
                }
                case 2:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"Red Blood Cells", @"Red Blood Cells");
                    resultCell.inputValueKind = FLOATINPUT;
                    if (0 < [self.redCells floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.redCells floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    break;
                }
                case 3:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"Platelets", @"Platelets");
                    resultCell.inputValueKind = FLOATINPUT;
                    if (0 < [self.platelets floatValue]) {
                        [[resultCell inputValueField]setText:[NSString stringWithFormat:@"%2.1f",[self.platelets floatValue]]];
                        [[resultCell inputValueField]setTextColor:[UIColor blackColor]];
                    }
                    break;
                }
            }
            return resultCell;
        }
        else{//other results
            NSString *identifier = @"PressureCell";
            PressureCell *pressureCell = (PressureCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (nil == pressureCell) {
                NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"PressureCell" owner:self options:nil];
                for (id currentObject in cellObjects) {
                    if ([currentObject isKindOfClass:[PressureCell class]]) {
                        pressureCell = (PressureCell *)currentObject;
                        break;
                    }
                }
                [pressureCell setDelegate:self];
            }
            pressureCell.pressureLabel.textColor = TEXTCOLOUR;
            pressureCell.pressureLabel.text = NSLocalizedString(@"Blood Pressure", @"Blood Pressure");
            pressureCell.systoleField.tag = 11000;
            pressureCell.diastoleField.tag = 12000;
            
            if (0 < [self.systole intValue] && 0 < [self.diastole intValue]) {
                pressureCell.systoleField.text = [NSString stringWithFormat:@"%d",[self.systole intValue]];
                pressureCell.diastoleField.text = [NSString stringWithFormat:@"%d",[self.diastole intValue]];
            }
            
            pressureCell.colourCodeView.backgroundColor = DARK_GREEN;
            pressureCell.colourCodeView.layer.cornerRadius = 5;
            [pressureCell setDelegate:self];
            return pressureCell;
            
        }
        
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

#pragma mark - delegate methods


- (void)setSystole:(NSString *)systole diastole:(NSString *)diastole{
    self.systole = [self valueFromString:systole];
    self.diastole = [self valueFromString:diastole];
}

@end
