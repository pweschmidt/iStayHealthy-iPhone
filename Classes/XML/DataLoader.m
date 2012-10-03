//
//  DataLoader.m
//  iStayHealthy
//
//  Created by peterschmidt on 07/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataLoader.h"
#import "iStayHealthyRecord.h"
#import "iStayHealthyAppDelegate.h"
#import "Results.h"
#import "Contacts.h"
#import "Medication.h"
#import "MissedMedication.h"
#import "OtherMedication.h"
#import "Procedures.h"
#import "SideEffects.h"
#import "PreviousMedication.h"
#import "Wellness.h"
#import "NSArray-Set.h"
#import "XMLDocument.h"
#import "XMLElement.h"
#import "XMLAttribute.h"
#import "Utilities.h"
#import "XMLConstants.h"

@implementation DataLoader
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize masterRecord = _masterRecord;
@synthesize allResults = _allResults;
@synthesize allMedications = _allMedications;
@synthesize allMissedMeds = _allMissedMeds;
@synthesize allOtherMeds = _allOtherMeds;
@synthesize allContacts = _allContacts;
@synthesize allProcedures = _allProcedures;
@synthesize allSideEffects = _allSideEffects;
@synthesize allPreviousMedications = _allPreviousMedications;
@synthesize allWellness = _allWellness;

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        // Initialization code here.
    }
    
    return self;
}

/**
 dealloc
 */

