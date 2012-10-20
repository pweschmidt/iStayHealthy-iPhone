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

- (void)storeAndContext;
- (void)selectStoreAndMigrate:(NSError *__autoreleasing *)error;
- (NSURL *)applicationDocumentsDirectory;
- (void)backupMainStore:(NSPersistentStore *)mainStore;
- (void)recoverFromBackupStore:(NSPersistentStore *)backupStore;
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification;
- (void)removeFaultyDataSource;
- (void)removeBackupStore;
@end


@implementation SQLDatabaseManager
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize mainStoreURL = _firstStoreURL;
@synthesize backupStoreURL = _secondStoreURL;
@synthesize mainQueue = _mainQueue;
@synthesize universalLock = _universalLock;
@synthesize isUsingiCloud = _isUsingiCloud;
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        self.mainQueue = [[NSOperationQueue alloc] init];
        self.universalLock = [[NSLock alloc] init];
        self.isUsingiCloud = NO;
        [self storeAndContext];
    }
    return self;
}

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
    
/*
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:[self.backupStoreURL path]])
    {
        NSError *error = nil;
        NSDictionary *targetOptions = [NSDictionary
                                       dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                       NSMigratePersistentStoresAutomaticallyOption,
                                       [NSNumber numberWithBool:YES],
                                       NSInferMappingModelAutomaticallyOption, nil];
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        [context setPersistentStoreCoordinator:coordinator];
        [context setMergePolicy:policy];
        [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.backupStoreURL options:targetOptions error:&error];
        
    }
*/
    
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
    NSFileManager *fileManager = [[NSFileManager alloc] init];
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
            [self backupMainStore:store];
        }
    }
    else
    {
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
            if (![fileManager fileExistsAtPath:[self.backupStoreURL path]])
            {
                [self backupMainStore:store];
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
    [self removeFaultyDataSource];
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"selectStoreAndMigrate LEAVING");
    }];
#endif
}

- (void)backupMainStore:(NSPersistentStore *)mainStore
{
    if (nil == mainStore)
    {
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"backupMainStore mainStore is NIL");
        }];
#endif
        return;
    }
    NSString *path = [[mainStore URL] path];
    if ([path isEqualToString:[self.backupStoreURL path]])
    {
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"backupMainStore mainStore has same URL as backupstore. store shouldn't migrate onto itself.");
        }];
#endif
        return;
    }
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"backupMainStore ENTERING");
    }];
#endif
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:[self.backupStoreURL path]])
    {
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"backupMainStore we already have a backup store. Remove the existing store, so we migrate to a fresh copy");
        }];
#endif
        return;
    }
    else
    {
#ifdef APPDEBUG
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"backupMainStore we DO NOT have a backup store yet");
        }];
#endif
        
    }
    
    NSError *error = nil;
    NSDictionary *targetOptions = [NSDictionary
                                   dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                   NSMigratePersistentStoresAutomaticallyOption,
                                   [NSNumber numberWithBool:YES],
                                   NSInferMappingModelAutomaticallyOption, nil];
    
    [self.persistentStoreCoordinator migratePersistentStore:mainStore
                                                      toURL:self.backupStoreURL
                                                    options:targetOptions
                                                   withType:NSSQLiteStoreType
                                                      error:&error];
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"backupMainStore LEAVING");
    }];
#endif
}


- (void)removeBackupStore
{
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"removeBackupStore ENTERING");
    }];
#endif
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:[self.backupStoreURL path]])
    {
        [fileManager removeItemAtPath:[self.backupStoreURL path] error:&error];
    }
    
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"backupMainStore LEAVING");
    }];
#endif
    
}


- (void)recoverFromBackupStore:(NSPersistentStore *)backupStore
{
    
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


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

/**
 version 3.2.1 introduced a faulty store which caused crashes. Remove from the document folder
 if present
 */
- (void)removeFaultyDataSource
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:removeFaultyDataSource ENTERING");
#endif
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *faultyURL = [[self applicationDocumentsDirectory]
                        URLByAppendingPathComponent:kFaultyDataSource];
    if ([fileManager fileExistsAtPath:[faultyURL path]])
    {
#ifdef APPDEBUG
        NSLog(@"SQLiteHelper:removeFaultyDataSource deleting faulty store");
#endif
        NSError *error = nil;
        [fileManager removeItemAtPath:[faultyURL path] error:&error];
        
#ifdef APPDEBUG
        if (nil != error)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"error in deleting file at path %@", [faultyURL path]);
            }];
        }
#endif
    }
#ifdef APPDEBUG
    else
    {
        NSLog(@"SQLiteHelper:removeFaultyDataSource faulty store is not there");        
    }
    NSLog(@"SQLiteHelper:removeFaultyDataSource LEAVING");
#endif
    
}


@end
