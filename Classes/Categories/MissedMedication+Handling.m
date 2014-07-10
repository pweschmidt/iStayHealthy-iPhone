//
//  MissedMedication+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "MissedMedication+Handling.h"
#import "PWESCalendar.h"

@implementation MissedMedication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return;
	}
	self.UID = [self stringFromValue:[attributes objectForKey:kUID]];
	self.Name = [self stringFromValue:[attributes objectForKey:kName]];
	self.MissedDate = [self dateFromValue:[attributes objectForKey:kMissedDate]];
	self.Drug = [self stringFromValue:[attributes objectForKey:kDrug]];
	self.missedReason = [self stringFromValue:[attributes objectForKey:kMissedReason]];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return NO;
	}
	BOOL isSame = NO;
	isSame = [self.UID isEqualToString:[self stringFromValue:[attributes objectForKey:kUID]]];
	if (isSame)
	{
		return YES;
	}
	NSString *name = [self stringFromValue:[attributes objectForKey:kName]];
	NSDate *date = [self dateFromValue:[attributes objectForKey:kMissedDate]];
	BOOL isSameDate = [[PWESCalendar sharedInstance] datesAreWithinDays:0.5 date1:self.MissedDate date2:date];
	BOOL isSameName = ([name caseInsensitiveCompare:kName] == NSOrderedSame);
	if (isSameDate && isSameName)
	{
		return YES;
	}

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

- (NSString *)xmlString
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:[self xmlOpenForElement:NSStringFromClass([self class])]];
	[string appendString:[self xmlAttributeString:kName attributeValue:self.Name]];
	[string appendString:[self xmlAttributeString:kMissedDate attributeValue:self.MissedDate]];
	[string appendString:[self xmlAttributeString:kDrug attributeValue:self.Drug]];
	[string appendString:[self xmlAttributeString:kMissedReason attributeValue:self.missedReason]];
	[string appendString:[self xmlAttributeString:kUID attributeValue:self.UID]];
	[string appendString:@"/>\r"];
	return string;
}

@end
