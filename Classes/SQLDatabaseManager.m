//
//  SQLDatabaseManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 20/10/2012.
//
//

#import "SQLDatabaseManager.h"
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

NSString * const kMainDataSource    = @"iStayHealthy.sqlite";
NSString * const kBackupDataSource  = @"iStayHealthyBackup.sqlite";
NSString * const kiCloudDataSource  = @"iStayHealthyiCloud.sqlite";
NSString * const kFaultyDataSource  = @"iStayHealthyNoiCloud.sqlite";
NSString * const kUbiquitousKeyPath = @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store";
NSString * const kTeamId            = @"5Y4HL833A4.com.pweschmidt.iStayHealthy";

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

- (void)storeAndContext;
- (void)selectStoreAndMigrate:(NSError *__autoreleasing *)error;
- (void)selectStoreAndMigrateInSimulator:(NSError *__autoreleasing *)error;
- (NSURL *)applicationDocumentsDirectory;
- (void)migrateMainStore;
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification;
- (BOOL)loadMainStoreLocally:(NSError *__autoreleasing *)error;
- (BOOL)loadCloudStore:(NSURL *)ubiquityContainerURL error:(NSError *__autoreleasing *)error;
- (BOOL)loadBackupStoreLocally:(NSError *__autoreleasing *)error;
- (void)addMasterRecord;
- (void)iCloudStoreChanged;
- (void)assignDataToBackupStore;

- (void)addResult:(Results *)result record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addHIVMed:(Medication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addPreviousMed:(PreviousMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addOtherMed:(OtherMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addMissedMed:(MissedMedication *)med record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addSideEffect:(SideEffects *)effect record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addContact:(Contacts *)contact record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addProcedure:(Procedures *)procedure record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;
- (void)addWellness:(Wellness *)wellness record:(iStayHealthyRecord *)record context:(NSManagedObjectContext *)context;


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
        self.ubiquityToken = nil;
        self.mainStore = nil;
        self.backupStore = nil;
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
                [self selectStoreAndMigrate:&error];
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

/**
 called from init. In here we set up the main object context using main queue as we want the
 UI to be notified of update/changes. We set up the persistent store coordinator and the store url's
 for both main store and backup store.
 We finally subscribe to be notified when changes come in through iCloud
 The merge policy is set to give priority to stored objects
 */
- (void)storeAndContext
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
    
    self.mainStoreURL           = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kMainDataSource];
    
    self.backupStoreURL   = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kBackupDataSource];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:[self.backupStoreURL path]])
    {
#ifdef APPDEBUG
        NSLog(@"***** Backupstore exists **********");
#endif
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


/*
#ifdef __IPHONE_6_0
    NSLog(@"SQLDatabaseManager::storeAndContext We are running at least version iOS 6");
    self.ubiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if (nil != self.ubiquityToken)
    {
        NSLog(@"we have iCloud enabled");
        NSData *currentTokenData = [NSKeyedArchiver archivedDataWithRootObject:self.ubiquityToken];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:currentTokenData forKey:@"com.pweschmidt.iStayHealthy.ubiquityToken"];
        [defaults synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.pweschmidt.iStayHealthy.ubiquityToken"];
    }

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(iCloudStoreChanged)
     name:NSUbiquityIdentityDidChangeNotification
     object:nil];
#endif
 */
#ifdef APPDEBUG
    NSLog(@"store URL = %@ and fallback store URL is %@", [self.mainStoreURL path], [self.backupStoreURL path]);
    NSLog(@"SQLiteHelper:setUpCoordinatorAndContext LEAVING");
#endif
    
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
    
    if (nil == store || nil != *error)
    {
        return NO;
    }
    self.mainStore = store;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"Local MAIN store should have been created successfully");
    }];
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
    
    if (nil == store || nil != *error)
    {
        return NO;
    }
    self.backupStore = store;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"BACKUP store should have been created successfully");
    }];
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
    
    if (nil == store || nil != *error)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"iCloud store is either NIL or we have an error message when loading the cloud store");
        }];
        return NO;
    }
    self.mainStore = store;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"iCloud store should have been created successfully");
    }];
    return YES;
}

/**
 this gets run only when we are in Simulator mode
 */
- (void)selectStoreAndMigrateInSimulator:(NSError *__autoreleasing *)error
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
#ifdef APPDEBUG
        NSLog(@"selectStoreAndMigrateInSimulator ENTERING");
#endif
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
        [self addMasterRecord];
        if (MIGRATE_STORE_FOR_SIMULATOR && !USE_BACKUP_STORE)
        {
            [self migrateMainStore];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"posting a reload notification");
            
            NSNotification* refreshNotification =
            [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                          object:self
                                        userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
            
            NSLog(@"LEAVING selectStoreAndMigrate");
        }];
    }
#ifdef APPDEBUG
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"we failed to load the store. Error message is %@ with code %d", [*error localizedDescription], [*error code]);
        }];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"selectStoreAndMigrateInSimulator LEAVING");        
    }];
#endif
    
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
#ifdef APPDEBUG
        NSLog(@"selectStoreAndMigrate ENTERING");
