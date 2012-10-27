//
//  SQLDatabaseManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 20/10/2012.
//
//

#import "SQLDatabaseManager.h"
#import "Utilities.h"
#import "Constants.h"
#import "SQLBackupStoreManager.h"

#define MIGRATE_STORE_FOR_SIMULATOR NO
#define USE_BACKUP_STORE NO

@interface SQLDatabaseManager ()
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext * mainObjectContext;
@property (nonatomic, strong, readwrite) NSURL *mainStoreURL;
@property (nonatomic, strong, readwrite) NSURL *backupStoreURL;
@property (nonatomic, strong, readwrite) NSOperationQueue * mainQueue;
@property (nonatomic, strong, readwrite) NSLock * universalLock;
@property (nonatomic, strong, readwrite) id ubiquityToken;
@property (nonatomic, strong, readwrite) NSPersistentStore *mainStore;
@property (nonatomic, strong, readwrite) NSPersistentStore *backupStore;
@property BOOL backupStoreExists;
@property BOOL mainStoreExists;
@property BOOL iCloudIsAvailable;
@property BOOL iOS6FeaturesAvailable;

- (void)storeAndContext;
- (void)selectStoreAndMigrate:(NSError *__autoreleasing *)error;
- (void)selectStoreAndMigrateForiOS6;
- (void)selectStoreAndMigrateInSimulator:(NSError *__autoreleasing *)error;
- (NSURL *)applicationDocumentsDirectory;
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification;
- (BOOL)loadMainStoreLocally:(NSError *__autoreleasing *)error;
- (BOOL)loadCloudStore:(NSURL *)ubiquityContainerURL error:(NSError *__autoreleasing *)error;
- (BOOL)loadBackupStoreLocally:(NSError *__autoreleasing *)error;
- (void)addMasterRecord;
- (void)iCloudStoreChanged;
- (void)manageChangesToiCloudStore;
- (BOOL)checkiOS6Availability;
- (void)sendDebugMessage:(NSString *)debug onMainThread:(BOOL) isOnMainThread;
@end


@implementation SQLDatabaseManager
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize mainStoreURL = _firstStoreURL;
@synthesize backupStoreURL = _secondStoreURL;
@synthesize mainQueue = _mainQueue;
@synthesize universalLock = _universalLock;
@synthesize backupStoreExists = _backupStoreExists;
@synthesize mainStoreExists = _mainStoreExists;
@synthesize mainStore = _mainStore;
@synthesize backupStore = _backupStore;
@synthesize iCloudIsAvailable = _iCloudIsAvailable;
@synthesize iOS6FeaturesAvailable = _iOS6FeaturesAvailable;
/**
 init 
 */
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        self.mainQueue = [[NSOperationQueue alloc] init];
        self.universalLock = [[NSLock alloc] init];
        self.backupStoreExists = NO;
        self.mainStoreExists = NO;
        self.iCloudIsAvailable = NO;
        self.ubiquityToken = nil;
        self.mainStore = nil;
        self.backupStore = nil;
        self.iOS6FeaturesAvailable = [self checkiOS6Availability];
        
        [self storeAndContext];
        
    }
    return self;
}

/**
 the method to load the store asynchronously
 */
- (void)loadSQLitePersistentStore
{
    __weak SQLDatabaseManager *weakSelf = self;
    [self.mainQueue addOperationWithBlock:^{
        BOOL isLocked = NO;
        @try
        {
            [weakSelf.universalLock lock];
            isLocked = YES;
            NSError *error = nil;
            if (DEVICE_IS_SIMULATOR)
            {
                [self selectStoreAndMigrateInSimulator:&error];
            }
            else
            {
                if (self.iOS6FeaturesAvailable)
                {
                    [self selectStoreAndMigrateForiOS6];
                }
                else
                {
                    [self selectStoreAndMigrate:&error];
                }
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

#pragma private methods
- (BOOL)checkiOS6Availability
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager respondsToSelector:@selector(ubiquityIdentityToken)])
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}



/**
 called from init. In here we set up the main object context using main queue as we want the
 UI to be notified of update/changes. We set up the persistent store coordinator and the store url's
 for both main store and backup store.
 We finally subscribe to be notified when changes come in through iCloud
 The merge policy is set to give priority to stored objects
 */
- (void)storeAndContext
{
    [self sendDebugMessage:@"SQLiteHelper:setUpCoordinatorAndContext ENTERING" onMainThread:YES];
    NSMergePolicy *policy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    self.mainObjectContext          = [[NSManagedObjectContext alloc]
                                       initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.mainObjectContext setMergePolicy:policy];
    
    self.mainStoreURL           = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kMainDataSource];
    
    self.backupStoreURL   = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kBackupDataSource];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:[self.backupStoreURL path]])
    {
        [self sendDebugMessage:@"***** Backupstore exists **********" onMainThread:YES];
        self.backupStoreExists = YES;
    }
    
    if ([fileManager fileExistsAtPath:[self.mainStoreURL path]])
    {
        self.mainStoreExists = YES;
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(mergeChangesFrom_iCloud:)
     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
     object:self.persistentStoreCoordinator];

    [self manageChangesToiCloudStore];
        
}

