//
//  SQLDataTableController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/02/2013.
//
//

#import "SQLDataTableController.h"
#import "iStayHealthyRecord+Comparator.h"
#import "Results+Comparator.h"
#import "OtherMedication+Comparator.h"
#import "Medication+Comparator.h"
#import "PreviousMedication+Comparator.h"
#import "Wellness+Comparator.h"
#import "Procedures+Comparator.h"
#import "MissedMedication+Comparator.h"
#import "SideEffects+Comparator.h"
#import "Contacts+Comparator.h"

@interface SQLDataTableController ()
@property (nonatomic, strong) NSEntityDescription *entityDescription;
@property (nonatomic, strong) NSSortDescriptor *sortDescriptor;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedContext;
@end

@implementation SQLDataTableController

- (id)initForEntityName:(NSString *)tableName
                 sortBy:(NSString *)sortBy
            isAscending:(BOOL)isAscending
                context:(NSManagedObjectContext *)context
{
    self = [super init];
    if (nil != self)
    {
        self.entityDescription = [NSEntityDescription entityForName:tableName
                                             inManagedObjectContext:context];
        self.sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortBy ascending:isAscending];
        self.managedContext = context;
    }
    return self;
}


- (id)initForEntity:(NSEntityDescription *)entity
         descriptor:(NSSortDescriptor *)descriptor
            context:(NSManagedObjectContext *)context
{
    self = [super init];
    if (nil != self)
    {
        self.entityDescription = entity;
        self.sortDescriptor = descriptor;
        self.managedContext = context;
    }
    return self;
}


- (NSArray *)entriesForEntity
{
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
    {
    }
	return [self.fetchedResultsController fetchedObjects];    
}


- (NSArray *)cleanEntriesForData:(NSArray *)dataTable table:(TableType)table
{
    id previous = nil;
    BOOL hasChanges = NO;

    for (id dataObject in dataTable)
    {
        if (previous)
        {
            if ([previous respondsToSelector:@selector(isEqualTo:)] && [dataObject respondsToSelector:@selector(isEqualTo:)])
            {
                if ([previous isEqualTo:dataObject])
                {
                    switch (table)
                    {
                        case kRecordTable:
                            [self.managedContext deleteObject:(iStayHealthyRecord *)previous];
                            break;
                        case kResultsTable:
                            [self.managedContext deleteObject:(Results *)previous];
                            break;
                        case kMedicationTable:
                            [self.managedContext deleteObject:(Medication *)previous];
                            break;
                        case kMissedMedicationTable:
                            [self.managedContext deleteObject:(MissedMedication *)previous];
                            break;
                        case kPreviousMedicationTable:
                            [self.managedContext deleteObject:(PreviousMedication *)previous];
                            break;
                        case kOtherMedicationTable:
                            [self.managedContext deleteObject:(OtherMedication *)previous];
                            break;
                        case kProceduresTable:
                            [self.managedContext deleteObject:(Procedures *)previous];
                            break;
                        case kContactsTable:
                            [self.managedContext deleteObject:(Contacts *)previous];
                            break;
                        case kSideEffectsTable:
                            [self.managedContext deleteObject:(SideEffects *)previous];
                            break;
                        case kWellnessTable:
                            [self.managedContext deleteObject:(Wellness *)previous];
                            break;
                            
                    }
                    hasChanges = YES;
                }
            }
            
        }
        
        previous = dataObject;
    }
    if (hasChanges)
    {
        NSError *error = nil;
        BOOL success = [self.managedContext save:&error];
        if (success)
        {
            return [self entriesForEntity];
        }
    }
        
    return dataTable;
}





/**
 this handles the fetching of the objects
 @return NSFetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil)
    {
		return _fetchedResultsController;
	}
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSArray *allDescriptors = [[NSArray alloc] initWithObjects:self.sortDescriptor, nil];
	[request setSortDescriptors:allDescriptors];
	[request setEntity:self.entityDescription];
	
	NSFetchedResultsController *tmpFetchController = [[NSFetchedResultsController alloc]
													  initWithFetchRequest:request
													  managedObjectContext:self.managedContext
													  sectionNameKeyPath:nil
													  cacheName:nil];
	tmpFetchController.delegate = self;
	_fetchedResultsController = tmpFetchController;
	
	return _fetchedResultsController;	
}

/**
 notified when changes to the database
 @controller
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
}

@end
