//
//  PreviousMedication+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "PreviousMedication+Handling.h"
#import "NSManagedObject+Handling.h"
#import "Constants.h"

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
