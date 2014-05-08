//
//  PWESCalendar.m
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 24/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import "PWESCalendar.h"

@implementation PWESCalendar
+ (PWESCalendar *)sharedInstance
{
	static dispatch_once_t onceToken;
	static PWESCalendar *calendar = nil;
	dispatch_once(&onceToken, ^{
	    calendar = [[self alloc] init];
	});
	return calendar;
}

- (NSDate *)dateFromStartDate:(NSDate *)startDate
               numberOfMonths:(NSUInteger)numberOfMonths
{
	if (1 > numberOfMonths)
	{
		return startDate;
	}


	NSTimeInterval dayInterval = 60 * 60 * 24 * numberOfMonths * 30;
	return [startDate dateByAddingTimeInterval:dayInterval];
}

+ (NSArray *)months
{
	static dispatch_once_t onceToken;
	static NSArray *months = nil;
	dispatch_once(&onceToken, ^{
	    months = @[NSLocalizedString(@"January", nil),
	               NSLocalizedString(@"February", nil),
	               NSLocalizedString(@"March", nil),
	               NSLocalizedString(@"April", nil),
	               NSLocalizedString(@"May", nil),
	               NSLocalizedString(@"June", nil),
	               NSLocalizedString(@"July", nil),
	               NSLocalizedString(@"August", nil),
	               NSLocalizedString(@"September", nil),
	               NSLocalizedString(@"October", nil),
	               NSLocalizedString(@"November", nil),
	               NSLocalizedString(@"December", nil)];
	});
	return months;
}

+ (NSArray *)weekdays
{
	static dispatch_once_t onceToken;
	static NSArray *weekdays = nil;
	dispatch_once(&onceToken, ^{
	    weekdays  = @[NSLocalizedString(@"Sun", @"Sunday"),
	                  NSLocalizedString(@"Mon", @"Monday"),
	                  NSLocalizedString(@"Tue", @"Tuesday"),
	                  NSLocalizedString(@"Wed", @"Wednesday"),
	                  NSLocalizedString(@"Thu", @"Thursday"),
	                  NSLocalizedString(@"Fri", @"Friday"),
	                  NSLocalizedString(@"Sat", @"Saturday")];
	});
	return weekdays;
}

- (NSDate *)monthsFromDate:(NSDate *)date months:(NSUInteger)months
{
	if (0 == months)
	{
		return date;
	}
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.month = months;
	return [calendar dateByAddingComponents:components toDate:date options:0];
}

- (NSInteger)weeksLeftInMonthInclusive:(NSDateComponents *)components date:(NSDate *)date
{
	NSInteger weeksLeft = 0;
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSRange weekRange = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	NSInteger currentWeek = components.weekOfMonth;
	weeksLeft = weekRange.length - currentWeek + 1;
	return weeksLeft;
}

- (NSInteger)daysLeftInMonthInclusive:(NSDateComponents *)components
{
	NSInteger daysLeft = 0;

	NSInteger daysInMonth = [self daysInMonth:components.month inYear:components.year];
	daysLeft = daysInMonth - components.day + 1;
	return daysLeft;
}

- (NSDateComponents *)dateComponentsForDate:(NSDate *)date
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	return [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekCalendarUnit
	                   fromDate:date];
}

- (NSString *)monthForDate:(NSDate *)date
{
	NSDateComponents *components = [self dateComponentsForDate:date];
	int monthIndex = (int)(components.month - 1);
	return (NSString *)[[PWESCalendar months] objectAtIndex:monthIndex];
}

- (NSString *)weekDayForDate:(NSDate *)date
{
	NSDateComponents *components = [self dateComponentsForDate:date];
	int dayIndex = (int)(components.weekday - 1);
	return (NSString *)[[PWESCalendar weekdays] objectAtIndex:dayIndex];
}

- (NSInteger)daysInMonth:(NSInteger)month inYear:(NSInteger)inYear
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	if (1 > month)
	{
		month = 1;
	}
	else if (12 < month)
	{
		month = 12;
	}
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setDay:1];
	[components setMonth:month];
	[components setYear:inYear];

	NSDate *date = [calendar dateFromComponents:components];
	NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	return days.length;
}

- (NSDateComponents *)dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.day = day;
	components.month = month;
	components.year = year;
	return components;
}

- (NSInteger)monthsBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
	NSDateComponents *start = [self dateComponentsForDate:startDate];
	NSDateComponents *end = [self dateComponentsForDate:endDate];

	NSInteger startMonth = start.month;
	NSInteger endMonth = end.month;

	NSInteger months = endMonth - startMonth;
	if (0 > months)
	{
		months += 12;
	}
	else if (0 == months)
	{
		months = 1;
	}
	NSInteger lastDay = end.day - 1;
	if (0 < lastDay)
	{
		months++;
	}
	return months;
}

@end
