//
//  DataLoader.m
//  iStayHealthy
//
//  Created by peterschmidt on 07/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataLoader.h"
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
#import "Constants.h"

@interface DataLoader ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) SQLDataTableController *resultsController;
@property (nonatomic, strong) SQLDataTableController *wellnessController;
@property (nonatomic, strong) SQLDataTableController *previousController;
@property (nonatomic, strong) SQLDataTableController *effectsController;
@property (nonatomic, strong) SQLDataTableController *missedController;
@property (nonatomic, strong) SQLDataTableController *medsController;
@property (nonatomic, strong) SQLDataTableController *otherMedsController;
@property (nonatomic, strong) SQLDataTableController *contactsController;
@property (nonatomic, strong) SQLDataTableController *proceduresController;
@property (nonatomic, strong) SQLDataTableController *masterRecordController;
- (BOOL)hasRecords;
- (void)addResults:(XMLElement *)resultsParent;
- (void)addMedications:(XMLElement *)medicationParent;
- (void)addMissedMedications:(XMLElement *)missedMedicationParent;
- (void)addOtherMeds:(XMLElement *)otherMedsParent;
- (void)addContacts:(XMLElement *)contactsParent;
- (void)addSideEffects:(XMLElement *)sideEffectsParent;
- (void)addProcedures:(XMLElement *)proceduresParent;
- (void)addPreviousMedications:(XMLElement *)previousMedsParent;
- (void)addWellness:(XMLElement *)wellnessParent;
- (BOOL)containsResultsUID:(NSString *)UID;
- (BOOL)containsMedicationsUID:(NSString *)UID;
- (BOOL)containsMissedMedicationsUID:(NSString *)UID;
- (BOOL)containsOtherMedicationsUID:(NSString *)UID;
- (BOOL)containsProceduresUID:(NSString *)UID;
- (BOOL)containsSideEffectsUID:(NSString *)UID;
- (BOOL)containsContactsUID:(NSString *)UID;
- (BOOL)containsPreviousMedsUID:(NSString *)UID;
- (BOOL)containsWellnessUID:(NSString *)UID;
@end

@implementation DataLoader

- (id)init
{
	self = [super init];
	if (nil != self)
	{
//		iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
//		self.context = appDelegate.managedObjectContext;
		/*
		   [[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(reloadData:)
		                                             name:@"RefetchAllDatabaseData"
		                                           object:nil];
		 */
		self.allMedications = [NSMutableArray array];
		self.allMissedMeds = [NSMutableArray array];
		self.allPreviousMedications = [NSMutableArray array];
		self.allSideEffects = [NSMutableArray array];
		self.allContacts = [NSMutableArray array];
		self.allOtherMeds = [NSMutableArray array];
		self.allProcedures = [NSMutableArray array];
		self.allResults = [NSMutableArray array];
		self.allWellness = [NSMutableArray array];
	}

	return self;
}

- (BOOL)hasRecords
{
	NSUInteger count = self.allMedications.count;
	count += self.allMissedMeds.count;
	count += self.allPreviousMedications.count;
	count += self.allSideEffects.count;
	count += self.allContacts.count;
	count += self.allOtherMeds.count;
	count += self.allProcedures.count;
	count += self.allResults.count;
	count += self.allWellness.count;
	return (0 < count) ? YES : NO;
}

/*
   - (void)reloadData:(NSNotification*)note
   {
    NSLog(@"DATALOADER reloadData:(NSNotification*)note");
    self.allMedications = [self.medsController cleanedEntries];
    self.allMissedMeds = [self.missedController cleanedEntries];
    self.allPreviousMedications = [self.previousController cleanedEntries];
    self.allSideEffects = [self.effectsController cleanedEntries];
    self.allContacts = [self.contactsController cleanedEntries];
    self.allOtherMeds = [self.otherMedsController cleanedEntries];
    self.allProcedures = [self.proceduresController cleanedEntries];
    self.allResults = [self.resultsController cleanedEntries];
    self.allWellness = [self.wellnessController cleanedEntries];

   }
 */
/**
   dealloc
 */

