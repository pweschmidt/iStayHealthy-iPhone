//
//  Medication+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Medication+Handling.h"
#import "NSManagedObject+Handling.h"
#import "Constants.h"

@implementation Medication (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
    if (nil == attributes || [attributes allKeys].count == 0)
    {
        return;
    }
    self.UID = [self stringFromValue:[attributes objectForKey:kUID]];
    self.Dose = [self numberFromValue:[attributes objectForKey:kDose]];
    self.Drug = [self stringFromValue:[attributes objectForKey:kDrug]];
    self.StartDate = [self dateFromValue:[attributes objectForKey:kStartDate]];
    if (nil != [attributes objectForKey:kEndDate] &&
        ![[attributes objectForKey:kEndDate] isEqualToString:@""])
    {
        self.EndDate = [self dateFromValue:[attributes objectForKey:kEndDate]];
    }
    self.Name = [self stringFromValue:[attributes objectForKey:kName]];
    self.MedicationForm = [self stringFromValue:[attributes objectForKey:kMedicationForm]];
}
- (NSString *)xmlString
{
    NSMutableString *string = [NSMutableString string];
    [string appendString:[self xmlOpenForElement:NSStringFromClass([self class])]];
    [string appendString:[self xmlAttributeString:kStartDate attributeValue:self.StartDate]];
    [string appendString:[self xmlAttributeString:kEndDate attributeValue:self.EndDate]];
    [string appendString:[self xmlAttributeString:kName attributeValue:self.Name]];
    [string appendString:[self xmlAttributeString:kMedicationForm attributeValue:self.MedicationForm]];
    [string appendString:[self xmlAttributeString:kDrug attributeValue:self.Drug]];
    [string appendString:[self xmlAttributeString:kDose attributeValue:self.Dose]];
    [string appendString:[self xmlAttributeString:kUID attributeValue:self.UID]];
    [string appendString:@"/>\r"];
    return string;
}

@end