//
//  SQLiteHelper.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/09/2012.
//
//

#import "SQLiteHelper.h"
#import "Utilities.h"
#import "iStayHealthyRecord.h"
#import "NSArray-Set.h"
#import "Wellness.h"
#import "PreviousMedication.h"
#import "Results.h"
#import "Procedures.h"
#import "SideEffects.h"
#import "MissedMedication.h"
#import "OtherMedication.h"
#import "Medication.h"
#import "Contacts.h"

#define USE_FALLBACK_STORE NO
#define TEST_DATA_TRANSFER NO

NSString * const kSQLiteiCloudStore = @"iStayHealthy.sqlite";
NSString * const kSQLiteNoiCloudStore = @"iStayHealthyNoiCloud.sqlite";

@interface SQLiteHelper ()
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator * localStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext * mainObjectContext;
@property (nonatomic, strong, readwrite) NSURL * storeURL;
@property (nonatomic, strong, readwrite) NSURL * noiCloudStoreURL;
@property (nonatomic, strong, readwrite) NSOperationQueue * mainQueue;
@property (nonatomic, strong, readwrite) NSLock * universalLock;
@property (nonatomic, strong, readwrite) id currentUbiquityToken;
@property (nonatomic, strong, readwrite) NSPersistentStore * noniCloudStore;
@property (nonatomic, strong, readwrite) NSDictionary * localStoreOptions;
@property BOOL useLocalStore;
- (void)setUpCoordinatorAndContext;
- (BOOL)loadLocalSQLiteStore:(NSError *__autoreleasing *)error;
- (BOOL)loadSQLiteStoreFromiCloud:(NSError *__autoreleasing *)error;
- (NSURL *)applicationDocumentsDirectory;
- (BOOL)addMasterRecordWithObjectContext:(NSManagedObjectContext *)context;
- (BOOL)hasMasterRecord:(NSManagedObjectContext *)context;
- (void)transferDataToLocalStore:(NSPersistentStore *)store context:(NSManagedObjectContext *)context;
- (void)addResult:(Results *)result record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addHIVMed:(Medication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addPreviousMed:(PreviousMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addOtherMed:(OtherMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addMissedMed:(MissedMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addSideEffect:(SideEffects *)effect record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addContact:(Contacts *)contact record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addProcedure:(Procedures *)procedure record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addWellness:(Wellness *)wellness record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification;
@end


@implementation SQLiteHelper
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize storeURL = _storeURL;
@synthesize mainQueue = _mainQueue;
@synthesize universalLock = _universalLock;
@synthesize noiCloudStoreURL = _noiCloudStoreURL;
@synthesize currentUbiquityToken = _currentUbiquityToken;
@synthesize noniCloudStore = _noniCloudStore;
@synthesize localStoreOptions = _localStoreOptions;
@synthesize useLocalStore = _useLocalStore;
/**
 init sets up the managedobject context and the non iCloud store
 */
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        self.mainQueue = [[NSOperationQueue alloc] init];
        self.universalLock = [[NSLock alloc] init];
        self.useLocalStore = NO;
        [self setUpCoordinatorAndContext];
    }
    return self;
}

/**
 this starts the async operation to load the persistent stores for either local (Simulator only) or
 iCloud. Always 2 stores are being loaded: the actual store (i.e. iCloud) iStayHealthy.sqlite and the 
 backup store, iStayHealthyNoiCloud.sqlite
 */
- (void)loadSQLitePersistentStore
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:loadSQLitePersistentStore ENTERING");
#endif
    __weak SQLiteHelper *weakSelf = self;
    [self.mainQueue addOperationWithBlock:^{
        BOOL isLocked = NO;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSNotification* animateNotification = [NSNotification
                                                   notificationWithName:@"startAnimation"
                                                   object:self
                                                   userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:animateNotification];
        }];
        @try
        {
            [weakSelf.universalLock lock];
            isLocked = YES;
            NSError *error;
            if (DEVICE_IS_SIMULATOR)
            {
                [weakSelf loadLocalSQLiteStore:&error];
            }
            else
            {
                [weakSelf loadSQLiteStoreFromiCloud:&error];
            }    
        } @finally
        {
            if (isLocked)
            {
                [weakSelf.universalLock unlock];
                isLocked = NO;
            }
        }
        
    }];
    
}


