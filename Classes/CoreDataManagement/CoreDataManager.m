//
//  CoreDataManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/08/2013.
//
//

#import "CoreDataManager.h"
#import "CoreDataUtils.h"
#import "CoreDataConstants.h"
#import "CoreXMLReader.h"
#import "iStayHealthyRecord+Handling.h"
@interface CoreDataManager ()
{
    NSManagedObjectContext *privateContext;
    dispatch_queue_t storeQueue;
}
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)unregisterObservers;
- (void)registerObservers;
- (void)mergeFromiCloud:(NSNotification *)notification;
- (BOOL)saveContext:(BOOL)wait error:(NSError **)error;
@end

@implementation CoreDataManager
+ (CoreDataManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static CoreDataManager *manager = nil;

    dispatch_once(&onceToken, ^{
                      manager = [[self alloc] init];
                  });
    return manager;
}

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
    self.iCloudIsAvailable = (nil != [[NSFileManager defaultManager] ubiquityIdentityToken]);
    self.persistentStoreCoordinator = psc;
    storeQueue = dispatch_queue_create(kBackgroundQueueName, NULL);
    [self registerObservers];
}

- (void)setUpStoreWithError:(iStayHealthyErrorBlock)error
{
    dispatch_async(storeQueue, ^{
                       NSFileManager *defaultManager = [NSFileManager defaultManager];

                       NSURL *mainURL = [[self applicationDocumentsDirectory]
                                         URLByAppendingPathComponent:kPersistentMainStore];
                       NSURL *fallbackURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kPersistentFallbackStore];


                       BOOL hasFallbackStore = [defaultManager
                                                fileExistsAtPath:[fallbackURL absoluteString]];

                       NSDictionary *iCloudOptions = [CoreDataUtils iCloudStoreOptions];
                       NSDictionary *defaultStoreOptions = [CoreDataUtils localStoreOptions];

                       BOOL iCloudEnabled = (nil != iCloudOptions);
                       id token = [defaultManager ubiquityIdentityToken];
                       BOOL iCloudAvailable = (nil != token);

                       NSURL *whichStoreURL = nil;
                       NSDictionary *whichOptions = nil;

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
                       NSError *creationError = nil;
                       NSPersistentStore *createdStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:whichStoreURL options:whichOptions error:&creationError];
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
                                              NSNotification *notification = [NSNotification
                                                                              notificationWithName:kLoadedStoreNotificationKey
                                                                                            object:self];
                                              [[NSNotificationCenter defaultCenter] postNotification:notification];
                                          }
                                      });
                   });
}

- (BOOL)saveContextAndWait:(NSError **)error
{
    [self saveContext:YES error:error];
    if (NULL != error)
    {
        if (nil != *error)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return YES;
    }
}

- (BOOL)saveContext:(NSError **)error
{
    return [self saveContext:NO error:error];
}

- (void)fetchiStayHealthyRecordWithCompletion:(iStayHealthyRecordCompletionBlock)completion
{
    [self fetchDataForEntityName:kiStayHealthyRecord predicate:nil sortTerm:nil ascending:NO completion: ^(NSArray *array, NSError *error) {
         if (nil == array)
         {
             completion(nil, error);
         }
         else if (0 == array.count)
         {
             NSError *error = [NSError errorWithDomain:@"com.pweschmidt.istayhealthy" code:100 userInfo:nil];
             completion(nil, error);
         }
         else
         {
             iStayHealthyRecord *lastRecord = (iStayHealthyRecord *) [array lastObject];
             completion(lastRecord, nil);
         }
     }];
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
                                   inManagedObjectContext:context];
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

    [context performBlock: ^{
         NSError *error = nil;
         NSArray *fetchedObjects = nil;
         fetchedObjects = [context executeFetchRequest:request error:&error];
         dispatch_async(dispatch_get_main_queue(), ^{
                            if (nil == fetchedObjects)
                            {
                                completion(nil, error);
                            }
                            else
                            {
                                completion(fetchedObjects, nil);
                            }
                        });
     }];
}

- (void)mergeFromiCloud:(NSNotification *)notification
{
    NSManagedObjectContext *context = self.defaultContext;

    if (nil == context || nil == notification)
    {
        return;
    }
    [context performBlockAndWait:^{
         [context mergeChangesFromContextDidSaveNotification:notification];
         [context processPendingChanges];
     }];
//	[context performBlock: ^{
//	    [privateContext performBlockAndWait: ^{
//	        [privateContext mergeChangesFromContextDidSaveNotification:notification];
//	        [privateContext processPendingChanges];
//		}];
//	}];
}

- (BOOL)saveContext:(BOOL)wait error:(NSError **)error
{
    NSManagedObjectContext *context = self.defaultContext;

    if (nil == context)
    {
        return NO;
    }
    if ([context hasChanges])
    {
        [context performBlockAndWait: ^{
             [context save:error];
         }];
    }

    void (^ savePrivateContext) (void) = ^{ [privateContext save:error]; };

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
    return YES;
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

#pragma mark - implemented methods

- (id)managedObjectForEntityName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName
                                         inManagedObjectContext:self.defaultContext];
}

- (NSDictionary *)attributesForEntityName:(NSString *)entityName
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
                                                         inManagedObjectContext:self.defaultContext];
    NSDictionary *attributes = [entityDescription attributesByName];

    return attributes;
}

- (BOOL)addFileToImportList:(NSURL *)sourceURL error:(NSError **)error
{
    if (nil == sourceURL)
    {
        return NO;
    }
    NSString *dstPath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), [sourceURL lastPathComponent]];
    NSString *sourcePath = [sourceURL absoluteString];
    [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:dstPath error:error];
    if (nil == error && [[NSFileManager defaultManager] fileExistsAtPath:dstPath])
    {
        NSData *xmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dstPath]];
        NSDictionary *importData = @{ kImportedDataFromFileKey : xmlData,
                                      kTmpFileKey : dstPath };
        self.hasDataForImport = YES;
        NSNotification *notification = [NSNotification
                                        notificationWithName:kImportedDataAvailableKey
                                                      object:self
                                                    userInfo:importData];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
                    inDomains:NSUserDomainMask] lastObject];
}

- (void)iCloudStoreChanged:(NSNotification *)notification
{
    id currentToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    id formerToken = [CoreDataUtils ubiquityTokenFromArchive];

    if (![formerToken isEqual:currentToken])
    {
        [CoreDataUtils dropUbiquityToken];
        [CoreDataUtils archiveUbiquityToken:currentToken];
    }
}

- (void)importWhenReady:(NSNotification *)notification
{
    if (nil == notification)
    {
        return;
    }
    NSString *tmpFilePath = [notification.userInfo objectForKey:kTmpFileKey];
    NSData *xmlData = [notification.userInfo objectForKey:kImportedDataAvailableKey];
    self.hasDataForImport = YES;
    self.xmlTmpPath = tmpFilePath;
    self.xmlImportData = xmlData;
    if (self.storeIsReady)
    {
        [self importWithData];
    }
}

- (void)importWithData
{
    if (nil == self.xmlImportData || nil == self.xmlTmpPath)
    {
        return;
    }
    [[CoreXMLReader sharedInstance] parseXMLData:self.xmlImportData];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.xmlTmpPath])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.xmlTmpPath error:&error];
    }
    self.hasDataForImport = NO;
    self.xmlTmpPath = nil;
    self.xmlImportData = nil;
}

@end
