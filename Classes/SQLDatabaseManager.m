//
//  SQLDatabaseManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 20/10/2012.
//
//

#import "SQLDatabaseManager.h"
#import "Utilities.h"

NSString * const kMainDataSource = @"iStayHealthy.sqlite";
NSString * const kBackupDataSource = @"iStayHealthyBackup.sqlite";
NSString * const kFaultyDataSource = @"iStayHealthyNoiCloud.sqlite";
NSString * const kUbiquitousKeyPath = @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store";

#define MIGRATE_STORE_FOR_SIMULATOR NO
#define USE_BACKUP_STORE NO

@interface SQLDatabaseManager ()
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext * mainObjectContext;
@property (nonatomic, strong, readwrite) NSURL *mainStoreURL;
@property (nonatomic, strong, readwrite) NSURL *backupStoreURL;
@property (nonatomic, strong, readwrite) NSOperationQueue * mainQueue;
@property (nonatomic, strong, readwrite) NSLock * universalLock;
@property BOOL backupStoreExists;
@property BOOL mainStoreExists;

- (void)storeAndContext;
- (void)selectStoreAndMigrate:(NSError *__autoreleasing *)error;
- (NSURL *)applicationDocumentsDirectory;
- (void)migrateMainStore;
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification;
- (void)createMasterRecord;
@end


@implementation SQLDatabaseManager
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize mainStoreURL = _firstStoreURL;
@synthesize backupStoreURL = _secondStoreURL;
@synthesize mainQueue = _mainQueue;
@synthesize universalLock = _universalLock;
@synthesize isUsingiCloud = _isUsingiCloud;
@synthesize backupStoreExists = _backupStoreExists;
@synthesize mainStoreExists = _mainStoreExists;
/**
 */
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        self.mainQueue = [[NSOperationQueue alloc] init];
        self.universalLock = [[NSLock alloc] init];
        self.isUsingiCloud = NO;
        self.backupStoreExists = NO;
        self.mainStoreExists = NO;
        [self storeAndContext];
    }
    return self;
}

/**
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
            [self selectStoreAndMigrate:&error];
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
        NSLog(@"backupstore exists");
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
    
    
#ifdef APPDEBUG
    NSLog(@"store URL = %@ and fallback store URL is %@", [self.mainStoreURL path], [self.backupStoreURL path]);
    NSLog(@"SQLiteHelper:setUpCoordinatorAndContext LEAVING");
#endif
    
}

/**
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
    NSDictionary *dbStoreOptions = nil;
    NSURL *storeURL = nil;
    NSPersistentStore * store = nil;
    if (DEVICE_IS_SIMULATOR)
    {
        self.isUsingiCloud = NO;
        storeURL = (USE_BACKUP_STORE) ? self.backupStoreURL : self.mainStoreURL;
        dbStoreOptions = [NSDictionary
                          dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                          NSMigratePersistentStoresAutomaticallyOption,
                          [NSNumber numberWithBool:YES],
                          NSInferMappingModelAutomaticallyOption, nil];
        store = [self.persistentStoreCoordinator
                 addPersistentStoreWithType:NSSQLiteStoreType
                 configuration:nil
                 URL:storeURL
                 options:dbStoreOptions
                 error:error];
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"selectStoreAndMigrate we are using the store at location %@", [[store URL] path]);
        }];
#endif
        if (MIGRATE_STORE_FOR_SIMULATOR)
        {
            [self migrateMainStore];
        }
    }
    else
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *ubiquityContainer = [fileManager URLForUbiquityContainerIdentifier:nil];
        if (nil != ubiquityContainer)
        {
            NSString* coreDataCloudContent = [[ubiquityContainer path] stringByAppendingPathComponent:@"data"];
            
            NSURL *amendedCloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
            dbStoreOptions = [NSDictionary
                              dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              NSMigratePersistentStoresAutomaticallyOption,
                              [NSNumber numberWithBool:YES],
                              NSInferMappingModelAutomaticallyOption,
                              kUbiquitousKeyPath,
                              NSPersistentStoreUbiquitousContentNameKey,
                              amendedCloudURL,
                              NSPersistentStoreUbiquitousContentURLKey, nil];
            store = [self.persistentStoreCoordinator
                     addPersistentStoreWithType:NSSQLiteStoreType
                     configuration:nil
                     URL:self.mainStoreURL
                     options:dbStoreOptions
                     error:error];
            self.isUsingiCloud = YES;
            if (!self.backupStoreExists)
            {
                [self migrateMainStore];
            }
        }
        else
        {
            dbStoreOptions = [NSDictionary
                              dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                              NSMigratePersistentStoresAutomaticallyOption,
                              [NSNumber numberWithBool:YES],
                              NSInferMappingModelAutomaticallyOption, nil];
            storeURL = self.mainStoreURL;
            store = [self.persistentStoreCoordinator
                     addPersistentStoreWithType:NSSQLiteStoreType
                     configuration:nil
                     URL:storeURL
                     options:dbStoreOptions
                     error:error];
            self.isUsingiCloud = NO;
        }
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"selectStoreAndMigrate we are using the store at location %@", [[store URL] path]);
        }];
#endif
    }
    

    if (nil != store)
    {
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
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"selectStoreAndMigrate LEAVING");
    }];
#endif
}

/**
 */
- (void)migrateMainStore
{
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"migrateMainStore ENTERING");
    }];
#endif
    
    NSPersistentStore *mainStore = [self.persistentStoreCoordinator persistentStoreForURL:self.mainStoreURL];
    if (nil == mainStore)
    {
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"migrateMainStore the mainstore is NIL - and we return straight away");
        }];
#endif
        return;
    }
    
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"migrateMainStore we are trying to migrate the store");
        [self.mainQueue addOperationWithBlock:^{
            NSURL *modelURL = [[NSBundle mainBundle]
                               URLForResource:@"iStayHealthy"
                               withExtension:@"momd"];
            NSManagedObjectModel *model = [[NSManagedObjectModel alloc]
                                           initWithContentsOfURL:modelURL];
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
            NSDictionary *targetOptions = [NSDictionary
                                           dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                           NSMigratePersistentStoresAutomaticallyOption,
                                           [NSNumber numberWithBool:YES],
                                           NSInferMappingModelAutomaticallyOption, nil];
            
            [psc migratePersistentStore:mainStore
                                  toURL:self.backupStoreURL
                                options:targetOptions
                               withType:NSSQLiteStoreType
                                  error:&error];
            
            if (nil == error)
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
    }];
#endif
    
    
    
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"migrateMainStore LEAVING");
    }];
#endif
    
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


- (void)createMasterRecord
{
    
}


@end