- (void)manageChangesToiCloudStore
{
    [self sendDebugMessage:@"SQLDatabaseManager::manageChangesToiCloudStore ENTERING" onMainThread:YES];
    
    if (!self.iOS6FeaturesAvailable)
    {
        [self sendDebugMessage:@"we don't have the iOS 6 features available to check for iCloud"
                  onMainThread:YES];
        return;
    }

    self.ubiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    self.iOS6FeaturesAvailable = YES;
    
    if (nil != self.ubiquityToken)
    {
        [self sendDebugMessage:@"SQLDatabaseManager::manageChangesToiCloudStore we have iCloud enabled" onMainThread:YES];
        NSData *currentTokenData = [NSKeyedArchiver archivedDataWithRootObject:self.ubiquityToken];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:currentTokenData forKey:@"com.pweschmidt.iStayHealthy.ubiquityToken"];
        [defaults synchronize];
        self.iCloudIsAvailable = YES;
    }
    else
    {
        [self sendDebugMessage:@"SQLDatabaseManager::manageChangesToiCloudStore we DO NOT have iCloud enabled" onMainThread:YES];
        self.iCloudIsAvailable = NO;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.pweschmidt.iStayHealthy.ubiquityToken"];
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(iCloudStoreChanged)
     name:NSUbiquityIdentityDidChangeNotification
     object:nil];
    [self sendDebugMessage:@"SQLDatabaseManager::manageChangesToiCloudStore LEAVING" onMainThread:YES];
    
}

/**
 this method loads the main store using local/non-iCloud options. 
 */
- (BOOL)loadMainStoreLocally:(NSError *__autoreleasing *)error
{
    NSDictionary *dbStoreOptions = [NSDictionary
                                    dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                    NSMigratePersistentStoresAutomaticallyOption,
                                    [NSNumber numberWithBool:YES],
                                    NSInferMappingModelAutomaticallyOption, nil];
    NSPersistentStore * store = [self.persistentStoreCoordinator
                                 addPersistentStoreWithType:NSSQLiteStoreType
                                 configuration:nil
                                 URL:self.mainStoreURL
                                 options:dbStoreOptions
                                 error:error];
    
    if (nil == store)
    {
        [self sendDebugMessage:@"Local MAIN store is NIL or returns an error" onMainThread:NO];
        return NO;
    }
    self.mainStore = store;
    [self sendDebugMessage:@"Local MAIN store created successfully" onMainThread:NO];
    return YES;
}

/**
 this method loads the backup store with local/non-iCloud options
 */
- (BOOL)loadBackupStoreLocally:(NSError *__autoreleasing *)error
{
    NSDictionary *dbStoreOptions = [NSDictionary
                                    dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                    NSMigratePersistentStoresAutomaticallyOption,
                                    [NSNumber numberWithBool:YES],
                                    NSInferMappingModelAutomaticallyOption, nil];
    NSPersistentStore * store = [self.persistentStoreCoordinator
                                 addPersistentStoreWithType:NSSQLiteStoreType
                                 configuration:nil
                                 URL:self.backupStoreURL
                                 options:dbStoreOptions
                                 error:error];
    
    if (nil == store)
    {
        [self sendDebugMessage:@"Local BACKUPSTORE store is NIL or returns an error" onMainThread:NO];
        return NO;
    }
    self.backupStore = store;
    [self sendDebugMessage:@"Local BACKUP store created successfully" onMainThread:NO];
    return YES;
}

/**
 this method loads the Cloud store with the appropriate cloud options
 */