#pragma mark - private methods

/**
 called first when initialising. This sets up the main object context on the main thread, the
 persistentstorecoordinator, the URLs for both iCloud store (which is the same as the local store for Simulator)
 and the non iCloud Store. This method is being called on the main thread.
 We also create the noniCloud store, its main context and store coordinator in full here.  
 NOTE: we do not create the persistent stores for iCloud itself here. This is done asynchronously in a separate step.
 Same holds when using Simulator (which only uses the local store)
 */

- (void)setUpCoordinatorAndContext
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:setUpCoordinatorAndContext ENTERING");
#endif
    NSMergePolicy *policy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    self.mainObjectContext          = [[NSManagedObjectContext alloc]
                                       initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.mainObjectContext setMergePolicy:policy];

    self.storeURL           = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSQLiteiCloudStore];

    self.noiCloudStoreURL   = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSQLiteNoiCloudStore];

#ifdef APPDEBUG
    NSLog(@"store URL = %@ and fallback store URL is %@", [self.storeURL path], [self.noiCloudStoreURL path]);
#endif
    

#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:setUpCoordinatorAndContext setting up local store");
#endif

    
    self.localStoreOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChangesFrom_iCloud:)
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:self.persistentStoreCoordinator];
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
    if (nil == notification)
    {
        return;
    }
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:mergeChangesFrom_iCloud we are about to merge changes that come from iCloud");
#endif
    [self.mainObjectContext performBlock:^{
        [self.mainObjectContext mergeChangesFromContextDidSaveNotification:notification];
        NSNotification* refreshNotification = [NSNotification
                                               notificationWithName:@"RefetchAllDatabaseData"
                                               object:self
                                               userInfo:[notification userInfo]];
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}

/**
 This method is only called when running in the simulator. It uses the same name for the SQLite database as it is used
 for iCloud.
 */
- (BOOL)loadLocalSQLiteStore:(NSError *__autoreleasing *)error
{
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"SQLiteHelper:loadLocalSQLiteStore ENTERING");
    }];
/*
    if (USE_FALLBACK_STORE == YES)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"SQLiteHelper:loadLocalSQLiteStore using FALLBACK store");
        }];
        NSPersistentStore *testStore = [self.persistentStoreCoordinator
                                         addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                         URL:self.noiCloudStoreURL
                                         options:self.localStoreOptions
                                         error:error];
        if (testStore != nil)
        {
            if (![self hasMasterRecord:self.mainObjectContext])
            {
                [self addMasterRecordWithObjectContext:self.mainObjectContext];
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"SQLiteHelper:loadLocalSQLiteStore we now got the store");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData"
                                                                    object:self
                                                                  userInfo:nil];
            }];
        }
        else
        {
            NSLog(@"Error in loadLocalSQLiteStore: %@ code %d", [*error localizedDescription], [*error code]);
            abort();
        }
        return YES;
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"SQLiteHelper:loadLocalSQLiteStore using normal store");
    }];
*/    
#endif
    
    NSPersistentStore *localStore = [self.persistentStoreCoordinator
                                     addPersistentStoreWithType:NSSQLiteStoreType
                                     configuration:nil
                                     URL:self.storeURL
                                     options:self.localStoreOptions
                                     error:error];
    if (nil == localStore)
    {
#ifdef APPDEBUG
        NSLog(@"Error in loadLocalSQLiteStore: %@ code %d", [*error localizedDescription], [*error code]);
#endif
        abort();
    }
    else
    {
        if (![self hasMasterRecord:self.mainObjectContext])
        {
            [self addMasterRecordWithObjectContext:self.mainObjectContext];
        }
        /*
        if (TEST_DATA_TRANSFER == YES && DEVICE_IS_SIMULATOR)
        {
#ifdef APPDEBUG
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"SQLiteHelper:loadLocalSQLiteStore testing transfer");
            }];
#endif
            NSManagedObjectContext *subContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
            NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
            NSError *error = nil;
            NSPersistentStore *localStore = [coordinator
                                             addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil
                                             URL:self.noiCloudStoreURL
                                             options:self.localStoreOptions
                                             error:&error];
            if (nil != localStore)
            {
                [subContext setPersistentStoreCoordinator:coordinator];
                if (![self hasMasterRecord:subContext])
                {
#ifdef APPDEBUG
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSLog(@"SQLiteHelper:loadLocalSQLiteStore the fallback store doesn't have a master record");
                    }];
#endif
                    [self addMasterRecordWithObjectContext:subContext];
                }
                [self transferDataToLocalStore:localStore context:subContext];                
            }
        }
         */
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"about to send refresh notification");
            NSNotification* refreshNotification = [NSNotification
                                                   notificationWithName:@"RefetchAllDatabaseData"
                                                   object:self
                                                   userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
        }];
    }
    return YES;
    
}


