//
//  PWESCalendar.h
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 24/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWESCalendar : NSObject
+ (PWESCalendar *)sharedInstance;

+ (NSArray *)months;

+ (NSArray *)weekdays;

- (NSDate *)dateFromStartDate:(NSDate *)startDate
               numberOfMonths:(NSUInteger)numberOfMonths;

- (NSInteger)daysInMonth:(NSInteger)month inYear:(NSInteger)inYear;
- (NSString *)weekDayForDate:(NSDate *)date;
- (NSString *)monthForDate:(NSDate *)date;
- (NSDateComponents *)dateComponentsForDate:(NSDate *)date;
- (NSInteger)daysLeftInMonthInclusive:(NSDateComponents *)components;
- (NSInteger)weeksLeftInMonthInclusive:(NSDateComponents *)components date:(NSDate *)date;
- (NSDate *)monthsFromDate:(NSDate *)date months:(NSUInteger)months;
- (NSDateComponents *)dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
- (NSInteger)monthsBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (NSInteger)daysBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (BOOL)datesAreWithin48Hours:(NSDate *)date1 date2:(NSDate *)date2;
- (BOOL)datesAreWithinDays:(NSTimeInterval)days date1:(NSDate *)date1 date2:(NSDate *)date2;
@end