- (NSString *)csvString
{
	NSMutableString *csv = [NSMutableString stringWithString:@"iStayHealthy\r"];
	if (![self hasRecords])
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
		NSString *cd4Percent = (0.0 < [results.CD4Percent floatValue]) ? [results.CD4Percent stringValue] : @"";
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
		[csv appendFormat:@"%@, %@, %@, %@\r", date, cd4, cd4Percent, vl];
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
		[csv appendFormat:@"%@, %@, %@, %@, %@\r", date, name, drugs, form, endDate];
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
		[csv appendFormat:@"%@, %@, %@\r", date, name, drug];
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
		[csv appendFormat:@"%@, %@, %@, %@\r", date, effectName, seriousness, name];
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
	[self getSQLData];
	XMLDocument *document = [[XMLDocument alloc] init];
	XMLElement *root = [document root];
	if (![self hasRecords])
	{
		NSString *xmlString = [document xmlString];
		return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	}
	NSString *masterUID = [Utilities GUID];
/*
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
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
                                        message:NSLocalizedString(@"Save error message", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil]
             show];
        }

    }
 */
	[root addAttribute:kUID andValue:masterUID];

	if (0 < [self.allResults count])
	{
		XMLElement *results = [[XMLElement alloc]initWithName:kResults];
		[self addResults:results];
		[root addChild:results];
	}

	if (0 < [self.allMedications count])
	{
		XMLElement *medications = [[XMLElement alloc]initWithName:kMedications];
		[self addMedications:medications];
		[root addChild:medications];
	}

	if (0 < [self.allMissedMeds count])
	{
		XMLElement *missedMedications = [[XMLElement alloc]initWithName:kMissedMedications];
		[self addMissedMedications:missedMedications];
		[root addChild:missedMedications];
	}

	if (0 < [self.allOtherMeds count])
	{
		XMLElement *otherMedications = [[XMLElement alloc]initWithName:kOtherMedications];
		[self addOtherMeds:otherMedications];
		[root addChild:otherMedications];
	}

	if (0 < [self.allContacts count])
	{
		XMLElement *contacts = [[XMLElement alloc]initWithName:kClinicalContacts];
		[self addContacts:contacts];
		[root addChild:contacts];
	}

	if (0 < [self.allSideEffects count])
	{
		XMLElement *sideEffects = [[XMLElement alloc]initWithName:kHIVSideEffects];
		[self addSideEffects:sideEffects];
		[root addChild:sideEffects];
	}

	if (0 < [self.allProcedures count])
	{
		XMLElement *procedures = [[XMLElement alloc]initWithName:kIllnessAndProcedures];
		[self addProcedures:procedures];
		[root addChild:procedures];
	}

	if (0 < self.allPreviousMedications.count)
	{
		XMLElement *previousMeds = [[XMLElement alloc]initWithName:kPreviousMedications];
		[self addPreviousMedications:previousMeds];
		[root addChild:previousMeds];
	}

	if (0 < self.allWellness.count)
	{
		XMLElement *wellness = [[XMLElement alloc]initWithName:kWellnesses];
		[self addWellness:wellness];
		[root addChild:wellness];
	}

	NSString *xmlString = [document xmlString];
#ifdef APPDEBUG
	NSLog(@"XML string = %@", xmlString);
#endif
	return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
}

/**
   adds the results to the XML doc
 */
