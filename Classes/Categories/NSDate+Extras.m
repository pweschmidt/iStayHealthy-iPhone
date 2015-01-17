//
//  NSDate+Extras.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/09/2013.
//
//

#import "NSDate+Extras.h"
#import "Constants.h"

@implementation NSDate (Extras)
- (NSString *)stringFromCustomDate
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = kDefaultDateFormatting;
	return [formatter stringFromDate:self];
}

- (NSDate *)dateFromCustomDateString:(NSString *)dateString
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = kDefaultDateFormatting;
	return [formatter dateFromString:dateString];
}

- (NSDate *)dateByAddingDays:(NSUInteger)days
{
	return [self dateByAddingTimeInterval:3600 * 24 * days];
}

- (NSUInteger)timeDifferenceInDays:(NSDate *)comparedDate
{
	NSTimeInterval thisTimeInterval = [self timeIntervalSince1970];
	NSTimeInterval comparedTimeInterval = [comparedDate timeIntervalSince1970];
	NSTimeInterval difference = 0.0;
	if (comparedTimeInterval > thisTimeInterval)
	{
		difference = comparedTimeInterval - thisTimeInterval;
	}
	else
	{
		difference = thisTimeInterval - comparedTimeInterval;
	}
	NSTimeInterval diffInDays = difference / (3600 * 24);
	return round(diffInDays);
}

- (NSUInteger)daysInMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange days = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return days.length;
}

+ (NSDate *)dateFromDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    components.hour = 12;
    components.minute = 0;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
}

@end
