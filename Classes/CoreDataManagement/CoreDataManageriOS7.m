//
//  CoreDataManageriOS7.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import "CoreDataManageriOS7.h"
#import "CoreDataConstants.h"
#import "CoreDataUtils.h"

@interface CoreDataManageriOS7 ()
{
    NSManagedObjectContext * privateContext;
    dispatch_queue_t storeQueue;
}
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@end


@implementation CoreDataManageriOS7

- (void)dealloc
{
    self.storeIsReady = NO;
    self.hasDataForImport = NO;
    [self unregisterObservers];
}


- (void)setUpCoreDataManager
{
    NSLog(@"setUpCoreDataManager iOS7");
    self.storeIsReady = NO;
    self.hasDataForImport = NO;
    NSMergePolicy *policy = [[NSMergePolicy alloc]
                             initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
    
    NSURL *modelURL = [[NSBundle mainBundle]
                       URLForResource:@"iStayHealthy"
                       withExtension:@"momd"];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc]
                                   initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]
                                         initWithManagedObjectModel:model];
    
    
    NSUInteger type = NSPrivateQueueConcurrencyType;
    privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    [privateContext setPersistentStoreCoordinator:psc];
    [privateContext setMergePolicy:policy];
    
    type = NSMainQueueConcurrencyType;
    NSManagedObjectContext *mainContext = [[NSManagedObjectContext alloc]
                                           initWithConcurrencyType:type];
    
    [mainContext setParentContext:privateContext];
    [self setDefaultContext:mainContext];
    self.iCloudIsAvailable = ( nil != [[NSFileManager defaultManager] ubiquityIdentityToken]);
    self.persistentStoreCoordinator = psc;
    storeQueue = dispatch_queue_create(kBackgroundQueueName, NULL);
    [self registerObservers];
}

- (void)setUpStoreWithError:(iStayHealthyErrorBlock)error
{
    dispatch_async(storeQueue, ^{
        NSFileManager * defaultManager = [NSFileManager defaultManager];
        
        NSURL * mainURL = [[self applicationDocumentsDirectory]
                           URLByAppendingPathComponent:kPersistentMainStore];
        NSURL * fallbackURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kPersistentFallbackStore];
        
        
        BOOL hasFallbackStore = [defaultManager
                                 fileExistsAtPath:[fallbackURL absoluteString]];
        
        NSDictionary *iCloudOptions = [CoreDataUtils iCloudStoreOptions];
        NSDictionary *defaultStoreOptions = [CoreDataUtils localStoreOptions];
        
        BOOL iCloudEnabled = (nil != iCloudOptions);
        id token = [defaultManager ubiquityIdentityToken];
        BOOL iCloudAvailable = (nil != token);
        
        NSURL * whichStoreURL = nil;
        NSDictionary * whichOptions = nil;
        
        if (iCloudEnabled)
        {
            if (iCloudAvailable)
            {
                whichOptions = iCloudOptions;
                whichStoreURL = mainURL;
            }
            else
            {
                whichOptions = defaultStoreOptions;
                whichStoreURL = fallbackURL;
            }
        }
        else
        {
            whichOptions = defaultStoreOptions;
            if (hasFallbackStore)
            {
                whichStoreURL = fallbackURL;
            }
            else
            {
                whichStoreURL = mainURL;
            }
        }
        
        if (nil == whichOptions)
        {
            whichOptions = defaultStoreOptions;
        }
        if (nil == whichStoreURL)
        {
            whichStoreURL = mainURL;
        }
        NSError * creationError = nil;
        NSPersistentStore * createdStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:whichStoreURL options:whichOptions error:&creationError];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil == createdStore)
            {
                if (error)
                {
                    error(creationError);
                }
            }
            else
            {
                if (error)
                {
                    error(nil);
                }
                NSNotification * notification = [NSNotification
                                                 notificationWithName:kLoadedStoreNotificationKey
                                                 object:self];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        });
        
    });
}

- (void)saveContextAndWait:(NSError **)error
{
    [self saveContext:YES error:error];
}

- (void)saveContext:(NSError **)error
{
    [self saveContext:NO error:error];
}

- (void)fetchDataForEntityName:(NSString *)entityName
                     predicate:(NSPredicate *)predicate
                      sortTerm:(NSString *)sortTerm
                     ascending:(BOOL)ascending
                    completion:(iStayHealthyArrayCompletionBlock)completion
{
    NSManagedObjectContext *context = self.defaultContext;
    if (nil == context)
    {
        return;
    }
    if (nil == completion || nil == entityName)
    {
        return;
    }
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:self.defaultContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    if (nil != predicate)
    {
        [request setPredicate:predicate];
    }
    if (nil != sortTerm)
    {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]
                                        initWithKey:sortTerm
                                        ascending:ascending];
        [request setSortDescriptors:@[descriptor]];
    }
    
    [context performBlock:^{
        [privateContext performBlockAndWait:^{
            NSError * error = nil;
            NSArray * results = nil;
            results = [context executeFetchRequest:request error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (nil == results)
                {
                    completion(nil, error);
                }
                else
                {
                    completion(results, nil);
                }
            });
        }];
    }];
}

#pragma mark - private
- (void)importWhenReady:(NSNotification *)notification
{
    
}

- (void)mergeFromiCloud:(NSNotification *)notification
{
    NSManagedObjectContext * context = self.defaultContext;
    if (nil == context || nil == privateContext || nil == notification)
    {
        return;
    }
    [context performBlock:^{
        [privateContext performBlockAndWait:^{
            [privateContext mergeChangesFromContextDidSaveNotification:notification];
            [privateContext processPendingChanges];
        }];
    }];
}


- (void)saveContext:(BOOL)wait error:(NSError **)error
{
    NSManagedObjectContext *context = self.defaultContext;
    if (nil == context)
    {
        return;
    }
    if ([context hasChanges])
    {
        [context performBlockAndWait:^{
            [context save:error];
        }];
    }
    
    void (^savePrivateContext) (void) = ^{[privateContext save:error];};
    
    if ([privateContext hasChanges])
    {
        if (wait)
        {
            [privateContext performBlockAndWait:savePrivateContext];
        }
        else
        {
            [privateContext performBlock:savePrivateContext];
        }
    }
    
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(mergeFromiCloud:)
     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(iCloudStoreChanged:)
     name:NSUbiquityIdentityDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(importWhenReady:)
     name:kImportedDataAvailableKey
     object:nil];
    
    
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSUbiquityIdentityDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:kImportedDataAvailableKey
     object:nil];
    
}


@end
