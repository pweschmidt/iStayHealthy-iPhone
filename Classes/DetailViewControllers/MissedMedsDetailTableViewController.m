//
//  MissedMedsDetailTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/08/2012.
//
//

#import "MissedMedsDetailTableViewController.h"
#import "iStayHealthyRecord.h"
#import "MissedMedication.h"
#import "SetDateCell.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "GradientButton.h"
#import "Utilities.h"
#import "Medication.h"
#import <QuartzCore/QuartzCore.h>

@interface MissedMedsDetailTableViewController ()
@property BOOL isEditMode;
@property (nonatomic, strong) NSMutableArray *currentMedArray;
@property (nonatomic, strong) NSString *currentMeds;
@property (nonatomic, strong) UITableViewCell *selectedCell;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSNumber *seriousnessIndex;
@property (nonatomic, strong) NSString *selectedReasonLabel;
@property (nonatomic, strong) NSArray *reasonArray;
@end

@implementation MissedMedsDetailTableViewController
@synthesize missedDate = _missedDate;
@synthesize record = _record;
@synthesize missedMeds = _missedMeds;
@synthesize setDateCell = _setDateCell;
@synthesize isEditMode = _isEditMode;
@synthesize currentMedArray = _currentMedArray;
@synthesize selectedCell = _selectedCell;
@synthesize formatter = _formatter;
@synthesize seriousnessIndex = _seriousnessIndex;
@synthesize selectedReasonLabel = _selectedReasonLabel;
@synthesize currentMeds = _currentMeds;
@synthesize reasonArray = _reasonArray;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithMissedMeds:(MissedMedication *)missed
            masterRecord:(iStayHealthyRecord *)masterRecord{
    self = [super initWithNibName:@"MissedMedsDetailTableViewController" bundle:nil];
    if (nil != self)
    {
        self.isEditMode = YES;
        self.missedMeds = missed;
        self.missedDate = self.missedMeds.MissedDate;
        self.currentMeds = self.missedMeds.Name;
        self.record = masterRecord;
        self.selectedCell = nil;
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateFormat = @"dd MMM YY";
        self.selectedReasonLabel = self.missedMeds.missedReason;
    }
    return self;
}

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord medication:(NSArray *)medArray{
    self = [super initWithNibName:@"MissedMedsDetailTableViewController" bundle:nil];
    if (nil != self)
    {
        self.isEditMode = NO;
        self.missedDate = [NSDate date];
        self.record = masterrecord;
        self.currentMedArray = [NSMutableArray arrayWithArray:medArray];
        NSMutableString *medsString = [NSMutableString string];
        for (Medication *med in self.currentMedArray) {
            [medsString appendFormat:@"%@ ",med.Name];
        }
        self.currentMeds = medsString;
        self.selectedCell = nil;
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateFormat = @"dd MMM YY";
        self.selectedReasonLabel = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.currentMeds;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];
    
    self.reasonArray = [NSArray arrayWithObjects:NSLocalizedString(@"Forgotten", @"Forgotton"),
                        NSLocalizedString(@"Ran out of meds", @"no meds"),
                        NSLocalizedString(@"Could not take the pills",@"Not possible to take"),
                        NSLocalizedString(@"Didn't want to take the meds",@"Didn't want to"),
                        NSLocalizedString(@"No particular reason",@"No reason"),nil];
}


- (IBAction) save:					(id) sender
{
    NSManagedObjectContext *context = nil;
    if (self.isEditMode)
    {
        context = [self.missedMeds managedObjectContext];
        self.missedMeds.MissedDate = self.missedDate;
        self.missedMeds.missedReason = self.selectedReasonLabel;
        self.missedMeds.UID = [Utilities GUID];
        self.record.UID = [Utilities GUID];
    }
    else
    {
        context = [self.record managedObjectContext];
        MissedMedication *newMissedMeds = [NSEntityDescription insertNewObjectForEntityForName:@"MissedMedication" inManagedObjectContext:context];
        [self.record addMissedMedicationsObject:newMissedMeds];
        self.record.UID = [Utilities GUID];
        newMissedMeds.UID = [Utilities GUID];
        newMissedMeds.missedReason = self.selectedReasonLabel;
        newMissedMeds.MissedDate = self.missedDate;
        NSMutableString *effectedDrugs = [NSMutableString string];
        for (Medication *med in self.currentMedArray) {
            NSString *name = med.Name;
            [effectedDrugs appendFormat:@"%@ ",name];
        }
        newMissedMeds.Name = effectedDrugs;
    }
    if (nil != context)
    {
        NSError *error = nil;
        if (![context save:&error])
        {
#ifdef APPDEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
                                        message:NSLocalizedString(@"Save error message", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil]
             show];
        }
    }
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel:				(id) sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)changeDate
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
	self.missedDate = datePicker.date;
}

- (IBAction) showAlertView:			(id) sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
    
    [alert show];
}

/**
 if user really wants to delete the entry call removeSQLEntry
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")])
    {
        [self removeSQLEntry];
    }
}


- (void)removeSQLEntry
{
    [self.record removeMissedMedicationsObject:self.missedMeds];
    NSManagedObjectContext *context = self.missedMeds.managedObjectContext;
    [context deleteObject:self.missedMeds];
    NSError *error = nil;
    if (![context save:&error])
    {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
                                    message:NSLocalizedString(@"Save error message", nil)
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles: nil]
         show];
    }
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else
    {
        return self.reasonArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section)
    {
        return 60;
    }
    else
    {
        return 48;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 10;
    if (1 == section)
    {
        height = 50;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = nil;
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    if (1 == section)
    {
        if (self.isEditMode)
        {
            footerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 50);
            CGRect deleteFrame = CGRectMake(10, 10, tableView.bounds.size.width - 20 , 37);
            GradientButton *deleteButton = [[GradientButton alloc] initWithFrame:deleteFrame colour:Red title:NSLocalizedString(@"Delete", @"Delete")];
            [deleteButton addTarget:self action:@selector(showAlertView:) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:deleteButton];
        }
    }
    
    return footerView;
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
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[SetDateCell class]])
                {
                    dateCell = (SetDateCell *)currentObject;
                    break;
                }
            }
        }
        dateCell.value.text = [formatter stringFromDate:self.missedDate];
        dateCell.tag = 1;
        dateCell.labelImageView.image = [UIImage imageNamed:@"appointments.png"];
        dateCell.title.textColor = TEXTCOLOUR;
        self.setDateCell = dateCell;
        return dateCell;
    }
    else
    {
        NSString *identifier = [NSString stringWithFormat:@"Row%d",indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.textLabel.textColor = TEXTCOLOUR;
        cell.textLabel.text = [self.reasonArray objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (self.isEditMode && nil != self.selectedReasonLabel)
        {
            if ([self.selectedReasonLabel isEqualToString:cell.textLabel.text])
            {
                self.selectedCell = cell;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (cell == self.selectedCell)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        return cell;
        
    }
    return nil;
}


#pragma mark - Table view delegate
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        [self changeDate];
    }
    else if (1 == indexPath.section)
    {
        if (nil != self.selectedCell)
        {
            self.selectedCell.accessoryType = UITableViewCellAccessoryNone;
            self.selectedCell = nil;
        }
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedCell = cell;
        self.selectedReasonLabel = cell.textLabel.text;
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        
    }
}

@end