- (BOOL)loadCloudStore:(NSURL *)ubiquityContainerURL error:(NSError *__autoreleasing *)error
{
    NSString* coreDataCloudContent = [[ubiquityContainerURL path] stringByAppendingPathComponent:@"data"];
    NSURL *amendedCloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
    NSDictionary *dbStoreOptions = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES],
                                    NSMigratePersistentStoresAutomaticallyOption,
                                    [NSNumber numberWithBool:YES],
                                    NSInferMappingModelAutomaticallyOption,
                                    kUbiquitousKeyPath,
                                    NSPersistentStoreUbiquitousContentNameKey,
                                    amendedCloudURL,
                                    NSPersistentStoreUbiquitousContentURLKey, nil];
    
    NSPersistentStore * store = [self.persistentStoreCoordinator
                                 addPersistentStoreWithType:NSSQLiteStoreType
                                 configuration:nil
                                 URL:self.mainStoreURL
                                 options:dbStoreOptions
                                 error:error];
    
    if (nil == store)
    {
        [self sendDebugMessage:@"iCloud store is NIL or returns an error" onMainThread:NO];
        return NO;
    }
    self.mainStore = store;
    [self sendDebugMessage:@"iCloud store created successfully" onMainThread:NO];
    return YES;
}

/**
 this gets run only when we are in Simulator mode
 */
- (void)selectStoreAndMigrateInSimulator:(NSError *__autoreleasing *)error
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self sendDebugMessage:@"selectStoreAndMigrateInSimulator ENTERING" onMainThread:YES];
        NSNotification* animateNotification = [NSNotification
                                               notificationWithName:@"startAnimation"
                                               object:self
                                               userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:animateNotification];
    }];
    
    BOOL success = NO;
    if (USE_BACKUP_STORE)
    {
        success = [self loadBackupStoreLocally:error];
    }
    else
    {
        success = [self loadMainStoreLocally:error];
    }
    
    if (success)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self addMasterRecord];
            
            NSNotification* refreshNotification =
            [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                          object:self
                                        userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
            if (!USE_BACKUP_STORE)
            {
                [self sendDebugMessage:@"selectStoreAndMigrateInSimulator about to backup the main store" onMainThread:YES];
                SQLBackupStoreManager *storeManager = [[SQLBackupStoreManager alloc] init];
                [storeManager transferDataToBackupStore];
            }
            [self sendDebugMessage:@"selectStoreAndMigrateInSimulator LEAVING" onMainThread:YES];
        }];
    }
    else
    {
        [self sendDebugMessage:@"selectStoreAndMigrateInSimulator failed to load the store" onMainThread:NO];
    }
        
}


- (void)selectStoreAndMigrateForiOS6
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self sendDebugMessage:@"selectStoreAndMigrateForiOS6 ENTERING" onMainThread:YES];
        NSNotification* animateNotification = [NSNotification
                                               notificationWithName:@"startAnimation"
                                               object:self
                                               userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:animateNotification];
    }];
    BOOL storeLoadingSuccess = NO;
    BOOL isRecoveringFromFailure = NO;
    BOOL shouldUseLocalStore = NO;
    NSError *error = nil;

    if (self.iCloudIsAvailable)
    {
        [self sendDebugMessage:@"selectStoreAndMigrateForiOS6 iCloud should be available" onMainThread:NO];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *ubiquityContainer = [fileManager URLForUbiquityContainerIdentifier:kTeamId];
        if (nil != ubiquityContainer && !USE_BACKUP_STORE)
        {
            storeLoadingSuccess = [self loadCloudStore:ubiquityContainer error:&error];
            if (!storeLoadingSuccess)
            {
                [self sendDebugMessage:@"selectStoreAndMigrateForiOS6 failure to load iCloud store" onMainThread:NO];
                shouldUseLocalStore = YES;
                isRecoveringFromFailure = YES;
                if (nil != self.mainStore)
                {
                    NSError *removeError = nil;
                    [self.persistentStoreCoordinator removePersistentStore:self.mainStore error:&removeError];
                    self.mainStore = nil;
                    [self sendDebugMessage:@"selectStoreAndMigrateForiOS6 remove iCloud store" onMainThread:NO];
                }
            }
            else
            {
                shouldUseLocalStore = NO;
                isRecoveringFromFailure = NO;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self sendDebugMessage:@"selectStoreAndMigrateForiOS6 success to load iCloud store" onMainThread:YES];
                    [self addMasterRecord];
                    NSNotification* refreshNotification =
                    [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                                  object:self
                                                userInfo:nil];
                    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
                    
                    SQLBackupStoreManager *storeManager = [[SQLBackupStoreManager alloc] init];
                    [storeManager transferDataToBackupStore];                    
                }];
                
            }
        }
        else
        {
            shouldUseLocalStore = YES;
            isRecoveringFromFailure = YES;
        }
    }
    else
    {
        shouldUseLocalStore = YES;
        isRecoveringFromFailure = NO;
    }
    
    if (shouldUseLocalStore)
    {
        NSError *localError = nil;
        storeLoadingSuccess = NO;
        if (self.backupStoreExists || isRecoveringFromFailure)
        {
            storeLoadingSuccess = [self loadBackupStoreLocally:&localError];
            [self sendDebugMessage:@"selectStoreAndMigrateForiOS6 using BACKUP store" onMainThread:NO];
        }
        else
        {
            storeLoadingSuccess = [self loadMainStoreLocally:&localError];
            [self sendDebugMessage:@"selectStoreAndMigrateForiOS6 using LOCAL MAIN store" onMainThread:NO];
        }
        
        if (storeLoadingSuccess)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self addMasterRecord];
                
                NSNotification* refreshNotification =
                [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                              object:self
                                            userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
                
            }];
        }
        else
        {
            [self sendDebugMessage:@"selectStoreAndMigrateForiOS6 could NOT LOAD ANY STORE" onMainThread:NO];
        }
    }
    
}

