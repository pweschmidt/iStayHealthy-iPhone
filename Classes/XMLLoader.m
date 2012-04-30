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
@synthesize xmlParser, document;
@synthesize results, medications, missedMedications, alerts, otherMedications;
@synthesize contacts, sideEffects, procedures;
- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}


+ (BOOL)isXML:(NSData *)data{
    NSString *testString = [[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]autorelease];
    if ([testString hasPrefix:XMLPREAMBLE]) {
        return YES;
    }
    return NO;
}



/**
 */
- (id)initWithData:(NSData *)data{
    self = [self init];
    if (self) {
#ifdef APPDEBUG
        NSLog(@"XMLLoader:initWithData");
#endif
        xmlParser = [[NSXMLParser alloc] initWithData:data];
        [xmlParser setDelegate:self];
        [xmlParser setShouldProcessNamespaces:NO];
        [xmlParser setShouldReportNamespacePrefixes:NO];
        [xmlParser setShouldResolveExternalEntities:NO];
    }
    
    return self;
}

/**
 parse the XML file
 */
- (BOOL)startParsing:(NSError **)parseError{
#ifdef APPDEBUG
    NSLog(@"XMLLoader:startParsing");
#endif
    error = parseError;
    [xmlParser parse];    
    if (nil == &error) {
        return YES;
    }
    return NO;
}

/**
 sync up with what we have in the database. Only add those elements for which we haven't
 got an existing UID
 */
- (void)synchronise{
    if (nil == document) {
        return;
    }
    if (nil == [document root]) {
        return;
    }
    DataLoader *loader = [[[DataLoader alloc]init] autorelease];
    [loader getSQLData];
    XMLElement *_results = [document elementForName:RESULTS];
    if (nil != _results) {
        NSMutableArray *children = [_results childElements];
        for (XMLElement *element in children) {
            [loader addResultsToSQL:element];
        }
    }
    XMLElement *_meds = [document elementForName:MEDICATIONS];
    if (nil != _meds) {
        NSMutableArray *children = [_meds childElements];
        for (XMLElement *element in children) {
            [loader addMedicationsToSQL:element];
        }
    }
    XMLElement *_missedMeds = [document elementForName:MISSEDMEDICATIONS];
    if (nil != _missedMeds) {
        NSMutableArray *children = [_missedMeds childElements];
        for (XMLElement *element in children) {
            [loader addMissedMedicationToSQL:element];
        }
    }
    XMLElement *_otherMeds = [document elementForName:OTHERMEDICATIONS];
    if (nil != _otherMeds) {
        NSMutableArray *children = [_otherMeds childElements];
        for (XMLElement *element in children) {
            [loader addOtherMedicationsToSQL:element];
        }
    }
    
    XMLElement *_contacts = [document elementForName:CLINICALCONTACTS];
    if (nil != _contacts) {
        NSMutableArray *children = [_contacts childElements];
        for (XMLElement *element in children) {
            [loader addClinicsToSQL:element];
        }
    }
    
    XMLElement *_procedures = [document elementForName:ILLNESSANDPROCEDURES];
    if(nil !=  _procedures){
        NSMutableArray *children = [_procedures childElements];
        for (XMLElement *element in children) {
            [loader addProceduresToSQL:element];
        }
    }

    XMLElement *_effects = [document elementForName:HIVSIDEEFFECTS];
    if(nil !=  _effects){
        NSMutableArray *children = [_effects childElements];
        for (XMLElement *element in children) {
            [loader addSideEffectsToSQL:element];
        }
    }
    
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
#ifdef APPDEBUG
    NSLog(@"XMLLoader:parserDidStartDocument");
#endif
    document = [[XMLDocument alloc] init];  
    results = nil;
    otherMedications = nil;
    alerts = nil;
    missedMedications = nil;
    medications = nil;
    sideEffects = nil;
    procedures = nil;
    contacts = nil;
}



