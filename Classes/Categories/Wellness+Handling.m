//
//  Wellness+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Wellness+Handling.h"

@implementation Wellness (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return;
	}
	self.sleepBarometer = [self numberFromValue:[attributes objectForKey:kSleepBarometer]];
	self.wellnessBarometer = [self numberFromValue:[attributes objectForKey:kWellnessBarometer]];
	self.moodBarometer = [self numberFromValue:[attributes objectForKey:kMoodBarometer]];
	self.uID = [self stringFromValue:[attributes objectForKey:kUIDLowerCase]];
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

- (NSString *)xmlString
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:[self xmlOpenForElement:NSStringFromClass([self class])]];
	[string appendString:[self xmlAttributeString:kUIDLowerCase attributeValue:self.uID]];
	[string appendString:[self xmlAttributeString:kSleepBarometer attributeValue:self.sleepBarometer]];
	[string appendString:[self xmlAttributeString:kWellnessBarometer attributeValue:self.wellnessBarometer]];
	[string appendString:[self xmlAttributeString:kMoodBarometer attributeValue:self.moodBarometer]];
	[string appendString:@"/>\r"];
	return string;
}

- (NSString *)csvString
{
	NSMutableString *string = [NSMutableString string];
	NSDictionary *attributes = [[self entity] attributesByName];
	[attributes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    if (nil != obj && ![key isEqualToString:kUIDLowerCase])
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
	                [string appendString:[NSString stringWithFormat:@"%9.2f", [number floatValue]]];
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

@end
