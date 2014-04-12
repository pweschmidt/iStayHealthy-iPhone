//
//  CalendarMonthView.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/01/2014.
//
//

#import "CalendarMonthView.h"
#import "NSDate+Extras.h"
#import "GeneralSettings.h"
#import "Utilities.h"
#import "UIFont+Standard.h"
#import "Constants.h"
#import "SeinfeldCalendar+Handling.h"
#import "SeinfeldCalendarEntry.h"
#import "CoreDataManager.h"
#import <QuartzCore/QuartzCore.h>

@interface CalendarMonthView ()
{
	CGFloat titleHeight;
	CGFloat weekDayTitleHeight;
	CGFloat weekDayValueHeight;
	CGFloat xOffset;
	CGFloat yOffset;
	CGFloat width;
	NSInteger weeks;
}
@property (nonatomic, strong) NSDateComponents *startComponents;
@property (nonatomic, strong) NSDateComponents *endComponents;
@property (nonatomic, strong) NSDateComponents *todayComponents;
@property (nonatomic, strong) NSDateComponents *courseEndComponents;
@property (nonatomic, strong) NSMutableDictionary *dayButtonsMap;
@property (nonatomic, strong) SeinfeldCalendar *calendar;
@property (nonatomic, strong) SeinfeldCalendarEntry *selectedEntry;
@property (nonatomic, strong) UIButton *selectedDayButton;
@end

@implementation CalendarMonthView


+ (CalendarMonthView *)calendarMonthViewForCalendar:(SeinfeldCalendar *)calendar
                                    startComponents:(NSDateComponents *)startComponents
                                      endComponents:(NSDateComponents *)endComponents
                                courseEndComponents:(NSDateComponents *)courseEndComponents
                                     suggestedFrame:(CGRect)suggestedFrame
{
	CalendarMonthView *monthView = [[CalendarMonthView alloc] initWithFrame:suggestedFrame];
	monthView.todayComponents = [Utilities dateComponentsForDate:[NSDate date]];
	monthView.startComponents = startComponents;
	monthView.endComponents = endComponents;
	monthView.courseEndComponents = courseEndComponents;
	monthView.calendar = calendar;
	[monthView correctHeightFromDates];
	[monthView addHeaderView];
	[monthView addWeekHeaderView];
	[monthView addWeekRows];
	return monthView;
}

- (void)addHeaderView
{
	UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, self.bounds.origin.y, width, titleHeight)];
	NSLog(@"HEADER bounds x=%f y=%f w=%f h=%f ", header.bounds.origin.x, header.bounds.origin.y, header.bounds.size.width, header.bounds.size.height);
	NSLog(@"HEADER frame x=%f y=%f w=%f h=%f ", header.frame.origin.x, header.frame.origin.y, header.frame.size.width, header.frame.size.height);
	header.backgroundColor = [UIColor clearColor];
	header.textAlignment = NSTextAlignmentRight;
	header.font = [UIFont fontWithType:Bold size:standard];
	header.textColor = TEXTCOLOUR;
	NSArray *months = [[Utilities calendarDictionary] objectForKey:@"months"];
	int monthIndex = (int)(self.startComponents.month - 1);
	header.text = [NSString stringWithFormat:@"%@, %ld", [months objectAtIndex:monthIndex], (long)self.startComponents.year];
	[self addSubview:header];
}

- (void)addWeekHeaderView
{
	__block UIView *weekHeader = [[UIView alloc] initWithFrame:CGRectMake(xOffset, self.bounds.origin.y + yOffset, width, weekDayTitleHeight)];
	NSLog(@"WEEKHEADER bounds x=%f y=%f w=%f h=%f ", weekHeader.bounds.origin.x, weekHeader.bounds.origin.y, weekHeader.bounds.size.width, weekHeader.bounds.size.height);
	NSLog(@"WEEKHEADER frame x=%f y=%f w=%f h=%f ", weekHeader.frame.origin.x, weekHeader.frame.origin.y, weekHeader.frame.size.width, weekHeader.frame.size.height);
	NSArray *days = [[Utilities calendarDictionary] objectForKey:@"shortDays"];
	CGFloat weekDaywidth = weekHeader.frame.size.width / 7;
	CGFloat weekDayX = weekHeader.bounds.origin.x + 20;
	CGFloat weekDayY = weekHeader.bounds.origin.y + 3;
	[days enumerateObjectsUsingBlock: ^(NSString *day, NSUInteger index, BOOL *stop) {
	    CGRect labelFrame = CGRectMake(index * weekDaywidth + weekDayX, weekDayY, weekDaywidth, weekDayTitleHeight);
	    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
	    label.backgroundColor = [UIColor clearColor];
	    label.text = day;
	    label.textAlignment = NSTextAlignmentLeft;
	    label.font = [UIFont fontWithType:Standard size:standard];
	    label.textColor = TEXTCOLOUR;
	    [weekHeader addSubview:label];
	}];
	weekHeader.backgroundColor = [UIColor clearColor];
	[self addSubview:weekHeader];
}

