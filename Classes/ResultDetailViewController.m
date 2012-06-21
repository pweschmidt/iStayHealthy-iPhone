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
@synthesize bloodpressure = _bloodpressure;


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
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                            target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                            target:self action:@selector(save:)];	
}


#pragma mark -
#pragma mark actions

/**
 when clicked it saves the entries for CD4 and Viral load to the database. then the view is dismissed
 @id
 */
- (IBAction) save: (id) sender{
	NSManagedObjectContext *context = [self.record managedObjectContext];
	Results *result = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:context];
	[self.record addResultsObject:result];
    self.record.UID = [Utilities GUID];
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
        case 102:
            self.glucose = number;
            break;
        case 103:
            self.cholesterol = number;
            break;
        case 104:
            self.hdl = number;
            break;
        case 105:
            self.ldl = number;
            break;
        case 106:
            self.weight = number;
            break;
        case 107:
            self.bloodpressure = valueString;
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
 @return 3 sections
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
    else if(1 == section){
        return 2;
    }
    else {
        return 8;
    }
}

/**
 for viralload we get more height as with have a togglebutton in there
 @tableView
 @indexPath
 @return height as CGFloat
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (1 == indexPath.section) {
        return 80;
    }
	return 48.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        return 10;
    }
    else {
        return 25;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 10)];
        sectionHeaderView.backgroundColor = [UIColor clearColor];
        return sectionHeaderView;
    }
    else {
        CGRect frame = CGRectMake(20, 20, 280, 25);
        UIView *sectionHeaderView = [[UIView alloc] initWithFrame:frame];
        CGRect colourCodeFrame = CGRectMake(20, 0, 10, 20);
        CGRect titleFrame = CGRectMake(35,0,255,25);
        
        UIView *colourCodeView = [[UIView alloc]initWithFrame:colourCodeFrame];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        switch (section) {
            case 1:
                colourCodeView.layer.backgroundColor = [UIColor blueColor].CGColor;
                titleLabel.text = NSLocalizedString(@"HIVResults", @"HIVResults");
                break;
            case 2:
                colourCodeView.layer.backgroundColor = [UIColor redColor].CGColor;
                titleLabel.text = NSLocalizedString(@"GeneralBloods", @"GeneralBloods");
                break;
        }
        
        [sectionHeaderView addSubview:colourCodeView];
        [sectionHeaderView addSubview:titleLabel];
        return sectionHeaderView;
    }
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
    if (2 == indexPath.section) {
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
        resultCell.inputTitle.textColor = TEXTCOLOUR;
        int row = indexPath.row;
        switch (row) {
            case 0:
                resultCell.inputTitle.text = NSLocalizedString(@"CD4 Count", @"CD4 Count");
                resultCell.inputValueKind = INTEGERINPUT;
                break;
            case 1:
                resultCell.inputTitle.text = NSLocalizedString(@"CD4 %", @"CD4 %");
                resultCell.inputValueKind = FLOATINPUT;
                break;
            case 2:
                resultCell.inputTitle.text = NSLocalizedString(@"Glucose", @"Glucose");
                resultCell.inputValueKind = FLOATINPUT;
                break;
            case 3:
                resultCell.inputTitle.text = NSLocalizedString(@"Total Cholesterol", @"Total Cholesterol");
                resultCell.inputValueKind = FLOATINPUT;
                break;
            case 4:
                resultCell.inputTitle.text = NSLocalizedString(@"HDL", @"HDL");
                resultCell.inputValueKind = FLOATINPUT;
                break;
            case 5:
                resultCell.inputTitle.text = NSLocalizedString(@"LDL", @"LDL");
                resultCell.inputValueKind = FLOATINPUT;
                break;
            case 6:
                resultCell.inputTitle.text = NSLocalizedString(@"Weight", @"Weight");
                resultCell.inputValueKind = FLOATINPUT;
                break;
            case 7:
                resultCell.inputTitle.text = NSLocalizedString(@"Blood Pressure", @"Blood Pressure");
                resultCell.inputValueKind = BLOODPRESSUREINPUT;
                break;
        }
        [resultCell setTag:tag];
        return resultCell;        
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


@end

