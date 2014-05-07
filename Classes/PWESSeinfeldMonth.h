//
//  PWESSeinfeldMonth.h
//  SeinfeldCalendarWithLayers
//
//  Created by Peter Schmidt on 24/04/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWESSeinfeldMonth : NSObject
@property (nonatomic, assign, readonly) NSInteger startDay;
@property (nonatomic, assign, readonly) NSInteger endDay;
@property (nonatomic, assign, readonly) NSInteger startWeekDay;
@property (nonatomic, assign, readonly) NSInteger endWeekDay;
@property (nonatomic, assign, readonly) NSInteger month;
@property (nonatomic, assign, readonly) NSInteger year;
@property (nonatomic, assign, readonly) NSInteger startWeek;
@property (nonatomic, assign, readonly) NSInteger endWeek;
@property (nonatomic, assign, readonly) NSInteger weeksToShow;
@property (nonatomic, assign, readonly) NSInteger totalDays;
@property (nonatomic, assign, readonly) BOOL isLastMonth;

/**
   A Seinfeld calendar is based on a number of months for which the user wishes
   to monitor a goal.
   The Seinfeld month is a convenience class returning all the relevant data required
   for constructing a view per month.
   This method returns a Seinfeld month object
   @param startDate the start date of the overall Seinfeld calendar
   @param monthIndex the index of the months to be monitored. Starts with 0
   @param numberOfMonths the overall lenght of months for a Seinfeld calendar
 */
+ (PWESSeinfeldMonth *)monthFromStartDate:(NSDate *)startDate
                               monthIndex:(NSInteger)monthIndex
                           numberOfMonths:(NSUInteger)numberOfMonths;


@end