- (NSString *)csvString
{
    NSMutableString *csv = [NSMutableString stringWithString:@"iStayHealthy\r"];
    if (nil == self.masterRecord)
    {
        return csv;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    BOOL isFirst = YES;
    for (Results *results in self.allResults)
    {
        if (isFirst)
        {
            [csv appendString:@"Results\r"];
            [csv appendString:@"ResultsDate, CD4Count, CD4%%, ViralLoad\r"];
            isFirst = NO;
        }
        NSString *cd4 = (0.0 < [results.CD4 floatValue]) ? [results.CD4 stringValue] : @"";
        NSString *cd4Percent = (0.0 < [results.CD4Percent floatValue]) ?[results.CD4Percent stringValue] : @"";
        NSString *date = [formatter stringFromDate:results.ResultsDate];
        NSString *vl = @"";
        if (0.0 == [results.ViralLoad floatValue])
        {
            vl = @"undetectable";
        }
        if (0.0 < [results.ViralLoad floatValue])
        {
            vl = [results.ViralLoad stringValue];
        }
        [csv appendFormat:@"%@, %@, %@, %@\r",date, cd4, cd4Percent, vl];
    }
    
    isFirst = YES;
    for (Medication *medication in self.allMedications)
    {
        if (isFirst)
        {
            [csv appendString:@"HIV Medication\r"];
            [csv appendString:@"StartDate, Name, Drugs, MedicationForm, EndDate\r"];
            isFirst = NO;
        }
        NSString *date = [formatter stringFromDate:medication.StartDate];
        NSString *name = medication.Name;
        NSString *drugs = medication.Drug;
        NSString *form = medication.MedicationForm;
        NSString *endDate = [formatter stringFromDate:medication.EndDate];
        if (nil == endDate)
        {
            endDate = @"ongoing";
        }
        if ([endDate isEqualToString:@""])
        {
            endDate = @"ongoing";
        }
        [csv appendFormat:@"%@, %@, %@, %@, %@\r",date, name, drugs, form, endDate];        
    }
    
    isFirst = YES;
    for (MissedMedication *missedMed in self.allMissedMeds)
    {
        if (isFirst)
        {
            [csv appendString:@"Missed HIV Medication\r"];
            [csv appendString:@"Missed, Name, Drugs\r"];
            isFirst = NO;
        }
        NSString *date = [formatter stringFromDate:missedMed.MissedDate];
        NSString *name = missedMed.Name;
        NSString *drug = missedMed.Drug;
        [csv appendFormat:@"%@, %@, %@\r",date, name, drug];
    }
    
    isFirst = YES;
    for (SideEffects *effect in self.allSideEffects)
    {
        if (isFirst)
        {
            [csv appendString:@"SideEffects\r"];
            [csv appendString:@"Date, SideEffect, Seriousness, DrugName\r"];
            isFirst = NO;
        }
        NSString *date = [formatter stringFromDate:effect.SideEffectDate];
        NSString *effectName = effect.SideEffect;
        NSString *name = effect.Name;
        NSString *seriousness = effect.seriousness;
        [csv appendFormat:@"%@, %@, %@, %@\r",date, effectName, seriousness, name];
    }
    
    isFirst = YES;
    for (OtherMedication *otherMed in self.allOtherMeds)
    {
        if (isFirst)
        {
            [csv appendString:@"Other Medications\r"];
            [csv appendString:@"StartDate, Name, Dose, EndDate\r"];
            isFirst = NO;
        }
        NSString *date = [formatter stringFromDate:otherMed.StartDate];
        NSString *name = otherMed.Name;
        NSString *dose = [otherMed.Dose stringValue];
        NSString *endDate = [formatter stringFromDate:otherMed.EndDate];
        if (nil == endDate)
        {
            endDate = @"ongoing";
        }
        if ([endDate isEqualToString:@""])
        {
            endDate = @"ongoing";
        }
        [csv appendFormat:@"%@, %@, %@, %@\r", date, name, dose, endDate];
    }
    
    isFirst = YES;
    for (Procedures *procs in self.allProcedures)
    {
        if (isFirst)
        {
            [csv appendString:@"Illness & Procedures\r"];
            [csv appendString:@"Date, Illness, Procedure\r"];
            isFirst = NO;
        }
        NSString *date = [formatter stringFromDate:procs.Date];
        NSString *illness = procs.Illness;
        NSString *name = procs.Name;
        [csv appendFormat:@"%@, %@, %@\r", date, illness, name];
    }
    return csv;
}



/**
 returns a string of comma-separated-values. to be used in sending per e-mail
 */
- (NSData *)csvData
{
    return [[self csvString] dataUsingEncoding:NSUTF8StringEncoding];
}


/**
 returns the XML document as a pointer to a NSData object
 */
- (NSData *)xmlData
{
    XMLDocument *document = [[XMLDocument alloc] init];
    XMLElement *root = [document root];
    if (nil == self.masterRecord)
    {
        NSString *xmlString = [document xmlString];
        return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    NSString *masterUID = self.masterRecord.UID;
    if (nil == masterUID || [masterUID isEqualToString:@""])
    {
        masterUID = [Utilities GUID];
        NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
        self.masterRecord.UID = masterUID;
        NSError *error = nil;
        if (![context save:&error])
        {
#ifdef APPDEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        }
        
    }
    [root addAttribute:kXMLAttributeUID andValue:masterUID];
    
    if (0 < [self.allResults count])
    {
        XMLElement *results = [[XMLElement alloc]initWithName:kXMLElementResults];
        [self addResults:results];
        [root addChild:results];
    }
    
    if (0 < [self.allMedications count])
    {
        XMLElement *medications = [[XMLElement alloc]initWithName:kXMLElementMedications];
        [self addMedications:medications];
        [root addChild:medications];
    }
    
    if (0 < [self.allMissedMeds count])
    {
        XMLElement *missedMedications = [[XMLElement alloc]initWithName:kXMLElementMissedMedications];
        [self addMissedMedications:missedMedications];
        [root addChild:missedMedications];
    }
        
    if (0 < [self.allOtherMeds count])
    {
        XMLElement *otherMedications = [[XMLElement alloc]initWithName:kXMLElementOtherMedications];
        [self addOtherMeds:otherMedications];        
        [root addChild:otherMedications];
    }
    
    if (0 < [self.allContacts count])
    {
        XMLElement *contacts = [[XMLElement alloc]initWithName:kXMLElementClinicalContacts];
        [self addContacts:contacts];
        [root addChild:contacts];
    }
    
    if (0 < [self.allSideEffects count])
    {
        XMLElement *sideEffects = [[XMLElement alloc]initWithName:kXMLElementHIVSideEffects];
        [self addSideEffects:sideEffects];
        [root addChild:sideEffects];
    }
    
    if (0 < [self.allProcedures count])
    {
        XMLElement *procedures = [[XMLElement alloc]initWithName:kXMLElementIllnessAndProcedures];
        [self addProcedures:procedures];
        [root addChild:procedures];        
    }
    
    if (0 < self.allPreviousMedications.count)
    {
        XMLElement *previousMeds = [[XMLElement alloc]initWithName:kXMLElementPreviousMedications];
        [self addPreviousMedications:previousMeds];
        [root addChild:previousMeds];
    }
    
    if (0 < self.allWellness.count)
    {
        XMLElement *wellness = [[XMLElement alloc]initWithName:kXMLElementWellnesses];
        [self addWellness:wellness];
        [root addChild:wellness];
    }

    NSString *xmlString = [document xmlString];
#ifdef APPDEBUG
    NSLog(@"XML string = %@",xmlString);
#endif
    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 adds the results to the XML doc
 */
- (void) addResults:(XMLElement *)resultsParent
{
    for (Results *results in self.allResults)
    {
        XMLElement *resultElement = [[XMLElement alloc]initWithName:kXMLElementResult];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [resultElement addAttribute:kXMLAttributeResultsDate
                           andValue:[formatter stringFromDate:results.ResultsDate]];
        if (0.0 < [results.CD4 floatValue])
        {
            [resultElement addAttribute:kXMLAttributeCD4 andValue:[results.CD4 stringValue]];
        }
        if (0.0 < [results.CD4Percent floatValue])
        {
            [resultElement addAttribute:kXMLAttributeCD4Percent andValue:[results.CD4Percent stringValue]];
        }
        if (0.0 <= [results.ViralLoad floatValue])
        {
            if (0.0 == [results.ViralLoad floatValue])
            {
                [resultElement addAttribute:kXMLAttributeViralLoad andValue:@"undetectable"];
            }
            else
                [resultElement addAttribute:kXMLAttributeViralLoad andValue:[results.ViralLoad stringValue]];
        }
        if (0.0 <= [results.HepCViralLoad floatValue])
        {
            if (0.0 == [results.HepCViralLoad floatValue])
            {
                [resultElement addAttribute:kXMLAttributeHepCViralLoad andValue:@"undetectable"];                
            }
            else
                [resultElement addAttribute:kXMLAttributeHepCViralLoad andValue:[results.HepCViralLoad stringValue]];
        }
        
        if (0.0 < [results.Glucose floatValue])
        {
            [resultElement addAttribute:kXMLAttributeGlucose andValue:[results.Glucose stringValue]];
        }
        if (0.0 < [results.TotalCholesterol floatValue])
        {
            [resultElement addAttribute:kXMLAttributeTotalCholesterol andValue:[results.TotalCholesterol stringValue]];
        }
        if (0.0 < [results.LDL floatValue])
        {
            [resultElement addAttribute:kXMLAttributeLDL andValue:[results.LDL stringValue]];
        }
        if (0.0 < [results.HDL floatValue])
        {
            [resultElement addAttribute:kXMLAttributeHDL andValue:[results.HDL stringValue]];
        }
        if (0.0 < [results.Hemoglobulin floatValue])
        {
            [resultElement addAttribute:kXMLAttributeHemoglobulin andValue:[results.Hemoglobulin stringValue]];
        }
        if (0.0 < [results.PlateletCount floatValue])
        {
            [resultElement addAttribute:kXMLAttributePlatelet andValue:[results.PlateletCount stringValue]];
        }
        if (0.0 < [results.WhiteBloodCellCount floatValue])
        {
            [resultElement addAttribute:kXMLAttributeWhiteBloodCells andValue:[results.WhiteBloodCellCount stringValue]];
        }
        if (0.0 < [results.redBloodCellCount floatValue])
        {
            [resultElement addAttribute:kXMLAttributeRedBloodCells andValue:[results.redBloodCellCount stringValue]];
        }
        if (0.0 < [results.Systole floatValue])
        {
            [resultElement addAttribute:kXMLAttributeSystole andValue:[results.Systole stringValue]];
        }
        if (0.0 < [results.Diastole floatValue])
        {
            [resultElement addAttribute:kXMLAttributeDiastole andValue:[results.Diastole stringValue]];
        }
        if (0.0 < [results.Weight floatValue])
        {
            [resultElement addAttribute:kXMLAttributeWeight andValue:[results.Weight stringValue]];
        }
        
        
        NSString *uid = results.UID;
        if (nil == uid)
        {
            uid = [Utilities GUID];
            NSManagedObjectContext *context = [results managedObjectContext];
            results.UID = uid;
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        [resultElement addAttribute:kXMLAttributeUID andValue:uid];

        [resultsParent addChild:resultElement];
    }
}

/**
 adds the HIV drugs to the XML doc
 */
- (void) addMedications:(XMLElement *)medicationParent
{
    for (Medication *medication in self.allMedications)
    {
        XMLElement *medElement = [[XMLElement alloc]initWithName:kXMLElementMedication];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [medElement addAttribute:kXMLAttributeStartDate andValue:[formatter stringFromDate:medication.StartDate]];
        [medElement addAttribute:kXMLAttributeName andValue:medication.Name];
        [medElement addAttribute:kXMLAttributeDrug andValue:medication.Drug];
        [medElement addAttribute:kXMLAttributeMedicationForm andValue:medication.MedicationForm];
        NSString *uid = medication.UID;
        if (nil == uid)
        {
            uid = [Utilities GUID];
            NSManagedObjectContext *context = [medication managedObjectContext];
            medication.UID = uid;
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        [medElement addAttribute:kXMLAttributeUID andValue:uid];
        [medicationParent addChild:medElement];
    }
    
}

/**
 adds the missed HIV drugs to the XML doc
 */
- (void) addMissedMedications:(XMLElement *)missedMedicationParent
{
    for (MissedMedication *missedMed in self.allMissedMeds)
    {
        XMLElement *missedMedElement = [[XMLElement alloc]initWithName:kXMLElementMissedMedication];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [missedMedElement addAttribute:kXMLAttributeMissedDate andValue:[formatter stringFromDate:missedMed.MissedDate]];
        [missedMedElement addAttribute:kXMLAttributeName andValue:missedMed.Name];
        [missedMedElement addAttribute:kXMLAttributeDrug andValue:missedMed.Drug];
        [missedMedElement addAttribute:kXMLAttributeMissedReason andValue:missedMed.missedReason];
        NSString *uid = missedMed.UID;
        if (nil == uid)
        {
            uid = [Utilities GUID];
            NSManagedObjectContext *context = [missedMed managedObjectContext];
            missedMed.UID = uid;
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        [missedMedElement addAttribute:kXMLAttributeUID andValue:uid];
        [missedMedicationParent addChild:missedMedElement];
    }
}


/**
 adds the list of general meds to the XML doc
 */
- (void) addOtherMeds:(XMLElement *)otherMedsParent
{
    for (OtherMedication *otherMed in self.allOtherMeds)
    {
        XMLElement *otherMedElement = [[XMLElement alloc]initWithName:kXMLElementOtherMedication];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [otherMedElement addAttribute:kXMLAttributeStartDate andValue:[formatter stringFromDate:otherMed.StartDate]];
        [otherMedElement addAttribute:kXMLAttributeName andValue:otherMed.Name];

        if (nil != otherMed.MedicationForm)
        {
            [otherMedElement addAttribute:kXMLAttributeMedicationForm andValue:otherMed.MedicationForm];
        }
        
        NSString *unit = otherMed.Unit;
        if (nil != unit)
        {
            [otherMedElement addAttribute:kXMLAttributeUnit andValue:unit];
        }
        
        NSString *uid = otherMed.UID;
        if (nil == uid)
        {
            uid = [Utilities GUID];
            NSManagedObjectContext *context = [otherMed managedObjectContext];
            otherMed.UID = uid;
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        [otherMedElement addAttribute:kXMLAttributeUID andValue:uid];
        [otherMedsParent addChild:otherMedElement];
        
    }
    
}

- (void) addContacts:(XMLElement *)contactsParent
{
    for (Contacts *contacts in self.allContacts)
    {
        XMLElement *contactElement = [[XMLElement alloc]initWithName:kXMLElementContacts];
        [contactElement addAttribute:kXMLAttributeClinicName andValue:contacts.ClinicName];
        [contactElement addAttribute:kXMLAttributeClinicID andValue:contacts.ClinicID];
        [contactElement addAttribute:kXMLAttributeClinicEmailAddress andValue:contacts.ClinicEmailAddress];
        [contactElement addAttribute:kXMLAttributeClinicWebSite andValue:contacts.ClinicWebSite];
        [contactElement addAttribute:kXMLAttributeClinicContactNumber andValue:contacts.ClinicContactNumber];
        [contactElement addAttribute:kXMLAttributeEmergencyContactNumber
                            andValue:contacts.EmergencyContactNumber];
        NSString *uid = contacts.UID;
        if (nil == uid)
        {
            uid = [Utilities GUID];
            NSManagedObjectContext *context = [contacts managedObjectContext];
            contacts.UID = uid;
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        [contactElement addAttribute:kXMLAttributeUID andValue:uid];
        [contactsParent addChild:contactElement];        
    }
    
}

- (void) addSideEffects:(XMLElement *)sideEffectsParent
{
    for (SideEffects *effects in self.allSideEffects)
    {
        XMLElement *sideEffect = [[XMLElement alloc]initWithName:kXMLElementSideEffects];
        [sideEffect addAttribute:kXMLAttributeSideEffect andValue:effects.SideEffect];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;

        [sideEffect addAttribute:kXMLAttributeSideEffectDate andValue:[formatter stringFromDate:effects.SideEffectDate]];
        [sideEffect addAttribute:kXMLAttributeName andValue:effects.Name];
        [sideEffect addAttribute:kXMLAttributeDrug andValue:effects.Drug];
        [sideEffect addAttribute:kXMLAttributeSeriousness andValue:effects.seriousness];
        NSString *uid = effects.UID;
        if (nil == uid)
        {
            uid = [Utilities GUID];
            NSManagedObjectContext *context = [effects managedObjectContext];
            effects.UID = uid;
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        [sideEffect addAttribute:kXMLAttributeUID andValue:uid];
        [sideEffectsParent addChild:sideEffect];        
    }
}

- (void) addProcedures:(XMLElement *)proceduresParent
{
    for (Procedures *procedure in self.allProcedures)
    {
        XMLElement *procElement = [[XMLElement alloc]initWithName:kXMLElementProcedures];
        [procElement addAttribute:kXMLAttributeIllness andValue:procedure.Illness];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [procElement addAttribute:kXMLAttributeDate andValue:[formatter stringFromDate:procedure.Date]];
        [procElement addAttribute:kXMLAttributeName andValue:procedure.Name];
        NSString *uid = procedure.UID;
        if (nil == uid)
        {
            uid = [Utilities GUID];
            NSManagedObjectContext *context = [procedure managedObjectContext];
            procedure.UID = uid;
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        [procElement addAttribute:kXMLAttributeUID andValue:uid];
        [proceduresParent addChild:procElement];                
    }
}

- (void) addPreviousMedications:(XMLElement *)previousMedsParent
{
    for (PreviousMedication *prevMed in self.allPreviousMedications)
    {
        XMLElement *prevElement = [[XMLElement alloc]initWithName:kXMLElementPreviousMedication];
        [prevElement addAttribute:kXMLAttributeNameLowerCase andValue:prevMed.name];
        [prevElement addAttribute:kXMLAttributeDrugLowerCase andValue:prevMed.drug];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [prevElement addAttribute:kXMLAttributeStartDateLowerCase andValue:[formatter stringFromDate:prevMed.startDate]];
        [prevElement addAttribute:kXMLAttributeEndDateLowerCase andValue:[formatter stringFromDate:prevMed.endDate]];
        BOOL isArt = [prevMed.isART boolValue];
        if (isArt)
        {
            [prevElement addAttribute:kXMLAttributeIsART andValue:@"YES"];
        }
        else
        {
            [prevElement addAttribute:kXMLAttributeIsART andValue:@"NO"];
        }
        NSString *uid = prevMed.uID;
        if (nil == uid)
        {
            uid = [Utilities GUID];
            NSManagedObjectContext *context = [prevMed managedObjectContext];
            prevMed.uID = uid;
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        [prevElement addAttribute:kXMLAttributeUIDLowerCase andValue:uid];
        [previousMedsParent addChild:prevElement];
        
    }
}

- (void) addWellness:(XMLElement *)wellnessParent
{
    
}


#pragma mark -
#pragma mark Utilities for Core Data Management 
/**
 */
- (BOOL) containsResultsUID:(NSString *)UID
{
    if (nil == UID)
    {
        return NO;
    }
    if (0 == [self.allResults count])
    {
        return NO;
    }
    for (Results *results in self.allResults)
    {
        if ([UID isEqualToString:results.UID])
        {
            return YES;
        }
    }
    return NO;
}
/**
 */
- (BOOL) containsMedicationsUID:(NSString *)UID
{
    if (nil == UID)
    {
        return NO;
    }
    if (0 == [self.allMedications count])
    {
        return NO;
    }
    for (Medication *med in self.allMedications)
    {
        if ([UID isEqualToString:med.UID])
        {
            return YES;
        }
    }
    return NO;
}
/**
 */
- (BOOL) containsMissedMedicationsUID:(NSString *)UID
{
    if (nil == UID)
    {
        return NO;
    }
    if (0 == [self.allMissedMeds count])
    {
        return NO;
    }
    for (MissedMedication *missedMed in self.allMissedMeds)
    {
        if ([UID isEqualToString:missedMed.UID])
        {
            return YES;
        }
    }
    return NO;
}
/**
 */
- (BOOL) containsOtherMedicationsUID:(NSString *)UID
{
    if (nil == UID)
    {
        return NO;
    }
    if (0 == [self.allOtherMeds count])
    {
        return NO;
    }
    for (OtherMedication *otherMed in self.allOtherMeds)
    {
        if ([UID isEqualToString:otherMed.UID])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL) containsProceduresUID:(NSString *)UID
{
    if (nil == UID)
    {
        return NO;
    }
    if (0 == [self.allProcedures count])
    {
        return NO;
    }
    for (Procedures *procs in self.allProcedures)
    {
        if ([UID isEqualToString:procs.UID])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL) containsSideEffectsUID:(NSString *)UID
{
    if (nil == UID)
    {
        return NO;
    }
    if (0 == [self.allSideEffects count])
    {
        return NO;
    }
    for (SideEffects *effects in self.allSideEffects)
    {
        if ([UID isEqualToString:effects.UID])
        {
            return YES;
        }
    }
    return NO;
    
}
- (BOOL) containsContactsUID:(NSString *)UID
{
    if (nil == UID)
    {
        return NO;
    }
    if (0 == [self.allContacts count])
    {
        return NO;
    }
    for (Contacts *contact in self.allContacts)
    {
        if ([UID isEqualToString:contact.UID])
        {
            return YES;
        }
    }
    return NO;
    
}

- (BOOL) containsPreviousMedsUID:(NSString *)UID
{
    return NO;
}
- (BOOL) containsWellnessUID:(NSString *)UID
{
    return NO;
}


/**
 only adds result if the UID doesn't exist
 */
- (void) addResultsToSQL:(XMLElement *)resultElement
{
    if ([self containsResultsUID:[resultElement elementUID]])
    {
        return;
    }
    NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
    Results *result = [NSEntityDescription insertNewObjectForEntityForName:kXMLElementResults inManagedObjectContext:context];
    [self.masterRecord addResultsObject:result];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    result.ResultsDate = [formatter dateFromString:[resultElement attributeValue:kXMLAttributeResultsDate]];
    if (nil != [resultElement elementUID])
    {
        result.UID = [resultElement elementUID];
    }
    else
    {
        result.UID = [Utilities GUID]; 
    }

    NSString *_cd4 = [resultElement attributeValue:kXMLAttributeCD4];
    NSString *_cd4Percent = [resultElement attributeValue:kXMLAttributeCD4Percent];
    NSString *_vl = [resultElement attributeValue:kXMLAttributeViralLoad];
    NSString *_vlHepC = [resultElement attributeValue:kXMLAttributeHepCViralLoad];
    NSString *_glucose = [resultElement attributeValue:kXMLAttributeGlucose];
    NSString *_cholesterol = [resultElement attributeValue:kXMLAttributeTotalCholesterol];
    NSString *_hdl = [resultElement attributeValue:kXMLAttributeHDL];
    NSString *_ldl = [resultElement attributeValue:kXMLAttributeLDL];

    NSString *_platelets = [resultElement attributeValue:kXMLAttributePlatelet];
    NSString *_hemo = [resultElement attributeValue:kXMLAttributeHemoglobulin];
    NSString *_red = [resultElement attributeValue:kXMLAttributeRedBloodCells];
    NSString *_white = [resultElement attributeValue:kXMLAttributeWhiteBloodCells];

    NSString *_weight = [resultElement attributeValue:kXMLAttributeWeight];
    NSString *_systole = [resultElement attributeValue:kXMLAttributeSystole];
    NSString *_diastole = [resultElement attributeValue:kXMLAttributeDiastole];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    if (nil != _cd4)
    {
        result.CD4 = [numberFormatter numberFromString:_cd4];
    }
    else
    {
        result.CD4 = [NSNumber numberWithFloat:(-1.0)];
    }

    if (nil != _cd4Percent)
    {
        result.CD4Percent = [numberFormatter numberFromString:_cd4Percent];
    }
    else
    {
        result.CD4Percent = [NSNumber numberWithFloat:(-1.0)];
    }

    if (nil != _vl)
    {
        if ([_vl isEqualToString:@"undetectable"])
        {
            result.ViralLoad = [NSNumber numberWithFloat:(0.0)];
        }
        else
            result.ViralLoad = [numberFormatter numberFromString:_vl];
    }
    else
    {
        result.ViralLoad = [NSNumber numberWithFloat:(-1.0)];
    }
    
    if (nil != _vlHepC)
    {
        if ([_vlHepC isEqualToString:@"undetectable"])
        {
            result.HepCViralLoad = [NSNumber numberWithFloat:(0.0)];
        }
        else
            result.HepCViralLoad = [numberFormatter numberFromString:_vlHepC];
    }
    else
    {
        result.HepCViralLoad = [NSNumber numberWithFloat:(-1.0)];
    }
    
    if (nil != _glucose)
    {
        result.Glucose = [numberFormatter numberFromString:_glucose];
    }
    else
    {
        result.Glucose = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _cholesterol)
    {
        result.TotalCholesterol = [numberFormatter numberFromString:_cholesterol];
    }
    else
    {
        result.TotalCholesterol = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _hdl)
    {
        result.HDL = [numberFormatter numberFromString:_hdl];
    }
    else
    {
        result.HDL = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _ldl)
    {
        result.LDL = [numberFormatter numberFromString:_ldl];
    }
    else
    {
        result.LDL = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _platelets)
    {
        result.PlateletCount = [numberFormatter numberFromString:_platelets];
    }
    else
    {
        result.PlateletCount = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _hemo)
    {
        result.Hemoglobulin = [numberFormatter numberFromString:_hemo];
    }
    else
    {
        result.Hemoglobulin = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _white)
    {
        result.WhiteBloodCellCount = [numberFormatter numberFromString:_white];
    }
    else
    {
        result.WhiteBloodCellCount = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _red)
    {
        result.redBloodCellCount = [numberFormatter numberFromString:_red];
    }
    else
    {
        result.redBloodCellCount = [NSNumber numberWithFloat:(-1.0)];
        
    }

    
    if (nil != _weight)
    {
        result.Weight = [numberFormatter numberFromString:_weight];
    }
    else
    {
        result.Weight = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _systole)
    {
        result.Systole = [numberFormatter numberFromString:_systole];
    }
    else
    {
        result.Systole = [NSNumber numberWithFloat:(-1.0)];
        
    }
    if (nil != _diastole)
    {
        result.Diastole = [numberFormatter numberFromString:_diastole];
    }
    else
    {
        result.Diastole = [NSNumber numberWithFloat:(-1.0)];
        
    }
    
    
	NSError *error = nil;
	if (![context save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}
/**
 only adds medication if the UID doesn't exist
 */
- (void) addMedicationsToSQL:(XMLElement *)medicationElement
{
    if ([self containsMedicationsUID:[medicationElement elementUID]])
    {
        return;
    }
    NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
    Medication *medication = [NSEntityDescription insertNewObjectForEntityForName:kXMLElementMedication inManagedObjectContext:context];
    [self.masterRecord addMedicationsObject:medication];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    medication.StartDate = [formatter dateFromString:[medicationElement attributeValue:kXMLAttributeStartDate]];
    if (nil != [medicationElement elementUID])
    {
        medication.UID = [medicationElement elementUID];
    }
    else
    {
        medication.UID = [Utilities GUID];
    }


    NSString *_name = [medicationElement attributeValue:kXMLAttributeName];
    NSString *_drug = [medicationElement attributeValue:kXMLAttributeDrug];
    NSString *_form = [medicationElement attributeValue:kXMLAttributeMedicationForm];
    NSString *_dose = [medicationElement attributeValue:kXMLAttributeDose];
    
    if (nil != _name)
    {
        medication.Name = _name;
    }
    if (nil != _drug)
    {
        medication.Drug = _drug;
    }
	if (nil != _form)
    {
        medication.MedicationForm = _form;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    if (nil != _dose)
    {
        medication.Dose = [numberFormatter numberFromString:_dose];
    }
    
    NSError *error = nil;
	if (![context save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
}
/**
 only adds missedMedication if the UID doesn't exist
 */
- (void) addMissedMedicationToSQL:(XMLElement *)missedMedicationElement
{
    if ([self containsMissedMedicationsUID:[missedMedicationElement elementUID]])
    {
        return;
    }
    NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
    MissedMedication *missedMed = [NSEntityDescription insertNewObjectForEntityForName:kXMLElementMissedMedication inManagedObjectContext:context];
    [self.masterRecord addMissedMedicationsObject:missedMed];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    missedMed.MissedDate = [formatter dateFromString:[missedMedicationElement attributeValue:kXMLAttributeMissedDate]];
    if (nil!= [missedMedicationElement elementUID])
    {
        missedMed.UID = [missedMedicationElement elementUID];        
    }
    else
    {
        missedMed.UID = [Utilities GUID];
    }
    NSString *_name = [missedMedicationElement attributeValue:kXMLAttributeName];
    NSString *_drug = [missedMedicationElement attributeValue:kXMLAttributeDrug];
    NSString *_reason = [missedMedicationElement attributeValue:kXMLAttributeMissedReason];

    if (nil != _name)
    {
        missedMed.Name = _name;
    }
    if (nil != _drug)
    {
        missedMed.Drug = _drug;
    }
    
    if (nil != _reason)
    {
        missedMed.missedReason = _reason;
    }
    NSError *error = nil;
	if (![context save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}
/**
 only adds other medication if the UID doesn't exist
 */
- (void) addOtherMedicationsToSQL:(XMLElement *)otherMedicationsElement
{
    if ([self containsOtherMedicationsUID:[otherMedicationsElement elementUID]])
    {
        return;
    }
    NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
    OtherMedication *otherMed = [NSEntityDescription insertNewObjectForEntityForName:kXMLElementOtherMedication inManagedObjectContext:context];
    [self.masterRecord addOtherMedicationsObject:otherMed];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    otherMed.StartDate = [formatter dateFromString:[otherMedicationsElement attributeValue:kXMLAttributeStartDate]];
    if (nil != [otherMedicationsElement elementUID])
    {
        otherMed.UID = [otherMedicationsElement elementUID];
    }
    else
    {
        otherMed.UID = [Utilities GUID];        
    }
    
    
    NSString *_name = [otherMedicationsElement attributeValue:kXMLAttributeName];
    NSString *_form = [otherMedicationsElement attributeValue:kXMLAttributeMedicationForm];
    NSString *_dose = [otherMedicationsElement attributeValue:kXMLAttributeDose];
    NSString *_unit = [otherMedicationsElement attributeValue:kXMLAttributeUnit];
    
    if (nil != _name)
    {
        otherMed.Name = _name;
    }
	if (nil != _form)
    {
        otherMed.MedicationForm = _form;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    if (nil != _dose)
    {
        otherMed.Dose = [numberFormatter numberFromString:_dose];
    }
    
    if (nil != _unit)
    {
        otherMed.Unit = _unit;
    }
    
    NSError *error = nil;
	if (![context save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
}

- (void) addClinicsToSQL:(XMLElement *)contactsElement
{
    if ([self containsContactsUID:[contactsElement elementUID]])
    {
        return;
    }
    NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
    Contacts *contacts = [NSEntityDescription insertNewObjectForEntityForName:kXMLElementContacts inManagedObjectContext:context];
    [self.masterRecord addContactsObject:contacts];
    
    if (nil != [contactsElement elementUID])
    {
        contacts.UID = [contactsElement elementUID];
    }
    else
        contacts.UID = [Utilities GUID];
        
    NSString *_clinicName = [contactsElement attributeValue:kXMLAttributeClinicName];
    NSString *_clinicID = [contactsElement attributeValue:kXMLAttributeClinicID];
    NSString *_clinicEmail = [contactsElement attributeValue:kXMLAttributeClinicEmailAddress];
    NSString *_clinicWWW = [contactsElement attributeValue:kXMLAttributeClinicWebSite];
    NSString *_clinicNumber = [contactsElement attributeValue:kXMLAttributeClinicContactNumber];
    NSString *_emergency = [contactsElement attributeValue:kXMLAttributeEmergencyContactNumber];
    if (nil != _clinicName)
    {
        contacts.ClinicName = _clinicName;
    }
    if (nil != _clinicID)
    {
        contacts.ClinicID = _clinicID;
    }
    if (nil != _clinicEmail)
    {
        contacts.ClinicEmailAddress = _clinicEmail;
    }
    if (nil != _clinicWWW)
    {
        contacts.ClinicWebSite = _clinicWWW;
    }
    if (nil != _clinicNumber)
    {
        contacts.ClinicContactNumber = _clinicNumber;
    }
    if (nil != _emergency)
    {
        contacts.EmergencyContactNumber = _emergency;
    }
                
    NSError *error = nil;
	if (![context save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
}

- (void) addSideEffectsToSQL:(XMLElement *)sideEffectsElement
{
    if ([self containsSideEffectsUID:[sideEffectsElement elementUID]])
    {
        return;
    }
    NSManagedObjectContext *context = [self.masterRecord managedObjectContext];

    SideEffects *effect = [NSEntityDescription insertNewObjectForEntityForName:kXMLElementSideEffects inManagedObjectContext:context];
    [self.masterRecord addSideeffectsObject:effect];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    if (nil != [sideEffectsElement elementUID])
    {
        effect.UID = [sideEffectsElement elementUID];
    }
    else
        effect.UID = [Utilities GUID];
    
    effect.SideEffectDate = [formatter dateFromString:[sideEffectsElement attributeValue:kXMLAttributeSideEffectDate]];
    
    NSString *_name = [sideEffectsElement attributeValue:kXMLAttributeName];
    NSString *_drug = [sideEffectsElement attributeValue:kXMLAttributeDrug];
    NSString *_effect = [sideEffectsElement attributeValue:kXMLAttributeSideEffect];
    NSString *_serious = [sideEffectsElement attributeValue:kXMLAttributeSeriousness];
    if(nil != _name)
        effect.Name = _name;
    if(nil != _drug)
        effect.Drug = _drug;
    if (nil != _effect)
    {
        effect.SideEffect = _effect;
    }
    if (nil != _serious)
    {
        effect.seriousness = _serious;
    }
    
    NSError *error = nil;
	if (![context save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
}

- (void) addProceduresToSQL:(XMLElement *)proceduresElement
{
    if ([self containsProceduresUID:[proceduresElement elementUID]])
    {
        return;
    }
    NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
    Procedures *procedures = [NSEntityDescription insertNewObjectForEntityForName:kXMLElementProcedures inManagedObjectContext:context];
    [self.masterRecord addProceduresObject:procedures];
    
    if (nil != [proceduresElement elementUID])
    {
        procedures.UID = [proceduresElement elementUID];
    }
    else
        procedures.UID = [Utilities GUID];
        
    NSString *_illness = [proceduresElement attributeValue:kXMLAttributeIllness];
    NSString *_name = [proceduresElement attributeValue:kXMLAttributeName];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    procedures.Date = [formatter dateFromString:[proceduresElement attributeValue:kXMLAttributeDate]];
    
    if (nil != _illness)
    {
        procedures.Illness = _illness;
    }
    
    if (nil != _name)
    {
        procedures.Name = _name;
    }
    
    NSError *error = nil;
	if (![context save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}    
}

- (void) addPreviousMedicationsToSQL:(XMLElement *)previousElement
{
    if ([self containsProceduresUID:[previousElement elementUID]])
    {
        return;
    }
    NSManagedObjectContext *context = [self.masterRecord managedObjectContext];
    PreviousMedication *prev = [NSEntityDescription insertNewObjectForEntityForName:kXMLElementPreviousMedication inManagedObjectContext:context];
    [self.masterRecord addPreviousMedicationsObject:prev];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    if (nil != [previousElement elementUID])
    {
        prev.uID = [previousElement elementUID];
    }
    else
        prev.uID = [Utilities GUID];
    
    prev.startDate = [formatter dateFromString:[previousElement attributeValue:kXMLAttributeStartDateLowerCase]];
    prev.endDate = [formatter dateFromString:[previousElement attributeValue:kXMLAttributeEndDateLowerCase]];
    
    
    NSString *_name = [previousElement attributeValue:kXMLAttributeName];
    NSString *_drug = [previousElement attributeValue:kXMLAttributeDrug];
    NSString *_isArt = [previousElement attributeValue:kXMLAttributeIsART];
    
    if (nil != _name)
    {
        prev.name = _name;
    }
    if (nil != _drug)
    {
        prev.drug = _drug;
    }
    if (nil != _isArt)
    {
        if ([_isArt hasPrefix:@"YES"])
        {
            prev.isART = [NSNumber numberWithBool:YES];
        }
        else
            prev.isART = [NSNumber numberWithBool:NO];
    }
    
    NSError *error = nil;
	if (![context save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
}

- (void) addWellnessToSQL:(XMLElement *)wellnessElement
{
    
}


#pragma mark -
#pragma mark Core Data 
/**
 fetch the latest data from the SQL database
 */
- (void)getSQLData
{
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
    {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"Error Loading Data",nil) 
							  message:[NSString stringWithFormat:NSLocalizedString(@"Error was %@, quitting.", @"Error was %@, quitting"), [error localizedDescription]] 
							  delegate:self 
							  cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
							  otherButtonTitles:nil];
		[alert show];
	}
    NSArray *records = [self.fetchedResultsController fetchedObjects];
    if (0 == records.count)
    {
        self.allResults = [NSMutableArray array];
        self.allMedications = [NSMutableArray array];
        self.allMissedMeds = [NSMutableArray array];
        self.allOtherMeds = [NSMutableArray array];
        self.allContacts = [NSMutableArray array];
        self.allSideEffects = [NSMutableArray array];
        self.allProcedures = [NSMutableArray array];
        self.allPreviousMedications = [NSMutableArray array];
        self.allWellness = [NSMutableArray array];
        self.masterRecord = nil;
        return;
    }
	self.masterRecord = (iStayHealthyRecord *)[records objectAtIndex:0];
    
	if (0 != [self.masterRecord.results count])
    {
		self.allResults = [NSArray arrayByOrderingSet:self.masterRecord.results byKey:@"ResultsDate" ascending:YES reverseOrder:NO];
	}
    else
        self.allResults = (NSArray *)self.masterRecord.results;
    
	if (0 != [self.masterRecord.medications count])
    {
		self.allMedications = [NSArray arrayByOrderingSet:self.masterRecord.medications byKey:@"StartDate" ascending:YES reverseOrder:NO];
	}
    else
        self.allMedications = (NSArray *)self.masterRecord.medications;
    
    if (0 != [self.masterRecord.missedMedications count])
    {
        self.allMissedMeds = [NSArray arrayByOrderingSet:self.masterRecord.missedMedications byKey:@"MissedDate" ascending:YES reverseOrder:NO];
    }
    else
        self.allMissedMeds = (NSArray *)self.masterRecord.missedMedications;
    
    if(0 != [self.masterRecord.otherMedications count])
    {
        self.allOtherMeds = [NSArray arrayByOrderingSet:self.masterRecord.otherMedications byKey:@"StartDate" ascending:YES reverseOrder:NO];
    }
    else
        self.allOtherMeds = (NSArray *)self.masterRecord.otherMedications;
    

    if(0 != [self.masterRecord.procedures count])
    {
        self.allProcedures = [NSArray arrayByOrderingSet:self.masterRecord.procedures byKey:@"Date" ascending:YES reverseOrder:NO];
    }
    else{
        self.allProcedures = (NSArray *)self.masterRecord.procedures;
    }
    
    if (0 != [self.masterRecord.sideeffects count])
    {
        self.allSideEffects = [NSArray arrayByOrderingSet:self.masterRecord.sideeffects byKey:@"SideEffectDate" ascending:YES reverseOrder:NO];
    }
    else
    {
        self.allSideEffects = (NSArray *)self.masterRecord.sideeffects;
    }
    // no particular order is needed for contacts
    self.allContacts = (NSArray *)self.masterRecord.contacts;
    
    
}

/**
 this handles the fetching of the objects
 @return NSFetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController_ != nil)
    {
		return fetchedResultsController_;
	}
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"iStayHealthyRecord" inManagedObjectContext:context];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"Name" ascending:YES];
	NSArray *allDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:allDescriptors];	
	[request setEntity:entity];
	
	NSFetchedResultsController *tmpFetchController = [[NSFetchedResultsController alloc]
													  initWithFetchRequest:request 
													  managedObjectContext:context 
													  sectionNameKeyPath:nil 
													  cacheName:nil];
	tmpFetchController.delegate = self;
	fetchedResultsController_ = tmpFetchController;
	
	return fetchedResultsController_;
	
}	

/**
 notified when changes to the database
 @controller
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	NSArray *objects = [self.fetchedResultsController fetchedObjects];
    if (0 == objects.count)
    {
        return;
    }
	self.masterRecord = (iStayHealthyRecord *)[objects objectAtIndex:0];
}



@end
