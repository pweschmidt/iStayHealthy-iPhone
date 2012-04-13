//
//  HL7Loader.m
//  iStayHealthy
//
//  Created by peterschmidt on 07/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HL7Loader.h"
#import "iStayHealthyRecord.h"
#import "iStayHealthyAppDelegate.h"
#import "Results.h"
#import "Utilities.h"

@implementation HL7Loader
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize masterRecord, rawData;

- (id)initWithData:(NSData *)data{
    self = [self init];
    if (self) {
        self.rawData = data;
        NSError *error = nil;
        if (![[self fetchedResultsController] performFetch:&error]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Error Loading Data",nil) 
                                  message:[NSString stringWithFormat:NSLocalizedString(@"Error was %@, quitting.", @"Error was %@, quitting"), [error localizedDescription]] 
                                  delegate:self 
                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        NSArray *records = [self.fetchedResultsController fetchedObjects];
        self.masterRecord = (iStayHealthyRecord *)[records objectAtIndex:0];
    }
    return self;
}

- (void)dealloc{
    self.rawData = nil;
    self.masterRecord = nil;
    [self.fetchedResultsController release];
    [super dealloc];
}


- (void)parse{
    NSString *hl7Content = [[[NSString alloc] initWithBytes:[self.rawData bytes] length:[self.rawData length] encoding:NSUTF8StringEncoding]autorelease];
    
    NSArray *content = [hl7Content componentsSeparatedByString:@" "];
    NSString *message = (NSString *)[content objectAtIndex:0];
    if ([message isEqualToString:@"CALLBACK"]) {
        return;
    }
    if (1 >= [content count]) {
        //no results are in the file
        return;
    }
    
    NSManagedObjectContext *context = [masterRecord managedObjectContext];
    Results *result = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:context];
    [masterRecord addResultsObject:result];
    
    NSString *cd4 = (NSString *)[content objectAtIndex:1];
    NSString *cd4Percent = (NSString *)[content objectAtIndex:2];
    NSString *vl = (NSString *)[content objectAtIndex:3];
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc]init]autorelease];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    result.ResultsDate = [NSDate date];
    result.CD4 = [numberFormatter numberFromString:cd4];
    result.CD4Percent = [numberFormatter numberFromString:cd4Percent];
    result.ViralLoad = [numberFormatter numberFromString:vl];
    result.UID = [Utilities GUID];

	NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
}
/**
 this handles the fetching of the objects
 @return NSFetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController{
	if (fetchedResultsController_ != nil) {
		return fetchedResultsController_;
	}
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"iStayHealthyRecord" inManagedObjectContext:context];
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
	fetchedResultsController_ = tmpFetchController;
	
	[request release];
    [allDescriptors release];
    [sortDescriptor release];
	return fetchedResultsController_;
	
}	

/**
 notified when changes to the database
 @controller
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{	
	NSArray *objects = [self.fetchedResultsController fetchedObjects];
	self.masterRecord = (iStayHealthyRecord *)[objects objectAtIndex:0];
}

@end
