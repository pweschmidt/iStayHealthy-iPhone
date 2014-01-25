//
//  NSDate+Extras.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/09/2013.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (Extras)
- (NSString *)stringFromCustomDate;
- (NSDate *)dateFromCustomDateString:(NSString *)dateString;
- (NSDate *)dateByAddingDays:(NSUInteger)days;
- (NSUInteger)timeDifferenceInDays:(NSDate *)comparedDate;
- (NSUInteger)daysInMonth;
+ (NSDate *)dateFromDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year;
@end
