//
//  iStayHealthyRecord.m
//  iStayHealthy
//
//  Created by peterschmidt on 15/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "iStayHealthyRecord.h"
#import "Contacts.h"
#import "Medication.h"
#import "MissedMedication.h"
#import "OtherMedication.h"
#import "Procedures.h"
#import "Results.h"
#import "SideEffects.h"


@implementation iStayHealthyRecord

@dynamic UID;
@dynamic isPasswordEnabled;
@dynamic Password;
@dynamic Name;
@dynamic otherMedications;
@dynamic missedMedications;
@dynamic contacts;
@dynamic results;
@dynamic medications;
@dynamic sideeffects;
@dynamic procedures;


/**
 Results
 */
- (void)addResultsObject:(Results *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"results" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"results"] addObject:value];
    [self didChangeValueForKey:@"results" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeResultsObject:(Results *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"results" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"results"] removeObject:value];
    [self didChangeValueForKey:@"results" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addResults:(NSSet *)value {    
    [self willChangeValueForKey:@"results" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"results"] unionSet:value];
    [self didChangeValueForKey:@"results" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeResults:(NSSet *)value {
    [self willChangeValueForKey:@"results" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"results"] minusSet:value];
    [self didChangeValueForKey:@"results" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

/**
 OtherMedication
 */

- (void)addOtherMedicationsObject:(OtherMedication *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"otherMedications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"otherMedications"] addObject:value];
    [self didChangeValueForKey:@"otherMedications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeOtherMedicationsObject:(OtherMedication *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"otherMedications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"otherMedications"] removeObject:value];
    [self didChangeValueForKey:@"otherMedications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addOtherMedications:(NSSet *)value {    
    [self willChangeValueForKey:@"otherMedications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"otherMedications"] unionSet:value];
    [self didChangeValueForKey:@"otherMedications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeOtherMedications:(NSSet *)value {
    [self willChangeValueForKey:@"otherMedications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"otherMedications"] minusSet:value];
    [self didChangeValueForKey:@"otherMedications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

/**
 Medication
 */

- (void)addMedicationsObject:(Medication *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"medications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"medications"] addObject:value];
    [self didChangeValueForKey:@"medications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeMedicationsObject:(Medication *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"medications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"medications"] removeObject:value];
    [self didChangeValueForKey:@"medications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addMedications:(NSSet *)value {    
    [self willChangeValueForKey:@"medications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"medications"] unionSet:value];
    [self didChangeValueForKey:@"medications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeMedications:(NSSet *)value {
    [self willChangeValueForKey:@"medications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"medications"] minusSet:value];
    [self didChangeValueForKey:@"medications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

/**
 MissedMedication
 */

- (void)addMissedMedicationsObject:(MissedMedication *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"missedMedications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"missedMedications"] addObject:value];
    [self didChangeValueForKey:@"missedMedications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeMissedMedicationsObject:(MissedMedication *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"missedMedications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"missedMedications"] removeObject:value];
    [self didChangeValueForKey:@"missedMedications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addMissedMedications:(NSSet *)value {    
    [self willChangeValueForKey:@"missedMedications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"missedMedications"] unionSet:value];
    [self didChangeValueForKey:@"missedMedications" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeMissedMedications:(NSSet *)value {
    [self willChangeValueForKey:@"missedMedications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"missedMedications"] minusSet:value];
    [self didChangeValueForKey:@"missedMedications" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

/**
 Contacts
 */

- (void)addContactsObject:(Contacts *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"contacts" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"contacts"] addObject:value];
    [self didChangeValueForKey:@"contacts" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeContactsObject:(Contacts *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"contacts" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"contacts"] removeObject:value];
    [self didChangeValueForKey:@"contacts" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addContacts:(NSSet *)value {    
    [self willChangeValueForKey:@"contacts" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"contacts"] unionSet:value];
    [self didChangeValueForKey:@"contacts" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeContacts:(NSSet *)value {
    [self willChangeValueForKey:@"contacts" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"contacts"] minusSet:value];
    [self didChangeValueForKey:@"contacts" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}
/**
 Side Effects
 */

- (void)addSideeffectsObject:(SideEffects *)value{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sideeffects" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sideeffects"] addObject:value];
    [self didChangeValueForKey:@"sideeffects" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
}

- (void)removeSideeffectsObject:(SideEffects *)value{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sideeffects" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sideeffects"] removeObject:value];
    [self didChangeValueForKey:@"sideeffects" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addSideeffects:(NSSet *)values{
    [self willChangeValueForKey:@"sideeffects" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"sideeffects"] unionSet:values];
    [self didChangeValueForKey:@"sideeffects" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];    
}

- (void)removeSideeffects:(NSSet *)values{
    [self willChangeValueForKey:@"sideeffects" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"sideeffects"] minusSet:values];
    [self didChangeValueForKey:@"sideeffects" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
}

/**
 Procedures
 */
- (void)addProceduresObject:(Procedures *)value{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"procedures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"procedures"] addObject:value];
    [self didChangeValueForKey:@"procedures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
}

- (void)removeProceduresObject:(Procedures *)value{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"procedures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"procedures"] removeObject:value];
    [self didChangeValueForKey:@"procedures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addProcedures:(NSSet *)values{
    [self willChangeValueForKey:@"procedures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"procedures"] unionSet:values];
    [self didChangeValueForKey:@"procedures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];    
}

- (void)removeProcedures:(NSSet *)values{
    [self willChangeValueForKey:@"procedures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"procedures"] minusSet:values];
    [self didChangeValueForKey:@"procedures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
}


@end
