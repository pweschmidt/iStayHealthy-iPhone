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

@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSNumber * isPasswordEnabled;
@property (nonatomic, strong) NSString * Password;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSSet *otherMedications;
@property (nonatomic, strong) NSSet *missedMedications;
@property (nonatomic, strong) NSSet *contacts;
@property (nonatomic, strong) NSSet *results;
@property (nonatomic, strong) NSSet *medications;
@property (nonatomic, strong) NSSet *sideeffects;
@property (nonatomic, strong) NSSet *procedures;
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
