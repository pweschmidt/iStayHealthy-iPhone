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
            [csv appendString:@"Date, SideEffect, DrugName\r"];
            isFirst = NO;
        }
        NSString *date = [formatter stringFromDate:effect.SideEffectDate];
        NSString *effectName = effect.SideEffect;
        NSString *name = effect.Name;
        [csv appendFormat:@"%@, %@, %@\r",date, effectName, name];
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
    [root addAttribute:@"UID" andValue:masterUID];
    
    if (0 < [self.allResults count])
    {
        XMLElement *results = [[XMLElement alloc]initWithName:@"Results"];
        [self addResults:results];
        [root addChild:results];
    }
    
    if (0 < [self.allMedications count])
    {
        XMLElement *medications = [[XMLElement alloc]initWithName:@"Medications"];
        [self addMedications:medications];
        [root addChild:medications];
    }
    
    if (0 < [self.allMissedMeds count])
    {
        XMLElement *missedMedications = [[XMLElement alloc]initWithName:@"MissedMedications"];
        [self addMissedMedications:missedMedications];
        [root addChild:missedMedications];
    }
        
    if (0 < [self.allOtherMeds count])
    {
        XMLElement *otherMedications = [[XMLElement alloc]initWithName:@"OtherMedications"];
        [self addOtherMeds:otherMedications];        
        [root addChild:otherMedications];
    }
    
    if (0 < [self.allContacts count])
    {
        XMLElement *contacts = [[XMLElement alloc]initWithName:@"ClinicalContacts"];
        [self addContacts:contacts];
        [root addChild:contacts];
    }
    
    if (0 < [self.allSideEffects count])
    {
        XMLElement *sideEffects = [[XMLElement alloc]initWithName:@"HIVSideEffects"];
        [self addSideEffects:sideEffects];
        [root addChild:sideEffects];
    }
    
    if (0 < [self.allProcedures count])
    {
        XMLElement *procedures = [[XMLElement alloc]initWithName:@"IllnessesAndProcedures"];
        [self addProcedures:procedures];
        [root addChild:procedures];        
    }
    
    if (0 < self.allPreviousMedications.count)
    {
        XMLElement *previousMeds = [[XMLElement alloc]initWithName:@"PreviousMedications"];
        [self addPreviousMedications:previousMeds];
        [root addChild:previousMeds];
    }
    
    if (0 < self.allWellness.count)
    {
        XMLElement *wellness = [[XMLElement alloc]initWithName:@"Wellness"];
        [self addWellness:wellness];
        [root addChild:wellness];
    }

    NSString *xmlString = [document xmlString];
    NSLog(@"XML string = %@",xmlString);

    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 adds the results to the XML doc
 */
