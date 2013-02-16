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

@interface SQLDataTableController : NSObject <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (id)initForEntityName:(NSString *)tableName
                 sortBy:(NSString *)sortBy
            isAscending:(BOOL)isAscending
                context:(NSManagedObjectContext *)context;

- (id)initForEntity:(NSEntityDescription *)entity
         descriptor:(NSSortDescriptor *)descriptor
            context:(NSManagedObjectContext *)context;
- (NSArray *)entriesForEntity;
@end
