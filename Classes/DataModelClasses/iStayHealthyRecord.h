//
//  iStayHealthyRecord.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contacts, Medication, MissedMedication, OtherMedication, Procedures, Results, SideEffects, Wellness, PreviousMedication;

@interface iStayHealthyRecord : NSManagedObject

@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSNumber * isPasswordEnabled;
@property (nonatomic, strong) NSString * Password;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSNumber * isSmoker;
@property (nonatomic, strong) NSDate * yearOfBirth;
@property (nonatomic, strong) NSNumber * isDiabetic;
@property (nonatomic, strong) NSString * gender;
@property (nonatomic, strong) NSSet *otherMedications;
@property (nonatomic, strong) NSSet *missedMedications;
@property (nonatomic, strong) NSSet *contacts;
@property (nonatomic, strong) NSSet *results;
@property (nonatomic, strong) NSSet *medications;
@property (nonatomic, strong) NSSet *procedures;
@property (nonatomic, strong) NSSet *sideeffects;
@property (nonatomic, strong) NSSet *wellness;
@property (nonatomic, strong) NSSet *previousMedications;
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

- (void)addProceduresObject:(Procedures *)value;
- (void)removeProceduresObject:(Procedures *)value;
- (void)addProcedures:(NSSet *)values;
- (void)removeProcedures:(NSSet *)values;

- (void)addSideeffectsObject:(SideEffects *)value;
- (void)removeSideeffectsObject:(SideEffects *)value;
- (void)addSideeffects:(NSSet *)values;
- (void)removeSideeffects:(NSSet *)values;

- (void)addWellnessObject:(Wellness *)value;
- (void)removeWellnessObject:(Wellness *)value;
- (void)addWellness:(NSSet *)values;
- (void)removeWellness:(NSSet *)values;

- (void)addPreviousMedicationsObject:(PreviousMedication *)value;
- (void)removePreviousMedicationsObject:(PreviousMedication *)value;
- (void)addPreviousMedications:(NSSet *)values;
- (void)removePreviousMedications:(NSSet *)values;

@end