- (void) addResults:(XMLElement *)resultsParent
{
    for (Results *results in self.allResults)
    {
        XMLElement *resultElement = [[XMLElement alloc]initWithName:@"Result"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [resultElement addAttribute:@"ResultsDate" andValue:[formatter stringFromDate:results.ResultsDate]];
        if (0.0 < [results.CD4 floatValue])
        {
            [resultElement addAttribute:@"CD4" andValue:[results.CD4 stringValue]];
        }
        if (0.0 < [results.CD4Percent floatValue])
        {
            [resultElement addAttribute:@"CD4Percent" andValue:[results.CD4Percent stringValue]];
        }
        if (0.0 <= [results.ViralLoad floatValue])
        {
            if (0.0 == [results.ViralLoad floatValue])
            {
                [resultElement addAttribute:@"ViralLoad" andValue:@"undetectable"];
            }
            else
                [resultElement addAttribute:@"ViralLoad" andValue:[results.ViralLoad stringValue]];
        }
        if (0.0 <= [results.HepCViralLoad floatValue])
        {
            if (0.0 == [results.HepCViralLoad floatValue])
            {
                [resultElement addAttribute:@"HepCViralLoad" andValue:@"undetectable"];                
            }
            else
                [resultElement addAttribute:@"HepCViralLoad" andValue:[results.HepCViralLoad stringValue]];
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
        [resultElement addAttribute:@"UID" andValue:uid];

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
        XMLElement *medElement = [[XMLElement alloc]initWithName:@"Medication"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [medElement addAttribute:@"StartDate" andValue:[formatter stringFromDate:medication.StartDate]];
        [medElement addAttribute:@"Name" andValue:medication.Name];
        [medElement addAttribute:@"Drug" andValue:medication.Drug];
        [medElement addAttribute:@"MedicationForm" andValue:medication.MedicationForm];
        NSDate *endDate = medication.EndDate;
        if (nil != endDate)
        {
            [medElement addAttribute:@"EndDate" andValue:[formatter stringFromDate:medication.EndDate]];
        }
        if (0.0 < [medication.Dose floatValue])
        {
            [medElement addAttribute:@"Dose" andValue:[medication.Dose stringValue]];
        }        
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
        [medElement addAttribute:@"UID" andValue:uid];
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
        XMLElement *missedMedElement = [[XMLElement alloc]initWithName:@"MissedMedication"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [missedMedElement addAttribute:@"MissedDate" andValue:[formatter stringFromDate:missedMed.MissedDate]];
        [missedMedElement addAttribute:@"Name" andValue:missedMed.Name];
        [missedMedElement addAttribute:@"Drug" andValue:missedMed.Drug];
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
        [missedMedElement addAttribute:@"UID" andValue:uid];        
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
        XMLElement *otherMedElement = [[XMLElement alloc]initWithName:@"OtherMedication"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [otherMedElement addAttribute:@"StartDate" andValue:[formatter stringFromDate:otherMed.StartDate]];
        [otherMedElement addAttribute:@"Name" andValue:otherMed.Name];

        if (nil != otherMed.MedicationForm)
        {
            [otherMedElement addAttribute:@"MedicationForm" andValue:otherMed.MedicationForm];
        }

        NSDate *endDate = otherMed.EndDate;
        if (nil != endDate)
        {
            [otherMedElement addAttribute:@"EndDate" andValue:[formatter stringFromDate:otherMed.EndDate]];
        }
        if (0.0 < [otherMed.Dose floatValue])
        {
            [otherMedElement addAttribute:@"Dose" andValue:[otherMed.Dose stringValue]];
        }   
        
        NSString *unit = otherMed.Unit;
        if (nil != unit)
        {
            [otherMedElement addAttribute:@"Unit" andValue:unit];
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
        [otherMedElement addAttribute:@"UID" andValue:uid];        
        [otherMedsParent addChild:otherMedElement];
        
    }
    
}

- (void) addContacts:(XMLElement *)contactsParent
{
    for (Contacts *contacts in self.allContacts)
    {
        XMLElement *contactElement = [[XMLElement alloc]initWithName:@"Contacts"];
        [contactElement addAttribute:@"ClinicName" andValue:contacts.ClinicName];
        [contactElement addAttribute:@"ClinicID" andValue:contacts.ClinicID];
        [contactElement addAttribute:@"ClinicEmailAddress" andValue:contacts.ClinicEmailAddress];
        [contactElement addAttribute:@"ClinicWebSite" andValue:contacts.ClinicWebSite];
        [contactElement addAttribute:@"ClinicContactNumber" andValue:contacts.ClinicContactNumber];
        [contactElement addAttribute:@"EmergencyContactNumber" andValue:contacts.EmergencyContactNumber];
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
        [contactElement addAttribute:@"UID" andValue:uid];    
        [contactsParent addChild:contactElement];        
    }
    
}

- (void) addSideEffects:(XMLElement *)sideEffectsParent
{
    for (SideEffects *effects in self.allSideEffects)
    {
        XMLElement *sideEffect = [[XMLElement alloc]initWithName:@"SideEffects"];
        [sideEffect addAttribute:@"SideEffect" andValue:effects.SideEffect];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;

        [sideEffect addAttribute:@"SideEffectDate" andValue:[formatter stringFromDate:effects.SideEffectDate]];
        [sideEffect addAttribute:@"Name" andValue:effects.Name];
        [sideEffect addAttribute:@"Drug" andValue:effects.Drug];
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
        [sideEffect addAttribute:@"UID" andValue:uid];    
        [sideEffectsParent addChild:sideEffect];        
    }
}

- (void) addProcedures:(XMLElement *)proceduresParent
{
    for (Procedures *procedure in self.allProcedures)
    {
        XMLElement *procElement = [[XMLElement alloc]initWithName:@"Procedures"];
        [procElement addAttribute:@"Illness" andValue:procedure.Illness];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATEFORMATSTYLE;
        [procElement addAttribute:@"Date" andValue:[formatter stringFromDate:procedure.Date]];
        [procElement addAttribute:@"Name" andValue:procedure.Name];
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
        [procElement addAttribute:@"UID" andValue:uid];    
        [proceduresParent addChild:procElement];                
    }
}

- (void) addPreviousMedications:(XMLElement *)previousMedsParent
{
    
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
    Results *result = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:context];
    [self.masterRecord addResultsObject:result];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    result.ResultsDate = [formatter dateFromString:[resultElement attributeValue:@"ResultsDate"]];
    if (nil != [resultElement elementUID])
    {
        result.UID = [resultElement elementUID];
    }
    else
    {
        result.UID = [Utilities GUID]; 
    }

    NSString *_cd4 = [resultElement attributeValue:@"CD4"];
    NSString *_cd4Percent = [resultElement attributeValue:@"CD4Percent"];
    NSString *_vl = [resultElement attributeValue:@"ViralLoad"];
    NSString *_vlHepC = [resultElement attributeValue:@"HepCViralLoad"];

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
    Medication *medication = [NSEntityDescription insertNewObjectForEntityForName:@"Medication" inManagedObjectContext:context];
    [self.masterRecord addMedicationsObject:medication];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    medication.StartDate = [formatter dateFromString:[medicationElement attributeValue:@"StartDate"]];
    if (nil != [medicationElement elementUID])
    {
        medication.UID = [medicationElement elementUID];
    }
    else
    {
        medication.UID = [Utilities GUID];
    }


    NSString *_name = [medicationElement attributeValue:@"Name"];
    NSString *_drug = [medicationElement attributeValue:@"Drug"];
    NSString *_form = [medicationElement attributeValue:@"MedicationForm"];
    NSString *_dose = [medicationElement attributeValue:@"Dose"];
    NSString *_endDate = [medicationElement attributeValue:@"EndDate"];
    
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
    if (nil != _endDate)
    {
        medication.EndDate = [formatter dateFromString:_endDate];
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
    MissedMedication *missedMed = [NSEntityDescription insertNewObjectForEntityForName:@"MissedMedication" inManagedObjectContext:context];
    [self.masterRecord addMissedMedicationsObject:missedMed];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    missedMed.MissedDate = [formatter dateFromString:[missedMedicationElement attributeValue:@"MissedDate"]];
    if (nil!= [missedMedicationElement elementUID])
    {
        missedMed.UID = [missedMedicationElement elementUID];        
    }
    else
    {
        missedMed.UID = [Utilities GUID];
    }
    NSString *_name = [missedMedicationElement attributeValue:@"Name"];
    NSString *_drug = [missedMedicationElement attributeValue:@"Drug"];

    if (nil != _name)
    {
        missedMed.Name = _name;
    }
    if (nil != _drug)
    {
        missedMed.Drug = _drug;
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
    OtherMedication *otherMed = [NSEntityDescription insertNewObjectForEntityForName:@"OtherMedication" inManagedObjectContext:context];
    [self.masterRecord addOtherMedicationsObject:otherMed];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    otherMed.StartDate = [formatter dateFromString:[otherMedicationsElement attributeValue:@"StartDate"]];
    if (nil != [otherMedicationsElement elementUID])
    {
        otherMed.UID = [otherMedicationsElement elementUID];
    }
    else
    {
        otherMed.UID = [Utilities GUID];        
    }
    
    
    NSString *_name = [otherMedicationsElement attributeValue:@"Name"];
    NSString *_form = [otherMedicationsElement attributeValue:@"MedicationForm"];
    NSString *_dose = [otherMedicationsElement attributeValue:@"Dose"];
    NSString *_endDate = [otherMedicationsElement attributeValue:@"EndDate"];
    NSString *_unit = [otherMedicationsElement attributeValue:@"Unit"];
    
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
    if (nil != _endDate)
    {
        otherMed.EndDate = [formatter dateFromString:_endDate];
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
    Contacts *contacts = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
    [self.masterRecord addContactsObject:contacts];
    
    if (nil != [contactsElement elementUID])
    {
        contacts.UID = [contactsElement elementUID];
    }
    else
        contacts.UID = [Utilities GUID];
        
    NSString *_clinicName = [contactsElement attributeValue:@"ClinicName"];
    NSString *_clinicID = [contactsElement attributeValue:@"ClinicID"];
    NSString *_clinicEmail = [contactsElement attributeValue:@"ClinicEmailAddress"];
    NSString *_clinicWWW = [contactsElement attributeValue:@"ClinicWebSite"];
    NSString *_clinicNumber = [contactsElement attributeValue:@"ClinicContactNumber"];
    NSString *_emergency = [contactsElement attributeValue:@"EmergencyContactNumber"];
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

    SideEffects *effect = [NSEntityDescription insertNewObjectForEntityForName:@"SideEffects" inManagedObjectContext:context];
    [self.masterRecord addSideeffectsObject:effect];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    if (nil != [sideEffectsElement elementUID])
    {
        effect.UID = [sideEffectsElement elementUID];
    }
    else
        effect.UID = [Utilities GUID];
    
    effect.SideEffectDate = [formatter dateFromString:[sideEffectsElement attributeValue:@"SideEffectDate"]];
    
    NSString *_name = [sideEffectsElement attributeValue:@"Name"];
    NSString *_drug = [sideEffectsElement attributeValue:@"Drug"];
    if(nil != _name)
        effect.Name = _name;
    if(nil != _drug)
        effect.Drug = _drug;    
    
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
    Procedures *procedures = [NSEntityDescription insertNewObjectForEntityForName:@"Procedures" inManagedObjectContext:context];
    [self.masterRecord addProceduresObject:procedures];
    
    if (nil != [proceduresElement elementUID])
    {
        procedures.UID = [proceduresElement elementUID];
    }
    else
        procedures.UID = [Utilities GUID];
        
    NSString *_illness = [proceduresElement attributeValue:@"Illness"];
    NSString *_name = [proceduresElement attributeValue:@"Name"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATEFORMATSTYLE;
    procedures.Date = [formatter dateFromString:[proceduresElement attributeValue:@"Date"]];
    
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
	self.masterRecord = (iStayHealthyRecord *)[objects objectAtIndex:0];
}



@end