- (void)addResults:(XMLElement *)resultsParent
{
	for (Results *results in self.allResults)
	{
		XMLElement *resultElement = [[XMLElement alloc]initWithName:kResult];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = DATEFORMATSTYLE;
		[resultElement addAttribute:kResultsDate
		                   andValue:[formatter stringFromDate:results.ResultsDate]];
		if (0.0 < [results.CD4 floatValue])
		{
			[resultElement addAttribute:kCD4 andValue:[results.CD4 stringValue]];
		}
		if (0.0 < [results.CD4Percent floatValue])
		{
			[resultElement addAttribute:kCD4Percent andValue:[results.CD4Percent stringValue]];
		}
		if (0.0 <= [results.ViralLoad floatValue])
		{
			if (0.0 == [results.ViralLoad floatValue])
			{
				[resultElement addAttribute:kViralLoad andValue:@"undetectable"];
			}
			else
				[resultElement addAttribute:kViralLoad andValue:[results.ViralLoad stringValue]];
		}
		if (0.0 <= [results.HepCViralLoad floatValue])
		{
			if (0.0 == [results.HepCViralLoad floatValue])
			{
				[resultElement addAttribute:kHepCViralLoad andValue:@"undetectable"];
			}
			else
				[resultElement addAttribute:kHepCViralLoad andValue:[results.HepCViralLoad stringValue]];
		}

		if (0.0 < [results.Glucose floatValue])
		{
			[resultElement addAttribute:kGlucose andValue:[results.Glucose stringValue]];
		}
		if (0.0 < [results.TotalCholesterol floatValue])
		{
			[resultElement addAttribute:kTotalCholesterol andValue:[results.TotalCholesterol stringValue]];
		}
		if (0.0 < [results.LDL floatValue])
		{
			[resultElement addAttribute:kLDL andValue:[results.LDL stringValue]];
		}
		if (0.0 < [results.HDL floatValue])
		{
			[resultElement addAttribute:kHDL andValue:[results.HDL stringValue]];
		}
		if (0.0 < [results.Hemoglobulin floatValue])
		{
			[resultElement addAttribute:kHemoglobulin andValue:[results.Hemoglobulin stringValue]];
		}
		if (0.0 < [results.PlateletCount floatValue])
		{
			[resultElement addAttribute:kPlatelet andValue:[results.PlateletCount stringValue]];
		}
		if (0.0 < [results.WhiteBloodCellCount floatValue])
		{
			[resultElement addAttribute:kWhiteBloodCells andValue:[results.WhiteBloodCellCount stringValue]];
		}
		if (0.0 < [results.redBloodCellCount floatValue])
		{
			[resultElement addAttribute:kRedBloodCells andValue:[results.redBloodCellCount stringValue]];
		}
		if (0.0 < [results.Systole floatValue])
		{
			[resultElement addAttribute:kSystole andValue:[results.Systole stringValue]];
		}
		if (0.0 < [results.Diastole floatValue])
		{
			[resultElement addAttribute:kDiastole andValue:[results.Diastole stringValue]];
		}
		if (0.0 < [results.Weight floatValue])
		{
			[resultElement addAttribute:kWeight andValue:[results.Weight stringValue]];
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
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
				                            message:NSLocalizedString(@"Save error message", nil)
				                           delegate:nil
				                  cancelButtonTitle:@"Ok"
				                  otherButtonTitles:nil]
				 show];
			}
		}
		[resultElement addAttribute:kUID andValue:uid];

		[resultsParent addChild:resultElement];
	}
}

/**
   adds the HIV drugs to the XML doc
 */
- (void)addMedications:(XMLElement *)medicationParent
{
	for (Medication *medication in self.allMedications)
	{
		XMLElement *medElement = [[XMLElement alloc]initWithName:kMedication];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = DATEFORMATSTYLE;
		[medElement addAttribute:kStartDate andValue:[formatter stringFromDate:medication.StartDate]];
		[medElement addAttribute:kName andValue:medication.Name];
		[medElement addAttribute:kDrug andValue:medication.Drug];
		[medElement addAttribute:kMedicationForm andValue:medication.MedicationForm];
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
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
				                            message:NSLocalizedString(@"Save error message", nil)
				                           delegate:nil
				                  cancelButtonTitle:@"Ok"
				                  otherButtonTitles:nil]
				 show];
			}
		}
		[medElement addAttribute:kUID andValue:uid];
		[medicationParent addChild:medElement];
	}
}

/**
   adds the missed HIV drugs to the XML doc
 */
- (void)addMissedMedications:(XMLElement *)missedMedicationParent
{
	for (MissedMedication *missedMed in self.allMissedMeds)
	{
		XMLElement *missedMedElement = [[XMLElement alloc]initWithName:kMissedMedication];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = DATEFORMATSTYLE;
		[missedMedElement addAttribute:kMissedDate andValue:[formatter stringFromDate:missedMed.MissedDate]];
		[missedMedElement addAttribute:kName andValue:missedMed.Name];
		[missedMedElement addAttribute:kDrug andValue:missedMed.Drug];
		[missedMedElement addAttribute:kMissedReason andValue:missedMed.missedReason];
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
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
				                            message:NSLocalizedString(@"Save error message", nil)
				                           delegate:nil
				                  cancelButtonTitle:@"Ok"
				                  otherButtonTitles:nil]
				 show];
			}
		}
		[missedMedElement addAttribute:kUID andValue:uid];
		[missedMedicationParent addChild:missedMedElement];
	}
}

