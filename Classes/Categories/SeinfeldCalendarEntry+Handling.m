//
//  SeinfeldCalendarEntry+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 12/07/2014.
//
//

#import "SeinfeldCalendarEntry+Handling.h"
#import "Utilities.h"

@implementation SeinfeldCalendarEntry (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
    if (nil == attributes || [attributes allKeys].count == 0)
    {
        return;
    }
    self.uID = [self stringFromValue:[attributes objectForKey:kUIDLowerCase]];
    self.hasTakenMeds = [self numberFromValue:[attributes objectForKey:kHasTakenMeds]];
    self.date = [self dateFromValue:[attributes objectForKey:kDate]];
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
                 NSNumber *number = (NSNumber *) obj;
                 NSString *trueOfFalse = ([number boolValue]) ? @"true" : @"false";
                 [dictionary setObject:trueOfFalse forKey:key];
             }
             else if ([obj isKindOfClass:[NSDate class]])
             {
                 NSDate *date = (NSDate *) obj;
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

- (NSString *)xmlString
{
    NSString *className = NSStringFromClass([self class]);
    NSMutableString *string = [NSMutableString string];

    [string appendString:[self xmlOpenForElement:className]];
    [string appendString:[self xmlAttributeString:kDateLowerCase attributeValue:self.date]];
    [string appendString:[self xmlAttributeString:kHasTakenMeds attributeValue:self.hasTakenMeds]];
    [string appendString:[self xmlAttributeString:kUIDLowerCase attributeValue:self.uID]];
    [string appendString:@"/>\r"];
    return string;

}
@end
