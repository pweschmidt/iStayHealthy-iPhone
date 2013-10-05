//
//  EditAppointmentsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditAppointmentsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
//#import "Appointments+Handling.h"
#import "Contacts+Handling.h"
#import "Utilities.h"
#import "UILabel+Standard.h"

@interface EditAppointmentsTableViewController ()
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSArray *clinics;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@end

@implementation EditAppointmentsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
     currentClinics:(NSArray *)currentClinics
      managedObject:(NSManagedObject *)managedObject
{
    self = [super initWithStyle:style managedObject:managedObject hasNumericalInput:NO];
    if (nil != self)
    {
        if (nil == currentClinics)
        {
            _clinics = [NSArray array];
        }
        else
        {
            _clinics = currentClinics;
        }
    }
    self.editMenu = @[kAppointmentClinic, kAppointmentNotes];
    self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isEditMode)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Appointment", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"New Appointment", nil);
    }
}

- (void)setDefaultValues
{
    if (!self.isEditMode)
    {
        return;
    }
    /**
    Appointments *appointment = (Appointments *)self.managedObject;
    int index = 0;
    for (NSNumber *key  in self.textViews.allKeys)
    {
        id viewObj = [self.textViews objectForKey:key];
        if (nil != viewObj && [viewObj isKindOfClass:[UITextField class]] &&
            index < self.editMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *type = [self.editMenu objectAtIndex:index];
            textField.text = [appointment valueStringForType:type];
            if ([textField.text isEqualToString:NSLocalizedString(@"Enter Value", nil)])
            {
                textField.textColor = [UIColor lightGrayColor];
            }
        }
        ++index;
    }
    */
}

- (void)save:(id)sender
{
    /**
    Appointments *appointment = nil;
    if (self.isEditMode)
    {
        appointment = (Appointments *)self.managedObject;
    }
    else
    {
        appointment = [[CoreDataManager sharedInstance] managedObjectForEntityName:kAppointments];
    }
    appointment.UID = [Utilities GUID];
    appointment.date = self.date;
    int index = 0;
    for (NSNumber *number in self.textViews.allKeys)
    {
        id viewObj = [self.textViews objectForKey:number];
        if (nil != viewObj && [viewObj isKindOfClass:[UITextField class]] &&
            index < self.editMenu.count)
        {
            UITextField *textField = (UITextField *)viewObj;
            NSString *valueString = textField.text;
            NSString *type = [self.editMenu objectAtIndex:index];
            [appointment addValueString:valueString type:type];
        }
        ++index;
    }
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContext:&error];
    */
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger resultsCount = self.editMenu.count;
    resultsCount++;
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = resultsCount;
        return ++numRows;
    }
    return resultsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (0 == indexPath.row)
    {
        identifier = [NSString stringWithFormat:kBaseDateCellRowIdentifier];
    }
    else
    {
        if ([self hasInlineDatePicker])
        {
            identifier = [NSString stringWithFormat:@"DatePickerCell"];
        }
        else
        {
            identifier = [NSString stringWithFormat:@"AppointmentCell"];
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    if (0 == indexPath.row)
    {
        [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
    }
    else
    {
        if ([self hasInlineDatePicker])
        {
            [self configureDatePickerCell:cell indexPath:indexPath];
        }
        else
        {
            NSUInteger titleIndex = (nil == self.datePickerIndexPath) ? indexPath.row - 1 : indexPath.row - 2;
            NSString *resultsString = [self.editMenu objectAtIndex:titleIndex];
            NSString *text = NSLocalizedString(resultsString, nil);
            [self configureTableCell:cell title:text indexPath:indexPath hasNumericalInput:YES];
        }
    }
    return cell;
}

@end
