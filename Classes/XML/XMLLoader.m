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
#import "XMLConstants.h"
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
    XMLElement *results = [self.document elementForName:kXMLElementResults];
    if (nil != results)
    {
        NSMutableArray *children = [results childElements];
        for (XMLElement *element in children)
        {
            [loader addResultsToSQL:element];
        }
    }
    XMLElement *meds = [self.document elementForName:kXMLElementMedications];
    if (nil != meds)
    {
        NSMutableArray *children = [meds childElements];
        for (XMLElement *element in children)
        {
            [loader addMedicationsToSQL:element];
        }
    }
    XMLElement *missedMeds = [self.document elementForName:kXMLElementMissedMedications];
    if (nil != missedMeds)
    {
        NSMutableArray *children = [missedMeds childElements];
        for (XMLElement *element in children)
        {
            [loader addMissedMedicationToSQL:element];
        }
    }
    XMLElement *otherMeds = [self.document elementForName:kXMLElementOtherMedications];
    if (nil != otherMeds)
    {
        NSMutableArray *children = [otherMeds childElements];
        for (XMLElement *element in children)
        {
            [loader addOtherMedicationsToSQL:element];
        }
    }
    
    XMLElement *contacts = [self.document elementForName:kXMLElementClinicalContacts];
    if (nil != contacts) {
        NSMutableArray *children = [contacts childElements];
        for (XMLElement *element in children) {
            [loader addClinicsToSQL:element];
        }
    }
    
    XMLElement *procedures = [self.document elementForName:kXMLElementIllnessAndProcedures];
    if(nil !=  procedures)
    {
        NSMutableArray *children = [procedures childElements];
        for (XMLElement *element in children)
        {
            [loader addProceduresToSQL:element];
        }
    }

    XMLElement *effects = [self.document elementForName:kXMLElementHIVSideEffects];
    if(nil !=  effects)
    {
        NSMutableArray *children = [effects childElements];
        for (XMLElement *element in children)
        {
            [loader addSideEffectsToSQL:element];
        }
    }
    
    XMLElement *previousMeds = [self.document elementForName:kXMLElementPreviousMedications];
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


        [root addAttribute:kXMLAttributeDBVersion andValue:[attributeDict valueForKey:kXMLAttributeDBVersion]];
        [root addAttribute:kXMLAttributeFromDevice andValue:[attributeDict valueForKey:kXMLAttributeFromDevice]];
        [root addAttribute:kXMLAttributeFromDate andValue:[attributeDict valueForKey:kXMLAttributeFromDate]];
    }
    else if ([elementName isEqualToString:kXMLElementResults] && (nil == self.results))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kXMLElementResults];
        self.results = tmpElement;
    }
    else if ([elementName isEqualToString:kXMLElementMedications] && (nil == self.medications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kXMLElementMedications];
        self.medications = tmpElement;
    }
    else if ([elementName isEqualToString:kXMLElementOtherMedications] && (nil == self.otherMedications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kXMLElementOtherMedications];
        self.otherMedications = tmpElement;
    }
    else if ([elementName isEqualToString:kXMLElementMissedMedications] && (nil == self.missedMedications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kXMLElementMissedMedications];
        self.missedMedications = tmpElement;
    }
    else if ([elementName isEqualToString:kXMLElementClinicalContacts] && (nil == self.contacts))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kXMLElementClinicalContacts];
        self.contacts = tmpElement;
    }
    else if ([elementName isEqualToString:kXMLElementHIVSideEffects] && (nil == self.sideEffects))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kXMLElementHIVSideEffects];
        self.sideEffects = tmpElement;
    }
    else if ([elementName isEqualToString:kXMLElementIllnessAndProcedures] && (nil == self.procedures))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kXMLElementIllnessAndProcedures];
        self.procedures = tmpElement;
    }
    else if ([elementName isEqualToString:kXMLElementPreviousMedications] && (nil == self.previousMedications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:kXMLElementPreviousMedications];
        self.previousMedications = tmpElement;
    }

    //child elements
    else if([elementName isEqualToString:kXMLElementResult] && (nil != self.results))
    {
        XMLElement *result = [[XMLElement alloc]initWithName:kXMLElementResult];
        [result addAttribute:kXMLAttributeResultsDate andValue:[attributeDict valueForKey:kXMLAttributeResultsDate]];
        [result addAttribute:kXMLAttributeCD4 andValue:[attributeDict valueForKey:kXMLAttributeCD4]];
        [result addAttribute:kXMLAttributeCD4Percent andValue:[attributeDict valueForKey:kXMLAttributeCD4Percent]];        
        NSString *vl = [attributeDict valueForKey:kXMLAttributeViralLoad];
        if ([vl isEqualToString:@"undetectable"])
        {
            [result addAttribute:kXMLAttributeViralLoad andValue:@"0"];
        }
        else
            [result addAttribute:kXMLAttributeViralLoad andValue:vl];
        
        NSString *hepVl = [attributeDict valueForKey:kXMLAttributeHepCViralLoad];
        if ([hepVl isEqualToString:@"undetectable"])
        {
            [result addAttribute:kXMLAttributeHepCViralLoad andValue:@"0"];
        }
        else
            [result addAttribute:kXMLAttributeHepCViralLoad andValue:hepVl];
        
        [result addAttribute:kXMLAttributeGlucose andValue:[attributeDict valueForKey:kXMLAttributeGlucose]];
        [result addAttribute:kXMLAttributeTotalCholesterol andValue:[attributeDict valueForKey:kXMLAttributeTotalCholesterol]];
        [result addAttribute:kXMLAttributeLDL andValue:[attributeDict valueForKey:kXMLAttributeLDL]];
        [result addAttribute:kXMLAttributeHDL andValue:[attributeDict valueForKey:kXMLAttributeHDL]];

        [result addAttribute:kXMLAttributeHemoglobulin andValue:[attributeDict valueForKey:kXMLAttributeHemoglobulin]];
        [result addAttribute:kXMLAttributePlatelet andValue:[attributeDict valueForKey:kXMLAttributePlatelet]];
        [result addAttribute:kXMLAttributeWhiteBloodCells andValue:[attributeDict valueForKey:kXMLAttributeWhiteBloodCells]];
        [result addAttribute:kXMLAttributeRedBloodCells andValue:[attributeDict valueForKey:kXMLAttributeRedBloodCells]];
        
        [result addAttribute:kXMLAttributeWeight andValue:[attributeDict valueForKey:kXMLAttributeWeight]];
        [result addAttribute:kXMLAttributeSystole andValue:[attributeDict valueForKey:kXMLAttributeSystole]];
        [result addAttribute:kXMLAttributeDiastole andValue:[attributeDict valueForKey:kXMLAttributeDiastole]];
        [result addAttribute:kXMLAttributeUID andValue:[attributeDict valueForKey:kXMLAttributeUID]];
        [self.results addChild:result];
    }
    else if([elementName isEqualToString:kXMLElementMedication] && (nil != self.medications))
    {
        XMLElement *medication = [[XMLElement alloc]initWithName:kXMLElementMedication];
        [medication addAttribute:kXMLAttributeStartDate andValue:[attributeDict valueForKey:kXMLAttributeStartDate]];
        [medication addAttribute:kXMLAttributeName andValue:[attributeDict valueForKey:kXMLAttributeName]];
        [medication addAttribute:kXMLAttributeDrug andValue:[attributeDict valueForKey:kXMLAttributeDrug]];
        [medication addAttribute:kXMLAttributeMedicationForm andValue:[attributeDict valueForKey:kXMLAttributeMedicationForm]];
        [medication addAttribute:kXMLAttributeDose andValue:[attributeDict valueForKey:kXMLAttributeDose]];
        [medication addAttribute:kXMLAttributeUID andValue:[attributeDict valueForKey:kXMLAttributeUID]];
        
        [self.medications addChild:medication];
    }
    else if([elementName isEqualToString:kXMLElementMissedMedication] && (nil != self.missedMedications))
    {
        XMLElement *missedMedication = [[XMLElement alloc]initWithName:kXMLElementMissedMedication];
        [missedMedication addAttribute:kXMLAttributeMissedDate andValue:[attributeDict valueForKey:kXMLAttributeMissedDate]];
        [missedMedication addAttribute:kXMLAttributeName andValue:[attributeDict valueForKey:kXMLAttributeName]];
        [missedMedication addAttribute:kXMLAttributeDrug andValue:[attributeDict valueForKey:kXMLAttributeDrug]];
        [missedMedication addAttribute:kXMLAttributeUID andValue:[attributeDict valueForKey:kXMLAttributeUID]];
        [missedMedication addAttribute:kXMLAttributeMissedReason andValue:[attributeDict valueForKey:kXMLAttributeMissedReason]];
        [self.missedMedications addChild:missedMedication];
    }
    else if([elementName isEqualToString:kXMLElementOtherMedication] && (nil != self.otherMedications))
    {
        XMLElement *otherMedication = [[XMLElement alloc]initWithName:kXMLElementOtherMedication];
        [otherMedication addAttribute:kXMLAttributeStartDate andValue:[attributeDict valueForKey:kXMLAttributeStartDate]];
        [otherMedication addAttribute:kXMLAttributeName andValue:[attributeDict valueForKey:kXMLAttributeName]];
        [otherMedication addAttribute:kXMLAttributeDrug andValue:[attributeDict valueForKey:kXMLAttributeDrug]];
        [otherMedication addAttribute:kXMLAttributeMedicationForm andValue:[attributeDict valueForKey:kXMLAttributeMedicationForm]];
        [otherMedication addAttribute:kXMLAttributeDose andValue:[attributeDict valueForKey:kXMLAttributeDose]];
        [otherMedication addAttribute:kXMLAttributeUnit andValue:[attributeDict valueForKey:kXMLAttributeUnit]];
        [otherMedication addAttribute:kXMLAttributeUID andValue:[attributeDict valueForKey:kXMLAttributeUID]];
        [self.otherMedications addChild:otherMedication];
    }
    else if([elementName isEqualToString:kXMLElementContacts] && (nil != self.contacts))
    {
        XMLElement *contact = [[XMLElement alloc]initWithName:kXMLElementContacts];
        [contact addAttribute:kXMLAttributeClinicName andValue:[attributeDict valueForKey:kXMLAttributeClinicName]];
        [contact addAttribute:kXMLAttributeClinicID andValue:[attributeDict valueForKey:kXMLAttributeClinicID]];
        [contact addAttribute:kXMLAttributeClinicStreet andValue:[attributeDict valueForKey:kXMLAttributeClinicStreet]];
        [contact addAttribute:kXMLAttributeClinicPostcode andValue:[attributeDict valueForKey:kXMLAttributeClinicPostcode]];
        [contact addAttribute:kXMLAttributeClinicCity andValue:[attributeDict valueForKey:kXMLAttributeClinicCity]];
        [contact addAttribute:kXMLAttributeClinicContactNumber andValue:[attributeDict valueForKey:kXMLAttributeClinicContactNumber]];
        [contact addAttribute:kXMLAttributeEmergencyContactNumber andValue:[attributeDict valueForKey:kXMLAttributeEmergencyContactNumber]];
        [contact addAttribute:kXMLAttributeClinicEmailAddress andValue:[attributeDict valueForKey:kXMLAttributeClinicEmailAddress]];
        [contact addAttribute:kXMLAttributeClinicWebSite andValue:[attributeDict valueForKey:kXMLAttributeClinicWebSite]];
        
        [self.contacts addChild:contact];
    }
    else if([elementName isEqualToString:kXMLElementSideEffects] && (nil != self.sideEffects))
    {
        XMLElement *effect = [[XMLElement alloc]initWithName:kXMLElementSideEffects];
        [effect addAttribute:kXMLAttributeSideEffect andValue:[attributeDict valueForKey:kXMLAttributeSideEffect]];
        [effect addAttribute:kXMLAttributeSideEffectDate andValue:[attributeDict valueForKey:kXMLAttributeSideEffectDate]];
        [effect addAttribute:kXMLAttributeName andValue:[attributeDict valueForKey:kXMLAttributeName]];
        [effect addAttribute:kXMLAttributeDrug andValue:[attributeDict valueForKey:kXMLAttributeDrug]];
        [effect addAttribute:kXMLAttributeSeriousness andValue:[attributeDict valueForKey:kXMLAttributeSeriousness]];
        [self.sideEffects addChild:effect];
    }
    else if([elementName isEqualToString:kXMLElementProcedures] && (nil != self.procedures))
    {
        XMLElement *procs = [[XMLElement alloc]initWithName:kXMLElementProcedures];
        [procs addAttribute:kXMLAttributeName andValue:[attributeDict valueForKey:kXMLAttributeName]];
        [procs addAttribute:kXMLAttributeIllness andValue:[attributeDict valueForKey:kXMLAttributeIllness]];
        [procs addAttribute:kXMLAttributeDate andValue:[attributeDict valueForKey:kXMLAttributeDate]];
        [self.procedures addChild:procs];
    }
    else if ([elementName isEqualToString:kXMLElementPreviousMedication] && (nil != self.previousMedications))
    {
        XMLElement *prev = [[XMLElement alloc] initWithName:kXMLElementPreviousMedication];
        [prev addAttribute:kXMLAttributeStartDateLowerCase andValue:[attributeDict valueForKey:kXMLAttributeStartDateLowerCase]];
        [prev addAttribute:kXMLAttributeEndDateLowerCase andValue:[attributeDict valueForKey:kXMLAttributeEndDateLowerCase]];
        [prev addAttribute:kXMLAttributeNameLowerCase andValue:[attributeDict valueForKey:kXMLAttributeNameLowerCase]];
        [prev addAttribute:kXMLAttributeDrugLowerCase andValue:[attributeDict valueForKey:kXMLAttributeDrugLowerCase]];
        [prev addAttribute:kXMLAttributeIsART andValue:[attributeDict valueForKey:kXMLAttributeIsART]];
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
    if ([elementName isEqualToString:kXMLElementResults] && (nil != self.results))
    {
        [root addChild:self.results];
    }
    else if ([elementName isEqualToString:kXMLElementMedications] && (nil != self.medications))
    {
        [root addChild:self.medications];
    }
    else if ([elementName isEqualToString:kXMLElementOtherMedications] && (nil != self.otherMedications))
    {
        [root addChild:self.otherMedications];
    }
    else if ([elementName isEqualToString:kXMLElementMissedMedications] && (nil != self.missedMedications))
    {
        [root addChild:self.missedMedications];
    }
    else if ([elementName isEqualToString:kXMLElementClinicalContacts] && (nil != self.contacts))
    {
        [root addChild:self.contacts];
    }
    else if ([elementName isEqualToString:kXMLElementHIVSideEffects] && (nil != self.sideEffects))
    {
        [root addChild:self.sideEffects];
    }
    else if ([elementName isEqualToString:kXMLElementIllnessAndProcedures] && (nil != self.procedures))
    {
        [root addChild:self.procedures];
    }
    else if ([elementName isEqualToString:kXMLElementPreviousMedications] && (nil != self.previousMedications))
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
