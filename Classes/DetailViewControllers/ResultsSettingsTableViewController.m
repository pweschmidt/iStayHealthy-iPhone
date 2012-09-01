//
//  ResultsSettingsTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 09/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResultsSettingsTableViewController.h"
#import "iStayHealthyRecord.h"
#import "SetDateCell.h"
#import "SwitcherCell.h"
#import "GeneralSettings.h"
#import "UnitCell.h"

@interface ResultsSettingsTableViewController ()

@end

@implementation ResultsSettingsTableViewController
@synthesize setDateCell = _setDateCell;
@synthesize dateOfBirth = _dateOfBirth;
@synthesize smokerSwitch = _smokerSwitch;
@synthesize diabeticSwitch = _diabeticSwitch;
@synthesize record = _record;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithRecord:(iStayHealthyRecord *)masterRecord
{
    self = [super initWithNibName:@"ResultsSettingsTableViewController" bundle:nil];
    if (self)
    {
        self.record = masterRecord;            
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    self.dateOfBirth = nil;
    self.setDateCell = nil;
    self.record = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd MMM YY";
        
        NSString *identifier = @"SetDateCell";
        SetDateCell *dateCell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == dateCell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[SetDateCell class]])
                {
                    dateCell = (SetDateCell *)currentObject;
                    break;
                }
            }  
        }
        [[dateCell value]setText:[formatter stringFromDate:self.dateOfBirth]];
        [dateCell setTag:indexPath.row];
        dateCell.labelImageView.image = [UIImage imageNamed:@"appointments.png"];
        [dateCell setTag:1];
        self.setDateCell = dateCell;
        return dateCell;
    }
    if (1 == indexPath.section)
    {
        NSString *identifier = @"SwitcherCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:identifier];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+12.0, 112.0, 22.0);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = TEXTCOLOUR;
        label.textAlignment = UITextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:15.0];
        
        CGRect frameSwitch = CGRectMake(215.0, 10.0, 94.0, 27.0);
        UISwitch *switchEnabled = [[UISwitch alloc] initWithFrame:frameSwitch];
        switchEnabled.onTintColor = TINTCOLOUR;
        cell.accessoryView = switchEnabled;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (indexPath.row)
        {
            case 0:
                [label setText:NSLocalizedString(@"Smoker", @"Smoker")];
                [switchEnabled addTarget:self action:@selector(switchSmoker:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:label];
                self.smokerSwitch = switchEnabled;
                break;
            case 1:
                [label setText:NSLocalizedString(@"Diabetic", @"Diabetic")];
                [switchEnabled addTarget:self action:@selector(switchDiabetic:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:label];
                self.diabeticSwitch = switchEnabled;
                break;
        }
        
        return cell;
    }
    if (2 == indexPath.section)
    {
        NSString *identifier = @"UnitCell";
        UnitCell *unitCell = (UnitCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == unitCell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"UnitCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[UnitCell class]])
                {
                    unitCell = (UnitCell *)currentObject;
                    break;
                }
            } 
        }
        unitCell.unitTitle.textColor = TEXTCOLOUR;
        switch (indexPath.row)
        {
            case 0:
                unitCell.unitTitle.text = NSLocalizedString(@"Chol., Sugar Unit", @"unit for sugar/cholesterol");
                [unitCell.segControl setTitle:@"mmol/L" forSegmentAtIndex:0];
                [unitCell.segControl setTitle:@"mg/dL" forSegmentAtIndex:1];
                break;
            case 1:
                unitCell.unitTitle.text = NSLocalizedString(@"Weight Unit", @"unit for sugar/cholesterol");
                [unitCell.segControl setTitle:@"kg" forSegmentAtIndex:0];
                [unitCell.segControl setTitle:@"lb" forSegmentAtIndex:1];
                break;
        }
        
        
        return unitCell;
    }
    
        
    
    return nil;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)switchSmoker:(id)sender
{
    
}

- (IBAction)switchDiabetic:(id)sender
{
    
}

- (void)changeDateOfBirth
{
	NSString *title =  @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set", nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    self.setDateCell.value.text = timestamp;
	self.dateOfBirth = datePicker.date;
}


@end
