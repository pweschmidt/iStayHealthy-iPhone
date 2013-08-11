//
//  XMLLoader.m
//  iStayHealthy
//
//  Created by peterschmidt on 14/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLLoader.h"
#import "XMLDocument.h"
#import "XMLElement.h"
#import "XMLAttribute.h"
//#import "XMLDefinitions.h"
#import "Constants.h"
#import "DataLoader.h"

@interface XMLLoader ()
- (void)postNotification;
@end

@implementation XMLLoader
- (id)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (void)postNotification
{
    NSNotification* refreshNotification =
    [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                  object:self
                                userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    
}


+ (BOOL)isXML:(NSData *)data
{
    NSString *testString = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    if ([testString hasPrefix:kXMLPreamble])
    {
        return YES;
    }
    return NO;
}



/**
 */
- (id)initWithData:(NSData *)data
{
    self = [self init];
    if (nil != self)
    {
#ifdef APPDEBUG
        NSLog(@"XMLLoader:initWithData");
#endif
        self.xmlParser = [[NSXMLParser alloc] initWithData:data];
        [self.xmlParser setDelegate:self];
        [self.xmlParser setShouldProcessNamespaces:NO];
        [self.xmlParser setShouldReportNamespacePrefixes:NO];
        [self.xmlParser setShouldResolveExternalEntities:NO];
    }
    
    return self;
}

/**
 parse the XML file
 */
- (BOOL)startParsing:(NSError **)parseError
{
#ifdef APPDEBUG
    NSLog(@"XMLLoader:startParsing");
#endif
    parseError = nil;
    [self.xmlParser parse];    
    if (nil == &parseError)
    {
        return YES;
    }
    return NO;
}

/**
 sync up with what we have in the database. Only add those elements for which we haven't
 got an existing UID
 */
- (BOOL)synchronise
{
    if (nil == self.document)
    {
        return NO;
    }
    if (nil == [self.document root])
    {
        return NO;
    }
    DataLoader *loader = [[DataLoader alloc]init];
    BOOL success = [loader getSQLData];
    if (!success)
    {
        return NO;
    }
    XMLElement *results = [self.document elementForName:kResults];
    if (nil != results)
    {
        NSMutableArray *children = [results childElements];
        for (XMLElement *element in children)
        {
            [loader addResultsToSQL:element];
        }
    }
    XMLElement *meds = [self.document elementForName:kMedications];
    if (nil != meds)
    {
        NSMutableArray *children = [meds childElements];
        for (XMLElement *element in children)
        {
            [loader addMedicationsToSQL:element];
        }
    }
    XMLElement *missedMeds = [self.document elementForName:kMissedMedications];
    if (nil != missedMeds)
    {
        NSMutableArray *children = [missedMeds childElements];
        for (XMLElement *element in children)
        {
            [loader addMissedMedicationToSQL:element];
        }
    }
    XMLElement *otherMeds = [self.document elementForName:kOtherMedications];
    if (nil != otherMeds)
    {
        NSMutableArray *children = [otherMeds childElements];
        for (XMLElement *element in children)
        {
            [loader addOtherMedicationsToSQL:element];
        }
    }
    
    XMLElement *contacts = [self.document elementForName:kClinicalContacts];
    if (nil != contacts) {
        NSMutableArray *children = [contacts childElements];
        for (XMLElement *element in children) {
            [loader addClinicsToSQL:element];
        }
    }
    
    XMLElement *procedures = [self.document elementForName:kIllnessAndProcedures];
    if(nil !=  procedures)
    {
        NSMutableArray *children = [procedures childElements];
        for (XMLElement *element in children)
        {
            [loader addProceduresToSQL:element];
        }
    }

    XMLElement *effects = [self.document elementForName:kHIVSideEffects];
    if(nil !=  effects)
    {
        NSMutableArray *children = [effects childElements];
        for (XMLElement *element in children)
        {
            [loader addSideEffectsToSQL:element];
        }
    }
    
    XMLElement *previousMeds = [self.document elementForName:kPreviousMedications];
    if (nil != previousMeds)
    {
        NSMutableArray *children = [previousMeds childElements];
        for (XMLElement *element in children)
        {
            [loader addPreviousMedicationsToSQL:element];
        }
    }
    [self postNotification];
    return YES;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
#ifdef APPDEBUG
    NSLog(@"XMLLoader:parserDidStartDocument");
#endif
    self.document = [[XMLDocument alloc] init];  
    self.results = nil;
    self.otherMedications = nil;
    self.alerts = nil;
    self.missedMedications = nil;
    self.medications = nil;
    self.sideEffects = nil;
    self.procedures = nil;
    self.contacts = nil;
    self.previousMedications = nil;
}



/**
 parse the XML file
 */
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if(qName)
    {
		elementName = qName;
	}

    XMLElement *root = [self.document root];
    if ([elementName isEqualToString:kXMLElementRoot])
    {


        [root addAttribute:kDBVersion andValue:[attributeDict valueForKey:kDBVersion]];
        [root addAttribute:kFromDevice andValue:[attributeDict valueForKey:kFromDevice]];
        [root addAttribute:kFromDate andValue:[attributeDict valueForKey:kFromDate]];
    }
    else if ([elementName isEqualToString:kResults] && (nil == self.results))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kResults];
        self.results = tmpElement;
    }
    else if ([elementName isEqualToString:kMedications] && (nil == self.medications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kMedications];
        self.medications = tmpElement;
    }
    else if ([elementName isEqualToString:kOtherMedications] && (nil == self.otherMedications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kOtherMedications];
        self.otherMedications = tmpElement;
    }
    else if ([elementName isEqualToString:kMissedMedications] && (nil == self.missedMedications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kMissedMedications];
        self.missedMedications = tmpElement;
    }
    else if ([elementName isEqualToString:kClinicalContacts] && (nil == self.contacts))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kClinicalContacts];
        self.contacts = tmpElement;
    }
    else if ([elementName isEqualToString:kHIVSideEffects] && (nil == self.sideEffects))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kHIVSideEffects];
        self.sideEffects = tmpElement;
    }
    else if ([elementName isEqualToString:kIllnessAndProcedures] && (nil == self.procedures))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kIllnessAndProcedures];
        self.procedures = tmpElement;
    }
    else if ([elementName isEqualToString:kPreviousMedications] && (nil == self.previousMedications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kPreviousMedications];
        self.previousMedications = tmpElement;
    }

    //child elements
    else if([elementName isEqualToString:kResult] && (nil != self.results))
    {
        XMLElement *result = [[XMLElement alloc]initWithName:kResult];
        [result addAttribute:kResultsDate andValue:[attributeDict valueForKey:kResultsDate]];
        [result addAttribute:kCD4 andValue:[attributeDict valueForKey:kCD4]];
        [result addAttribute:kCD4Percent andValue:[attributeDict valueForKey:kCD4Percent]];        
        NSString *vl = [attributeDict valueForKey:kViralLoad];
        if ([vl isEqualToString:@"undetectable"])
        {
            [result addAttribute:kViralLoad andValue:@"0"];
        }
        else
            [result addAttribute:kViralLoad andValue:vl];
        
        NSString *hepVl = [attributeDict valueForKey:kHepCViralLoad];
        if ([hepVl isEqualToString:@"undetectable"])
        {
            [result addAttribute:kHepCViralLoad andValue:@"0"];
        }
        else
            [result addAttribute:kHepCViralLoad andValue:hepVl];
        
        [result addAttribute:kGlucose andValue:[attributeDict valueForKey:kGlucose]];
        [result addAttribute:kTotalCholesterol andValue:[attributeDict valueForKey:kTotalCholesterol]];
        [result addAttribute:kLDL andValue:[attributeDict valueForKey:kLDL]];
        [result addAttribute:kHDL andValue:[attributeDict valueForKey:kHDL]];

        [result addAttribute:kHemoglobulin andValue:[attributeDict valueForKey:kHemoglobulin]];
        [result addAttribute:kPlatelet andValue:[attributeDict valueForKey:kPlatelet]];
        [result addAttribute:kWhiteBloodCells andValue:[attributeDict valueForKey:kWhiteBloodCells]];
        [result addAttribute:kRedBloodCells andValue:[attributeDict valueForKey:kRedBloodCells]];
        
        [result addAttribute:kWeight andValue:[attributeDict valueForKey:kWeight]];
        [result addAttribute:kSystole andValue:[attributeDict valueForKey:kSystole]];
        [result addAttribute:kDiastole andValue:[attributeDict valueForKey:kDiastole]];
        [result addAttribute:kUID andValue:[attributeDict valueForKey:kUID]];
        [self.results addChild:result];
    }
    else if([elementName isEqualToString:kMedication] && (nil != self.medications))
    {
        XMLElement *medication = [[XMLElement alloc]initWithName:kMedication];
        [medication addAttribute:kStartDate andValue:[attributeDict valueForKey:kStartDate]];
        [medication addAttribute:kName andValue:[attributeDict valueForKey:kName]];
        [medication addAttribute:kDrug andValue:[attributeDict valueForKey:kDrug]];
        [medication addAttribute:kMedicationForm andValue:[attributeDict valueForKey:kMedicationForm]];
        [medication addAttribute:kDose andValue:[attributeDict valueForKey:kDose]];
        [medication addAttribute:kUID andValue:[attributeDict valueForKey:kUID]];
        
        [self.medications addChild:medication];
    }
    else if([elementName isEqualToString:kMissedMedication] && (nil != self.missedMedications))
    {
        XMLElement *missedMedication = [[XMLElement alloc]initWithName:kMissedMedication];
        [missedMedication addAttribute:kMissedDate andValue:[attributeDict valueForKey:kMissedDate]];
        [missedMedication addAttribute:kName andValue:[attributeDict valueForKey:kName]];
        [missedMedication addAttribute:kDrug andValue:[attributeDict valueForKey:kDrug]];
        [missedMedication addAttribute:kUID andValue:[attributeDict valueForKey:kUID]];
        [missedMedication addAttribute:kMissedReason andValue:[attributeDict valueForKey:kMissedReason]];
        [self.missedMedications addChild:missedMedication];
    }
    else if([elementName isEqualToString:kOtherMedication] && (nil != self.otherMedications))
    {
        XMLElement *otherMedication = [[XMLElement alloc]initWithName:kOtherMedication];
        [otherMedication addAttribute:kStartDate andValue:[attributeDict valueForKey:kStartDate]];
        [otherMedication addAttribute:kName andValue:[attributeDict valueForKey:kName]];
        [otherMedication addAttribute:kDrug andValue:[attributeDict valueForKey:kDrug]];
        [otherMedication addAttribute:kMedicationForm andValue:[attributeDict valueForKey:kMedicationForm]];
        [otherMedication addAttribute:kDose andValue:[attributeDict valueForKey:kDose]];
        [otherMedication addAttribute:kUnit andValue:[attributeDict valueForKey:kUnit]];
        [otherMedication addAttribute:kUID andValue:[attributeDict valueForKey:kUID]];
        [self.otherMedications addChild:otherMedication];
    }
    else if([elementName isEqualToString:kContacts] && (nil != self.contacts))
    {
        XMLElement *contact = [[XMLElement alloc]initWithName:kContacts];
        [contact addAttribute:kClinicName andValue:[attributeDict valueForKey:kClinicName]];
        [contact addAttribute:kClinicID andValue:[attributeDict valueForKey:kClinicID]];
        [contact addAttribute:kClinicStreet andValue:[attributeDict valueForKey:kClinicStreet]];
        [contact addAttribute:kClinicPostcode andValue:[attributeDict valueForKey:kClinicPostcode]];
        [contact addAttribute:kClinicCity andValue:[attributeDict valueForKey:kClinicCity]];
        [contact addAttribute:kClinicContactNumber andValue:[attributeDict valueForKey:kClinicContactNumber]];
        [contact addAttribute:kEmergencyContactNumber andValue:[attributeDict valueForKey:kEmergencyContactNumber]];
        [contact addAttribute:kClinicEmailAddress andValue:[attributeDict valueForKey:kClinicEmailAddress]];
        [contact addAttribute:kClinicWebSite andValue:[attributeDict valueForKey:kClinicWebSite]];
        
        [self.contacts addChild:contact];
    }
    else if([elementName isEqualToString:kSideEffects] && (nil != self.sideEffects))
    {
        XMLElement *effect = [[XMLElement alloc]initWithName:kSideEffects];
        [effect addAttribute:kSideEffect andValue:[attributeDict valueForKey:kSideEffect]];
        [effect addAttribute:kSideEffectDate andValue:[attributeDict valueForKey:kSideEffectDate]];
        [effect addAttribute:kName andValue:[attributeDict valueForKey:kName]];
        [effect addAttribute:kDrug andValue:[attributeDict valueForKey:kDrug]];
        [effect addAttribute:kSeriousness andValue:[attributeDict valueForKey:kSeriousness]];
        [self.sideEffects addChild:effect];
    }
    else if([elementName isEqualToString:kProcedures] && (nil != self.procedures))
    {
        XMLElement *procs = [[XMLElement alloc]initWithName:kProcedures];
        [procs addAttribute:kName andValue:[attributeDict valueForKey:kName]];
        [procs addAttribute:kIllness andValue:[attributeDict valueForKey:kIllness]];
        [procs addAttribute:kDate andValue:[attributeDict valueForKey:kDate]];
        [self.procedures addChild:procs];
    }
    else if ([elementName isEqualToString:kPreviousMedication] && (nil != self.previousMedications))
    {
        XMLElement *prev = [[XMLElement alloc] initWithName:kPreviousMedication];
        [prev addAttribute:kStartDateLowerCase andValue:[attributeDict valueForKey:kStartDateLowerCase]];
        [prev addAttribute:kEndDateLowerCase andValue:[attributeDict valueForKey:kEndDateLowerCase]];
        [prev addAttribute:kNameLowerCase andValue:[attributeDict valueForKey:kNameLowerCase]];
        [prev addAttribute:kDrugLowerCase andValue:[attributeDict valueForKey:kDrugLowerCase]];
        [prev addAttribute:kIsART andValue:[attributeDict valueForKey:kIsART]];
        [self.previousMedications addChild:prev];
    }
}

