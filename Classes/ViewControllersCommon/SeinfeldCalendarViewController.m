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
#import "CalendarMonthView.h"
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
    NSDate *startDate = self.currentCalendar.startDate;
    NSDate *endDate = self.currentCalendar.endDate;
    
    NSDateComponents *startComponents = [Utilities dateComponentsForDate:startDate];
    NSDateComponents *endComponents = [Utilities dateComponentsForDate:endDate];

    NSInteger months = endComponents.month - startComponents.month + 1;
    if (endComponents.year > startComponents.year)
    {
        months += 12;
    }
    NSInteger month = startComponents.month;
    NSInteger year = startComponents.year;
    
    CGFloat xOffset = self.calendarScrollView.frame.origin.x;
    CGFloat yScrollOffset = self.calendarScrollView.frame.origin.y;
    CGFloat scrollWidth = self.view.frame.size.width;
    CGFloat contentHeight = 0;
    CGFloat contentGap = 20;
    NSDateComponents *monthStart = startComponents;

    NSDateComponents *monthEnd = [[NSDateComponents alloc] init];
    [monthEnd setDay:[Utilities daysInMonth:startComponents.month inYear:startComponents.year]];
    [monthEnd setMonth:startComponents.month];
    [monthEnd setYear:startComponents.year];
    for (NSInteger monthIndex = 0; monthIndex < months; ++monthIndex)
    {
        CGRect frame = CGRectMake(xOffset, yScrollOffset + contentGap + contentHeight, scrollWidth, 150);
        CalendarMonthView *monthView = [CalendarMonthView calendarMonthViewForCalendar:self.currentCalendar
                                                                       startComponents:monthStart
                                                                         endComponents:monthEnd
                                                                        suggestedFrame:frame];
        contentHeight += monthView.bounds.size.height;
        [self.calendarScrollView addSubview:monthView];
        month++;
        if (12 < month)
        {
            month = 1;
            year++;
        }
        [monthStart setDay:1];
        [monthStart setMonth:month];
        [monthStart setYear:year];
        if (endComponents.month == month && endComponents.year == year)
        {
            monthEnd = endComponents;
        }
        else
        {
            [monthEnd setDay:[Utilities daysInMonth:monthStart.month inYear:monthStart.year]];
            [monthEnd setMonth:monthStart.month];
            [monthEnd setYear:monthStart.year];
        }
    }
    self.calendarScrollView.contentSize = CGSizeMake(scrollWidth, contentHeight);
    self.calendarScrollView.scrollsToTop = YES;
    [self.calendarScrollView setNeedsDisplay];
}


@end
