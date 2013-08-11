//
//  Wellness+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Wellness+Handling.h"
#import "NSManagedObject+Handling.h"
#import "Constants.h"

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

@end
