//
//  EditPreviousMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 02/10/2013.
//
//

#import "EditPreviousMedsTableViewController.h"
#import "UITableViewCell+Extras.h"
#import "NSDate+Extras.h"
#import "Medication+Handling.h"
#import "PreviousMedication+Handling.h"
#import "UILabel+Standard.h"
#import "Utilities.h"
#import "iStayHealthy-Swift.h"

@interface EditPreviousMedsTableViewController ()
@property (nonatomic, strong) NSDate *origEndDate;
@end

@implementation EditPreviousMedsTableViewController
- (id)  initWithStyle:(UITableViewStyle)style
        managedObject:(NSManagedObject *)managedObject
    hasNumericalInput:(BOOL)hasNumericalInput
{
    self = [super initWithStyle:style managedObject:managedObject hasNumericalInput:hasNumericalInput];
    if (nil != self)
    {
        [self populateDates];
    }
    return self;
}

- (void)populateDates
{
    if (nil == self.managedObject)
    {
        return;
    }
    PreviousMedication *med = (PreviousMedication *) self.managedObject;
    self.date = med.startDate;
    self.endDate = med.endDate;
    self.origEndDate = med.endDate;
    self.endDateIsSet = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)save:(id)sender
{
    BOOL nothingToDo = NO;

    if (nil == self.managedObject)
    {
        nothingToDo = YES;
    }
    if (!self.dateIsChanged && ([self.endDate compare:self.origEndDate] == NSOrderedSame))
    {
        nothingToDo = YES;
    }
    if (nothingToDo)
    {
        [PWESAlertHandler.alertHandler
         showAlertViewWithOKButton:NSLocalizedString(@"Nothing to save", nil)
         message:NSLocalizedString(@"There is nothing to save", nil)
         presentingController:self];
    }
    else
    {
        PreviousMedication *med = (PreviousMedication *) self.managedObject;
        med.uID = [Utilities GUID];
        med.startDate = self.date;
        med.endDate = self.endDate;
        PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
        NSError *error = nil;
        [manager saveContextAndReturnError:&error];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : 44);
    }
    else
    {
        return ([self indexPathHasEndDatePicker:indexPath] ? kBaseDateCellRowHeight : 44);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return ([self hasInlineDatePicker] ? 2 : 1);
    }
    else
    {
        return ([self hasInlineEndDatePicker] ? 2 : 1);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = (0 == indexPath.section) ? kBaseDateCellRowIdentifier : kEndDateCellRowIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    if (0 == indexPath.row)
    {
        if (0 == indexPath.section)
        {
            [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
        }
        else
        {
            [self configureEndDateCell:cell indexPath:indexPath dateType:DateOnly];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];

    headerView.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [UILabel standardLabel];
    headerLabel.frame = CGRectMake(20, 0, headerView.frame.size.width - 40, headerView.frame.size.height);
    if (0 == section)
    {
        headerLabel.text = NSLocalizedString(@"Start Date", nil);
    }
    else
    {
        headerLabel.text = NSLocalizedString(@"End Date", nil);
    }
    [headerView addSubview:headerLabel];
    return headerView;
}

@end
