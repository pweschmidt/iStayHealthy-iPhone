//
//  Contacts+Handling.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "Contacts+Handling.h"
#import "NSManagedObject+Handling.h"
#import "Constants.h"

@implementation Contacts (Handling)
- (void)importFromDictionary:(NSDictionary *)attributes
{
    if (nil == attributes || [attributes allKeys].count == 0)
    {
        return;
    }
    self.UID = [self stringFromValue:[attributes objectForKey:kUID]];
    self.InsuranceID = [self stringFromValue:[attributes objectForKey:kInsuranceID]];
    self.InsuranceName = [self stringFromValue:[attributes objectForKey:kInsuranceName]];
    self.AppointmentContactNumber = [self stringFromValue:[attributes objectForKey:kAppointmentContactNumber]];
    self.InsuranceWebSite = [self stringFromValue:[attributes objectForKey:kInsuranceWebSite]];
    self.ClinicCountry = [self stringFromValue:[attributes objectForKey:kClinicCountry]];
    self.EmergencyContactNumber = [self stringFromValue:[attributes objectForKey:kEmergencyContactNumber]];
    self.ClinicName = [self stringFromValue:[attributes objectForKey:kClinicName]];
    self.ClinicCity = [self stringFromValue:[attributes objectForKey:kClinicCity]];
    self.ClinicPostcode = [self stringFromValue:[attributes objectForKey:kClinicPostcode]];
    self.ClinicID = [self stringFromValue:[attributes objectForKey:kClinicID]];
    self.ClinicWebSite = [self stringFromValue:[attributes objectForKey:kClinicWebSite]];
    self.ConsultantName = [self stringFromValue:[attributes objectForKey:kConsultantName]];
    self.InsuranceAuthorisationCode = [self stringFromValue:[attributes objectForKey:kInsuranceAuthorisationCode]];
    self.InsuranceContactNumber = [self stringFromValue:[attributes objectForKey:kInsuranceContactNumber]];
    self.EmergencyContactNumber2 = [self stringFromValue:[attributes objectForKey:kEmergencyContactNumber2]];
    self.ClinicNurseName = [self stringFromValue:[attributes objectForKey:kClinicNurseName]];
    self.ResultsContactNumber = [self stringFromValue:[attributes objectForKey:kResultsContactNumber]];
    self.ClinicEmailAddress = [self stringFromValue:[attributes objectForKey:kClinicEmailAddress]];
    self.ContactName = [self stringFromValue:[attributes objectForKey:kContactName]];
    self.ClinicContactNumber = [self stringFromValue:[attributes objectForKey:kClinicContactNumber]];
    self.ClinicStreet = [self stringFromValue:[attributes objectForKey:kClinicStreet]];
}

- (NSString *)xmlString
{
    NSMutableString *string = [NSMutableString string];
    [string appendString:[self xmlOpenForElement:NSStringFromClass([self class])]];
    [string appendString:[self xmlAttributeString:kUID attributeValue:self.UID]];
    [string appendString:[self xmlAttributeString:kInsuranceID attributeValue:self.InsuranceID]];
    [string appendString:[self xmlAttributeString:kInsuranceName attributeValue:self.InsuranceName]];
    [string appendString:[self xmlAttributeString:kAppointmentContactNumber attributeValue:self.AppointmentContactNumber]];
    [string appendString:[self xmlAttributeString:kInsuranceWebSite attributeValue:self.InsuranceWebSite]];
    [string appendString:[self xmlAttributeString:kClinicCountry attributeValue:self.ClinicCountry]];
    [string appendString:[self xmlAttributeString:kEmergencyContactNumber attributeValue:self.EmergencyContactNumber]];
    [string appendString:[self xmlAttributeString:kClinicName attributeValue:self.ClinicName]];
    [string appendString:[self xmlAttributeString:kClinicCity attributeValue:self.ClinicCity]];
    [string appendString:[self xmlAttributeString:kClinicPostcode attributeValue:self.ClinicPostcode]];
    [string appendString:[self xmlAttributeString:kClinicID attributeValue:self.ClinicID]];
    [string appendString:[self xmlAttributeString:kClinicWebSite attributeValue:self.ClinicWebSite]];
    [string appendString:[self xmlAttributeString:kConsultantName attributeValue:self.ConsultantName]];
    [string appendString:[self xmlAttributeString:kInsuranceAuthorisationCode attributeValue:self.InsuranceAuthorisationCode]];
    [string appendString:[self xmlAttributeString:kInsuranceContactNumber attributeValue:self.InsuranceContactNumber]];
    [string appendString:[self xmlAttributeString:kEmergencyContactNumber2 attributeValue:self.EmergencyContactNumber2]];
    [string appendString:[self xmlAttributeString:kInsuranceAuthorisationCode attributeValue:self.ClinicNurseName]];
    [string appendString:[self xmlAttributeString:kResultsContactNumber attributeValue:self.ResultsContactNumber]];
    [string appendString:[self xmlAttributeString:kClinicEmailAddress attributeValue:self.ClinicEmailAddress]];
    [string appendString:[self xmlAttributeString:kContactName attributeValue:self.ContactName]];
    [string appendString:[self xmlAttributeString:kClinicContactNumber attributeValue:self.ClinicContactNumber]];
    [string appendString:[self xmlAttributeString:kClinicStreet attributeValue:self.ClinicStreet]];
    [string appendString:@"/>\r"];
    return string;
}

