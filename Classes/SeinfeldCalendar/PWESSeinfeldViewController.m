//
//  PWESSeinfeldViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/05/2014.
//
//

#import "PWESSeinfeldViewController.h"
#import "CoreDataManager.h"
#import "SeinfeldCalendar.h"
#import "SeinfeldCalendarEntry.h"
#import "EditSeinfeldCalendarTableViewController.h"
#import "EditMissedMedsTableViewController.h"
#import "PWESCalendar.h"
#import "PWESSeinfeldMonth.h"
#import "PWESMonthlyView.h"
#import "EditMissedMedsTableViewController.h"
#import "PWESStar.h"
#import <QuartzCore/QuartzCore.h>

#define kScrollViewTag 12358
#define kLabelViewTag 6247

@interface PWESSeinfeldViewController ()
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) NSArray *currentMeds;
@property (nonatomic, strong) SeinfeldCalendar *currentCalendar;
@property (nonatomic, strong) UIScrollView *calendarScoller;
@end

@implementation PWESSeinfeldViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitleViewWithTitle:NSLocalizedString(@"Medication Diary", nil)];
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
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kSeinfeldCalendar predicate:nil sortTerm:kEndDateLowerCase ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        for (SeinfeldCalendar * calendar in array)
	        {
	            if (NO == [calendar.isCompleted boolValue])
	            {
	                self.currentCalendar = calendar;
	                break;
				}
			}
	        [self configureCalenderScroller];
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *medsarray, NSError *innererror) {
	            if (nil == medsarray)
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
	                self.currentMeds = nil;
	                self.currentMeds = medsarray;
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

#pragma mark private
- (void)configureCalenderScroller
{
	UIView *existingScrollView = [self.view viewWithTag:kScrollViewTag];
	if (nil != existingScrollView)
	{
		[existingScrollView removeFromSuperview];
	}
	UIView *existingLabelView = [self.view viewWithTag:kLabelViewTag];
	if (nil != existingLabelView)
	{
		[existingLabelView removeFromSuperview];
	}
	if (nil == self.currentCalendar)
	{
		UIView *label = [self calendarLabel];
		[self.view addSubview:label];
		return;
	}

	UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 70, self.view.bounds.size.width, self.view.bounds.size.height - 120);
	scrollView.pagingEnabled = YES;
	scrollView.scrollEnabled = YES;
	scrollView.tag = kScrollViewTag;
	CGFloat contentHeight = 0.f;

	NSInteger months = [[PWESCalendar sharedInstance] monthsBetweenStartDate:self.currentCalendar.startDate
	                                                                 endDate:self.currentCalendar.endDate];
	for (NSInteger month = 0; month < months; ++month)
	{
		CGRect monthFrame = CGRectMake(scrollView.frame.origin.x, contentHeight, scrollView.frame.size.width, 200);
		PWESSeinfeldMonth *seinfeldMonth = [PWESSeinfeldMonth monthFromStartDate:self.currentCalendar.startDate
		                                                              monthIndex:month
		                                                          numberOfMonths:months];
		PWESMonthlyView *view = [PWESMonthlyView monthlyViewForCalendar:self.currentCalendar
		                                                  seinfeldMonth:seinfeldMonth
		                                                          frame:monthFrame];
		view.resultsDelegate = self;
		contentHeight += view.frame.size.height;
		if (0 == month)
		{
			contentHeight += 20.f;
		}
		[scrollView addSubview:view];
	}
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentHeight);

	[self.view addSubview:scrollView];
}

- (UIView *)calendarLabel
{
	BOOL showLastEntry = YES;
	if (nil == self.calendars)
	{
		showLastEntry = NO;
	}
	else if (0 == self.calendars.count)
	{
		showLastEntry = NO;
	}

	if (showLastEntry)
	{
		SeinfeldCalendar *lastEntry = [self.calendars objectAtIndex:0];
		float score = [lastEntry.score floatValue];
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 100)];
		view.tag = kLabelViewTag;
		view.layer.cornerRadius = 10;
		view.layer.borderColor = [UIColor darkGrayColor].CGColor;
		view.layer.borderWidth = 1;
		view.layer.backgroundColor = [UIColor whiteColor].CGColor;

		UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 40)];
		title.textColor = TEXTCOLOUR;
		title.textAlignment = NSTextAlignmentLeft;
		title.font = [UIFont fontWithType:Bold size:large];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateStyle = kDateFormatting;
		NSString *endString = [formatter stringFromDate:lastEntry.endDate];

		NSString *text = NSLocalizedString(@"Last diary ending", nil);
		title.text = [NSString stringWithFormat:@"%@: %@", text, endString];

		[view addSubview:title];

		UILabel *results = [[UILabel alloc] initWithFrame:CGRectMake(10, 43, self.view.frame.size.width - 20, 20)];
		results.textColor = TEXTCOLOUR;
		results.textAlignment = NSTextAlignmentLeft;
		results.font = [UIFont fontWithType:Standard size:standard];
		NSString *scoreText = NSLocalizedString(@"Your score:", nil);
		NSString *resultsText = [NSString stringWithFormat:@"%@ %3.2f (%%)", scoreText, score];
		results.text = resultsText;

		[view addSubview:results];

		UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width - 40, 17)];

		CGFloat xOffset = starView.frame.origin.x;
		CGFloat yOffset = 0;
		CGFloat width = 17;
		CGFloat height = 17;
		float goldenRule = floorf(score / 20);
		for (int i = 0; i < 5; ++i)
		{
			CGFloat x = xOffset + i * width + 10;
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
		[view addSubview:starView];
		return view;
	}
	else
	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 100)];
		label.text = NSLocalizedString(@"No Calender Available", nil);
		label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = DARK_RED;
		label.tag = kLabelViewTag;
		return label;
	}
}

#pragma mark PWESResultsDelegate methods
- (void)updateCalendarWithSuccess:(BOOL)success
{
	if (nil == self.currentMeds || 0 == self.currentMeds.count)
	{
		return;
	}
	if (success)
	{
		return;
	}
	EditMissedMedsTableViewController *controller = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped currentMeds:self.currentMeds managedObject:nil];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)finishCalendarWithSuccess:(BOOL)success
{
	SeinfeldCalendar *calendar = self.currentCalendar;
	NSSet *calendarEntries = calendar.entries;
	double totalCount = (double)calendarEntries.count;
	double days = (double)[[PWESCalendar sharedInstance] daysBetweenStartDate:calendar.startDate
	                                                                  endDate:calendar.endDate];

	double totalDays = abs(days);
	double fractionMonitored = totalCount / totalDays;

	__block NSUInteger counter = 0;
	[calendarEntries enumerateObjectsUsingBlock: ^(SeinfeldCalendarEntry *entry, BOOL *stop) {
	    if (nil != entry.hasTakenMeds)
	    {
	        if ([entry.hasTakenMeds boolValue])
	        {
	            counter++;
			}
		}
	}];

	double fractionTaken = counter / totalCount;
	double result = (fractionTaken * fractionMonitored) * 100.0;
	calendar.score = [NSNumber numberWithDouble:result];
	calendar.isCompleted = [NSNumber numberWithBool:YES];
	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];

	self.currentCalendar = nil;
	[self reloadSQLData:nil];
}

@end
