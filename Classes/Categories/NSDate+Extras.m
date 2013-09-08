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
@end
