//
//  SeinfeldCalendarViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "SeinfeldCalendarViewController.h"
#import "Utilities.h"
#import "GeneralSettings.h"
#import "Constants.h"
#import "Medication.h"
#import "MissedMedication.h"
#import "CoreDataManager.h"
#import "NSDate+Extras.h"
#import "CalendarView.h"
#import "SeinfeldCalendar.h"
#import "SeinfeldCalendarEntry.h"
#import "EditSeinfeldCalendarTableViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface SeinfeldCalendarViewController ()
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) SeinfeldCalendar *currentCalendar;
@end

@implementation SeinfeldCalendarViewController

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _calendars = [NSArray array];
        _currentCalendar = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitleViewWithTitle:NSLocalizedString(@"Medication Diary", nil)];
    CGFloat xOffset = 0;
    CGFloat yScrollOffset = 95;
    CGFloat scrollHeight = self.view.frame.size.height - 188;
    CGFloat scrollWidth = self.view.frame.size.width;
    CGRect scrollFrame = CGRectMake(xOffset, yScrollOffset, scrollWidth, scrollHeight);

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    [self.view addSubview:scrollView];
    
    self.calendarScrollView = scrollView;
    self.calendarScrollView.backgroundColor = [UIColor clearColor];
    self.calendarScrollView.delegate = self;
    self.calendarScrollView.scrollsToTop = YES;
    self.calendarScrollView.pagingEnabled = YES;
    
    /*
     [self datesFromArchive];
     
     
     
     CGFloat xOffset = 0;
     CGFloat yScrollOffset = 95;
     CGFloat scrollHeight = self.view.frame.size.height - 188;
     CGFloat scrollWidth = self.view.frame.size.width;
     NSUInteger months = [self monthsToMonitor];
     NSDateComponents *components = [Utilities dateComponentsForDate:self.startDate];
     NSUInteger startMonth = components.month;
     NSUInteger startYear = components.year;
     CGFloat contentHeight = 150 * months;
     self.calendarScrollView.contentSize = CGSizeMake(scrollWidth, contentHeight);
    for (int month = 0; month < months; month++)
    {
        NSDate *date = self.startDate;
        if (0 < month)
        {
            NSDateComponents *newMonth = [[NSDateComponents alloc] init];
            newMonth.month = startMonth;
            newMonth.day = 1;
            newMonth.year = startYear;
            date = [[NSCalendar currentCalendar] dateFromComponents:newMonth];
        }
        CGRect frame = CGRectMake(self.calendarScrollView.frame.origin.x, self.calendarScrollView.frame.origin.y + month * 150, scrollWidth, 150);
        CalendarView *calendarView = [CalendarView calenderViewForDate:date frame:frame];
        [self.calendarScrollView addSubview:calendarView];
        startMonth++;
        if (12 < startMonth)
        {
            startMonth = 1;
            startYear++;
        }
    }
    */
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(addButtonPressed:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
    EditSeinfeldCalendarTableViewController *calendarCtrl = [[EditSeinfeldCalendarTableViewController alloc]
                                                             initWithStyle:UITableViewStyleGrouped calendars:self.calendars];
    [self.navigationController pushViewController:calendarCtrl animated:YES];
}


#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kSeinfeldCalendar predicate:nil sortTerm:kStartDateLowerCase ascending:NO completion:^(NSArray *array, NSError *error) {
        if (nil == array)
        {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Error"
                                       message:@"Error loading data"
                                       delegate:nil
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:nil];
            [errorAlert show];
            
        }
        else
        {
            self.calendars = nil;
            self.calendars = [NSArray arrayWithArray:array];
            for (SeinfeldCalendar *calendar in array)
            {
                if (NO == [calendar.isCompleted boolValue])
                {
                    self.currentCalendar = calendar;
                    break;
                }
            }
            if (nil != self.currentCalendar)
            {
                [self buildSeinfeldCalendar];
            }
        }
    }];
}
- (void)startAnimation:(NSNotification *)notification
{
}
- (void)stopAnimation:(NSNotification *)notification
{
}
- (void)handleError:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
}

#pragma mark scroll view delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

#pragma mark private
- (void)buildSeinfeldCalendar
{
    if (nil == self.currentCalendar)
    {
        return;
    }
    
}
@end
