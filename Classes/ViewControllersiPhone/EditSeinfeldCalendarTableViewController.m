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
#import "PWESStar.h"
#import "DateView.h"
#import "PWESResultsDelegate.h"

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
	self.navigationItem.title = NSLocalizedString(@"Configure Med. Diary", nil);
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
	SeinfeldCalendar *newCalendar = [[CoreDataManager sharedInstance] managedObjectForEntityName:kSeinfeldCalendar];
	newCalendar.uID = [Utilities GUID];
	newCalendar.startDate = self.date;
	newCalendar.endDate = self.endDate;
	newCalendar.isCompleted = [NSNumber numberWithBool:NO];
	[self scheduleAlert];

	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];
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
	medAlert.repeatInterval = NSDayCalendarUnit;
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
	NSManagedObjectContext *defaultContext = [[CoreDataManager sharedInstance] defaultContext];
	[defaultContext deleteObject:self.currentCalendar];
	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];
	__strong id <PWESResultsDelegate> resultsDelegate = self.resultsDelegate;
	if (nil != resultsDelegate && [resultsDelegate respondsToSelector:@selector(removeCalendar)])
	{
		[resultsDelegate removeCalendar];
	}

	[self.navigationController popViewControllerAnimated:YES];
}

- (void)showDeleteAlertView
{
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"End or Delete?", nil)
	                                               message:NSLocalizedString(@"Do you want to end or delete this entry?", nil)
	                                              delegate:self
	                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
	                                     otherButtonTitles:NSLocalizedString(@"End", nil), NSLocalizedString(@"Delete", nil), nil];

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
		NSDate *now = [NSDate date];
		self.currentCalendar.endDate = now;
		NSError *error = nil;
		[[CoreDataManager sharedInstance] saveContextAndWait:&error];
		__strong id <PWESResultsDelegate> resultsDelegate = self.resultsDelegate;
		if (nil != resultsDelegate && [resultsDelegate respondsToSelector:@selector(finishCalendarWithEndDate:)])
		{
			[resultsDelegate finishCalendarWithEndDate:now];
		}
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
	float score = [calendar.score floatValue];
	CGFloat rowHeight = self.tableView.rowHeight - 2;
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
		identifier = [NSString stringWithFormat:@"OtherCell%ld", (long)indexPath.row];
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
