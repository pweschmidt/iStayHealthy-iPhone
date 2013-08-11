//
//  iStayHealthyRecord+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "iStayHealthyRecord+Handling.h"
#import "NSManagedObject+Handling.h"
#import "Constants.h"

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