/**
   adds the list of general meds to the XML doc
 */
- (void)addOtherMeds:(XMLElement *)otherMedsParent
{
	for (OtherMedication *otherMed in self.allOtherMeds)
	{
		XMLElement *otherMedElement = [[XMLElement alloc]initWithName:kOtherMedication];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = DATEFORMATSTYLE;
		[otherMedElement addAttribute:kStartDate andValue:[formatter stringFromDate:otherMed.StartDate]];
		[otherMedElement addAttribute:kName andValue:otherMed.Name];

		if (nil != otherMed.MedicationForm)
		{
			[otherMedElement addAttribute:kMedicationForm andValue:otherMed.MedicationForm];
		}

		NSString *unit = otherMed.Unit;
		if (nil != unit)
		{
			[otherMedElement addAttribute:kUnit andValue:unit];
		}

		NSNumber *dose = otherMed.Dose;
		if (nil != dose)
		{
			[otherMedElement addAttribute:kDose andValue:[NSString stringWithFormat:@"%f", [dose floatValue]]];
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
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
				                            message:NSLocalizedString(@"Save error message", nil)
				                           delegate:nil
				                  cancelButtonTitle:@"Ok"
				                  otherButtonTitles:nil]
				 show];
			}
		}
		[otherMedElement addAttribute:kUID andValue:uid];
		[otherMedsParent addChild:otherMedElement];
	}
}

- (void)addContacts:(XMLElement *)contactsParent
{
	for (Contacts *contacts in self.allContacts)
	{
		XMLElement *contactElement = [[XMLElement alloc]initWithName:kContacts];
		[contactElement addAttribute:kClinicName andValue:contacts.ClinicName];
		[contactElement addAttribute:kClinicID andValue:contacts.ClinicID];
		[contactElement addAttribute:kClinicEmailAddress andValue:contacts.ClinicEmailAddress];
		[contactElement addAttribute:kClinicWebSite andValue:contacts.ClinicWebSite];
		[contactElement addAttribute:kClinicContactNumber andValue:contacts.ClinicContactNumber];
		[contactElement addAttribute:kEmergencyContactNumber
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
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
				                            message:NSLocalizedString(@"Save error message", nil)
				                           delegate:nil
				                  cancelButtonTitle:@"Ok"
				                  otherButtonTitles:nil]
				 show];
			}
		}
		[contactElement addAttribute:kUID andValue:uid];
		[contactsParent addChild:contactElement];
	}
}

- (void)addSideEffects:(XMLElement *)sideEffectsParent
{
	for (SideEffects *effects in self.allSideEffects)
	{
		XMLElement *sideEffect = [[XMLElement alloc]initWithName:kSideEffects];
		[sideEffect addAttribute:kSideEffect andValue:effects.SideEffect];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = DATEFORMATSTYLE;

		[sideEffect addAttribute:kSideEffectDate andValue:[formatter stringFromDate:effects.SideEffectDate]];
		[sideEffect addAttribute:kName andValue:effects.Name];
		[sideEffect addAttribute:kDrug andValue:effects.Drug];
		[sideEffect addAttribute:kSeriousness andValue:effects.seriousness];
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
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
				                            message:NSLocalizedString(@"Save error message", nil)
				                           delegate:nil
				                  cancelButtonTitle:@"Ok"
				                  otherButtonTitles:nil]
				 show];
			}
		}
		[sideEffect addAttribute:kUID andValue:uid];
		[sideEffectsParent addChild:sideEffect];
	}
}

