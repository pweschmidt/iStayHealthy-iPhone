//
//  SeinfeldCalendar+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 25/01/2014.
//
//

#import "SeinfeldCalendar+Handling.h"
#import "SeinfeldCalendarEntry+Handling.h"
#import "Utilities.h"

@implementation SeinfeldCalendar (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
    if (nil == attributes || [attributes allKeys].count == 0)
    {
        return;
    }
    self.uID = [self stringFromValue:[attributes objectForKey:kUIDLowerCase]];
    self.score = [self numberFromValue:[attributes objectForKey:kScore]];
    if (nil != self.score && 100 < self.score.floatValue)
    {
        self.score = [NSNumber numberWithFloat:100];
    }
    self.startDate = [self dateFromValue:[attributes objectForKey:kStartDateLowerCase]];
    self.endDate = [self dateFromValue:[attributes objectForKey:kEndDateLowerCase]];
    self.isCompleted = [self numberFromValue:[attributes objectForKey:kIsCompleted]];
    NSArray *entries = [attributes objectForKey:kEntries];
    if (nil != entries)
    {
        self.entries = [NSSet setWithArray:entries];
    }
}

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
                 NSNumber *number = (NSNumber *) obj;
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
                 NSDate *date = (NSDate *) obj;
                 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                 formatter.dateFormat = kDefaultDateFormatting;
                 [dictionary setObject:[NSString stringWithFormat:@"%@", [formatter stringFromDate:date]] forKey:key];
             }
             else if ([obj isKindOfClass:[NSString class]])
             {
                 [dictionary setObject:obj forKey:key];
             }
             else if ([key isEqualToString:kEntries])
             {
                 NSSet *entries = (NSSet *) obj;
                 [dictionary setObject:[entries allObjects] forKey:key];
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
                 [string appendString:[formatter stringFromDate:(NSDate *) obj]];
                 [string appendString:@"\t"];
             }
             else if ([obj isKindOfClass:[NSNumber class]])
             {
                 NSNumber *number = (NSNumber *) obj;
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
    NSString *className = NSStringFromClass([self class]);
    NSMutableString *string = [NSMutableString string];

    [string appendString:[self xmlOpenForElement:className]];
    [string appendString:[self xmlAttributeString:kStartDateLowerCase attributeValue:self.startDate]];
    [string appendString:[self xmlAttributeString:kEndDateLowerCase attributeValue:self.endDate]];
    [string appendString:[self xmlAttributeString:kIsCompleted attributeValue:self.isCompleted]];
    [string appendString:[self xmlAttributeString:kScore attributeValue:self.score]];
    [string appendString:[self xmlAttributeString:kUIDLowerCase attributeValue:self.uID]];
    if (nil != self.entries && 0 < self.entries.count)
    {
        [string appendString:@">\r"];
        [self.entries enumerateObjectsUsingBlock:^(SeinfeldCalendarEntry *entry, BOOL *stop) {
             NSString *entryString = entry.xmlString;
             if (nil != entryString)
             {
                 [string appendString:entryString];
             }
         }];
        NSString *closeString = [NSString stringWithFormat:@"</%@>", className];
        [string appendString:closeString];
    }
    else
    {
        [string appendString:@"/>\r"];
    }
    return string;
}

@end