/**
 This is the heart and core of SQLiteHelper.
 We first check the availability of iCloud. If available, we create the store using the cloud options. If that fails, or if
 iCloud (ubiquityContainer) is not available, we then create the non-iCloud Store instead. 
 However, if we do succeed creating the iCloud store, we then call onto a method that checks whether the fallback store is empty.
 If yes, we then copy all material from the current iCloud store over to the non-iCloud store to have a snapshot from the moment
 the app is started.
 
 */
- (BOOL)loadSQLiteStoreFromiCloud:(NSError *__autoreleasing *)error
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *ubiquityContainer = [fileManager URLForUbiquityContainerIdentifier:nil];
    
#ifdef APPDEBUG
    if (USE_FALLBACK_STORE == YES)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud we are using the fallbackstore");
        }];
        NSError *error = nil;
        NSPersistentStore *localStore = [self.persistentStoreCoordinator
                                         addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                         URL:self.noiCloudStoreURL
                                         options:self.localStoreOptions
                                         error:&error];
        if (nil == localStore)
        {
            NSLog(@"error creating local store with message %@ and code %d", [error localizedDescription], [error code]);
            abort();
        }
        return YES;
    }
#endif
    
    if (nil != ubiquityContainer)
    {
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud We have iCloud store available");
        }];
#endif
        NSString* coreDataCloudContent = [[ubiquityContainer path] stringByAppendingPathComponent:@"data"];
        
        NSURL *amendedCloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store", NSPersistentStoreUbiquitousContentNameKey,
                                 amendedCloudURL, NSPersistentStoreUbiquitousContentURLKey,
                                 nil];
        NSError *error = nil;
        NSPersistentStore *cloudStore = [self.persistentStoreCoordinator
                                         addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                         URL:self.storeURL
                                         options:options
                                         error:&error];
        if (nil != cloudStore)
        {
#ifdef APPDEBUG
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud we successfully created the Persistent iCloud store");
            }];
#endif
            if (![self hasMasterRecord:self.mainObjectContext])
            {
#ifdef APPDEBUG
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud we don't have a master record so we create one");
                }];
#endif
                [self addMasterRecordWithObjectContext:self.mainObjectContext];
            }
            NSManagedObjectContext *subContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
            NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
            NSError *error = nil;
            NSPersistentStore *localStore = [coordinator
                                             addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil
                                             URL:self.noiCloudStoreURL
                                             options:self.localStoreOptions
                                             error:&error];
            if (nil != localStore)
            {
                [subContext setPersistentStoreCoordinator:coordinator];
#ifdef APPDEBUG
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud we we are now ready to create the fallback store");
                }];
#endif
                if (![self hasMasterRecord:subContext])
                {
#ifdef APPDEBUG
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud the fallback store doesn't have a master record");
                    }];
#endif
                    [self addMasterRecordWithObjectContext:subContext];
                    [self transferDataToLocalStore:localStore context:subContext];
                }
            }
            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                                                                    object:self
                                                                                  userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
            }];
        }
        
    }
    else
    {
        NSError *error = nil;
        /*
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud We DO NOT have an iCloud store available");
        }];
#endif
        NSError *error = nil;
        NSManagedObjectContext *subContext = [[NSManagedObjectContext alloc] init];
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSPersistentStore *localStore = [coordinator
                                         addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                         URL:self.noiCloudStoreURL
                                         options:self.localStoreOptions
                                         error:&error];
        if (nil != localStore)
        {
#ifdef APPDEBUG
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud checking the noniCloud store for master record");
            }];
#endif
            if ([self hasMasterRecord:subContext])
            {
#ifdef APPDEBUG
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"SQLiteHelper:loadSQLiteStoreFromiCloud  the noniCloud store has a master record");
                }];
#endif
                [self.persistentStoreCoordinator
                 addPersistentStoreWithType:NSSQLiteStoreType
                 configuration:nil
                 URL:self.noiCloudStoreURL
                 options:self.localStoreOptions
                 error:&error];
                if (nil == error)
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSNotification* refreshNotification = [NSNotification
                                                               notificationWithName:@"RefetchAllDatabaseData"
                                                               object:self
                                                               userInfo:nil];
                        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
                    }];
                }
            }
            else
            {
                [self loadLocalSQLiteStore:&error];
            }
        }
        else
        {
            [self loadLocalSQLiteStore:&error];            
        }
         */
        [self loadLocalSQLiteStore:&error];
        
    }
    return YES;
}