/**
 this is called asynchronously from loadPersistentStores.
 a.) when run on simulator we always go and load the main store using local store options. We can test
 migrating the store and using the backupstore as well.
 
 b.) for devices things are a bit more complex:
    i.) check if iCloud is available. If yes:
        1. load main store with iCloud options
        2. if the store is successfully loaded
            - we check if the backupstore exists. If no - we migrate the iCloud store to it (done elsewhere)
            - we set the NSUserDefaults flag to isUsingCloud to remind ourselves in future, that we have loaded the store with iCloud options
        3. if the store loading fails
            - we set a flag saying that we should be using a local store
    ii.) if iCloud is not available
        - we set the flag saying that we should be using a local store
    iii.) if we get an indication that we need to use a local store we need to decide which one
        1. if no backup store exists it's easy, we simply load the main store with local options
        2. if the backup store exists.
            - check user defaults and see if we have used iCloud before. 
                * If yes, change the NSUserDefault setting and say we don't use iCloud
                * If no, there is no reason to load the backup store, use the main store with local options
            - 
 */

- (void)selectStoreAndMigrate:(NSError *__autoreleasing *)error
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self sendDebugMessage:@"selectStoreAndMigrate ENTERING" onMainThread:YES];
        NSNotification* animateNotification = [NSNotification
                                           notificationWithName:@"startAnimation"
                                           object:self
                                           userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:animateNotification];
    }];
    BOOL storeLoadingSuccess = NO;
    BOOL isRecoveringFromFailure = NO;
    BOOL shouldUseLocalStore = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *ubiquityContainer = [fileManager URLForUbiquityContainerIdentifier:kTeamId];

    if (nil != ubiquityContainer && !USE_BACKUP_STORE)
    {
        storeLoadingSuccess = [self loadCloudStore:ubiquityContainer error:error];
        if (storeLoadingSuccess)
        {
            shouldUseLocalStore = NO;

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"isUsingiCloud"];
            [defaults synchronize];
            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self sendDebugMessage:@"posting a reload notification and USING iCloud" onMainThread:YES];
                [self addMasterRecord];
                NSNotification* refreshNotification =
                [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                              object:self
                                            userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];

                SQLBackupStoreManager *storeManager = [[SQLBackupStoreManager alloc] init];
                [storeManager transferDataToBackupStore];
                [self sendDebugMessage:@"selectStoreAndMigrate LEAVING" onMainThread:YES];
            }];
        }
        else // loading the iCloud store failed
        {            
            if (nil != self.mainStore)
            {
                NSError *removeError = nil;
                [self.persistentStoreCoordinator removePersistentStore:self.mainStore error:&removeError];
                self.mainStore = nil;
                [self sendDebugMessage:@"we need to remove a store if we have any, otherwise we might get a conflict loading it locally"
                          onMainThread:NO];
            }
            shouldUseLocalStore = YES;
            isRecoveringFromFailure = YES;
        }
    }
    else
    {
        shouldUseLocalStore = YES;
    }
    
    if (shouldUseLocalStore)
    {
        storeLoadingSuccess = NO;
        __block BOOL isForTransfer = NO;
        if (self.backupStoreExists || isRecoveringFromFailure)
        {
            [self sendDebugMessage:@"selectStoreAndMigrate using BACKUP store" onMainThread:NO];
            storeLoadingSuccess = [self loadBackupStoreLocally:error];
            isForTransfer = NO;
        }
        else
        {
            [self sendDebugMessage:@"selectStoreAndMigrate using LOCAL MAIN store" onMainThread:NO];
            storeLoadingSuccess = [self loadMainStoreLocally:error];
            isForTransfer = YES;
        }
        if (storeLoadingSuccess)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self sendDebugMessage:@"selectStoreAndMigrate NOT using iCloud store" onMainThread:YES];
                [self addMasterRecord];
                
                NSNotification* refreshNotification =
                [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                              object:self
                                            userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
                if (isForTransfer)
                {
                    SQLBackupStoreManager *storeManager = [[SQLBackupStoreManager alloc] init];
                    [storeManager transferDataToBackupStore];
                }
                [self sendDebugMessage:@"selectStoreAndMigrate LEAVING" onMainThread:YES];
            }];
        }
        else
        {
            [self sendDebugMessage:@"we were not successful in creating ANY store, but can't access the error message " onMainThread:NO];
        }
        
    }
    

}


