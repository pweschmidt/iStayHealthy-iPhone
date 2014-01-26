//
//  EditSeinfeldCalendarTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/01/2014.
//
//

#import "EditSeinfeldCalendarTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "SeinfeldCalendar.h"
#import "UILabel+Standard.h"
#import "Utilities.h"
#import "StarView.h"

@interface EditSeinfeldCalendarTableViewController ()
@property (nonatomic, strong) UISegmentedControl *calendarSegmentControl;
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) NSMutableArray *completedCalendars;
@property (nonatomic, strong) SeinfeldCalendar *currentCalendar;
@property (nonatomic, assign) BOOL hasCalendarRunning;
@property (nonatomic, strong) NSDate *endDate;
@end

@implementation EditSeinfeldCalendarTableViewController

- (id)initWithStyle:(UITableViewStyle)style calendars:(NSArray *)calendars
{
    self = [super initWithStyle:style managedObject:nil hasNumericalInput:NO];
    if (nil != self)
    {
        _calendars = calendars;
        _currentCalendar = nil;
        _endDate = nil;
        _hasCalendarRunning = NO;
    }
    return self;
}

- (void)populateCalendars
{
    if (nil == self.calendars || 0 == self.calendars.count)
    {
        self.completedCalendars = [NSMutableArray array];
        return;
    }
    for (SeinfeldCalendar *calendar in self.calendars)
    {
        if (YES == [calendar.isCompleted boolValue])
        {
            [self.completedCalendars addObject:calendar];
        }
        else
        {
            self.currentCalendar = calendar;
            self.hasCalendarRunning = YES;
            self.isEditMode = YES;
        }
    }
}

- (void)viewDidLoad
{
    [self populateCalendars];
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Configure Med. Diary", nil);
    NSArray *menuTitles = @[@"1", @"2", @"3", @"4"];
    self.calendarSegmentControl = [[UISegmentedControl alloc] initWithItems:menuTitles];
    CGFloat width = self.tableView.bounds.size.width;
    CGFloat segmentWidth = width - 2 * 20;
    self.calendarSegmentControl.frame = CGRectMake(20, 3, segmentWidth, 30);
    self.calendarSegmentControl.tintColor = TINTCOLOUR;
    self.calendarSegmentControl.selectedSegmentIndex = 2;
    [self.calendarSegmentControl addTarget:self action:@selector(indexDidChangeForSegment) forControlEvents:UIControlEventValueChanged];
    [self indexDidChangeForSegment];
}

- (void)save:(id)sender
{
    SeinfeldCalendar *newCalendar = [[CoreDataManager sharedInstance] managedObjectForEntityName:kSeinfeldCalendar];
    newCalendar.uID = [Utilities GUID];
    newCalendar.startDate = self.date;
    newCalendar.endDate = self.endDate;
    newCalendar.isCompleted = [NSNumber numberWithBool:NO];
    
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeManagedObject
{
    if (nil == self.currentCalendar)
    {
        return;
    }
    NSManagedObjectContext *defaultContext = [[CoreDataManager sharedInstance] defaultContext];
    [defaultContext deleteObject:self.currentCalendar];
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)showDeleteAlertView
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"End or Delete?", nil) message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"End", nil), NSLocalizedString(@"Delete", nil), nil];
    
    [alert show];
}

/**
 if user really wants to delete the entry call removeSQLEntry
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Delete", @"Delete")])
    {
        [self removeManagedObject];
    }
    else if ([title isEqualToString:NSLocalizedString(@"End", nil)] && nil != self.currentCalendar)
    {
        self.currentCalendar.isCompleted = [NSNumber numberWithBool:YES];
        NSError *error = nil;
        [[CoreDataManager sharedInstance] saveContextAndWait:&error];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
    }
    else
    {
        return self.tableView.rowHeight;
    }
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
        return self.completedCalendars.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self identifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
        }
    }
    else
    {
        [self configureCell:cell indexPath:indexPath];
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
            indexPath:(NSIndexPath *)indexPath
{
    SeinfeldCalendar *calendar = (SeinfeldCalendar *)[self.completedCalendars objectAtIndex:indexPath.row];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 55;
    }
    else
    {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 40;
    }
    else
    {
        return 60;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    if (0 < section || nil != self.currentCalendar)
    {
        footer.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
        footer.backgroundColor = [UIColor clearColor];
        return footer;
    }
    footer.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    UILabel *label = [UILabel standardLabel];
    label.frame = CGRectMake(20, 10, tableView.bounds.size.width-40, 20);
    label.text = NSLocalizedString(@"For how many months?", nil);
    [footer addSubview:label];
    self.calendarSegmentControl.frame = CGRectMake(20, 35, tableView.bounds.size.width-40, 25);
    [footer addSubview:self.calendarSegmentControl];
    return footer;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    CGFloat height = (0 == section) ? 40 : 60;
    header.frame = CGRectMake(0, 0, tableView.frame.size.width, height);
    UILabel *label = [UILabel standardLabel];
    label.frame = CGRectMake(20, 0, tableView.bounds.size.width - 40, height);
    if (0 == section)
    {
        if (nil == self.currentCalendar)
        {
            label.text = NSLocalizedString(@"New Course", nil);
        }
        else
        {
            label.text = NSLocalizedString(@"Current Course", nil);
        }
    }
    else
    {
        if (0 < self.completedCalendars.count)
        {
            label.text = NSLocalizedString(@"Completed Courses", nil);
        }
        else
        {
            label.text = @"";
        }
    }
    [header addSubview:label];
    return header;
}

- (NSString *)identifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (0 == indexPath.section)
    {
        identifier = [NSString stringWithFormat:kBaseDateCellRowIdentifier];
        if ([self hasInlineDatePicker])
        {
            identifier = [NSString stringWithFormat:@"DatePickerCell"];
        }
    }
    else
    {
        identifier = [NSString stringWithFormat:@"OtherCell%d", indexPath.row];
    }
    return identifier;
}

- (void)indexDidChangeForSegment
{
    NSDateComponents *components = [Utilities dateComponentsForDate:self.date];
    NSUInteger startDay = components.day;
    NSUInteger startMonth = components.month;
    NSUInteger startYear = components.year;
    NSUInteger length = self.calendarSegmentControl.selectedSegmentIndex + 1;
    NSUInteger endMonth = startMonth + length;
    NSUInteger endYear = startYear;
    if (12 < endMonth)
    {
        endMonth -= 12;
        endYear++;
    }
    NSDateComponents *endComponents = [[NSDateComponents alloc] init];
    [endComponents setDay:startDay];
    [endComponents setMonth:endMonth];
    [endComponents setYear:endYear];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.endDate = [gregorianCalendar dateFromComponents:endComponents];
}
@end