/**
 gets the URL to the directory where we store the SQLite databases
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 This method ensures that we always have a master record available.
 The master record contains relationships to all other records. Only 1 can ever be present.
 */
- (BOOL)addMasterRecordWithObjectContext:(NSManagedObjectContext *)context
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:addMasterRecordWithObjectContext ENTERING");
#endif
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"iStayHealthyRecord"];
    NSArray *records = [context executeFetchRequest:fetchRequest error:&error];
    if (nil != records)
    {
        if (0 == records.count)
        {
            NSManagedObject *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"iStayHealthyRecord"
                                                                       inManagedObjectContext:context];
            [newRecord setValue:@"YourName" forKey:@"Name"];
            BOOL success = [context save:&error];
            if (!success)
            {
#ifdef APPDEBUG
                NSLog(@"SQLiteHelper:addMasterRecordWithObjectContext we could not save a master Record to the store");
#endif
            }
            
        }
#ifdef APPDEBUG
        else
        {
            NSLog(@"SQLiteHelper:addMasterRecordWithObjectContext we already have 1 master record in the store");            
        }
#endif
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)hasMasterRecord:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"iStayHealthyRecord"];
    NSArray *records = [context executeFetchRequest:fetchRequest error:&error];
    if (nil != records)
    {
        if (0 < records.count)
        {
            return YES;
        }
    }
    
    return NO;
}


/**
 a rather big method - as we transfer all data records to the local store
 */
- (void)transferDataToLocalStore:(NSPersistentStore *)store context:(NSManagedObjectContext *)context
{
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"SQLiteHelper:transferDataToLocalStore ENTERING");
    }];
#endif
    NSError *error = nil;
    NSManagedObjectContext *topcontext = [[NSManagedObjectContext alloc] init];
    [topcontext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"iStayHealthyRecord"];
    NSArray *records = [self.mainObjectContext executeFetchRequest:fetchRequest
                                                             error:&error];
    if (nil == records)
    {
        return;
    }
    if (0 == records.count)
    {
        return;
    }

    NSArray *fallbackRecords = [context executeFetchRequest:fetchRequest error:&error];
    if (nil == fallbackRecords)
    {
        return;
    }
    if (0 == fallbackRecords.count)
    {
        return;
    }

#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"SQLiteHelper:transferDataToLocalStore ready to transfer data to fallback store");
    }];
#endif
    
    iStayHealthyRecord *record = (iStayHealthyRecord *)[records objectAtIndex:0];
    NSArray *results = [record.results allObjects];
    NSArray *hivMeds = [record.medications allObjects];
    NSArray *meds = [record.otherMedications allObjects];
    NSArray *effects = [record.sideeffects allObjects];
    NSArray *missed = [record.missedMedications allObjects];
    NSArray *procs = [record.procedures allObjects];
    NSArray *contacts = [record.contacts allObjects];
    NSArray *previous = [record.previousMedications allObjects];
    NSArray *wellness = [record.wellness allObjects];
    BOOL success = YES;
    
    
    iStayHealthyRecord *fallbackRecord = (iStayHealthyRecord *)[fallbackRecords objectAtIndex:0];
    for (Results *result in results)
    {
        [self addResult:result record:fallbackRecord  context:context];
    }

    for (Medication *hivmed in hivMeds)
    {
        [self addHIVMed:hivmed record:fallbackRecord  context:context];
    }

    for (OtherMedication *med in meds)
    {
        [self addOtherMed:med record:fallbackRecord  context:context];
    }

    for (SideEffects *effect in effects)
    {
        [self addSideEffect:effect record:fallbackRecord  context:context];
    }

    for (MissedMedication *mis in missed)
    {
        [self addMissedMed:mis record:fallbackRecord  context:context];
    }

    for (Procedures *proc in procs)
    {
        [self addProcedure:proc record:fallbackRecord  context:context];
    }

    for (Contacts *contact in contacts)
    {
        [self addContact:contact record:fallbackRecord  context:context];
    }

    for (PreviousMedication *old in previous)
    {
        [self addPreviousMed:old record:fallbackRecord  context:context];
    }

    for (Wellness *well in wellness)
    {
        [self addWellness:well record:fallbackRecord  context:context];
    }

    if ([context hasChanges])
    {
        success = [context save:&error];
        if (!success)
        {
#ifdef APPDEBUG
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"SQLiteHelper:transferDataToLocalStore error saving context data");
            }];