/**
 parse the XML file
 */
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if(qName) {
		elementName = qName;
	}

    XMLElement *root = [document root];
    if ([elementName isEqualToString:ROOT]) {


        [root addAttribute:DBVERSION andValue:[attributeDict valueForKey:DBVERSION]];
        [root addAttribute:FROMDEVICE andValue:[attributeDict valueForKey:FROMDEVICE]];
        [root addAttribute:FROMDATE andValue:[attributeDict valueForKey:FROMDATE]];
    }
    else if ([elementName isEqualToString:RESULTS] && (nil == self.results)) {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:RESULTS];
        self.results = tmpElement;
        [tmpElement release];
    }
    else if ([elementName isEqualToString:MEDICATIONS] && (nil == self.medications)) {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:MEDICATIONS];
        self.medications = tmpElement;
        [tmpElement release];
    }
    else if ([elementName isEqualToString:OTHERMEDICATIONS] && (nil == self.otherMedications)) {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:OTHERMEDICATIONS];
        self.otherMedications = tmpElement;
        [tmpElement release];
    }
    else if ([elementName isEqualToString:MISSEDMEDICATIONS] && (nil == self.missedMedications)) {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:MISSEDMEDICATIONS];
        self.missedMedications = tmpElement;
        [tmpElement release];
    }
    else if ([elementName isEqualToString:CLINICALCONTACTS] && (nil == self.contacts)) {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:CLINICALCONTACTS];
        self.contacts = tmpElement;
        [tmpElement release];
    }
    else if ([elementName isEqualToString:HIVSIDEEFFECTS] && (nil == self.sideEffects)) {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:HIVSIDEEFFECTS];
        self.sideEffects = tmpElement;
        [tmpElement release];
    }
    else if ([elementName isEqualToString:ILLNESSANDPROCEDURES] && (nil == self.procedures)) {
        XMLElement *tmpElement = [[XMLElement alloc]initWithName:ILLNESSANDPROCEDURES];
        self.procedures = tmpElement;
        [tmpElement release];
    }
    //child elements
    else if([elementName isEqualToString:RESULT] && (nil != results)){
        XMLElement *result = [[XMLElement alloc]initWithName:RESULT];
        [result addAttribute:RESULTSDATE andValue:[attributeDict valueForKey:RESULTSDATE]];
        [result addAttribute:CD4COUNT andValue:[attributeDict valueForKey:CD4COUNT]];
        [result addAttribute:CD4PERCENT andValue:[attributeDict valueForKey:CD4PERCENT]];        
        NSString *vl = [attributeDict valueForKey:VIRALLOAD];
        if ([vl isEqualToString:@"undetectable"]) {
            [result addAttribute:VIRALLOAD andValue:@"0"];
        }
        else
            [result addAttribute:VIRALLOAD andValue:vl];
        [result addAttribute:GUID andValue:[attributeDict valueForKey:GUID]];
        [results addChild:result];
        [result release];
    }
    else if([elementName isEqualToString:MEDICATION] && (nil != self.medications)){
        XMLElement *medication = [[XMLElement alloc]initWithName:MEDICATION];
        [medication addAttribute:STARTDATE andValue:[attributeDict valueForKey:STARTDATE]];
        [medication addAttribute:ENDDATE andValue:[attributeDict valueForKey:ENDDATE]];
        [medication addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [medication addAttribute:DRUG andValue:[attributeDict valueForKey:DRUG]];
        [medication addAttribute:MEDICATIONFORM andValue:[attributeDict valueForKey:MEDICATIONFORM]];
        [medication addAttribute:DOSE andValue:[attributeDict valueForKey:DOSE]];
        [medication addAttribute:GUID andValue:[attributeDict valueForKey:GUID]];
        
        [self.medications addChild:medication];
        [medication release];
    }
    else if([elementName isEqualToString:MISSEDMEDICATION] && (nil != self.missedMedications)){
        XMLElement *missedMedication = [[XMLElement alloc]initWithName:MISSEDMEDICATION];
        [missedMedication addAttribute:MISSEDDATE andValue:[attributeDict valueForKey:MISSEDDATE]];
        [missedMedication addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [missedMedication addAttribute:DRUG andValue:[attributeDict valueForKey:DRUG]];
        [missedMedication addAttribute:GUID andValue:[attributeDict valueForKey:GUID]];
        [self.missedMedications addChild:missedMedication];
        [missedMedication release];
    }
    else if([elementName isEqualToString:OTHERMEDICATION] && (nil != self.otherMedications)){
        XMLElement *otherMedication = [[XMLElement alloc]initWithName:OTHERMEDICATION];
        [otherMedication addAttribute:STARTDATE andValue:[attributeDict valueForKey:STARTDATE]];
        [otherMedication addAttribute:ENDDATE andValue:[attributeDict valueForKey:ENDDATE]];
        [otherMedication addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [otherMedication addAttribute:DRUG andValue:[attributeDict valueForKey:DRUG]];
        [otherMedication addAttribute:MEDICATIONFORM andValue:[attributeDict valueForKey:MEDICATIONFORM]];
        [otherMedication addAttribute:DOSE andValue:[attributeDict valueForKey:DOSE]];
        [otherMedication addAttribute:GUID andValue:[attributeDict valueForKey:GUID]];
        [self.otherMedications addChild:otherMedication];
        [otherMedication release];
    }
    else if([elementName isEqualToString:CONTACTS] && (nil != self.contacts)){
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
        [contact release];
    }
    else if([elementName isEqualToString:SIDEEFFECTS] && (nil != self.sideEffects)){
        XMLElement *effect = [[XMLElement alloc]initWithName:SIDEEFFECTS];
        [effect addAttribute:SIDEEFFECT andValue:[attributeDict valueForKey:SIDEEFFECT]];
        [effect addAttribute:SIDEEFFECTDATE andValue:[attributeDict valueForKey:SIDEEFFECTDATE]];
        [effect addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [effect addAttribute:DRUG andValue:[attributeDict valueForKey:DRUG]];
        [self.sideEffects addChild:effect];
        [effect release];
    }
    else if([elementName isEqualToString:PROCEDURES] && (nil != self.procedures)){
        XMLElement *procs = [[XMLElement alloc]initWithName:PROCEDURES];
        [procs addAttribute:NAME andValue:[attributeDict valueForKey:NAME]];
        [procs addAttribute:ILLNESS andValue:[attributeDict valueForKey:ILLNESS]];
        [procs addAttribute:DATE andValue:[attributeDict valueForKey:DATE]];
        [self.procedures addChild:procs];
        [procs release];
    }
}

/**
 end reading the element
 */

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if(qName) {
		elementName = qName;
	}
    XMLElement *root = [document root];
    if ([elementName isEqualToString:RESULTS] && (nil != self.results)) {
        [root addChild:self.results];
    }
    else if ([elementName isEqualToString:MEDICATIONS] && (nil != self.medications)) {
        [root addChild:self.medications];
    }
    else if ([elementName isEqualToString:OTHERMEDICATIONS] && (nil != self.otherMedications)) {
        [root addChild:self.otherMedications];
    }
    else if ([elementName isEqualToString:MISSEDMEDICATIONS] && (nil != missedMedications)) {
        [root addChild:missedMedications];
    }
    else if ([elementName isEqualToString:CLINICALCONTACTS] && (nil != self.contacts)){
        [root addChild:self.contacts];
    }
    else if ([elementName isEqualToString:HIVSIDEEFFECTS] && (nil != self.sideEffects)){
        [root addChild:self.sideEffects];
    }
    else if ([elementName isEqualToString:ILLNESSANDPROCEDURES] && (nil != self.procedures)){
        [root addChild:self.procedures];
    }
    
}

/**
 handle parsing errors
 */
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
#ifdef APPDEBUG
	NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
#endif
    *error = [NSError errorWithDomain:[parseError domain] code:[parseError code] userInfo:[parseError userInfo]];
}


/**
 dealloc
 */
- (void)dealloc{
    [xmlParser release];
    [document release];
    [results release];
    [medications release];
    [missedMedications release];
    [alerts release];
    [otherMedications release];
    [contacts release];
    [procedures release];
    [sideEffects release];
    xmlParser = nil;
    document = nil;
    results = nil;
    medications = nil;
    missedMedications = nil;
    alerts = nil;
    otherMedications = nil;
    contacts = nil;
    procedures = nil;
    sideEffects = nil;
    [super dealloc];
}

@end
