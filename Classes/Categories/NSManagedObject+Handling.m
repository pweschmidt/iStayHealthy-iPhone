//
//  NSManagedObject+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "NSManagedObject+Handling.h"
#import "Constants.h"
@implementation NSManagedObject (Handling)

- (NSDate *)dateFromValue:(id)value
{
    if (nil == value || [NSNull class] == value || ![value isKindOfClass:[NSString class]])
    {
        return [NSDate date];
    }
    NSString *valueString = (NSString *) value;
    if ([valueString isEqualToString:@""] || [valueString hasPrefix:@"(null)"])
    {
        return [NSDate date];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MMM-yy HH:mm:ss";
    NSDate *formattedDate = [dateFormatter dateFromString:valueString];
    if (nil == formattedDate || NULL == formattedDate || [NSNull class] == formattedDate)
    {
        formattedDate = [NSDate date];
    }

    return formattedDate;
}

- (NSNumber *)numberFromValue:(id)value
{
    if (nil == value || [NSNull class] == value || ![value isKindOfClass:[NSString class]])
    {
        return [NSNumber numberWithInt:-1];
    }
    NSString *valueString = (NSString *) value;
    if ([valueString isEqualToString:@""] || [valueString hasPrefix:@"(null)"])
    {
        return [NSNumber numberWithInt:-1];
    }
    NSString *lowercaseValueString = [valueString lowercaseString];
    if ([lowercaseValueString hasPrefix:NSLocalizedString(@"undetectable", nil)])
    {
        return [NSNumber numberWithInt:1];
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    return [numberFormatter numberFromString:valueString];
}

- (NSString *)stringFromValue:(id)value
{
    if (nil == value || [NSNull class] == value || ![value isKindOfClass:[NSString class]])
    {
        return @"";
    }
    else
    {
        return (NSString *) value;
    }
}

- (NSString *)csvRowHeader
{
    NSMutableString *string = [NSMutableString string];
    NSDictionary *attributes = [[self entity] attributesByName];

    for (NSString *attribute in attributes)
    {
        [string appendString:attribute];
        [string appendString:@"\t"];
    }
    [string appendString:@"\r\n"];

    return string;
}

- (NSString *)csvString
{
    NSMutableString *string = [NSMutableString string];

    return string;
}

- (NSString *)xmlString
{
    NSMutableString *string = [NSMutableString string];

    return string;
}

- (NSString *)xmlOpenForElement:(NSString *)name
{
    return [NSString stringWithFormat:@"<%@ ", name];
}

- (NSString *)xmlClose:(NSString *)name
{
    if (nil == name)
    {
        return @"/>\r";
    }
    else
    {
        return [NSString stringWithFormat:@"</%@>\r", name];
    }
}

- (NSString *)xmlAttributeString:(NSString *)attributeName attributeValue:(id)attributeValue
{
    NSMutableString *string = [NSMutableString string];

    if (nil == attributeValue)
    {
        return @"";
    }

    if ([attributeValue isKindOfClass:[NSNumber class]])
    {
        float value = [attributeValue floatValue];
        if (0 < value)
        {
            [string appendString:attributeName];
            [string appendString:[NSString stringWithFormat:@"=\"%3.2f\" ", value]];
        }
    }
    else if ([attributeValue isKindOfClass:[NSString class]])
    {
        if (![attributeValue isEqualToString:@""])
        {
            [string appendString:attributeName];
            [string appendString:[NSString stringWithFormat:@"=\"%@\" ", attributeValue]];
        }
    }
    else if ([attributeValue isKindOfClass:[NSDate class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd-MMM-yy HH:mm:ss";
        NSString *dateString = [dateFormatter stringFromDate:attributeValue];
        [string appendString:attributeName];
        [string appendString:[NSString stringWithFormat:@"=\"%@\" ", dateString]];
    }
    return string;
}

@end