- (void)addValueString:(NSString *)valueString type:(NSString *)type
{
    if ([type isEqualToString:kClinicName])
    {
        self.ClinicName = valueString;
    }
    else if ([type isEqualToString:kClinicID])
    {
        self.ClinicID = valueString;
    }
    else if ([type isEqualToString:kClinicWebSite])
    {
        self.ClinicWebSite = valueString;
    }
    else if ([type isEqualToString:kConsultantName])
    {
        self.ConsultantName = valueString;
    }
    else if ([type isEqualToString:kClinicEmailAddress])
    {
        self.ClinicEmailAddress = valueString;
    }
    else if ([type isEqualToString:kContactName])
    {
        self.ContactName = valueString;
    }
    else if ([type isEqualToString:kClinicContactNumber])
    {
        self.ClinicContactNumber = valueString;
    }
    else if ([type isEqualToString:kClinicStreet])
    {
        self.ClinicStreet = valueString;
    }
    else if ([type isEqualToString:kResultsContactNumber])
    {
        self.ResultsContactNumber = valueString;
    }
    else if ([type isEqualToString:kInsuranceAuthorisationCode])
    {
        self.InsuranceAuthorisationCode = valueString;
    }
    else if ([type isEqualToString:kEmergencyContactNumber2])
    {
        self.EmergencyContactNumber2 = valueString;
    }
    else if ([type isEqualToString:kInsuranceContactNumber])
    {
        self.InsuranceContactNumber = valueString;
    }
    else if ([type isEqualToString:kInsuranceAuthorisationCode])
    {
        self.InsuranceAuthorisationCode = valueString;
    }
    else if ([type isEqualToString:kClinicPostcode])
    {
        self.ClinicPostcode = valueString;
    }
    else if ([type isEqualToString:kClinicCity])
    {
        self.ClinicCity = valueString;
    }
    else if ([type isEqualToString:kEmergencyContactNumber])
    {
        self.EmergencyContactNumber = valueString;
    }
    else if ([type isEqualToString:kClinicCountry])
    {
        self.ClinicCountry = valueString;
    }
    else if ([type isEqualToString:kInsuranceWebSite])
    {
        self.InsuranceWebSite = valueString;
    }
    else if ([type isEqualToString:kAppointmentContactNumber])
    {
        self.AppointmentContactNumber = valueString;
    }
    else if ([type isEqualToString:kInsuranceName])
    {
        self.InsuranceName = valueString;
    }
    else if ([type isEqualToString:kInsuranceID])
    {
        self.InsuranceID = valueString;
    }
}

- (NSString *)valueStringForType:(NSString *)type
{
    if ([type isEqualToString:kClinicName])
    {
        return self.ClinicName;
    }
    else if ([type isEqualToString:kClinicID])
    {
        return self.ClinicID;
    }
    else if ([type isEqualToString:kClinicWebSite])
    {
        return self.ClinicWebSite;
    }
    else if ([type isEqualToString:kConsultantName])
    {
        return self.ConsultantName;
    }
    else if ([type isEqualToString:kClinicEmailAddress])
    {
        return self.ClinicEmailAddress;
    }
    else if ([type isEqualToString:kContactName])
    {
        return self.ContactName;
    }
    else if ([type isEqualToString:kClinicContactNumber])
    {
        return self.ClinicContactNumber;
    }
    else if ([type isEqualToString:kClinicStreet])
    {
        return self.ClinicStreet;
    }
    else if ([type isEqualToString:kResultsContactNumber])
    {
        return self.ResultsContactNumber;
    }
    else if ([type isEqualToString:kInsuranceAuthorisationCode])
    {
        return self.InsuranceAuthorisationCode;
    }
    else if ([type isEqualToString:kEmergencyContactNumber2])
    {
        return self.EmergencyContactNumber2;
    }
    else if ([type isEqualToString:kInsuranceContactNumber])
    {
        return self.InsuranceContactNumber;
    }
    else if ([type isEqualToString:kInsuranceAuthorisationCode])
    {
        return self.InsuranceAuthorisationCode;
    }
    else if ([type isEqualToString:kClinicPostcode])
    {
        return self.ClinicPostcode;
    }
    else if ([type isEqualToString:kClinicCity])
    {
        return self.ClinicCity;
    }
    else if ([type isEqualToString:kEmergencyContactNumber])
    {
        return self.EmergencyContactNumber;
    }
    else if ([type isEqualToString:kClinicCountry])
    {
        return self.ClinicCountry;
    }
    else if ([type isEqualToString:kInsuranceWebSite])
    {
        return self.InsuranceWebSite;
    }
    else if ([type isEqualToString:kAppointmentContactNumber])
    {
        return self.AppointmentContactNumber;
    }
    else if ([type isEqualToString:kInsuranceName])
    {
        return self.InsuranceName;
    }
    else if ([type isEqualToString:kInsuranceID])
    {
        return self.InsuranceID;
    }
    return nil;
}

@end
