//
//  PWESSeinfeldMonth.m
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 24/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import "PWESSeinfeldMonth.h"
#import "PWESCalendar.h"

@interface PWESSeinfeldMonth ()
@property (nonatomic, assign, readwrite) NSInteger startDay;
@property (nonatomic, assign, readwrite) NSInteger endDay;
@property (nonatomic, assign, readwrite) NSInteger startWeekDay;
@property (nonatomic, assign, readwrite) NSInteger endWeekDay;
@property (nonatomic, assign, readwrite) NSInteger month;
@property (nonatomic, assign, readwrite) NSInteger year;
@property (nonatomic, assign, readwrite) NSInteger startWeek;
@property (nonatomic, assign, readwrite) NSInteger endWeek;
@property (nonatomic, assign, readwrite) NSInteger weeksToShow;
@property (nonatomic, assign, readwrite) NSInteger totalDays;
@property (nonatomic, assign, readwrite) BOOL isLastMonth;
@end

@implementation PWESSeinfeldMonth

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		_isLastMonth = NO;
	}
	return self;
}

+ (PWESSeinfeldMonth *)monthFromStartDate:(NSDate *)startDate
                               monthIndex:(NSInteger)monthIndex
                           numberOfMonths:(NSUInteger)numberOfMonths
{
	PWESSeinfeldMonth *month = [[PWESSeinfeldMonth alloc] init];
	NSDate *nextMonth = [[PWESCalendar sharedInstance] monthsFromDate:startDate months:monthIndex];
	if (0 == monthIndex)
	{
		if (1 == numberOfMonths)
		{
			month.isLastMonth = YES;
		}
		[month configureFromDate:nextMonth];
	}
	else if (monthIndex == numberOfMonths - 1)
	{
		month.isLastMonth = YES;
		[month configureUntilDate:nextMonth];
	}
	else
	{
		[month configureFullMonth:nextMonth];
	}
	return month;
}

- (void)configureFromDate:(NSDate *)fromDate
{
	NSDateComponents *components = [[PWESCalendar sharedInstance] dateComponentsForDate:fromDate];
	NSInteger daysInMonth = [[PWESCalendar sharedInstance] daysInMonth:components.month inYear:components.year];
	NSInteger weekdays = daysInMonth - components.day;
	NSInteger weeks = weekdays / 7;

	self.startDay = components.day;
	self.startWeekDay = components.weekday;
	self.endDay = daysInMonth;
	self.startWeek = components.weekOfYear;
	self.weeksToShow = weeks;
	if (0 == weeks)
	{
		self.weeksToShow = 1;
	}
	[self endParametersForDay:components.day
	                   endday:daysInMonth
	                  weekday:components.weekday
	                     week:components.weekOfYear];

	self.month = components.month;
	self.year = components.year;
	self.totalDays = weekdays + 1;
	if (0 == self.totalDays)
	{
		self.totalDays = 1;
	}
}

- (void)configureFullMonth:(NSDate *)date
{
	NSDateComponents *components = [[PWESCalendar sharedInstance] dateComponentsForDate:date];
	NSInteger daysInMonth = [[PWESCalendar sharedInstance] daysInMonth:components.month inYear:components.year];
	NSInteger daysToEnd = daysInMonth - components.day;
	NSInteger restDaysToEnd = daysToEnd % 7;

	self.startDay = 1;
	[self startParametersForDay:components.day
	                    weekday:components.weekday
	                       week:components.weekOfYear];
	[self endParametersForDay:components.day
	                   endday:daysInMonth
	                  weekday:components.weekday
	                     week:components.weekOfYear];
	self.endDay = daysInMonth;

	self.weeksToShow = daysInMonth / 7;
	if (0 < restDaysToEnd)
	{
		self.weeksToShow++;
	}

	self.month = components.month;
	self.year = components.year;
	self.totalDays = daysInMonth;
}

- (void)configureUntilDate:(NSDate *)date
{
	NSDateComponents *components = [[PWESCalendar sharedInstance] dateComponentsForDate:date];
	NSInteger daysFromStart = components.day - 1;
	NSInteger restDaysFromStart = daysFromStart % 7;
	self.startDay = 1;
	[self startParametersForDay:components.day
	                    weekday:components.weekday
	                       week:components.weekOfYear];
	self.weeksToShow = components.day / 7;
	if (0 < restDaysFromStart)
	{
		self.weeksToShow++;
	}
	self.endDay = components.day;
	self.endWeek = components.weekOfYear;
	self.endWeekDay = components.weekday;
	self.month = components.month;
	self.year = components.year;
	self.totalDays = components.day;
}

- (void)endParametersForDay:(NSInteger)day
                     endday:(NSInteger)endday
                    weekday:(NSInteger)weekday
                       week:(NSInteger)week
{
	NSInteger endWeekday = weekday;
	NSInteger endWeek = week;
	for (NSInteger daysCounted = day; daysCounted < endday; ++daysCounted)
	{
		endWeekday++;
		if (7 < endWeekday)
		{
			endWeekday = 1;
			endWeek++;
		}
	}
	self.endWeek = endWeek;
	self.endWeekDay = endWeekday;
}

- (void)startParametersForDay:(NSInteger)day weekday:(NSInteger)weekday week:(NSInteger)week
{
	NSInteger startWeekday = weekday;
	NSInteger startWeek = week;
	NSInteger daysCounted = day;
	while (1 < daysCounted)
	{
		startWeekday--;
		if (0 == startWeekday)
		{
			startWeekday = 7;
			startWeek--;
		}
		daysCounted--;
	}
	self.startWeekDay = startWeekday;
	self.startWeek = startWeek;
}

@end
