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
@property (nonatomic, strong) NSData *xmlImportData;
@property (nonatomic, strong) NSString *xmlTmpPath;

+ (CoreDataManager *)sharedInstance;

- (void)setUpCoreDataManager;

- (BOOL)hasNewiCloudStore;

- (void)migrateToNewiCloudStore:(iStayHealthySuccessBlock)error;

- (void)setUpStoreWithError:(iStayHealthyErrorBlock)error;

- (BOOL)saveContextAndWait:(NSError **)error;

- (BOOL)saveAndBackup:(NSError **)error;

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

- (id)managedObjectForEntityName:(NSString *)entityName;

- (NSDictionary *)attributesForEntityName:(NSString *)entityName;

@end
