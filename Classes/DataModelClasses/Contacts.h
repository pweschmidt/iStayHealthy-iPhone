//
//  Contacts.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Contacts : NSManagedObject

@property (nonatomic, strong) NSString * InsuranceID;
@property (nonatomic, strong) NSString * InsuranceName;
@property (nonatomic, strong) NSString * AppointmentContactNumber;
@property (nonatomic, strong) NSString * InsuranceWebSite;
@property (nonatomic, strong) NSString * ClinicCountry;
@property (nonatomic, strong) NSString * EmergencyContactNumber;
@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSString * ClinicName;
@property (nonatomic, strong) NSString * ClinicCity;
@property (nonatomic, strong) NSString * ClinicPostcode;
@property (nonatomic, strong) NSString * ClinicID;
@property (nonatomic, strong) NSString * ClinicWebSite;
@property (nonatomic, strong) NSString * ConsultantName;
@property (nonatomic, strong) NSString * InsuranceAuthorisationCode;
@property (nonatomic, strong) NSString * InsuranceContactNumber;
@property (nonatomic, strong) NSString * EmergencyContactNumber2;
@property (nonatomic, strong) NSString * ClinicNurseName;
@property (nonatomic, strong) NSString * ResultsContactNumber;
@property (nonatomic, strong) NSString * ClinicEmailAddress;
@property (nonatomic, strong) NSString * ContactName;
@property (nonatomic, strong) NSString * ClinicContactNumber;
@property (nonatomic, strong) NSString * ClinicStreet;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
