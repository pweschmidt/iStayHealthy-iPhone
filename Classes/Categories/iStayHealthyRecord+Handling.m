//
//  iStayHealthyRecord+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "iStayHealthyRecord+Handling.h"

@implementation iStayHealthyRecord (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return;
	}
	self.UID = [self stringFromValue:[attributes objectForKey:kUID]];
	self.isPasswordEnabled = [self numberFromValue:[attributes objectForKey:kIsPasswordEnabled]];
	self.Password = [self stringFromValue:[attributes objectForKey:kPassword]];
	self.Name = [self stringFromValue:[attributes objectForKey:kName]];
	self.isSmoker = [self numberFromValue:[attributes objectForKey:kIsSmoker]];
	self.yearOfBirth = [self dateFromValue:[attributes objectForKey:kYearOfBirth]];
	self.isDiabetic = [self numberFromValue:[attributes objectForKey:kIsDiabetic]];
	self.gender = [self stringFromValue:[attributes objectForKey:kGender]];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)attributes
{
	if (nil == attributes || [attributes allKeys].count == 0)
	{
		return NO;
	}
	BOOL isSame = NO;
	isSame = [self.UID isEqualToString:[self stringFromValue:[attributes objectForKey:kUID]]];
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
	                [string appendString:[NSString stringWithFormat:@"%d", [number intValue]]];
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
	        else if ([obj isKindOfClass:[NSString class]])
	        {
	            [dictionary setObject:obj forKey:key];
			}
		}
	}];
	return dictionary;
}

- (NSString *)xmlString
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:kXMLPreamble];
	[string appendString:@"\r"];
	[string appendString:[self xmlOpenForElement:NSStringFromClass([self class])]];
	[string appendString:[self xmlAttributeString:kUID attributeValue:self.UID]];
	[string appendString:[self xmlAttributeString:kIsPasswordEnabled attributeValue:self.isPasswordEnabled]];
	[string appendString:[self xmlAttributeString:kName attributeValue:self.Name]];
	[string appendString:[self xmlAttributeString:kIsSmoker attributeValue:self.isSmoker]];
	[string appendString:[self xmlAttributeString:kYearOfBirth attributeValue:self.yearOfBirth]];
	[string appendString:[self xmlAttributeString:kIsDiabetic attributeValue:self.isDiabetic]];
	[string appendString:[self xmlAttributeString:kGender attributeValue:self.gender]];
	[string appendString:@">\r"];
	return string;
}

@end