- (void)addProcedures:(XMLElement *)proceduresParent
{
	for (Procedures *procedure in self.allProcedures)
	{
		XMLElement *procElement = [[XMLElement alloc]initWithName:kProcedures];
		[procElement addAttribute:kIllness andValue:procedure.Illness];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = DATEFORMATSTYLE;
		[procElement addAttribute:kDate andValue:[formatter stringFromDate:procedure.Date]];
		[procElement addAttribute:kName andValue:procedure.Name];
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
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
				                            message:NSLocalizedString(@"Save error message", nil)
				                           delegate:nil
				                  cancelButtonTitle:@"Ok"
				                  otherButtonTitles:nil]
				 show];
			}
		}
		[procElement addAttribute:kUID andValue:uid];
		[proceduresParent addChild:procElement];
	}
}

- (void)addPreviousMedications:(XMLElement *)previousMedsParent
{
	for (PreviousMedication *prevMed in self.allPreviousMedications)
	{
		XMLElement *prevElement = [[XMLElement alloc]initWithName:kPreviousMedication];
		[prevElement addAttribute:kNameLowerCase andValue:prevMed.name];
		[prevElement addAttribute:kDrugLowerCase andValue:prevMed.drug];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = DATEFORMATSTYLE;
		[prevElement addAttribute:kStartDateLowerCase andValue:[formatter stringFromDate:prevMed.startDate]];
		[prevElement addAttribute:kEndDateLowerCase andValue:[formatter stringFromDate:prevMed.endDate]];
		BOOL isArt = [prevMed.isART boolValue];
		if (isArt)
		{
			[prevElement addAttribute:kIsART andValue:@"YES"];
		}
		else
		{
			[prevElement addAttribute:kIsART andValue:@"NO"];
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
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
				                            message:NSLocalizedString(@"Save error message", nil)
				                           delegate:nil
				                  cancelButtonTitle:@"Ok"
				                  otherButtonTitles:nil]
				 show];
			}
		}
		[prevElement addAttribute:kUIDLowerCase andValue:uid];
		[previousMedsParent addChild:prevElement];
	}
}

- (void)addWellness:(XMLElement *)wellnessParent
{
}

#pragma mark -
#pragma mark Utilities for Core Data Management
/**
 */
