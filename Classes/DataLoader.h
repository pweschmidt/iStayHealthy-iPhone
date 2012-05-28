//
//  DataLoader.h
//  iStayHealthy
//
//  Created by peterschmidt on 07/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TMPFILE @"iStayHealthy.xml"
#define DATEFORMATSTYLE @"dd-MMM-yy HH:mm:ss"

@class iStayHealthyRecord, XMLElement;

@interface DataLoader : NSObject <NSFetchedResultsControllerDelegate>{
	NSFetchedResultsController *__unsafe_unretained fetchedResultsController_;
	iStayHealthyRecord *masterRecord;
    NSArray *allResults;
    NSArray *allMedications;
    NSArray *allMissedMeds;
    NSArray *allOtherMeds;
    NSArray *allContacts;
    NSArray *allSideEffects;
    NSArray *allProcedures;
}
@property (unsafe_unretained, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) iStayHealthyRecord *masterRecord;
@property (nonatomic, strong) NSArray *allResults;
@property (nonatomic, strong) NSArray *allMedications;
@property (nonatomic, strong) NSArray *allMissedMeds;
@property (nonatomic, strong) NSArray *allOtherMeds;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *allSideEffects;
@property (nonatomic, strong) NSArray *allProcedures;
- (void)getSQLData;
- (NSData *)xmlData;
- (NSData *)csvData;
- (NSString *)csvString;
- (void) addResults:(XMLElement *)resultsParent;
- (void) addMedications:(XMLElement *)medicationParent;
- (void) addMissedMedications:(XMLElement *)missedMedicationParent;
- (void) addOtherMeds:(XMLElement *)otherMedsParent;
- (void) addContacts:(XMLElement *)contactsParent;
- (void) addSideEffects:(XMLElement *)sideEffectsParent;
- (void) addProcedures:(XMLElement *)proceduresParent;
- (BOOL) containsResultsUID:(NSString *)UID;
- (BOOL) containsMedicationsUID:(NSString *)UID;
- (BOOL) containsMissedMedicationsUID:(NSString *)UID;
- (BOOL) containsOtherMedicationsUID:(NSString *)UID;
- (BOOL) containsProceduresUID:(NSString *)UID;
- (BOOL) containsSideEffectsUID:(NSString *)UID;
- (BOOL) containsContactsUID:(NSString *)UID;
- (void) addResultsToSQL:(XMLElement *)resultElement;
- (void) addMedicationsToSQL:(XMLElement *)medicationElement;
- (void) addMissedMedicationToSQL:(XMLElement *)missedMedicationElement;
- (void) addOtherMedicationsToSQL:(XMLElement *)otherMedicationsElement;
- (void) addClinicsToSQL:(XMLElement *)contactsElement;
- (void) addSideEffectsToSQL:(XMLElement *)sideEffectsElement;
- (void) addProceduresToSQL:(XMLElement *)proceduresElement;
@end
