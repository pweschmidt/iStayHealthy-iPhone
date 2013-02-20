//
//  DataLoader.h
//  iStayHealthy
//
//  Created by peterschmidt on 07/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDataTableController.h"
#define TMPFILE @"iStayHealthy.xml"
#define DATEFORMATSTYLE @"dd-MMM-yy HH:mm:ss"

@class XMLElement;

@interface DataLoader : NSObject
@property (nonatomic, strong) NSArray *allResults;
@property (nonatomic, strong) NSArray *allMedications;
@property (nonatomic, strong) NSArray *allMissedMeds;
@property (nonatomic, strong) NSArray *allOtherMeds;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *allSideEffects;
@property (nonatomic, strong) NSArray *allProcedures;
@property (nonatomic, strong) NSArray *allPreviousMedications;
@property (nonatomic, strong) NSArray *allWellness;
- (BOOL)getSQLData;
- (NSData *)xmlData;
- (NSData *)csvData;
- (NSString *)csvString;
//- (void) reloadData:(NSNotification*)note;
- (void) addResultsToSQL:(XMLElement *)resultElement;
- (void) addMedicationsToSQL:(XMLElement *)medicationElement;
- (void) addMissedMedicationToSQL:(XMLElement *)missedMedicationElement;
- (void) addOtherMedicationsToSQL:(XMLElement *)otherMedicationsElement;
- (void) addClinicsToSQL:(XMLElement *)contactsElement;
- (void) addSideEffectsToSQL:(XMLElement *)sideEffectsElement;
- (void) addProceduresToSQL:(XMLElement *)proceduresElement;
- (void) addPreviousMedicationsToSQL:(XMLElement *)previousElement;
- (void) addWellnessToSQL:(XMLElement *)wellnessElement;
@end
