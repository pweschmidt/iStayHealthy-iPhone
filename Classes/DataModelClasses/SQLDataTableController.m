//
//  SQLDataTableController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/02/2013.
//
//

#import "SQLDataTableController.h"

@interface SQLDataTableController ()
@property (nonatomic, strong) NSEntityDescription *entityDescription;
@property (nonatomic, strong) NSSortDescriptor *sortDescriptor;
@property (nonatomic, strong) NSManagedObjectContext *managedContext;
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