- (void)addWeekRows
{
	CGFloat heightOffset = self.bounds.origin.y + 3 + 2 * yOffset;
	UIView *weekRowView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, heightOffset, width, weeks * yOffset)];
	NSLog(@"WEEK bounds x=%f y=%f w=%f h=%f ", weekRowView.bounds.origin.x, weekRowView.bounds.origin.y, weekRowView.bounds.size.width, weekRowView.bounds.size.height);
	NSLog(@"WEEK frame x=%f y=%f w=%f h=%f ", weekRowView.frame.origin.x, weekRowView.frame.origin.y, weekRowView.frame.size.width, weekRowView.frame.size.height);
	weekRowView.backgroundColor = [UIColor clearColor];
	NSUInteger startDay = self.startComponents.day;
	NSUInteger endDay = self.endComponents.day;
	NSInteger days = endDay - startDay + 1;


	NSUInteger startWeekDayIndex = self.startComponents.weekday - 1;
	NSUInteger weekIndex = 0;
	if (0 >= days)
	{
		days = 1;
	}
	CGFloat dayWidth = width / 7;
	NSUInteger dayCounter = startDay;
	for (NSUInteger day = 0; day < days; ++day)
	{
		if (6 < startWeekDayIndex)
		{
			startWeekDayIndex = 0;
			weekIndex++;
		}
		CGFloat xDay = startWeekDayIndex * dayWidth;
		CGFloat yDay =  yOffset * weekIndex;
		CGRect buttonFrame = CGRectMake(xDay, yDay, dayWidth, yOffset);
		UIButton *dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		dayButton.backgroundColor = [UIColor clearColor];
		dayButton.frame = buttonFrame;
		dayButton.tag = day;
		[dayButton addTarget:self action:@selector(checkIfMissed:) forControlEvents:UIControlEventTouchUpInside];
		if (self.todayComponents.day < dayCounter ||
		    self.todayComponents.month != self.startComponents.month ||
		    self.todayComponents.year != self.startComponents.year)
		{
			dayButton.enabled = NO;
		}
		else
		{
			dayButton.enabled = YES;
		}

		SeinfeldCalendarEntry *entry = [self.calendar entryForDay:dayCounter month:self.startComponents.month year:self.startComponents.year];
		if (nil != entry)
		{
			[self.dayButtonsMap setObject:entry forKey:[NSNumber numberWithUnsignedInteger:day]];
		}

		CGFloat labelXOffset = (dayWidth - 20) / 2 + 3.5;
		CGRect labelFrame = CGRectMake(labelXOffset, 0, xOffset, yOffset);
		UILabel *dayLabel = [[UILabel alloc] initWithFrame:labelFrame];
		dayLabel.tag = day;
		[self decorateLabel:dayLabel day:dayCounter entry:entry];

		[dayButton addSubview:dayLabel];
		[weekRowView addSubview:dayButton];
		startWeekDayIndex++;
		dayCounter++;
	}
	[self addSubview:weekRowView];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (nil != self)
	{
		titleHeight = 18;
		weekDayTitleHeight = 18;
		weekDayValueHeight = 18;
		yOffset = 20;
		weeks = 1;
		xOffset = self.bounds.origin.x + 20;
		width = self.bounds.size.width - 40;
		_dayButtonsMap = [NSMutableDictionary dictionary];
		_selectedEntry = nil;
		_selectedDayButton = nil;
	}
	return self;
}

- (void)correctHeightFromDates
{
	CGFloat height = titleHeight + weekDayTitleHeight;
	weeks = self.endComponents.weekOfMonth - self.startComponents.weekOfMonth + 1;
	height += (yOffset * weeks);

	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;

	CGRect bounds = self.bounds;
	bounds.size.height = height;
	self.bounds = bounds;
}

- (void)checkIfMissed:(id)sender
{
	self.selectedDayButton = nil;
	self.selectedEntry = nil;
	if (![sender isKindOfClass:[UIButton class]])
	{
		return;
	}
	UIButton *button = (UIButton *)sender;
	self.selectedDayButton = button;
	NSNumber *key = [NSNumber numberWithUnsignedInteger:button.tag];
	SeinfeldCalendarEntry *entry = [self.dayButtonsMap objectForKey:key];

	NSString *title = NSLocalizedString(@"Set", nil);
	NSString *message = NSLocalizedString(@"Have you taken All of your meds?", nil);
	if (nil != entry)
	{
		title = NSLocalizedString(@"Change", nil);
		self.selectedEntry = entry;
	}
	UIAlertView *medAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil), nil];
	[medAlert show];
}