#endif
        }
    }
#ifdef APPDEBUG
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"SQLiteHelper:transferDataToLocalStore context doesn't have any changes to save");
        }];        
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"SQLiteHelper:transferDataToLocalStore LEAVING");
    }];
#endif
}

#pragma mark - adding the data to the store
- (void)addResult:(Results *)result record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Results *copiedResult = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:context];
    [record addResultsObject:copiedResult];
    copiedResult.UID = result.UID;
    copiedResult.ResultsDate = result.ResultsDate;
    copiedResult.CD4 = result.CD4;
    copiedResult.CD4Percent = result.CD4Percent;
    copiedResult.ViralLoad = result.ViralLoad;
    copiedResult.HepCViralLoad = result.HepCViralLoad;
    copiedResult.Hemoglobulin = result.Hemoglobulin;
    copiedResult.WhiteBloodCellCount = result.WhiteBloodCellCount;
    copiedResult.redBloodCellCount = result.redBloodCellCount;
    copiedResult.PlateletCount = result.PlateletCount;

    copiedResult.Glucose = result.Glucose;
    copiedResult.cholesterolRatio = result.cholesterolRatio;
    copiedResult.TotalCholesterol = result.TotalCholesterol;
    copiedResult.Triglyceride = result.Triglyceride;
    copiedResult.HDL = result.HDL;
    copiedResult.LDL = result.LDL;

    copiedResult.Weight = result.Weight;
    copiedResult.Systole = result.Systole;
    copiedResult.Diastole = result.Diastole;

    copiedResult.HeartRate = result.HeartRate;
    copiedResult.hepBTiter = result.hepBTiter;
    copiedResult.hepCTiter = result.hepCTiter;
    copiedResult.liverAlanineDirectBilirubin = result.liverAlanineDirectBilirubin;
    copiedResult.liverAlanineTotalBilirubin = result.liverAlanineTotalBilirubin;
    copiedResult.liverAlanineTransaminase = result.liverAlanineTransaminase;
    copiedResult.liverAlbumin = result.liverAlbumin;
    copiedResult.liverAlkalinePhosphatase = result.liverAlkalinePhosphatase;
    copiedResult.liverAspartateTransaminase = result.liverAspartateTransaminase;
    copiedResult.liverGammaGlutamylTranspeptidase = result.liverGammaGlutamylTranspeptidase;
}

- (void)addHIVMed:(Medication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Medication *copiedMed = [NSEntityDescription insertNewObjectForEntityForName:@"Medication" inManagedObjectContext:context];
    [record addMedicationsObject:copiedMed];
    copiedMed.UID = med.UID;
    copiedMed.StartDate = med.StartDate;
    copiedMed.Name = med.Name;
    copiedMed.Dose = med.Dose;
    copiedMed.Drug = med.Drug;
    copiedMed.MedicationForm = med.MedicationForm;
}

- (void)addPreviousMed:(PreviousMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    PreviousMedication *copiedMed = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"PreviousMedication"
                                     inManagedObjectContext:context];
    [record addPreviousMedicationsObject:copiedMed];
    copiedMed.uID = med.uID;
    copiedMed.startDate = med.startDate;
    copiedMed.endDate = med.endDate;
    copiedMed.name = med.name;
    copiedMed.drug = med.drug;
    copiedMed.isART = med.isART;
    copiedMed.reasonEnded = med.reasonEnded;
}

