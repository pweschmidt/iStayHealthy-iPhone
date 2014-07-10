//
//  PreviousMedication+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "PreviousMedication+Handling.h"
#import "PWESCalendar.h"

@implementation PreviousMedication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return;
	}
	self.startDate = [self dateFromValue:[attributes objectForKey:kStartDateLowerCase]];
	self.endDate = [self dateFromValue:[attributes objectForKey:kEndDateLowerCase]];
	self.isART = [self numberFromValue:[attributes objectForKey:kIsART]];
	self.name = [self stringFromValue:[attributes objectForKey:kNameLowerCase]];
	self.drug = [self stringFromValue:[attributes objectForKey:kDrugLowerCase]];
	self.reasonEnded = [self stringFromValue:[attributes objectForKey:kReasonEnded]];
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
	NSString *name = [self stringFromValue:[attributes objectForKey:kNameLowerCase]];
	NSDate *date = [self dateFromValue:[attributes objectForKey:kStartDateLowerCase]];

	BOOL isSameName = ([name caseInsensitiveCompare:self.name] == NSOrderedSame);
	BOOL isSameDate = [[PWESCalendar sharedInstance] datesAreWithin48Hours:date date2:self.startDate];
	if (isSameName && isSameDate)
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

- (NSString *)xmlString
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:[self xmlOpenForElement:NSStringFromClass([self class])]];
	[string appendString:[self xmlAttributeString:kStartDateLowerCase attributeValue:self.startDate]];
	[string appendString:[self xmlAttributeString:kEndDateLowerCase attributeValue:self.endDate]];
	[string appendString:[self xmlAttributeString:kIsART attributeValue:self.isART]];
	[string appendString:[self xmlAttributeString:kNameLowerCase attributeValue:self.name]];
	[string appendString:[self xmlAttributeString:kDrugLowerCase attributeValue:self.drug]];
	[string appendString:[self xmlAttributeString:kReasonEnded attributeValue:self.reasonEnded]];
	[string appendString:[self xmlAttributeString:kUIDLowerCase attributeValue:self.uID]];
	[string appendString:@"/>\r"];
	return string;
}

@end
