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
#import "XMLDefinitions.h"
#import "DataLoader.h"

@implementation XMLLoader
@synthesize xmlParser = _xmlParser;
@synthesize document = _document;
@synthesize results = _results;
@synthesize medications = _medications;
@synthesize missedMedications = _missedMedications;
@synthesize alerts = _alerts;
@synthesize otherMedications = _otherMedications;
@synthesize contacts = _contacts;
@synthesize sideEffects = _sideEffects;
@synthesize procedures = _procedures;

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}


+ (BOOL)isXML:(NSData *)data
{
    NSString *testString = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    if ([testString hasPrefix:XMLPREAMBLE])
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
- (void)synchronise
{
    if (nil == self.document)
    {
        return;
    }
    if (nil == [self.document root])
    {
        return;
    }
    DataLoader *loader = [[DataLoader alloc]init];
    [loader getSQLData];
    XMLElement *results = [self.document elementForName:RESULTS];
    if (nil != results)
    {
        NSMutableArray *children = [results childElements];
        for (XMLElement *element in children)
        {
            [loader addResultsToSQL:element];
        }
    }
    XMLElement *meds = [self.document elementForName:MEDICATIONS];
    if (nil != meds)
    {
        NSMutableArray *children = [meds childElements];
        for (XMLElement *element in children)
        {
            [loader addMedicationsToSQL:element];
        }
    }
    XMLElement *missedMeds = [self.document elementForName:MISSEDMEDICATIONS];
    if (nil != missedMeds)
    {
        NSMutableArray *children = [missedMeds childElements];
        for (XMLElement *element in children)
        {
            [loader addMissedMedicationToSQL:element];
        }
    }
    XMLElement *otherMeds = [self.document elementForName:OTHERMEDICATIONS];
    if (nil != otherMeds)
    {
        NSMutableArray *children = [otherMeds childElements];
        for (XMLElement *element in children)
        {
            [loader addOtherMedicationsToSQL:element];
        }
    }
    
    XMLElement *contacts = [self.document elementForName:CLINICALCONTACTS];
    if (nil != contacts) {
        NSMutableArray *children = [contacts childElements];
        for (XMLElement *element in children) {
            [loader addClinicsToSQL:element];
        }
    }
    
    XMLElement *procedures = [self.document elementForName:ILLNESSANDPROCEDURES];
    if(nil !=  procedures)
    {
        NSMutableArray *children = [procedures childElements];
        for (XMLElement *element in children)
        {
            [loader addProceduresToSQL:element];
        }
    }

    XMLElement *effects = [self.document elementForName:HIVSIDEEFFECTS];
    if(nil !=  effects)
    {
        NSMutableArray *children = [effects childElements];
        for (XMLElement *element in children)
        {
            [loader addSideEffectsToSQL:element];
        }
    }
    
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
    if ([elementName isEqualToString:ROOT])
    {


        [root addAttribute:DBVERSION andValue:[attributeDict valueForKey:DBVERSION]];
        [root addAttribute:FROMDEVICE andValue:[attributeDict valueForKey:FROMDEVICE]];
        [root addAttribute:FROMDATE andValue:[attributeDict valueForKey:FROMDATE]];
    }
    else if ([elementName isEqualToString:RESULTS] && (nil == self.results))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:RESULTS];
        self.results = tmpElement;
    }
    else if ([elementName isEqualToString:MEDICATIONS] && (nil == self.medications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:MEDICATIONS];
        self.medications = tmpElement;
    }
    else if ([elementName isEqualToString:OTHERMEDICATIONS] && (nil == self.otherMedications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:OTHERMEDICATIONS];
        self.otherMedications = tmpElement;
    }
    else if ([elementName isEqualToString:MISSEDMEDICATIONS] && (nil == self.missedMedications))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:MISSEDMEDICATIONS];
        self.missedMedications = tmpElement;
    }
    else if ([elementName isEqualToString:CLINICALCONTACTS] && (nil == self.contacts))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:CLINICALCONTACTS];
        self.contacts = tmpElement;
    }
    else if ([elementName isEqualToString:HIVSIDEEFFECTS] && (nil == self.sideEffects))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:HIVSIDEEFFECTS];
        self.sideEffects = tmpElement;
    }
    else if ([elementName isEqualToString:ILLNESSANDPROCEDURES] && (nil == self.procedures))
    {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:ILLNESSANDPROCEDURES];
        self.procedures = tmpElement;
    }
    //child elements
    else if([elementName isEqualToString:RESULT] && (nil != self.results))
    {
        XMLElement *result = [[XMLElement alloc]initWithName:RESULT];
        [result addAttribute:RESULTSDATE andValue:[attributeDict valueForKey:RESULTSDATE]];
        [result addAttribute:CD4COUNT andValue:[attributeDict valueForKey:CD4COUNT]];
        [result addAttribute:CD4PERCENT andValue:[attributeDict valueForKey:CD4PERCENT]];        
        NSString *vl = [attributeDict valueForKey:VIRALLOAD];
        if ([vl isEqualToString:@"undetectable"])
        {
            [result addAttribute:VIRALLOAD andValue:@"0"];
        }
        else
            [result addAttribute:VIRALLOAD andValue:vl];
        [result addAttribute:GUID andValue:[attributeDict valueForKey:GUID]];
        [self.results addChild:result];
    }
    else if([elementName isEqualToString:MEDICATION] && (nil != self.medications))
    {
        XMLElement *medication = [[XMLElement alloc]initWithName:MEDICATION];
        [medication addAttribute:STARTDATE andValue:[attributeDict valueForKey:STARTDATE]];
        [medication addAttribute:ENDDATE andValue:[attributeDict valueForKey:ENDDATE]];
        [medication addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [medication addAttribute:DRUG andValue:[attributeDict valueForKey:DRUG]];
        [medication addAttribute:MEDICATIONFORM andValue:[attributeDict valueForKey:MEDICATIONFORM]];
        [medication addAttribute:DOSE andValue:[attributeDict valueForKey:DOSE]];
        [medication addAttribute:GUID andValue:[attributeDict valueForKey:GUID]];
        
        [self.medications addChild:medication];
    }
    else if([elementName isEqualToString:MISSEDMEDICATION] && (nil != self.missedMedications))
    {
        XMLElement *missedMedication = [[XMLElement alloc]initWithName:MISSEDMEDICATION];
        [missedMedication addAttribute:MISSEDDATE andValue:[attributeDict valueForKey:MISSEDDATE]];
        [missedMedication addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [missedMedication addAttribute:DRUG andValue:[attributeDict valueForKey:DRUG]];
        [missedMedication addAttribute:GUID andValue:[attributeDict valueForKey:GUID]];
        [self.missedMedications addChild:missedMedication];
    }
    else if([elementName isEqualToString:OTHERMEDICATION] && (nil != self.otherMedications))
    {
        XMLElement *otherMedication = [[XMLElement alloc]initWithName:OTHERMEDICATION];
        [otherMedication addAttribute:STARTDATE andValue:[attributeDict valueForKey:STARTDATE]];
        [otherMedication addAttribute:ENDDATE andValue:[attributeDict valueForKey:ENDDATE]];
        [otherMedication addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [otherMedication addAttribute:DRUG andValue:[attributeDict valueForKey:DRUG]];
        [otherMedication addAttribute:MEDICATIONFORM andValue:[attributeDict valueForKey:MEDICATIONFORM]];
        [otherMedication addAttribute:DOSE andValue:[attributeDict valueForKey:DOSE]];
        [otherMedication addAttribute:GUID andValue:[attributeDict valueForKey:GUID]];
        [self.otherMedications addChild:otherMedication];
    }
    else if([elementName isEqualToString:CONTACTS] && (nil != self.contacts))
    {
        XMLElement *contact = [[XMLElement alloc]initWithName:CONTACTS];
        [contact addAttribute:CLINICNAME andValue:[attributeDict valueForKey:CLINICNAME]];
        [contact addAttribute:CLINICID andValue:[attributeDict valueForKey:CLINICID]];
        [contact addAttribute:CLINICSTREET andValue:[attributeDict valueForKey:CLINICSTREET]];
        [contact addAttribute:CLINICPOSTCODE andValue:[attributeDict valueForKey:CLINICPOSTCODE]];
        [contact addAttribute:CLINICCITY andValue:[attributeDict valueForKey:CLINICCITY]];
        [contact addAttribute:CLINICCONTACTNUMBER andValue:[attributeDict valueForKey:CLINICCONTACTNUMBER]];
        [contact addAttribute:RESULTSCONTACTNUMBER andValue:[attributeDict valueForKey:RESULTSCONTACTNUMBER]];
        [contact addAttribute:APPOINTMENTCONTACTNUMBER andValue:[attributeDict valueForKey:APPOINTMENTCONTACTNUMBER]];
        
        [self.contacts addChild:contact];
    }
    else if([elementName isEqualToString:SIDEEFFECTS] && (nil != self.sideEffects))
    {
        XMLElement *effect = [[XMLElement alloc]initWithName:SIDEEFFECTS];
        [effect addAttribute:SIDEEFFECT andValue:[attributeDict valueForKey:SIDEEFFECT]];
        [effect addAttribute:SIDEEFFECTDATE andValue:[attributeDict valueForKey:SIDEEFFECTDATE]];
        [effect addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [effect addAttribute:DRUG andValue:[attributeDict valueForKey:DRUG]];
        [self.sideEffects addChild:effect];
    }
    else if([elementName isEqualToString:PROCEDURES] && (nil != self.procedures))
    {
        XMLElement *procs = [[XMLElement alloc]initWithName:PROCEDURES];
        [procs addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [procs addAttribute:ILLNESS andValue:[attributeDict valueForKey:ILLNESS]];
        [procs addAttribute:DATE andValue:[attributeDict valueForKey:DATE]];
        [self.procedures addChild:procs];
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
    if ([elementName isEqualToString:RESULTS] && (nil != self.results))
    {
        [root addChild:self.results];
    }
    else if ([elementName isEqualToString:MEDICATIONS] && (nil != self.medications))
    {
        [root addChild:self.medications];
    }
    else if ([elementName isEqualToString:OTHERMEDICATIONS] && (nil != self.otherMedications))
    {
        [root addChild:self.otherMedications];
    }
    else if ([elementName isEqualToString:MISSEDMEDICATIONS] && (nil != self.missedMedications))
    {
        [root addChild:self.missedMedications];
    }
    else if ([elementName isEqualToString:CLINICALCONTACTS] && (nil != self.contacts))
    {
        [root addChild:self.contacts];
    }
    else if ([elementName isEqualToString:HIVSIDEEFFECTS] && (nil != self.sideEffects))
    {
        [root addChild:self.sideEffects];
    }
    else if ([elementName isEqualToString:ILLNESSANDPROCEDURES] && (nil != self.procedures))
    {
        [root addChild:self.procedures];
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
