//
//  ProcedureDetailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import "ProcedureDetailViewController.h"
#import "Procedures.h"
#import "Utilities.h"
#import "SetDateCell.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "GradientButton.h"

@interface ProcedureDetailViewController ()
@property BOOL isEdit;
@end

@implementation ProcedureDetailViewController
@synthesize dateCell = _dateCell;
@synthesize startDate = _startDate;
@synthesize record = _record;
@synthesize name = _name;
@synthesize illness = _illness;
@synthesize procedures = _procedures;
@synthesize isEdit = _isEdit;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord
{
    self = [super initWithNibName:@"ProcedureDetailViewController" bundle:nil];
    if (nil != self)
    {
        self.isEdit = NO;
        self.record = masterrecord;
        self.startDate = [NSDate date];
    }
    return self;
}

- (id)initWithProcedure:(Procedures *)procedure masterRecord:(iStayHealthyRecord *)masterRecord
{
    self = [super initWithNibName:@"ProcedureDetailViewController" bundle:nil];
    if (nil != self)
    {
        self.isEdit = YES;
        self.procedures = procedure;
        self.record = masterRecord;
        self.startDate = procedure.Date;
        self.name = procedure.Name;
        self.illness = procedure.Illness;
    }
    return self;
    
}

- (IBAction) save:					(id) sender
{
	NSError *error = nil;
    NSManagedObjectContext *context = nil;
    if (self.isEdit)
    {
        context = [self.procedures managedObjectContext];
        self.record.UID = [Utilities GUID];
        self.procedures.UID = [Utilities GUID];
        self.procedures.Illness = self.illness;
        self.procedures.Name = self.name;
        self.procedures.Date = self.startDate;
    }
    else
    {
        context = [self.record managedObjectContext];
        Procedures *procedures = [NSEntityDescription insertNewObjectForEntityForName:@"Procedures" inManagedObjectContext:context];
        [self.record addProceduresObject:procedures];
        procedures.Date = self.startDate;
        procedures.Name = self.name;
        procedures.Illness = self.illness;
        procedures.UID = [Utilities GUID];
        self.record.UID = [Utilities GUID];
    }
    if (![context save:&error])
    {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel:				(id) sender
{
    [self dismissModalViewControllerAnimated:YES];    
}


- (void)changeStartDate
{
	NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set", nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
    datePicker.date = self.startDate;
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
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
	self.dateCell.value.text = timestamp;
	self.startDate = datePicker.date;
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


- (void) removeSQLEntry
{
    [self.record removeProceduresObject:self.procedures];
    NSManagedObjectContext *context = self.procedures.managedObjectContext;
    [context deleteObject:self.procedures];
    NSError *error = nil;
    if (![context save:&error])
    {
#ifdef APPDEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
	[self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isEdit)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Illness/Surgery",@"Edit Illness/Surgery");
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Illness/Surgery",nil);
    }
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section)
    {
        return 60;
    }
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.isEdit && 1 == section)
    {
        return 90;
    }
    else
    {
        return 10;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = nil;
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    if (self.isEdit && 1 == section)
    {
        footerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 50);
        CGRect deleteFrame = CGRectMake(10, 10, tableView.bounds.size.width - 20 , 37);
        GradientButton *deleteButton = [[GradientButton alloc] initWithFrame:deleteFrame colour:Red title:NSLocalizedString(@"Delete", @"Delete")];
        [deleteButton addTarget:self action:@selector(showAlertView:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:deleteButton];
    }
    
    return footerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd MMM YY";
        
        NSString *identifier = @"SetDateCell";
        SetDateCell *cell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[SetDateCell class]])
                {
                    cell = (SetDateCell *)currentObject;
                    break;
                }
            }
        }
        cell.value.text = [formatter stringFromDate:self.startDate];
        cell.tag = indexPath.row;
        cell.labelImageView.image = [UIImage imageNamed:@"appointments.png"];
        self.dateCell = cell;
        return cell;
    }
    else
    {
        NSString *identifier = @"ClinicAddressCell";
        ClinicAddressCell *clinicCell = (ClinicAddressCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == clinicCell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicAddressCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[ClinicAddressCell class]])
                {
                    clinicCell = (ClinicAddressCell *)currentObject;
                    break;
                }
            }
            [clinicCell setDelegate:self];
        }
        if (0 == indexPath.row)
        {
            clinicCell.title.text = NSLocalizedString(@"Surgery", @"Surgery");
            if (self.isEdit)
            {
                clinicCell.valueField.text = self.name;
            }
            else
            {
                clinicCell.valueField.text = NSLocalizedString(@"Enter Name", @"Enter Name");
                clinicCell.valueField.textColor = [UIColor lightGrayColor];
            }
        }
        if (1 == indexPath.row)
        {
            clinicCell.title.text = NSLocalizedString(@"Illness", @"Illness");
            if (self.isEdit)
            {
                clinicCell.valueField.text = self.illness;
            }
            else
            {
                clinicCell.valueField.text = NSLocalizedString(@"Enter Name", @"Enter Name");
                clinicCell.valueField.textColor = [UIColor lightGrayColor];                
            }
        }
        clinicCell.tag = indexPath.row + 10;
        return clinicCell;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            [self changeStartDate];
        }
    }
}

#pragma mark - ClinicAddressCellDelegate Protocol implementation
- (void)setValueString:(NSString *)valueString withTag:(int)tag{
    switch (tag)
    {
        case 10:
            self.name = valueString;
            break;
        case 11:
            self.illness = valueString;
            break;
    }
}
- (void)setUnitString:(NSString *)unitString{
    //nothing to do
}


@end
