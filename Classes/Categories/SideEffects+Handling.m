//
//  SideEffects+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "SideEffects+Handling.h"
#import "PWESCalendar.h"

@implementation SideEffects (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return;
	}
	self.SideEffect = [self stringFromValue:[attributes objectForKey:kSideEffect]];
	self.SideEffectDate = [self dateFromValue:[attributes objectForKey:kSideEffectDate]];
	self.Name = [self stringFromValue:[attributes objectForKey:kName]];
	self.UID = [self stringFromValue:[attributes objectForKey:kUID]];
	self.Drug = [self stringFromValue:[attributes objectForKey:kDrug]];
	self.seriousness = [self stringFromValue:[attributes objectForKey:kSeriousness]];
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
	            [dictionary setObject:[NSString stringWithFormat:@"%f", [number floatValue]] forKey:key];
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
	isSame = [self.UID isEqualToString:[self stringFromValue:[attributes objectForKey:kUID]]];

	NSString *name = [self stringFromValue:[attributes objectForKey:kName]];
	NSString *effect = [self stringFromValue:[attributes objectForKey:kSideEffect]];
	NSDate *date = [self dateFromValue:[attributes objectForKey:kSideEffectDate]];

	BOOL isSameEffect = ([effect caseInsensitiveCompare:self.SideEffect] == NSOrderedSame);
	BOOL isSameDate = [[PWESCalendar sharedInstance] datesAreWithinDays:1.0 date1:date date2:self.SideEffectDate];
	BOOL isSameDrug = ([name caseInsensitiveCompare:self.Name] == NSOrderedSame);
	if (isSameEffect && isSameDate && isSameDrug)
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
	[string appendString:[self xmlAttributeString:kUID attributeValue:self.UID]];
	[string appendString:[self xmlAttributeString:kSideEffect attributeValue:self.SideEffect]];
	[string appendString:[self xmlAttributeString:kSideEffectDate attributeValue:self.SideEffectDate]];
	[string appendString:[self xmlAttributeString:kName attributeValue:self.Name]];
	[string appendString:[self xmlAttributeString:kDrug attributeValue:self.Drug]];
	[string appendString:[self xmlAttributeString:kSeriousness attributeValue:self.seriousness]];
	[string appendString:@"/>\r"];
	return string;
}

@end