#endif
        NSNotification* animateNotification = [NSNotification
                                           notificationWithName:@"startAnimation"
                                           object:self
                                           userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:animateNotification];
    }];
    BOOL storeLoadingSuccess = NO;
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
            
            [self addMasterRecord];
            
//            [self migrateMainStore];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"posting a reload notification and USING iCloud");
                NSNotification* refreshNotification =
                [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                              object:self
                                            userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
//                [self migrateMainStore];
                [self assignDataToBackupStore];
                NSLog(@"LEAVING selectStoreAndMigrate");
            }];
        }
        else
        {
            shouldUseLocalStore = YES;
        }
    }
    else
    {
        shouldUseLocalStore = YES;
    }
    
    if (shouldUseLocalStore)
    {
        storeLoadingSuccess = NO;
        if (self.backupStoreExists)
        {
#ifdef APPDEBUG
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"selectStoreAndMigrate we are using the BACKUP store locally");
            }];
#endif
            
            storeLoadingSuccess = [self loadBackupStoreLocally:error];
        }
        else
        {
#ifdef APPDEBUG
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"selectStoreAndMigrate we are using the MAIN store locally");
            }];
#endif
            storeLoadingSuccess = [self loadMainStoreLocally:error];
        }
        if (storeLoadingSuccess)
        {
#ifdef APPDEBUG
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"selectStoreAndMigrate we succeeded loading the store");
            }];
#endif
            [self addMasterRecord];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"posting a reload notification NOT using iCloud store");
                
                NSNotification* refreshNotification =
                [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                              object:self
                                            userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
                
                NSLog(@"LEAVING selectStoreAndMigrate");
                
            }];
        }
        else
        {
#ifdef APPDEBUG
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"selectStoreAndMigrate we failed loading the store locally. Error code is %@ and code is %d", [*error localizedDescription], [*error code]);
            }];
#endif
        }
        
    }
    

}

/**
 */
- (void)migrateMainStore
{
#ifdef APPDEBUG
    NSLog(@"migrateMainStore ENTERING");
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    }];
#endif
    
    if (nil == self.mainStore)
    {
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"migrateMainStore the mainstore is NIL - and we return straight away");
        }];
#endif
        return;
    }
    
#ifdef APPDEBUG
#endif
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    }];
    
    NSLog(@"migrateMainStore we are trying to migrate the store");
    [self.mainQueue addOperationWithBlock:^{
        NSURL *modelURL = [[NSBundle mainBundle]
                           URLForResource:@"iStayHealthy"
                           withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc]
                                       initWithContentsOfURL:modelURL];
        NSError *modelError = nil;
        NSMappingModel *mappingModel = [NSMappingModel inferredMappingModelForSourceModel:model destinationModel:model error:&modelError];
        
        if (nil == mappingModel)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"mapping returns an error with %@ and code %d", [modelError localizedDescription], [modelError code]);
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"Mapping was successful");
            }];
            
        }
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]
                                             initWithManagedObjectModel:model];
        NSDictionary *backupOptions = @{ NSReadOnlyPersistentStoreOption : [NSNumber numberWithBool:YES] };
        NSError *error = nil;
        NSPersistentStore *mainStore = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:self.mainStoreURL
                                                               options:backupOptions
                                                                 error:&error];
        
        if (self.backupStoreExists)
        {
            NSError *deleteError = nil;
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            [fileManager removeItemAtPath:[self.backupStoreURL path] error:&deleteError];
            if (nil == deleteError)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"the deletion of the backupstore was successful");
                }];
            }
            else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"the deletion of the backupstore failed with error message %@ and code %d", [deleteError localizedDescription], [deleteError code]);
                }];
            }
        }
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"We are in the background thread migrating the store");
        }];
        
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        NSError *migrationError = nil;
        __block NSError *internalError = nil;
        [fileCoordinator coordinateReadingItemAtURL:self.mainStoreURL options:NSFileCoordinatorReadingWithoutChanges error:&migrationError byAccessor:^(NSURL *newURL){
            if (mappingModel)
            {
                NSDictionary *dbStoreOptions = [NSDictionary
                                                dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                                NSMigratePersistentStoresAutomaticallyOption,
                                                [NSNumber numberWithBool:YES],
                                                NSInferMappingModelAutomaticallyOption, nil];
                NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:model destinationModel:model];
                BOOL success = [migrationManager migrateStoreFromURL:self.mainStoreURL type:NSSQLiteStoreType options:backupOptions withMappingModel:mappingModel toDestinationURL:self.backupStoreURL destinationType:NSSQLiteStoreType destinationOptions:dbStoreOptions error:&internalError];
            }
            /*
            [psc migratePersistentStore:mainStore
                                  toURL:self.backupStoreURL
                                options:nil
                               withType:NSSQLiteStoreType
                                  error:&internalError];
             */
        }];
        
        if (nil == internalError)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"the migration was successful");
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"the migration failed with error message %@ and code %d", [error localizedDescription], [error code]);
            }];
        }
        
        
    }];
    
    
