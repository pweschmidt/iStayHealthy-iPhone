//
//  SQLiteHelper.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/09/2012.
//
//

#import "SQLiteHelper.h"
#import "Utilities.h"

NSString * const kSQLiteiCloudStore = @"iStayHealthy.sqlite";
NSString * const kSQLiteNoiCloudStore = @"iStayHealthyNoiCloud.sqlite";


@interface SQLiteHelper ()
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext * mainObjectContext;
@property (nonatomic, strong, readwrite) NSURL * storeURL;
@property (nonatomic, strong, readwrite) NSURL * noiCloudStoreURL;
@property (nonatomic, strong, readwrite) NSOperationQueue * mainQueue;
@property (nonatomic, strong, readwrite) NSLock * universalLock;
@property (nonatomic, strong, readwrite) id currentUbiquityToken;
- (void)setUpCoordinatorAndContext;
- (BOOL)loadLocalSQLiteStore:(NSError *__autoreleasing *)error;
- (BOOL)loadSQLiteStoreFromiCloud:(NSError *__autoreleasing *)error;
- (NSURL *)applicationDocumentsDirectory;
@end


@implementation SQLiteHelper
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize storeURL = _storeURL;
@synthesize mainQueue = _mainQueue;
@synthesize universalLock = _universalLock;
@synthesize noiCloudStoreURL = _noiCloudStoreURL;
@synthesize currentUbiquityToken = _currentUbiquityToken;


- (id)init
{
    self = [super init];
    if (nil != self)
    {
        self.mainQueue = [[NSOperationQueue alloc] init];
        self.universalLock = [[NSLock alloc] init];
        [self setUpCoordinatorAndContext];
    }
    return self;
}


- (void)loadSQLitePersistentStore
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:loadSQLitePersistentStore ENTERING");
#endif
    __weak SQLiteHelper *weakSelf = self;
    [self.mainQueue addOperationWithBlock:^{
        BOOL locked = NO;
        @try
        {
            [weakSelf.universalLock lock];
            locked = YES;
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
            if (locked)
            {
                [weakSelf.universalLock unlock];
                locked = NO;
            }
        }
        
    }];
    
}


#pragma mark - private methods


- (void)setUpCoordinatorAndContext
{
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:setUpCoordinatorAndContext ENTERING");
#endif
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    self.mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];

    self.storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSQLiteiCloudStore];

    self.noiCloudStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSQLiteNoiCloudStore];
#ifdef APPDEBUG
    NSLog(@"store URL = %@ and fallback store URL is %@", [self.storeURL path], [self.noiCloudStoreURL path]);
#endif

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        self.currentUbiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    }
#ifdef APPDEBUG
    NSLog(@"SQLiteHelper:setUpCoordinatorAndContext LEAVING");
#endif
}

- (BOOL)loadLocalSQLiteStore:(NSError *__autoreleasing *)error
{
#ifdef APPDEBUG
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"SQLiteHelper:loadLocalSQLiteStore ENTERING");
    }];
#endif
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSPersistentStore *localStore = [self.persistentStoreCoordinator
                                     addPersistentStoreWithType:NSSQLiteStoreType
                                     configuration:nil
                                     URL:self.storeURL
                                     options:options
                                     error:error];
    if (nil == localStore)
    {
        abort();
    }
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"SQLiteHelper:loadLocalSQLiteStore we now got the store");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
        }];
    }
    return YES;
    
}

- (BOOL)loadSQLiteStoreFromiCloud:(NSError *__autoreleasing *)error
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *ubiquityContainer = [fileManager URLForUbiquityContainerIdentifier:nil];
    if (nil == ubiquityContainer)
    {
        return [self loadLocalSQLiteStore:error];
    }
    else
    {
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
        if (nil == cloudStore)
        {
            abort();
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
            }];            
        }
        
    }
    return YES;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
