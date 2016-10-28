//
//  EditSeinfeldCalendarTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/01/2014.
//
//

#import "EditSeinfeldCalendarTableViewController.h"
#import "Constants.h"
#import "SeinfeldCalendar.h"
#import "UILabel+Standard.h"
#import "Utilities.h"
#import "PWESStar.h"
#import "DateView.h"
#import "PWESResultsDelegate.h"
#import "iStayHealthy-Swift.h"

@interface EditSeinfeldCalendarTableViewController ()
@property (nonatomic, strong) UISegmentedControl *calendarSegmentControl;
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) NSMutableArray *completedCalendars;
@property (nonatomic, strong) SeinfeldCalendar *currentCalendar;
@property (nonatomic, assign) BOOL hasCalendarRunning;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSIndexPath *markedIndexPath;
@property (nonatomic, strong) NSManagedObject *markedObject;
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
        _markedIndexPath = nil;
        _markedObject = nil;
    }
    return self;
}

- (void)populateCalendars
{
    self.completedCalendars = [NSMutableArray array];
    if (nil == self.calendars || 0 == self.calendars.count)
    {
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
    [super viewDidLoad];
    [self populateCalendars];
    [self setTitleViewWithTitle:NSLocalizedString(@"Configure Med. Diary", nil)];
    //    self.navigationItem.title = NSLocalizedString(@"Configure Med. Diary", nil);
    NSArray *menuTitles = @[@"1", @"2", @"3"];

    self.calendarSegmentControl = [[UISegmentedControl alloc] initWithItems:menuTitles];
    self.calendarSegmentControl.selectedSegmentIndex = 0;
    [self.calendarSegmentControl addTarget:self action:@selector(indexDidChangeForSegment) forControlEvents:UIControlEventValueChanged];

    if (self.isEditMode)
    {
        UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showDeleteAlertView)];
        self.navigationItem.rightBarButtonItems = @[trashButton];
    }
    [self indexDidChangeForSegment];
}

- (void)save:(id)sender
{
    if (self.isEditMode)
    {
        return;
    }
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    SeinfeldCalendar *newCalendar = (SeinfeldCalendar *) [manager managedObjectForEntityName:kSeinfeldCalendar];
    newCalendar.uID = [Utilities GUID];
    newCalendar.startDate = self.date;
    newCalendar.endDate = self.endDate;
    newCalendar.isCompleted = [NSNumber numberWithBool:NO];
    [self scheduleAlert];

    NSError *error = nil;
    [manager saveContextAndReturnError:&error];
    [self popController];
}

- (void)scheduleAlert
{
    NSString *alertText = NSLocalizedString(@"Med. Diary Reminder", nil);

    NSDictionary *userDictionary = @{ kAppNotificationIntervalKey: @"daily",
                                      kAppNotificationKey : alertText };

    UILocalNotification *medAlert = [[UILocalNotification alloc]init];

    medAlert.fireDate = [NSDate date];
    medAlert.timeZone = [NSTimeZone localTimeZone];
    medAlert.repeatInterval = NSCalendarUnitDay;
    medAlert.userInfo = userDictionary;
    medAlert.alertBody = alertText;
    medAlert.alertAction = @"Show me";
    medAlert.soundName = UILocalNotificationDefaultSoundName;
    medAlert.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication]scheduleLocalNotification:medAlert];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kDiaryActivatedKey];
    [defaults synchronize];
}

- (void)removeManagedObject
{
    if (nil == self.currentCalendar)
    {
        return;
    }
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    NSError *error = nil;
    [manager removeManagedObject:self.currentCalendar error:&error];
    [manager saveContextAndReturnError:&error];
    __strong id <PWESResultsDelegate> resultsDelegate = self.resultsDelegate;
    if (nil != resultsDelegate && [resultsDelegate respondsToSelector:@selector(removeCalendar)])
    {
        [resultsDelegate removeCalendar];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeMarkedObject
{
    if (nil == self.markedObject || nil == self.markedIndexPath)
    {
        return;
    }
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    NSError *error = nil;
    [manager removeManagedObject:self.markedObject error:&error];
    [manager saveContextAndReturnError:&error];
    self.markedObject = nil;
    self.markedIndexPath = nil;
    [self populateCalendars];
    [self.tableView reloadData];
}


- (void)showDeleteAlertView
{
    PWESAlertAction *cancel = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel action:nil];
    PWESAlertAction *delete = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDestructive action:^{
        [self removeManagedObject];
    }];
    PWESAlertAction *end = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault action:^{
        self.currentCalendar.isCompleted = [NSNumber numberWithBool:YES];
        NSDate *now = [NSDate date];
        self.currentCalendar.endDate = now;
        PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
        NSError *error = nil;
        [manager saveContextAndReturnError:&error];
        __strong id <PWESResultsDelegate> resultsDelegate = self.resultsDelegate;
        if (nil != resultsDelegate && [resultsDelegate respondsToSelector:@selector(finishCalendarWithEndDate:)])
        {
            [resultsDelegate finishCalendarWithEndDate:now];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [PWESAlertHandler.alertHandler
     showAlertView:NSLocalizedString(@"End or Delete?", nil)
     message:NSLocalizedString(@"Do you want to end or delete this entry?", nil)
     presentingController:self
     actions:@[end, delete, cancel]];
    
}

- (void)showDeleteCalendarAlertView
{
    PWESAlertAction *cancel = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel action:nil];
    PWESAlertAction *delete = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDestructive action:^{
        [self removeMarkedObject];
    }];
    [PWESAlertHandler.alertHandler
     showAlertView:NSLocalizedString(@"Delete?", nil)
     message:NSLocalizedString(@"Do you want to delete this calendar?", nil)
     presentingController:self
     actions:@[delete, cancel]];
}

