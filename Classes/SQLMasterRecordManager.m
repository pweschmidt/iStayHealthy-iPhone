//
//  SQLMasterRecordManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/02/2013.
//
//

#import "SQLMasterRecordManager.h"
#import "iStayHealthyAppDelegate.h"
#import "iStayHealthyRecord.h"

@interface SQLMasterRecordManager ()
- (NSArray *)loadMasterRecord;
@end

@implementation SQLMasterRecordManager

- (void)checkMasterRecord
{
    NSArray * records = [self loadMasterRecord];
    if (nil == records || 0 == records.count)
    {
    }
    
    
    
}
#warning We need to search for a non-empty record
- (iStayHealthyRecord *)validMasterRecord
{
    NSArray * records = [self loadMasterRecord];    
    if (nil == records || 0 == records.count)
    {
        return nil;
    }
    if (1 == records.count)
    {
        return (iStayHealthyRecord *)[records lastObject];
    }
    
    iStayHealthyRecord * validRecord = nil;
    
    for (iStayHealthyRecord *masterRecord in records)
    {
        NSString *UID = masterRecord.UID;
        NSSet *results = masterRecord.results;
        NSSet *meds = masterRecord.medications;
        NSSet *missed = masterRecord.missedMedications;
        NSSet *previous = masterRecord.previousMedications;
        NSSet *effects = masterRecord.sideeffects;
        NSSet *other = masterRecord.otherMedications;
        NSSet *procs = masterRecord.procedures;
        NSSet *contacts = masterRecord.contacts;
        NSSet *wellness = masterRecord.wellness;
        int count = (nil != results) ? results.count : 0;
        count += (nil != meds) ? meds.count : 0;
        count += (nil != missed) ? missed.count : 0;
        count += (nil != previous) ? previous.count : 0;
        count += (nil != effects) ? effects.count : 0;
        count += (nil != other) ? other.count : 0;
        count += (nil != procs) ? procs.count : 0;
        count += (nil != contacts) ? contacts.count : 0;
        count += (nil != wellness) ? wellness.count : 0;
        if (nil != UID && ![UID isEqualToString:@""])
        {
            
        }
        if (0 < count)
        {
            validRecord = masterRecord;
        }
        else
        {
            [masterRecord prepareForDeletion];
        }
    }
    
    return validRecord;
}

/**
 we delete any record that contains no data. Only relevant if we have more than 1 master record
 */
- (void)cleanUpMasterRecords
{
    NSArray * records = [self loadMasterRecord];
    if (nil == records || 1 >= records.count)
    {
        return;
    }
    
}


- (NSArray *)loadMasterRecord
{
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
    {
    }
	return [self.fetchedResultsController fetchedObjects];
}



#pragma mark -
#pragma mark Table view delegate

/**
 this handles the fetching of the objects
 @return NSFetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController
{
#ifdef APPDEBUG
    NSLog(@"iStayHealthyTableViewController::fetchedResultsController");
#endif
	if (_fetchedResultsController != nil)
    {
		return _fetchedResultsController;
	}
#ifdef APPDEBUG
    NSLog(@"iStayHealthyTableViewController::fetchedResultsController about to create fetch request");
#endif
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"iStayHealthyRecord" inManagedObjectContext:context];
#ifdef APPDEBUG
    NSLog(@"iStayHealthyTableViewController::fetchedResultsController created entity iStayHealthyRecord");
#endif
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"Name" ascending:YES];
	NSArray *allDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:allDescriptors];
	[request setEntity:entity];
	
	NSFetchedResultsController *tmpFetchController = [[NSFetchedResultsController alloc]
													  initWithFetchRequest:request
													  managedObjectContext:context
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
