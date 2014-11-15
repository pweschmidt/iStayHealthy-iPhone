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

- (void)setUpCoreDataManager;

- (BOOL)hasNewiCloudStore;

- (void)migrateToNewiCloudStore:(iStayHealthySuccessBlock)error;

- (BOOL)setUpStoreAsLocalStoreWithError:(NSError **)error;

- (void)setUpStoreAsiCloudStoreWithCompletionBlock:(iStayHealthySuccessBlock)completionBlock;

- (void)setUpStoreWithError:(iStayHealthyErrorBlock)error;

- (void)resetContextsAndWait;

- (BOOL)saveContextAndWait:(NSError **)error;

- (BOOL)saveAndBackup:(NSError **)error;

- (void)restoreLocallyWithCompletionBlock:(iStayHealthySuccessBlock)completionBlock;

- (BOOL)saveContext:(NSError **)error;

- (NSURL *)applicationDocumentsDirectory;

- (BOOL)addFileToImportList:(NSURL *)sourceURL error:(NSError **)error;

- (void)fetchiStayHealthyRecordWithCompletion:(iStayHealthyRecordCompletionBlock)completion;

- (void)fetchDataForEntityName:(NSString *)entityName
                     predicate:(NSPredicate *)predicate
                      sortTerm:(NSString *)sortTerm
                     ascending:(BOOL)ascending
                    completion:(iStayHealthyArrayCompletionBlock)completion;

- (void)iCloudStoreChanged:(NSNotification *)notification;

- (void)importWhenReady:(NSNotification *)notification;
- (void)importWithData;
- (void)importFromTmpFileURL;

- (id)managedObjectForEntityName:(NSString *)entityName;

- (NSDictionary *)attributesForEntityName:(NSString *)entityName;

/**
   We may want to do this part later. 2 August 2014
 */
//- (void)replaceStoreWithLocalFallbackStoreWithCompletion:(iStayHealthySuccessBlock)completionBlock;

- (void)migrateToLocalWithCompletion:(iStayHealthySuccessBlock)completionBlock;

- (void)migrateToiCloudStoreWithCompletion:(iStayHealthySuccessBlock)completionBlock;


@end