/**
 */
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
    if (nil == notification)
    {
        return;
    }
    [self sendDebugMessage:@"SQLiteHelper:mergeChangesFrom_iCloud we are about to merge changes that come from iCloud" onMainThread:YES];
    [self.mainObjectContext performBlock:^{
        [self.mainObjectContext mergeChangesFromContextDidSaveNotification:notification];
        [self.mainObjectContext processPendingChanges];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSNotification* refreshNotification = [NSNotification
                                                   notificationWithName:@"RefetchAllDatabaseData"
                                                   object:self
                                                   userInfo:[notification userInfo]];
            [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
        }];
    }];
}


/**
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}


- (void)addMasterRecord
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"iStayHealthyRecord"];
    NSArray *records = [self.mainObjectContext executeFetchRequest:fetchRequest error:&error];
    if (nil == error)
    {
        if (0 == records.count)
        {
            NSManagedObject *newRecord = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"iStayHealthyRecord"
                                          inManagedObjectContext:self.mainObjectContext];
            [newRecord setValue:@"YourName" forKey:@"Name"];
            BOOL success = [self.mainObjectContext save:&error];
            if (!success)
            {
                [self sendDebugMessage:@"SQLiteHelper:addMasterRecordWithObjectContext we could not save a master Record to the store" onMainThread:YES];
            }
            
        }
    }
    
}
- (void)iCloudStoreChanged
{
    if (!self.iOS6FeaturesAvailable)
    {
        return;
    }

    self.ubiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *formerToken = [defaults objectForKey:@"com.pweschmidt.iStayHealthy.ubiquityToken"];
    BOOL isDropStore = NO;
    [self sendDebugMessage:@"iCloudStoreChanged:: the iCloud store changed" onMainThread:YES];

    if (nil != self.ubiquityToken)
    {
        [self sendDebugMessage:@"iCloudStoreChanged:: we have a store available" onMainThread:YES];
        NSData *currentTokenData = [NSKeyedArchiver archivedDataWithRootObject:self.ubiquityToken];
        [defaults setObject:currentTokenData forKey:@"com.pweschmidt.iStayHealthy.ubiquityToken"];
        self.iCloudIsAvailable = YES;
        if (nil != formerToken)
        {
            [self sendDebugMessage:@"iCloudStoreChanged:: we previously had a store available"
                      onMainThread:YES];
            if (![formerToken isEqualToData:currentTokenData])
            {
                [self sendDebugMessage:@"iCloudStoreChanged:: the previous store was from a different account"
                          onMainThread:YES];
                isDropStore = YES;
                self.iCloudIsAvailable = NO;
                SQLBackupStoreManager *backupManager = [[SQLBackupStoreManager alloc] init];
                [backupManager transferDataToBackupStore];
            }
            else
            {
                [self sendDebugMessage:@"iCloudStoreChanged:: the previous store was the same"
                          onMainThread:YES];
                self.iCloudIsAvailable = YES;
                isDropStore = NO;
            }
        }
    }
    else
    {
        [self sendDebugMessage:@"iCloudStoreChanged:: we DO NOT have a store available"
                  onMainThread:YES];
        [defaults removeObjectForKey:@"com.pweschmidt.iStayHealthy.ubiquityToken"];
        self.iCloudIsAvailable = NO;
        isDropStore = NO;
    }
    [defaults synchronize];
    
    if (self.mainStore && self.persistentStoreCoordinator && isDropStore)
    {
        [self sendDebugMessage:@"iCloudStoreChanged:: we have a change in iCloud account - drop store"
                  onMainThread:YES];
        NSError *dropError = nil;
        BOOL success = [self.persistentStoreCoordinator removePersistentStore:self.mainStore error:&dropError];
        if (success)
        {
            self.mainStore = nil;
            [self loadSQLitePersistentStore];
        }
        
    }
    
}

- (void)sendDebugMessage:(NSString *)debug onMainThread:(BOOL) isOnMainThread
{
#ifdef APPDEBUG
    if (isOnMainThread)
    {
        NSLog(@"DEBUG message: %@", debug);
    }
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"DEBUG message: %@", debug);
        }];
    }
#endif
}


@end
