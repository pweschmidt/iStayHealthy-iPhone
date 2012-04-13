//
//  Contacts.h
//  iStayHealthy
//
//  Created by peterschmidt on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Contacts : NSManagedObject

@property (nonatomic, retain) NSString * InsuranceID;
@property (nonatomic, retain) NSString * InsuranceName;
@property (nonatomic, retain) NSString * AppointmentContactNumber;
@property (nonatomic, retain) NSString * ClinicCountry;
@property (nonatomic, retain) NSString * EmergencyContactNumber;
@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) NSString * ClinicName;
@property (nonatomic, retain) NSString * ClinicCity;
@property (nonatomic, retain) NSString * ClinicPostcode;
@property (nonatomic, retain) NSString * ClinicID;
@property (nonatomic, retain) NSString * ConsultantName;
@property (nonatomic, retain) NSString * InsuranceAuthorisationCode;
@property (nonatomic, retain) NSString * EmergencyContactNumber2;
@property (nonatomic, retain) NSString * ClinicNurseName;
@property (nonatomic, retain) NSString * InsuranceContactNumber;
@property (nonatomic, retain) NSString * ResultsContactNumber;
@property (nonatomic, retain) NSString * ContactName;
@property (nonatomic, retain) NSString * ClinicContactNumber;
@property (nonatomic, retain) NSString * ClinicStreet;
@property (nonatomic, retain) NSString * ClinicEmailAddress;
@property (nonatomic, retain) NSString * ClinicWebSite;
@property (nonatomic, retain) NSString * InsuranceWebSite;
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
