//
//  SQLDataTableController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "Wellness.h"
#import "PreviousMedication.h"
#import "Results.h"
#import "Procedures.h"
#import "SideEffects.h"
#import "MissedMedication.h"
#import "Medication.h"
#import "OtherMedication.h"
#import "Contacts.h"
#import "iStayHealthyRecord.h"

typedef enum
{
    kResultsTable = 0,
    kMedicationTable = 1,
    kMissedMedicationTable = 2,
    kPreviousMedicationTable = 3,
    kOtherMedicationTable = 4,
    kProceduresTable = 5,
    kRecordTable = 6,
    kContactsTable = 7,
    kSideEffectsTable = 8,
    kWellnessTable = 9
}TableType;

@interface SQLDataTableController : NSObject <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedContext;

- (id)initForEntityType:(TableType *)table
                 sortBy:(NSString *)sortBy
            isAscending:(BOOL)isAscending
                context:(NSManagedObjectContext *)context;

- (NSArray *)cleanedEntries;

@end