/**
 end reading the element
 */

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if(qName)
    {
		elementName = qName;
	}
    XMLElement *root = [self.document root];
    if ([elementName isEqualToString:kResults] && (nil != self.results))
    {
        [root addChild:self.results];
    }
    else if ([elementName isEqualToString:kMedications] && (nil != self.medications))
    {
        [root addChild:self.medications];
    }
    else if ([elementName isEqualToString:kOtherMedications] && (nil != self.otherMedications))
    {
        [root addChild:self.otherMedications];
    }
    else if ([elementName isEqualToString:kMissedMedications] && (nil != self.missedMedications))
    {
        [root addChild:self.missedMedications];
    }
    else if ([elementName isEqualToString:kClinicalContacts] && (nil != self.contacts))
    {
        [root addChild:self.contacts];
    }
    else if ([elementName isEqualToString:kHIVSideEffects] && (nil != self.sideEffects))
    {
        [root addChild:self.sideEffects];
    }
    else if ([elementName isEqualToString:kIllnessAndProcedures] && (nil != self.procedures))
    {
        [root addChild:self.procedures];
    }
    else if ([elementName isEqualToString:kPreviousMedications] && (nil != self.previousMedications))
    {
        [root addChild:self.previousMedications];
    }
    
}

/**
 handle parsing errors
 */
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
#ifdef APPDEBUG
	NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
#endif
//    *error = &parseError;
}


/**
 dealloc
 */

@end