#ifdef APPDEBUG
    NSLog(@"migrateMainStore LEAVING");
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    }];
#endif
    
}

- (void)assignDataToBackupStore
{
    [self.mainQueue addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"assignDataToBackupStore ENTERING");
        }];
        if (self.backupStoreExists)
        {
            NSError *deleteError = nil;
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            [fileManager removeItemAtPath:[self.backupStoreURL path] error:&deleteError];
            if (nil == deleteError)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"the deletion of the backupstore was successful");
                }];
            }
            else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"the deletion of the backupstore failed with error message %@ and code %d", [deleteError localizedDescription], [deleteError code]);
                }];
            }
        }
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"assignDataToBackupStore about to create the temp stores");
        }];
        NSError *error = nil;
        NSURL *modelURL = [[NSBundle mainBundle]
                           URLForResource:@"iStayHealthy"
                           withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc]
                                       initWithContentsOfURL:modelURL];

        NSPersistentStoreCoordinator *mainPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSDictionary *seedStoreOptions = @{ NSReadOnlyPersistentStoreOption : [NSNumber numberWithBool:YES] };
        NSPersistentStore *mainStore = [mainPSC addPersistentStoreWithType:NSSQLiteStoreType
                                                             configuration:nil
                                                                       URL:self.mainStoreURL
                                                                   options:seedStoreOptions
                                                                     error:&error];
        
        
        NSPersistentStoreCoordinator *backupPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSDictionary *dbStoreOptions = [NSDictionary
                                        dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                        NSMigratePersistentStoresAutomaticallyOption,
                                        [NSNumber numberWithBool:YES],
                                        NSInferMappingModelAutomaticallyOption, nil];
        
        NSPersistentStore *backupStore = [backupPSC addPersistentStoreWithType:NSSQLiteStoreType
                                                               configuration:nil
                                                                         URL:self.backupStoreURL
                                                                     options:dbStoreOptions
                                                                       error:&error];
        
        if (mainStore && backupStore)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"assignDataToBackupStore successfully created the temp stores");
            }];
            NSManagedObjectContext *seedMOC = [[NSManagedObjectContext alloc] init];
            [seedMOC setPersistentStoreCoordinator:mainPSC];
            NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"iStayHealthyRecord"];
//            NSUInteger batchSize = 5000;
//            [fr setFetchBatchSize:batchSize];
            NSArray *records = [seedMOC executeFetchRequest:fr error:&error];

            NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [moc setPersistentStoreCoordinator:backupPSC];
            if (records)
            {
                if (0 < records.count)
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSLog(@"assignDataToBackupStore about to seed the backup store. We have %d records in the system", records.count);
                    }];
                    iStayHealthyRecord *record = (iStayHealthyRecord *)[records lastObject];
                    NSEntityDescription *newEntity = [record entity];
                    iStayHealthyRecord *newMasterRecord = [[iStayHealthyRecord alloc] initWithEntity:newEntity insertIntoManagedObjectContext:moc];
                    newMasterRecord.Name = record.Name;
                    newMasterRecord.isPasswordEnabled = record.isPasswordEnabled;
                    newMasterRecord.Password = record.Password;
                    newMasterRecord.UID = record.UID;
                    for (Contacts *contacts in record.contacts)
                    {
                        [self addContact:contacts record:newMasterRecord context:moc];
                    }
                    for (Results *results in record.results)
                    {
                        [self addResult:results record:newMasterRecord context:moc];
                    }
                    for (MissedMedication *missed in record.missedMedications)
                    {
                        [self addMissedMed:missed record:newMasterRecord context:moc];
                    }
                    for (Medication *med in record.medications)
                    {
                        [self addHIVMed:med record:newMasterRecord context:moc];
                    }
                    for (OtherMedication *med in record.otherMedications)
                    {
                        [self addOtherMed:med record:newMasterRecord context:moc];
                    }
                    for (PreviousMedication *med in record.previousMedications)
                    {
                        [self addPreviousMed:med record:newMasterRecord context:moc];
                    }
                    for (SideEffects *effects in record.sideeffects)
                    {
                        [self addSideEffect:effects record:newMasterRecord context:moc];
                    }
                    for (Procedures *procs in record.procedures)
                    {
                        [self addProcedure:procs record:newMasterRecord context:moc];
                    }
                    for (Wellness *well in record.wellness)
                    {
                        [self addWellness:well record:newMasterRecord context:moc];
                    }
                    [moc assignObject:newMasterRecord toPersistentStore:backupStore];
                    BOOL success = [moc save:&error];
                    if (success)
                    {
                        [moc reset];
                    }
                }
                if ([moc hasChanges])
                {
                    BOOL success = [moc save:&error];
                    if (success)
                    {
                        [moc reset];
                    }                
                }
            }
        }
    }];
    
}



/**
 */
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
#ifdef APPDEBUG
                NSLog(@"SQLiteHelper:addMasterRecordWithObjectContext we could not save a master Record to the store");
#endif
            }
            
        }
    }
    
}

- (void)iCloudStoreChanged
{
    
}

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
