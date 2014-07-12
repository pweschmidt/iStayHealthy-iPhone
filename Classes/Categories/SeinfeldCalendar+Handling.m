//
//  SeinfeldCalendar+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/01/2014.
//
//

#import "SeinfeldCalendar+Handling.h"
#import "Utilities.h"

@implementation SeinfeldCalendar (Handling)
- (SeinfeldCalendarEntry *)entryForDay:(NSUInteger)day
                                 month:(NSUInteger)month
                                  year:(NSUInteger)year
{
	if (nil == self.entries || 0 == self.entries.count)
	{
		return nil;
	}
	SeinfeldCalendarEntry *foundEntry = nil;
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.day = day;
	components.month = month;
	components.year = year;

	for (SeinfeldCalendarEntry *entry in self.entries)
	{
		NSDateComponents *entryComponent = [Utilities dateComponentsForDate:entry.date];
		if (entryComponent.day == components.day &&
		    entryComponent.month == components.month &&
		    entryComponent.year == components.year)
		{
			foundEntry = entry;
			break;
		}
	}

	return foundEntry;
}

- (NSDictionary *)dictionaryForAttributes
{
	__block NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	NSDictionary *attributes = [[self entity] attributesByName];
	[attributes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    if (nil != obj)
	    {
	        if ([obj isKindOfClass:[NSNumber class]])
	        {
	            NSNumber *number = (NSNumber *)obj;
	            if ([key isEqualToString:kIsCompleted])
	            {
	                NSString *trueOfFalse = ([number boolValue]) ? @"true" : @"false";
	                [dictionary setObject:trueOfFalse forKey:key];
				}
	            else
	            {
	                [dictionary setObject:[NSString stringWithFormat:@"%f", [number floatValue]] forKey:key];
				}
			}
	        else if ([obj isKindOfClass:[NSDate class]])
	        {
	            NSDate *date = (NSDate *)obj;
	            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	            formatter.dateFormat = kDefaultDateFormatting;
	            [dictionary setObject:[NSString stringWithFormat:@"%@", [formatter stringFromDate:date]] forKey:key];
			}
	        else if ([obj isKindOfClass:[NSString class]])
	        {
	            [dictionary setObject:obj forKey:key];
			}
		}
	}];
	return dictionary;
}

- (BOOL)isEqualToDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return NO;
	}
	BOOL isSame = NO;
	isSame = [self.uID isEqualToString:[self stringFromValue:[attributes objectForKey:kUIDLowerCase]]];
	return isSame;
}

- (NSString *)csvString
{
	NSMutableString *string = [NSMutableString string];
	NSDictionary *attributes = [[self entity] attributesByName];
	[attributes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    if (nil != obj && ![key isEqualToString:kUID])
	    {
	        if ([obj isKindOfClass:[NSDate class]])
	        {
	            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	            formatter.dateFormat = kDefaultDateFormatting;
	            [string appendString:[formatter stringFromDate:(NSDate *)obj]];
	            [string appendString:@"\t"];
			}
	        else if ([obj isKindOfClass:[NSNumber class]])
	        {
	            NSNumber *number = (NSNumber *)obj;
	            if (0 < [number floatValue])
	            {
	                NSString *boolString = ([number boolValue]) ? @"true" : @"false";
	                [string appendString:boolString];
	                [string appendString:@"\t"];
				}
			}
	        else if ([obj isKindOfClass:[NSString class]])
	        {
	            [string appendString:obj];
	            [string appendString:@"\t"];
			}
		}
	}];
	[string appendString:@"\r\n"];
	return string;
}

- (NSString *)xmlString
{
	NSMutableString *string = [NSMutableString string];

	return string;
}

@end