/**
   if user really wants to delete the entry call removeSQLEntry
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

    [self removeAlert];
    if ([title isEqualToString:NSLocalizedString(@"Delete", @"Delete")])
    {
        [self removeManagedObject];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Delete Calendar", nil)])
    {
        [self removeMarkedObject];
    }
    else if ([title isEqualToString:NSLocalizedString(@"End", nil)] && nil != self.currentCalendar)
    {
        self.currentCalendar.isCompleted = [NSNumber numberWithBool:YES];
        NSDate *now = [NSDate date];
        self.currentCalendar.endDate = now;
        PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
        NSError *error = nil;
        [manager saveContextAndReturnError:&error];
        __strong id <PWESResultsDelegate> resultsDelegate = self.resultsDelegate;
        if (nil != resultsDelegate && [resultsDelegate respondsToSelector:@selector(finishCalendarWithEndDate:)])
        {
            [resultsDelegate finishCalendarWithEndDate:now];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
 */

- (void)removeAlert
{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];

    [notifications enumerateObjectsUsingBlock: ^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
         NSDictionary *userInfo = notification.userInfo;

         NSString *alertText = [userInfo objectForKey:kAppNotificationKey];
         if (nil != alertText && [alertText isEqualToString:NSLocalizedString(@"Med. Diary Reminder", nil)])
         {
             [[UIApplication sharedApplication] cancelLocalNotification:notification];
         }
     }];
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
        return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : 44);
    }
    else
    {
        return 44;
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
    SeinfeldCalendar *calendar = (SeinfeldCalendar *) [self.completedCalendars objectAtIndex:indexPath.row];
    float score = [calendar.score floatValue];

    if (100 < score)
    {
        score = 100.f;
    }
    else if (0 > score)
    {
        score = 0.f;
    }
    CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath] - 2;
    DateView *dateView = [DateView viewWithDate:calendar.endDate frame:CGRectMake(20, 1, rowHeight, rowHeight)];

    [cell.contentView addSubview:dateView];

    UILabel *results = [[UILabel alloc] initWithFrame:CGRectMake(25 + rowHeight, 0, self.view.frame.size.width - 40 - rowHeight, rowHeight / 2)];
    results.textColor = TEXTCOLOUR;
    results.textAlignment = NSTextAlignmentLeft;
    results.font = [UIFont fontWithType:Standard size:standard];
    NSString *scoreText = NSLocalizedString(@"Your score:", nil);
    NSString *resultsText = [NSString stringWithFormat:@"%@ %3.2f (%%)", scoreText, score];
    results.text = resultsText;
    [cell.contentView addSubview:results];

    UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(15 + rowHeight, rowHeight / 2, self.view.frame.size.width - 40, rowHeight / 2)];

    CGFloat xOffset = 0;
    CGFloat yOffset = ((rowHeight / 2) - 17) / 2;
    CGFloat width = 17;
    CGFloat height = 17;
    CGFloat marginX = 10;
    float goldenRule = floorf(score / 20);
    for (int i = 0; i < 5; ++i)
    {
        CGFloat x = xOffset + i * width + marginX;
        CGRect frame = CGRectMake(x, yOffset, width, height);
        PWESStar *star = nil;
        if (i < goldenRule)
        {
            star = [PWESStar starWithColourAndFrame:frame];
        }
        else
        {
            star = [PWESStar starWithoutColourAndFrame:frame];
        }
        [starView addSubview:star];
    }
    [cell.contentView addSubview:starView];
}

- (void)     tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle &&
        0 < indexPath.section &&
        0 < self.completedCalendars.count)
    {
        self.markedIndexPath = indexPath;
        self.markedObject = [self.completedCalendars objectAtIndex:indexPath.row];
        [self showDeleteCalendarAlertView];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 50;
    }
    else
    {
        return 40;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];

    if (0 == section)
    {
        footer.frame = CGRectMake(0, 0, tableView.frame.size.width, 50);
        UILabel *label = [UILabel standardLabel];
        label.frame = CGRectMake(20, 0, tableView.bounds.size.width - 40, 20);
        label.text = NSLocalizedString(@"For how many months?", nil);
        [footer addSubview:label];
        self.calendarSegmentControl.frame = CGRectMake(20, 23, tableView.bounds.size.width - 40, 30);
        [footer addSubview:self.calendarSegmentControl];
    }
    else
    {
        footer.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
        footer.backgroundColor = [UIColor clearColor];
        return footer;
    }
    return footer;
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
            label.text = NSLocalizedString(@"New Diary", nil);
        }
        else
        {
            label.text = NSLocalizedString(@"Current Diary", nil);
        }
    }
    else
    {
        if (0 < self.completedCalendars.count)
        {
            label.text = NSLocalizedString(@"Completed Diaries", nil);
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
        identifier = [NSString stringWithFormat:@"OtherCell%ld", (long) indexPath.row];
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
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.endDate = [gregorianCalendar dateFromComponents:endComponents];
}

@end