- (void)decorateLabel:(UILabel *)label day:(NSUInteger)day entry:(SeinfeldCalendarEntry *)entry
{
	label.backgroundColor = [UIColor clearColor];
	label.text = [NSString stringWithFormat:@"%lu", (unsigned long)day];
	label.textColor = [UIColor lightGrayColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont fontWithType:Standard size:standard];
	label.layer.cornerRadius = yOffset / 2;
	if (self.todayComponents.day == day)
	{
		label.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont fontWithType:Bold size:standard];
	}
	else if (self.todayComponents.day > day &&
	         self.todayComponents.month == self.startComponents.month &&
	         self.todayComponents.year == self.startComponents.year)
	{
		label.textColor = [UIColor darkGrayColor];
	}
	if (nil != entry)
	{
		BOOL hasTaken = [entry.hasTakenMeds boolValue];
		if (hasTaken)
		{
			label.layer.backgroundColor = DARK_GREEN.CGColor;
			label.textColor = [UIColor whiteColor];
			label.font = [UIFont fontWithType:Bold size:standard];
		}
		else
		{
			label.layer.backgroundColor = DARK_RED.CGColor;
			label.textColor = [UIColor whiteColor];
			label.font = [UIFont fontWithType:Bold size:standard];
		}
	}
}

#pragma mark Alert View delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [alertView cancelButtonIndex])
	{
		return;
	}
	if (nil == self.selectedDayButton)
	{
		return;
	}

	__block UILabel *foundLabel = nil;
	[self.selectedDayButton.subviews enumerateObjectsUsingBlock: ^(id object, NSUInteger index, BOOL *stop) {
	    if ([object isKindOfClass:[UILabel class]])
	    {
	        foundLabel = (UILabel *)object;
		}
	}];

	if (nil == foundLabel)
	{
		return;
	}

	SeinfeldCalendarEntry *entry = self.selectedEntry;
	BOOL isEntryUpdate = YES;
	BOOL needToEnterMissed = NO;
	NSUInteger day = self.selectedDayButton.tag + self.startComponents.day;

	BOOL courseIsEnded = (day == self.courseEndComponents.day &&
	                      self.startComponents.month == self.courseEndComponents.month &&
	                      self.startComponents.year == self.courseEndComponents.year);

	if (nil == entry)
	{
		isEntryUpdate = NO;
		entry = [[CoreDataManager sharedInstance] managedObjectForEntityName:kSeinfeldCalendarEntry];
		entry.uID = [Utilities GUID];
	}
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if ([title isEqualToString:NSLocalizedString(@"Yes", nil)])
	{
		foundLabel.layer.backgroundColor = DARK_GREEN.CGColor;
		foundLabel.textColor = [UIColor whiteColor];
		foundLabel.font = [UIFont fontWithType:Bold size:standard];
		entry.hasTakenMeds = [NSNumber numberWithBool:YES];
	}
	else if ([title isEqualToString:NSLocalizedString(@"No", nil)])
	{
		needToEnterMissed = YES;
		foundLabel.layer.backgroundColor = DARK_RED.CGColor;
		foundLabel.textColor = [UIColor whiteColor];
		foundLabel.font = [UIFont fontWithType:Bold size:standard];
		entry.hasTakenMeds = [NSNumber numberWithBool:NO];
	}

	if (!isEntryUpdate)
	{
		entry.date = [NSDate dateFromDay:day month:self.startComponents.month year:self.startComponents.year];
		[self.calendar addEntriesObject:entry];
	}

	NSError *error = nil;
	[[CoreDataManager sharedInstance] saveContextAndWait:&error];

	if (courseIsEnded)
	{
		if (nil != self.calendarDelegate && [self.calendarDelegate respondsToSelector:@selector(courseHasEndedHasMissedMedsOnLastDay::)])
		{
			[self.calendarDelegate courseHasEndedHasMissedMedsOnLastDay:needToEnterMissed];
		}
	}
	else
	{
		if (nil != self.calendarDelegate && [self.calendarDelegate respondsToSelector:@selector(popToMissedMedicationControllerHasMissed:)])
		{
			[self.calendarDelegate popToMissedMedicationControllerHasMissed:needToEnterMissed];
		}
	}
}

@end
