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
#import <QuartzCore/QuartzCore.h>

@interface SeinfeldCalendarViewController ()
@property (nonatomic, strong) NSArray *medications;
@property (nonatomic, strong) NSArray *missedMedications;
@end

@implementation SeinfeldCalendarViewController

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _medications = [NSArray array];
        _missedMedications = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self datesFromArchive];
    self.navigationItem.title = NSLocalizedString(@"Medication Diary", nil);
    CGFloat xOffset = 0;
    CGFloat yScrollOffset = 95;
    CGFloat scrollHeight = self.view.frame.size.height - 188;
    CGFloat scrollWidth = self.view.frame.size.width;
    NSUInteger months = [self monthsToMonitor];
    NSDateComponents *components = [Utilities dateComponentsForDate:self.startDate];
    NSUInteger startMonth = components.month;
    NSUInteger startYear = components.year;
    CGFloat contentHeight = 150 * months;
    CGRect scrollFrame = CGRectMake(xOffset, yScrollOffset, scrollWidth, scrollHeight);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    [self.view addSubview:scrollView];
    
    self.calendarScrollView = scrollView;
    self.calendarScrollView.backgroundColor = [UIColor clearColor];
    self.calendarScrollView.delegate = self;
    self.calendarScrollView.scrollsToTop = YES;
    self.calendarScrollView.pagingEnabled = YES;
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
}


#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion:^(NSArray *array, NSError *error) {
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
            self.medications = nil;
            self.medications = [NSArray arrayWithArray:array];
            [[CoreDataManager sharedInstance] fetchDataForEntityName:kMissedMedication predicate:nil sortTerm:kMissedDate ascending:NO completion:^(NSArray *missedArray, NSError *missedError) {
                if (nil == missedArray)
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
                    self.missedMedications = nil;
                    self.missedMedications = [NSArray arrayWithArray:missedArray];
                }
            }];
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
- (void)datesFromArchive
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *start = [defaults objectForKey:@"diaryStart"];
    NSData *end = [defaults objectForKey:@"diaryEnd"];
    
    if (nil == start)
    {
        self.startDate = [NSDate date];
        start = [NSKeyedArchiver archivedDataWithRootObject:self.startDate];
        [defaults setObject:start forKey:@"diaryStart"];
        [defaults synchronize];
    }
    if (nil == end)
    {
        self.endDate = [self.startDate dateByAddingDays:90];
        end = [NSKeyedArchiver archivedDataWithRootObject:self.endDate];
        [defaults setObject:end forKey:@"diaryEnd"];
        [defaults synchronize];
    }
    self.startDate = [NSKeyedUnarchiver unarchiveObjectWithData:start];
    self.endDate = [NSKeyedUnarchiver unarchiveObjectWithData:end];
}

- (NSUInteger)monthsToMonitor
{
    NSDateComponents *startComponents = [Utilities dateComponentsForDate:self.startDate];
    NSDateComponents *endComponents = [Utilities dateComponentsForDate:self.endDate];
    NSUInteger startMonth = startComponents.month;
    NSUInteger endMonth = endComponents.month;
    return (endMonth - startMonth + 1);
}


@end
