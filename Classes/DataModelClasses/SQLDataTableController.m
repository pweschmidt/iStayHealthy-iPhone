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
#import "Constants.h"

@interface SQLDataTableController ()
@property (nonatomic, strong) NSEntityDescription *entityDescription;
@property (nonatomic, strong) NSSortDescriptor *sortDescriptor;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedContext;
@property (nonatomic, assign) TableType table;
- (NSArray *)getCurrentData;
+ (NSString *)tableNameFromType:(TableType)type;
@end

@implementation SQLDataTableController

+ (NSString *)tableNameFromType:(TableType)type
{
    switch (type)
    {
        case kRecordTable:
            return @"iStayHealthyRecord";
        case kResultsTable:
            return @"Results";
        case kMedicationTable:
            return @"Medication";
        case kMissedMedicationTable:
            return @"MissedMedication";
        case kPreviousMedicationTable:
            return @"PreviousMedication";
        case kOtherMedicationTable:
            return @"OtherMedication";
        case kProceduresTable:
            return @"Procedures";
        case kContactsTable:
            return @"Contacts";
        case kSideEffectsTable:
            return @"SideEffects";
        case kWellnessTable:
            return @"Wellness";
            
    }
    return nil;
}

- (id)initForEntityType:(TableType *)table
                 sortBy:(NSString *)sortBy
            isAscending:(BOOL)isAscending
                context:(NSManagedObjectContext *)context
{
    self = [super init];
    if (nil != self)
    {
        NSString *tableName = [SQLDataTableController tableNameFromType:table];
        self.entityDescription = [NSEntityDescription entityForName:tableName
                                             inManagedObjectContext:context];
        self.sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortBy ascending:isAscending];
        self.managedContext = context;
        self.table = table;
    }
    return self;

}

- (NSArray *)cleanedEntries
{
    NSArray *data = [self getCurrentData];
    if (2 > data.count)
    {
        return data;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL dataTablesCleaned = [defaults boolForKey:kDataTablesCleaned];
    if (dataTablesCleaned)
    {
        return data;
    }
    
    BOOL hasChanged = NO;
    for (int index = 1; index < data.count; ++index)
    {
        id previous = [data objectAtIndex:index - 1];
        id current = [data objectAtIndex:index];
        if ([previous respondsToSelector:@selector(isEqualTo:)] && [current respondsToSelector:@selector(isEqualTo:)])
        {
            if ([previous isEqualTo:current])
            {
                switch (self.table)
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
                hasChanged = YES;
            }
        }
    }
    if (hasChanged)
    {
        NSError *error = nil;
        BOOL success = [self.managedContext save:&error];
        if (success)
        {
            return [self getCurrentData];
        }
    }
    [defaults setBool:YES forKey:kDataTablesCleaned];
    [defaults synchronize];
    return data;
}


- (NSArray *)getCurrentData
{
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
    {
        return [NSArray array];
    }
    return [self.fetchedResultsController fetchedObjects];
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
    [self getCurrentData];
}

@end
