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
    [string appendString:[self xmlAttributeString:kClinicNurseName attributeValue:self.ClinicNurseName]];
    [string appendString:[self xmlAttributeString:kResultsContactNumber attributeValue:self.ResultsContactNumber]];
    [string appendString:[self xmlAttributeString:kClinicEmailAddress attributeValue:self.ClinicEmailAddress]];
    [string appendString:[self xmlAttributeString:kContactName attributeValue:self.ContactName]];
    [string appendString:[self xmlAttributeString:kClinicContactNumber attributeValue:self.ClinicContactNumber]];
    [string appendString:[self xmlAttributeString:kClinicStreet attributeValue:self.ClinicStreet]];
    [string appendString:@"/>\r"];
    return string;
}

@end
