//
//  MedicationChangeTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedicationChangeTableViewController.h"
#import "MissedMedication.h"
#import "PreviousMedication.h"
#import "Medication.h"
#import "Utilities.h"
#import "GeneralSettings.h"
#import "SideEffects.h"
#import "SetDateCell.h"
#import "MoreResultsCell.h"
#import "GradientButton.h"

@interface MedicationChangeTableViewController ()
@property (nonatomic, strong) NSManagedObjectContext *context;
- (void)postNotification;
@end

@implementation MedicationChangeTableViewController

- (id)initWithMedication:(Medication *)medication context:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:@"MedicationChangeTableViewController" bundle:nil];
    if (self)
    {
        self.context = context;
        self.selectedMedication = medication;
        self.startDateChanged = NO;
        self.endDateChanged = NO;
        self.startDate = self.selectedMedication.StartDate;
        if (nil == self.startDate)
        {
            self.startDate = [NSDate date];
        }
        self.state = 0;
        self.medName = medication.Name;
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
    self.navigationItem.title = self.medName;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                            target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                            target:self action:@selector(save:)];	
}

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.startDate = nil;
    self.startDateCell = nil;
    self.endDateCell = nil;
    self.endDate = nil;
    self.medName = nil;
    [super viewDidUnload];
}
#endif
/**
 save the changes and/or dismiss
 */
- (IBAction) save:					(id) sender
{
    NSError *error = nil;
    if (self.startDateChanged)
    {
        self.selectedMedication.StartDate = self.startDate;
        self.selectedMedication.UID = [Utilities GUID];
        if (![self.selectedMedication.managedObjectContext save:&error])
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
        [self postNotification];
        [self dismissModalViewControllerAnimated:YES];
    }
    if (self.endDateChanged)
    {
        PreviousMedication *previousMed = [NSEntityDescription insertNewObjectForEntityForName:@"PreviousMedication" inManagedObjectContext:self.context];
        previousMed.uID = [Utilities GUID];
        previousMed.name = self.selectedMedication.Name;
        previousMed.startDate = self.selectedMedication.StartDate;
        previousMed.endDate = self.endDate;
        previousMed.isART = [NSNumber numberWithBool:YES];
        previousMed.drug = self.selectedMedication.Drug;
        if (![self.context save:&error])
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
        [self postNotification];
        [self removeSQLEntry];
    }
    
}

- (IBAction) cancel: (id) sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)postNotification
{
    NSNotification* refreshNotification =
    [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                  object:self
                                userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];

    NSNotification* animateNotification = [NSNotification
                                           notificationWithName:@"startAnimation"
                                           object:self
                                           userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:animateNotification];
}


/**
 shows the Alert view when user clicks the Trash button
 */
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

/**
 remove the medication from the database - only called after user confirms that we 
 really want to delete it
 */
- (void) removeSQLEntry
{
    [self.selectedMedication.managedObjectContext deleteObject:self.selectedMedication];
    NSError *error = nil;
    if (![self.selectedMedication.managedObjectContext save:&error])
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
    [self postNotification];
	[self dismissModalViewControllerAnimated:YES];
}




/**
 changes the start date for this medication
 */
- (void)changeDate
{
	NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",@"Set"), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
    if (self.state == 0)
    {
        datePicker.date = self.startDate;
    }
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];
}

/**
 sets the label and resultsdate to the one selected
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
#ifdef APPDEBUG
    NSLog(@"MedicationChangeTableViewController:actionSheet buttonIndex == %d",buttonIndex);
#endif	
    
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        switch (self.state)
        {
            case 0:
                self.startDate = datePicker.date;
                self.startDateChanged = YES;
                self.startDateCell.value.text = timestamp;
                break;
            case 1:
                self.endDate = datePicker.date;
                self.endDateCell.value.text = timestamp;
                self.endDateChanged = YES;
                break;
        }
    }
}


#pragma mark - Table view data source
/**
 3 sections in the table
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

/**
 each section has 1 row
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == section)
    {
        return NSLocalizedString(@"Treatment Start Date", @"Treatment Start Date");
    }
    else{
        return NSLocalizedString(@"Treatment End Date", @"Treatment End Date");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 10;
    if (1 == section)
    {
        height = 90;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = nil;
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    if (1 == section)
    {
        footerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 50);
        CGRect deleteFrame = CGRectMake(10, 10, tableView.bounds.size.width - 20 , 37);
        GradientButton *deleteButton = [[GradientButton alloc] initWithFrame:deleteFrame colour:Red title:NSLocalizedString(@"Delete", @"Delete")];
        [deleteButton addTarget:self action:@selector(showAlertView:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:deleteButton];
    }    
    return footerView;
}


/**
 configure the cells
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd MMM YY";
    if (0 == indexPath.section)
    {
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
        dateCell.value.text = [formatter stringFromDate:self.startDate];
        dateCell.tag = indexPath.row;
        dateCell.labelImageView.image = [UIImage imageNamed:@"appointments.png"];
        self.startDateCell= dateCell;
        return dateCell;
    }
    else
    {
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
        dateCell.value.text = @"----";
        dateCell.tag = indexPath.row;
        dateCell.labelImageView.image = [UIImage imageNamed:@"stop.png"];
        self.endDateCell= dateCell;
        return dateCell;        
    }
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        self.state = 0;
    }
    else
    {
        self.state = 1;
    }
    [self changeDate];
}

@end
