//
//  CoreDataManager.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface CoreDataManager : NSObject
@property (nonatomic, strong) NSManagedObjectContext *defaultContext;
@property (nonatomic, assign) BOOL iCloudIsAvailable;
@property (nonatomic, assign) BOOL iCloudEnabled;
@property (nonatomic, assign) BOOL storeIsReady;
@property (nonatomic, assign) BOOL hasDataForImport;
@property (nonatomic, strong) NSString *importedFilePath;

+ (CoreDataManager *)sharedInstance;

/**
   sets up the CoreData Manager
 */
- (void)setUpCoreDataManager;

/**
   sets up the persistent store and storage coordinator in an asynchronous manner
   This is to enable searching for the Uibiquity container content, ie SQLite DB
   with iCloud enabled
 */
- (void)setUpStoreWithError:(iStayHealthyErrorBlock)error;

/**
   saves the NSManagedObjectContext using a performBlockAndWait
 */
- (BOOL)saveContextAndWait:(NSError **)error;

/**
   restores data from a local XML backup file
 */
- (void)restoreLocallyWithCompletionBlock:(iStayHealthySuccessBlock)completionBlock;

/**
   the application documents directory in the apps sandbox
 */
- (NSURL *)applicationDocumentsDirectory;

/**
   adds a file to be imported to the import list
 */
- (BOOL)addFileToImportList:(NSURL *)sourceURL error:(NSError **)error;

/**
   fetches the iStayHealthy master record
 */
- (void)fetchiStayHealthyRecordWithCompletion:(iStayHealthyRecordCompletionBlock)completion;

/**
   a general method to obtain a record of entity with name, predicate and sort term
 */
- (void)fetchDataForEntityName:(NSString *)entityName
                     predicate:(NSPredicate *)predicate
                      sortTerm:(NSString *)sortTerm
                     ascending:(BOOL)ascending
                    completion:(iStayHealthyArrayCompletionBlock)completion;

/**
   get the managed object for a specified entity with name
 */
- (id)managedObjectForEntityName:(NSString *)entityName;
/**
   notification when the iCloud storage has changed
 */
- (void)iCloudStoreChanged:(NSNotification *)notification;

/**
   puts the import data in a queue and will process them when ready
   @param notification
 */
- (void)importWhenReady:(NSNotification *)notification;

/**
   bit of a misnomer: imports the data made available previously via a notification
   see importWhenReady
 */
- (void)importWithData;

/**
   imports the data from a temporary file URL
 */
- (void)importFromTmpFileURL;


@end
