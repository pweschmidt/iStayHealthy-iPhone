//
//  Procedures+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Procedures+Handling.h"
#import "NSManagedObject+Handling.h"
#import "Constants.h"

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

@end
