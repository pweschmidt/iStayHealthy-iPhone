//
//  OtherMedication+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "OtherMedication+Handling.h"
#import "PWESCalendar.h"

@implementation OtherMedication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return;
	}
	self.UID = [self stringFromValue:[attributes objectForKey:kUID]];
	self.Dose = [self numberFromValue:[attributes objectForKey:kDose]];
	self.StartDate = [self dateFromValue:[attributes objectForKey:kStartDate]];
	if (nil != [attributes objectForKey:kEndDate] &&
	    ![[attributes objectForKey:kEndDate] isEqualToString:@""])
	{
		self.EndDate = [self dateFromValue:[attributes objectForKey:kEndDate]];
	}
	self.Name = [self stringFromValue:[attributes objectForKey:kName]];
	self.Unit = [self stringFromValue:[attributes objectForKey:kUnit]];
	self.MedicationForm = [self stringFromValue:[attributes objectForKey:kMedicationForm]];
	self.Image = [attributes objectForKey:kImage];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return NO;
	}
	BOOL isSame = NO;
	isSame = [self.UID isEqualToString:[self stringFromValue:[attributes objectForKey:kUID]]];
	NSString *name = [self stringFromValue:[attributes objectForKey:kName]];
	NSDate *date = [self dateFromValue:[attributes objectForKey:kStartDate]];

	BOOL isSameName = ([name caseInsensitiveCompare:self.Name] == NSOrderedSame);
	BOOL isSameDate = [[PWESCalendar sharedInstance] datesAreWithin48Hours:date date2:self.StartDate];
	if (isSameName && isSameDate)
	{
		return YES;
	}
	return isSame;
}

- (NSString *)xmlString
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:[self xmlOpenForElement:NSStringFromClass([self class])]];
	[string appendString:[self xmlAttributeString:kStartDate attributeValue:self.StartDate]];
	[string appendString:[self xmlAttributeString:kEndDate attributeValue:self.EndDate]];
	[string appendString:[self xmlAttributeString:kName attributeValue:self.Name]];
	[string appendString:[self xmlAttributeString:kUnit attributeValue:self.Unit]];
	[string appendString:[self xmlAttributeString:kMedicationForm attributeValue:self.MedicationForm]];
	[string appendString:[self xmlAttributeString:kDose attributeValue:self.Dose]];
	[string appendString:[self xmlAttributeString:kUID attributeValue:self.UID]];
	[string appendString:@"/>\r"];
	return string;
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

- (void)addValueString:(NSString *)valueString type:(NSString *)type
{
	if ([type isEqualToString:kName])
	{
		self.Name = valueString;
	}
	else if ([type isEqualToString:kDose])
	{
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		formatter.numberStyle = NSNumberFormatterDecimalStyle;
		self.Dose = [formatter numberFromString:valueString];
	}
	else if ([type isEqualToString:kUnit])
	{
		self.Unit = valueString;
	}
	else if ([type isEqualToString:kMedicationForm])
	{
		self.MedicationForm = valueString;
	}
}

- (NSString *)valueStringForType:(NSString *)type
{
	if ([type isEqualToString:kName])
	{
		return self.Name;
	}
	else if ([type isEqualToString:kDose])
	{
		return [NSString stringWithFormat:@"%3.2f", [self.Dose floatValue]];
	}
	else if ([type isEqualToString:kUnit])
	{
		return self.Unit;
	}
	else if ([type isEqualToString:kMedicationForm])
	{
		return self.MedicationForm;
	}
	return nil;
}

@end
