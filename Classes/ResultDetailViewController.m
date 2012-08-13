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
#import "PressureCell.h"
#import "ResultSegmentedCell.h"
#import "GeneralSettings.h"
#import "MoreResultsCell.h"
#import "ChartSettings.h"
#import <QuartzCore/QuartzCore.h>

@implementation ResultDetailViewController
@synthesize resultsDate = _resultsDate;
@synthesize setDateCell = _setDateCell;
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
@synthesize hemoglobulin = _hemoglobulin;
@synthesize whiteCells = _whiteCells;
@synthesize redCells = _redCells;
@synthesize platelets = _platelets;
@synthesize resultsSegmentControl = _resultsSegmentControl;

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
        self.glucose = [NSNumber numberWithFloat:-1.0];
        self.cholesterol = [NSNumber numberWithFloat:-1.0];
        self.hdl = [NSNumber numberWithFloat:-1.0];
        self.ldl = [NSNumber numberWithFloat:-1.0];
        self.weight = [NSNumber numberWithFloat:-1.0];
        self.systole = [NSNumber numberWithFloat:-1.0];
        self.diastole = [NSNumber numberWithFloat:-1.0];
        self.hemoglobulin = [NSNumber numberWithFloat:-1.0];
        self.whiteCells = [NSNumber numberWithFloat:-1.0];
        self.redCells = [NSNumber numberWithFloat:-1.0];
        self.platelets = [NSNumber numberWithFloat:-1.0];
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
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                            target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
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


#pragma mark -
#pragma mark actions

/**
 when clicked it saves the entries for CD4 and Viral load to the database. then the view is dismissed
 @id
 */
- (IBAction) save: (id) sender{
    NSManagedObjectContext *context = [self.record managedObjectContext];
    Results *results = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:context];
	[self.record addResultsObject:results];
    self.record.UID = [Utilities GUID];
    results.UID = [Utilities GUID];
    results.ResultsDate = self.resultsDate;
    results.ViralLoad = self.vlHIV;
    results.HepCViralLoad = self.vlHepC;
    results.CD4 = self.cd4;
    results.CD4Percent = self.cd4Percent;
    results.Systole = self.systole;
    results.Diastole = self.diastole;
    results.Weight = self.weight;
    results.Glucose = self.glucose;
    results.TotalCholesterol = self.cholesterol;
    results.HDL = self.hdl;
    results.LDL = self.ldl;
    results.Hemoglobulin = self.hemoglobulin;
    results.WhiteBloodCellCount = self.whiteCells;
    results.PlateletCount = self.platelets;
//TODO - add to data model    results.RedBloodCellCount = self.redCells;
    
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


#pragma mark -
#pragma mark Table view data source
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        dateCell.value.text = [formatter stringFromDate:self.resultsDate];
        dateCell.tag = 1;
        dateCell.title.text = NSLocalizedString(@"Set Date", @"Set Date");
        dateCell.title.textColor = TEXTCOLOUR;
        self.setDateCell = dateCell;
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
        resultCell.inputTitle.textColor = TEXTCOLOUR;
        
        int row = indexPath.row;
        if (0 == self.resultsSegmentControl.selectedSegmentIndex) {
            tag = indexPath.row + 100;
            resultCell.colourCodeView.backgroundColor = DARK_YELLOW;
            resultCell.colourCodeView.layer.cornerRadius = 5;
            resultCell.tag = tag;
            switch (row) {
                case 0:
                    resultCell.inputTitle.text = NSLocalizedString(@"CD4 Count", @"CD4 Count");
                    resultCell.inputValueKind = INTEGERINPUT;
                    break;
                case 1:
                    resultCell.inputTitle.text = NSLocalizedString(@"CD4 %", @"CD4 %");
                    resultCell.inputValueKind = FLOATINPUT;
                    break;
            }
        }
        else if (1 == self.resultsSegmentControl.selectedSegmentIndex){
            tag = indexPath.row + 1000;
            resultCell.colourCodeView.backgroundColor = DARK_RED;
            resultCell.colourCodeView.layer.cornerRadius = 5;
            resultCell.tag = tag;
            switch (row) {
                case 0:
                    resultCell.inputTitle.text = NSLocalizedString(@"Glucose", @"Glucose");
                    resultCell.inputValueKind = INTEGERINPUT;
                    break;
                case 1:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"Total Cholesterol", @"Total Cholesterol");
                    resultCell.inputValueKind = FLOATINPUT;
                    break;
                }
                case 2:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"HDL", @"HDL");
                    resultCell.inputValueKind = FLOATINPUT;
                    break;
                }
                case 3:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"LDL", @"LDL");
                    resultCell.inputValueKind = FLOATINPUT;
                    break;
                }
            }
        }
        else{
            tag = indexPath.row + 100000;
            resultCell.colourCodeView.backgroundColor = DARK_GREEN;
            resultCell.colourCodeView.layer.cornerRadius = 5;
            resultCell.inputTitle.text = NSLocalizedString(@"Weight", @"Weight");
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
                    segCell.inputTitle.text = NSLocalizedString(@"Viral Load",@"Viral Load");
                    segCell.inputValueField.enabled = NO;
                    [segCell.switchControl setOn:FALSE];
                    break;
                case 1:
                    segCell.inputTitle.text = NSLocalizedString(@"Viral Load HepC",@"Viral Load HepC");
                    segCell.inputValueField.enabled = YES;
                    [segCell.switchControl setOn:TRUE];
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
                    break;
                }
                case 1:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"White Blood Cells", @"White Blood Cells");
                    resultCell.inputValueKind = FLOATINPUT;
                    break;
                }
                case 2:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"Red Blood Cells", @"Red Blood Cells");
                    resultCell.inputValueKind = FLOATINPUT;
                    break;
                }
                case 3:
                {
                    resultCell.inputTitle.text = NSLocalizedString(@"Platelets", @"Platelets");
                    resultCell.inputValueKind = FLOATINPUT;
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
            pressureCell.colourCodeView.backgroundColor = DARK_GREEN;
            pressureCell.colourCodeView.layer.cornerRadius = 5;
            [pressureCell setDelegate:self];
            return pressureCell;
            
        }
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


/*
#pragma mark - delegate methods
- (void)setResultString:(NSString *)valueString forTag:(NSInteger)tag{
    [self setValueString:valueString withTag:tag];
}
*/

- (void)setSystole:(NSString *)systole diastole:(NSString *)diastole{
    self.systole = [self valueFromString:systole];
    self.diastole = [self valueFromString:diastole];
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
    self.glucose = nil;
    self.cholesterol = nil;
    self.hdl = nil;
    self.ldl = nil;
    self.weight = nil;
    self.systole = nil;
    self.diastole = nil;
    self.hemoglobulin = nil;
    self.whiteCells = nil;
    self.redCells = nil;
    self.platelets = nil;
	[super viewDidUnload];
}

/**
 dealloc
 */


@end

