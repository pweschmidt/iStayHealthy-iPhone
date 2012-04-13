//
//  iStayHealthyRecord.h
//  iStayHealthy
//
//  Created by peterschmidt on 15/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contacts, Medication, MissedMedication, OtherMedication, Procedures, Results, SideEffects;

@interface iStayHealthyRecord : NSManagedObject

@property (nonatomic, retain) NSString * UID;
@property (nonatomic, retain) NSNumber * isPasswordEnabled;
@property (nonatomic, retain) NSString * Password;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSSet *otherMedications;
@property (nonatomic, retain) NSSet *missedMedications;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *results;
@property (nonatomic, retain) NSSet *medications;
@property (nonatomic, retain) NSSet *sideeffects;
@property (nonatomic, retain) NSSet *procedures;
@end

@interface iStayHealthyRecord (CoreDataGeneratedAccessors)

- (void)addOtherMedicationsObject:(OtherMedication *)value;
- (void)removeOtherMedicationsObject:(OtherMedication *)value;
- (void)addOtherMedications:(NSSet *)values;
- (void)removeOtherMedications:(NSSet *)values;
- (void)addMissedMedicationsObject:(MissedMedication *)value;
- (void)removeMissedMedicationsObject:(MissedMedication *)value;
- (void)addMissedMedications:(NSSet *)values;
- (void)removeMissedMedications:(NSSet *)values;
- (void)addContactsObject:(Contacts *)value;
- (void)removeContactsObject:(Contacts *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;
- (void)addResultsObject:(Results *)value;
- (void)removeResultsObject:(Results *)value;
- (void)addResults:(NSSet *)values;
- (void)removeResults:(NSSet *)values;
- (void)addMedicationsObject:(Medication *)value;
- (void)removeMedicationsObject:(Medication *)value;
- (void)addMedications:(NSSet *)values;
- (void)removeMedications:(NSSet *)values;
- (void)addSideeffectsObject:(SideEffects *)value;
- (void)removeSideeffectsObject:(SideEffects *)value;
- (void)addSideeffects:(NSSet *)values;
- (void)removeSideeffects:(NSSet *)values;
- (void)addProceduresObject:(Procedures *)value;
- (void)removeProceduresObject:(Procedures *)value;
- (void)addProcedures:(NSSet *)values;
- (void)removeProcedures:(NSSet *)values;
@end