- (void)addOtherMed:(OtherMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    OtherMedication *copiedMed = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"OtherMedication"
                                  inManagedObjectContext:context];
    [record addOtherMedicationsObject:copiedMed];
    copiedMed.UID = med.UID;
    copiedMed.Unit = med.Unit;
    copiedMed.StartDate = med.StartDate;
    copiedMed.EndDate = med.EndDate;
    copiedMed.Name = med.Name;
    copiedMed.Dose = med.Dose;
    copiedMed.MedicationForm = med.MedicationForm;
    copiedMed.Image = med.Image;
}

- (void)addMissedMed:(MissedMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    MissedMedication *copiedMed = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"MissedMedication"
                                   inManagedObjectContext:context];
    [record addMissedMedicationsObject:copiedMed];
    copiedMed.UID = med.UID;
    copiedMed.missedReason = med.missedReason;
    copiedMed.MissedDate = med.MissedDate;
    copiedMed.Name = med.Name;
    copiedMed.Drug = med.Drug;
}
- (void)addSideEffect:(SideEffects *)effect record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    SideEffects *copiedEffect = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"SideEffects"
                                 inManagedObjectContext:context];
    [record addSideeffectsObject:copiedEffect];
    copiedEffect.UID = effect.UID;
    copiedEffect.SideEffect = effect.SideEffect;
    copiedEffect.SideEffectDate = effect.SideEffectDate;
    copiedEffect.seriousness = effect.seriousness;
    copiedEffect.Name = effect.Name;
    copiedEffect.Drug = effect.Drug;
}

- (void)addContact:(Contacts *)contact record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Contacts *copiedContact = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Contacts"
                               inManagedObjectContext:context];
    [record addContactsObject:copiedContact];
    copiedContact.UID = contact.UID;
    copiedContact.ClinicCity = contact.ClinicCity;
    copiedContact.ClinicContactNumber = contact.ClinicContactNumber;
    copiedContact.ClinicCountry = contact.ClinicCountry;
    copiedContact.ClinicEmailAddress = contact.ClinicEmailAddress;
    copiedContact.ClinicID = contact.ClinicID;
    copiedContact.ClinicName = contact.ClinicName;
    copiedContact.ClinicNurseName = contact.ClinicNurseName;
    copiedContact.ClinicPostcode = contact.ClinicPostcode;
    copiedContact.ClinicStreet = contact.ClinicStreet;
    copiedContact.ClinicWebSite = contact.ClinicWebSite;
    copiedContact.ConsultantName = contact.ConsultantName;
    copiedContact.ContactName = contact.ContactName;
    copiedContact.AppointmentContactNumber = contact.AppointmentContactNumber;
    copiedContact.EmergencyContactNumber = contact.EmergencyContactNumber;
    copiedContact.EmergencyContactNumber2 = contact.EmergencyContactNumber2;
    copiedContact.InsuranceAuthorisationCode = contact.InsuranceAuthorisationCode;
    copiedContact.InsuranceContactNumber = contact.InsuranceContactNumber;
    copiedContact.InsuranceID = contact.InsuranceID;
    copiedContact.InsuranceName = contact.InsuranceName;
    copiedContact.InsuranceWebSite = contact.InsuranceWebSite;
    copiedContact.ResultsContactNumber = contact.ResultsContactNumber;
}

- (void)addProcedure:(Procedures *)procedure record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Procedures *copiedProcedure = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"Procedures"
                                  inManagedObjectContext:context];
    [record addProceduresObject:copiedProcedure];
    copiedProcedure.UID = procedure.UID;
    copiedProcedure.Date = procedure.Date;
    copiedProcedure.Illness = procedure.Illness;
    copiedProcedure.Name = procedure.Name;
    copiedProcedure.Notes = procedure.Notes;
    copiedProcedure.EndDate = procedure.EndDate;
    copiedProcedure.CausedBy = procedure.CausedBy;
}

- (void)addWellness:(Wellness *)wellness record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context
{
    Wellness *copiedWellness = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Wellness"
                                inManagedObjectContext:context];
    [record addWellnessObject:copiedWellness];
    copiedWellness.uID = wellness.uID;
    copiedWellness.sleepBarometer = wellness.sleepBarometer;
    copiedWellness.moodBarometer = wellness.moodBarometer;
    copiedWellness.wellnessBarometer = wellness.wellnessBarometer;
}


@end
