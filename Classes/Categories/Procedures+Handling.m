//
//  Procedures+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Procedures+Handling.h"

@implementation Procedures (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return;
	}
	self.UID = [self stringFromValue:[attributes objectForKey:kUID]];
	self.Illness = [self stringFromValue:[attributes objectForKey:kIllness]];
	self.Date = [self dateFromValue:[attributes objectForKey:kDate]];
	if (nil != [attributes objectForKey:kEndDate] &&
	    ![[attributes objectForKey:kEndDate] isEqualToString:@""])
	{
		self.EndDate = [self dateFromValue:[attributes objectForKey:kEndDate]];
	}
	self.Name = [self stringFromValue:[attributes objectForKey:kName]];
	self.Notes = [self stringFromValue:[attributes objectForKey:kNotes]];
	self.CausedBy = [self stringFromValue:[attributes objectForKey:kCausedBy]];
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
	[string appendString:[self xmlAttributeString:kUID attributeValue:self.UID]];
	[string appendString:[self xmlAttributeString:kIllness attributeValue:self.Illness]];
	[string appendString:[self xmlAttributeString:kDate attributeValue:self.Date]];
	[string appendString:[self xmlAttributeString:kEndDate attributeValue:self.EndDate]];
	[string appendString:[self xmlAttributeString:kName attributeValue:self.Name]];
	[string appendString:[self xmlAttributeString:kNotes attributeValue:self.Notes]];
	[string appendString:[self xmlAttributeString:kCausedBy attributeValue:self.CausedBy]];
	[string appendString:@"/>\r"];
	return string;
}

- (void)addValueString:(NSString *)valueString type:(NSString *)type
{
	if ([type isEqualToString:kName])
	{
		self.Name = valueString;
	}
	else if ([type isEqualToString:kIllness])
	{
		self.Illness = valueString;
	}
	else if ([type isEqualToString:kCausedBy])
	{
		self.CausedBy = valueString;
	}
	else if ([type isEqualToString:kNotes])
	{
		self.Notes = valueString;
	}
}

- (NSString *)valueStringForType:(NSString *)type
{
	if ([type isEqualToString:kName])
	{
		return self.Name;
	}
	else if ([type isEqualToString:kIllness])
	{
		return self.Illness;
	}
	else if ([type isEqualToString:kCausedBy])
	{
		return self.CausedBy;
	}
	else if ([type isEqualToString:kNotes])
	{
		return self.Notes;
	}
	return nil;
}

@end