- (BOOL)containsResultsUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allResults.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (Results *results in self.allResults)
	{
		if ([UID isEqualToString:results.UID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

/**
 */
- (BOOL)containsMedicationsUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allMedications.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (Medication *med in self.allMedications)
	{
		if ([UID isEqualToString:med.UID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

/**
 */
- (BOOL)containsMissedMedicationsUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allMissedMeds.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (MissedMedication *missedMed in self.allMissedMeds)
	{
		if ([UID isEqualToString:missedMed.UID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

/**
 */
- (BOOL)containsOtherMedicationsUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allOtherMeds.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (OtherMedication *otherMed in self.allOtherMeds)
	{
		if ([UID isEqualToString:otherMed.UID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

- (BOOL)containsProceduresUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allProcedures.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (Procedures *procs in self.allProcedures)
	{
		if ([UID isEqualToString:procs.UID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

- (BOOL)containsSideEffectsUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allSideEffects.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (SideEffects *effects in self.allSideEffects)
	{
		if ([UID isEqualToString:effects.UID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

- (BOOL)containsContactsUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allContacts.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (Contacts *contact in self.allContacts)
	{
		if ([UID isEqualToString:contact.UID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

- (BOOL)containsPreviousMedsUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allPreviousMedications.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (PreviousMedication *previous in self.allPreviousMedications)
	{
		if ([UID isEqualToString:previous.uID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

- (BOOL)containsWellnessUID:(NSString *)UID
{
	if (nil == UID)
	{
		return NO;
	}
	if (0 == self.allWellness.count)
	{
		return NO;
	}
	BOOL contains = NO;
	for (Wellness *well in self.allWellness)
	{
		if ([UID isEqualToString:well.uID])
		{
			contains = YES;
			break;
		}
	}
	return contains;
}

/**
   only adds result if the UID doesn't exist
 */
- (void)addResultsToSQL:(XMLElement *)resultElement
{
	if ([self containsResultsUID:[resultElement elementUID]])
	{
		return;
	}
	Results *result = [NSEntityDescription insertNewObjectForEntityForName:kResults
	                                                inManagedObjectContext:self.context];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = DATEFORMATSTYLE;
	result.ResultsDate = [formatter dateFromString:[resultElement attributeValue:kResultsDate]];
	if (nil != [resultElement elementUID])
	{
		result.UID = [resultElement elementUID];
	}
	else
	{
		result.UID = [Utilities GUID];
	}

	NSString *_cd4 = [resultElement attributeValue:kCD4];
	NSString *_cd4Percent = [resultElement attributeValue:kCD4Percent];
	NSString *_vl = [resultElement attributeValue:kViralLoad];
	NSString *_vlHepC = [resultElement attributeValue:kHepCViralLoad];
	NSString *_glucose = [resultElement attributeValue:kGlucose];
	NSString *_cholesterol = [resultElement attributeValue:kTotalCholesterol];
	NSString *_hdl = [resultElement attributeValue:kHDL];
	NSString *_ldl = [resultElement attributeValue:kLDL];

	NSString *_platelets = [resultElement attributeValue:kPlatelet];
	NSString *_hemo = [resultElement attributeValue:kHemoglobulin];
	NSString *_red = [resultElement attributeValue:kRedBloodCells];
	NSString *_white = [resultElement attributeValue:kWhiteBloodCells];

	NSString *_weight = [resultElement attributeValue:kWeight];
	NSString *_systole = [resultElement attributeValue:kSystole];
	NSString *_diastole = [resultElement attributeValue:kDiastole];

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
	if (![self.context save:&error])
	{
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
		                            message:NSLocalizedString(@"Save error message", nil)
		                           delegate:nil
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil]
		 show];
	}
}

/**
   only adds medication if the UID doesn't exist
 */
- (void)addMedicationsToSQL:(XMLElement *)medicationElement
{
	if ([self containsMedicationsUID:[medicationElement elementUID]])
	{
		return;
	}
	Medication *medication = [NSEntityDescription insertNewObjectForEntityForName:kMedication inManagedObjectContext:self.context];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = DATEFORMATSTYLE;
	medication.StartDate = [formatter dateFromString:[medicationElement attributeValue:kStartDate]];
	if (nil != [medicationElement elementUID])
	{
		medication.UID = [medicationElement elementUID];
	}
	else
	{
		medication.UID = [Utilities GUID];
	}


	NSString *_name = [medicationElement attributeValue:kName];
	NSString *_drug = [medicationElement attributeValue:kDrug];
	NSString *_form = [medicationElement attributeValue:kMedicationForm];
	NSString *_dose = [medicationElement attributeValue:kDose];

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
	if (![self.context save:&error])
	{
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
		                            message:NSLocalizedString(@"Save error message", nil)
		                           delegate:nil
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil]
		 show];
	}
}

/**
   only adds missedMedication if the UID doesn't exist
 */
- (void)addMissedMedicationToSQL:(XMLElement *)missedMedicationElement
{
	if ([self containsMissedMedicationsUID:[missedMedicationElement elementUID]])
	{
		return;
	}
	MissedMedication *missedMed = [NSEntityDescription insertNewObjectForEntityForName:kMissedMedication inManagedObjectContext:self.context];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = DATEFORMATSTYLE;
	missedMed.MissedDate = [formatter dateFromString:[missedMedicationElement attributeValue:kMissedDate]];
	if (nil != [missedMedicationElement elementUID])
	{
		missedMed.UID = [missedMedicationElement elementUID];
	}
	else
	{
		missedMed.UID = [Utilities GUID];
	}
	NSString *_name = [missedMedicationElement attributeValue:kName];
	NSString *_drug = [missedMedicationElement attributeValue:kDrug];
	NSString *_reason = [missedMedicationElement attributeValue:kMissedReason];

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
	if (![self.context save:&error])
	{
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
		                            message:NSLocalizedString(@"Save error message", nil)
		                           delegate:nil
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil]
		 show];
	}
}

/**
   only adds other medication if the UID doesn't exist
 */
- (void)addOtherMedicationsToSQL:(XMLElement *)otherMedicationsElement
{
	if ([self containsOtherMedicationsUID:[otherMedicationsElement elementUID]])
	{
		return;
	}
	OtherMedication *otherMed = [NSEntityDescription insertNewObjectForEntityForName:kOtherMedication inManagedObjectContext:self.context];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = DATEFORMATSTYLE;
	otherMed.StartDate = [formatter dateFromString:[otherMedicationsElement attributeValue:kStartDate]];
	if (nil != [otherMedicationsElement elementUID])
	{
		otherMed.UID = [otherMedicationsElement elementUID];
	}
	else
	{
		otherMed.UID = [Utilities GUID];
	}


	NSString *_name = [otherMedicationsElement attributeValue:kName];
	NSString *_form = [otherMedicationsElement attributeValue:kMedicationForm];
	NSString *_dose = [otherMedicationsElement attributeValue:kDose];
	NSString *_unit = [otherMedicationsElement attributeValue:kUnit];

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
	if (![self.context save:&error])
	{
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
		                            message:NSLocalizedString(@"Save error message", nil)
		                           delegate:nil
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil]
		 show];
	}
}

- (void)addClinicsToSQL:(XMLElement *)contactsElement
{
	if ([self containsContactsUID:[contactsElement elementUID]])
	{
		return;
	}
	Contacts *contacts = [NSEntityDescription insertNewObjectForEntityForName:kContacts
	                                                   inManagedObjectContext:self.context];

	if (nil != [contactsElement elementUID])
	{
		contacts.UID = [contactsElement elementUID];
	}
	else
		contacts.UID = [Utilities GUID];

	NSString *_clinicName = [contactsElement attributeValue:kClinicName];
	NSString *_clinicID = [contactsElement attributeValue:kClinicID];
	NSString *_clinicEmail = [contactsElement attributeValue:kClinicEmailAddress];
	NSString *_clinicWWW = [contactsElement attributeValue:kClinicWebSite];
	NSString *_clinicNumber = [contactsElement attributeValue:kClinicContactNumber];
	NSString *_emergency = [contactsElement attributeValue:kEmergencyContactNumber];
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
	if (![self.context save:&error])
	{
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
		                            message:NSLocalizedString(@"Save error message", nil)
		                           delegate:nil
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil]
		 show];
	}
}

- (void)addSideEffectsToSQL:(XMLElement *)sideEffectsElement
{
	if ([self containsSideEffectsUID:[sideEffectsElement elementUID]])
	{
		return;
	}

	SideEffects *effect = [NSEntityDescription insertNewObjectForEntityForName:kSideEffects
	                                                    inManagedObjectContext:self.context];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = DATEFORMATSTYLE;
	if (nil != [sideEffectsElement elementUID])
	{
		effect.UID = [sideEffectsElement elementUID];
	}
	else
		effect.UID = [Utilities GUID];

	effect.SideEffectDate = [formatter dateFromString:[sideEffectsElement attributeValue:kSideEffectDate]];

	NSString *_name = [sideEffectsElement attributeValue:kName];
	NSString *_drug = [sideEffectsElement attributeValue:kDrug];
	NSString *_effect = [sideEffectsElement attributeValue:kSideEffect];
	NSString *_serious = [sideEffectsElement attributeValue:kSeriousness];
	if (nil != _name)
		effect.Name = _name;
	if (nil != _drug)
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
	if (![self.context save:&error])
	{
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
		                            message:NSLocalizedString(@"Save error message", nil)
		                           delegate:nil
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil]
		 show];
	}
}

- (void)addProceduresToSQL:(XMLElement *)proceduresElement
{
	if ([self containsProceduresUID:[proceduresElement elementUID]])
	{
		return;
	}
	Procedures *procedures = [NSEntityDescription insertNewObjectForEntityForName:kProcedures
	                                                       inManagedObjectContext:self.context];

	if (nil != [proceduresElement elementUID])
	{
		procedures.UID = [proceduresElement elementUID];
	}
	else
		procedures.UID = [Utilities GUID];

	NSString *_illness = [proceduresElement attributeValue:kIllness];
	NSString *_name = [proceduresElement attributeValue:kName];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = DATEFORMATSTYLE;
	procedures.Date = [formatter dateFromString:[proceduresElement attributeValue:kDate]];

	if (nil != _illness)
	{
		procedures.Illness = _illness;
	}

	if (nil != _name)
	{
		procedures.Name = _name;
	}

	NSError *error = nil;
	if (![self.context save:&error])
	{
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
		                            message:NSLocalizedString(@"Save error message", nil)
		                           delegate:nil
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil]
		 show];
	}
}

- (void)addPreviousMedicationsToSQL:(XMLElement *)previousElement
{
	if ([self containsProceduresUID:[previousElement elementUID]])
	{
		return;
	}
	PreviousMedication *prev = [NSEntityDescription insertNewObjectForEntityForName:kPreviousMedication inManagedObjectContext:self.context];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = DATEFORMATSTYLE;
	if (nil != [previousElement elementUID])
	{
		prev.uID = [previousElement elementUID];
	}
	else
		prev.uID = [Utilities GUID];

	prev.startDate = [formatter dateFromString:[previousElement attributeValue:kStartDateLowerCase]];
	prev.endDate = [formatter dateFromString:[previousElement attributeValue:kEndDateLowerCase]];


	NSString *_name = [previousElement attributeValue:kName];
	NSString *_drug = [previousElement attributeValue:kDrug];
	NSString *_isArt = [previousElement attributeValue:kIsART];

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
	if (![self.context save:&error])
	{
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
		                            message:NSLocalizedString(@"Save error message", nil)
		                           delegate:nil
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil]
		 show];
	}
}

- (void)addWellnessToSQL:(XMLElement *)wellnessElement
{
}

#pragma mark -
#pragma mark Core Data
/**
   fetch the latest data from the SQL database
 */
- (BOOL)getSQLData
{
	self.medsController = [[SQLDataTableController alloc] initForEntityType:kMedicationTable
	                                                                 sortBy:@"StartDate"
	                                                            isAscending:YES
	                                                                context:self.context];

	self.missedController = [[SQLDataTableController alloc] initForEntityType:kMissedMedicationTable
	                                                                   sortBy:@"MissedDate"
	                                                              isAscending:YES
	                                                                  context:self.context];

	self.previousController = [[SQLDataTableController alloc] initForEntityType:kPreviousMedicationTable
	                                                                     sortBy:@"endDate"
	                                                                isAscending:YES
	                                                                    context:self.context];

	self.effectsController = [[SQLDataTableController alloc] initForEntityType:kSideEffectsTable
	                                                                    sortBy:@"SideEffectDate"
	                                                               isAscending:YES
	                                                                   context:self.context];
	self.contactsController = [[SQLDataTableController alloc] initForEntityType:kContactsTable
	                                                                     sortBy:@"ClinicName"
	                                                                isAscending:YES
	                                                                    context:self.context];

	self.otherMedsController = [[SQLDataTableController alloc] initForEntityType:kOtherMedicationTable
	                                                                      sortBy:@"StartDate"
	                                                                 isAscending:YES
	                                                                     context:self.context];

	self.proceduresController = [[SQLDataTableController alloc] initForEntityType:kProceduresTable
	                                                                       sortBy:@"Date"
	                                                                  isAscending:YES
	                                                                      context:self.context];
	self.resultsController = [[SQLDataTableController alloc] initForEntityType:kResultsTable
	                                                                    sortBy:@"ResultsDate"
	                                                               isAscending:YES
	                                                                   context:self.context];

	self.wellnessController = [[SQLDataTableController alloc] initForEntityType:kWellnessTable
	                                                                     sortBy:@"sleepBarometer"
	                                                                isAscending:YES
	                                                                    context:self.context];

	self.allMedications = [self.medsController cleanedEntries];
	self.allMissedMeds = [self.missedController cleanedEntries];
	self.allPreviousMedications = [self.previousController cleanedEntries];
	self.allSideEffects = [self.effectsController cleanedEntries];
	self.allContacts = [self.contactsController cleanedEntries];
	self.allOtherMeds = [self.otherMedsController cleanedEntries];
	self.allProcedures = [self.proceduresController cleanedEntries];
	self.allResults = [self.resultsController cleanedEntries];
	self.allWellness = [self.wellnessController cleanedEntries];

	return YES;
}

@end
