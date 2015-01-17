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
#import "CoreXMLWriter.h"
#import "AppSettings.h"

@interface CoreDataManager ()
{
	NSManagedObjectContext *privateContext;
	dispatch_queue_t storeQueue;
}
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSData *importedXMLData;
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

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		storeQueue = dispatch_queue_create(kBackgroundQueueName, NULL);
		_importedXMLData = nil;
		_importedFilePath = nil;
	}
	return self;
}

- (void)dealloc
{
	self.storeIsReady = NO;
	self.hasDataForImport = NO;
	[self unregisterObservers];
}

- (void)parseStorageContainersWithCompletionBlock:(iStayHealthyArrayCompletionBlock)completionBlock
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    dispatch_async(storeQueue, ^{
        NSURL *ubiquityURL = [defaultManager URLForUbiquityContainerIdentifier:kTeamId];
        NSURL *documentURL = [self applicationDocumentsDirectory];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"ubiquityURL is %@", ubiquityURL);
            NSLog(@"document lib is %@", documentURL);
        });
        
    });
    
}


- (void)setUpCoreDataManager
{
#ifdef APPDEBUG
	NSLog(@"setUpCoreDataManager iOS7");
#endif
	self.storeIsReady = NO;
	self.hasDataForImport = NO;
	[self registerObservers];

	NSURL *modelURL = [[NSBundle mainBundle]
	                   URLForResource:@"iStayHealthy"
	                    withExtension:@"momd"];

	NSManagedObjectModel *model = [[NSManagedObjectModel alloc]
	                               initWithContentsOfURL:modelURL];

	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]
	                                     initWithManagedObjectModel:model];

	self.persistentStoreCoordinator = psc;

	[self setUpContextsForCoordinator];
}

- (void)setUpContextsForCoordinator
{
	NSMergePolicy *policy = [[NSMergePolicy alloc]
	                         initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
	privateContext = [[NSManagedObjectContext alloc]
	                  initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	[privateContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	[privateContext setMergePolicy:policy];

	NSManagedObjectContext *mainContext = [[NSManagedObjectContext alloc]
	                                       initWithConcurrencyType:NSMainQueueConcurrencyType];
    mainContext.parentContext = privateContext;
    self.defaultContext = mainContext;
}

- (BOOL)setUpStoreAsLocalStoreWithError:(NSError **)error
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSDictionary *noniCloudOptions = [CoreDataUtils noiCloudStoreOptions];
    
    NSURL *mainURL = [[self applicationDocumentsDirectory]
                      URLByAppendingPathComponent:kPersistentMainStore];
    BOOL hasStore = [defaultManager fileExistsAtPath:[mainURL path]];
    
    if (!hasStore)
    {
            //for newly created stores always take local store options
        noniCloudOptions = [CoreDataUtils localStoreOptions];
    }
    
    NSPersistentStore *createdStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:mainURL
                                                                       options:noniCloudOptions
                                                                         error:error];
    
    BOOL success = (nil != createdStore);
    if (success)
    {
        NSNotification *notification = [NSNotification
                                        notificationWithName:kLoadedStoreNotificationKey
                                        object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return success;
}

- (void)setUpStoreAsiCloudStoreWithCompletionBlock:(iStayHealthySuccessBlock)completionBlock
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    
    NSURL *mainURL = [[self applicationDocumentsDirectory]
                      URLByAppendingPathComponent:kPersistentMainStore];
    BOOL hasStore = [defaultManager fileExistsAtPath:[mainURL path]];
    if (!hasStore)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"iCloud is no longer supported for newly created stores"};
        NSError *error = [NSError errorWithDomain:@"com.iStayHealthy" code:3001 userInfo:userInfo];
        if (nil != completionBlock)
        {
            completionBlock(NO, error);
        }
        return;
    }
    
    
    dispatch_async(storeQueue, ^{
        NSDictionary *iCloudOptions = [CoreDataUtils iCloudStoreOptions];
        
        
        if (self.iCloudEnabled && self.iCloudIsAvailable)
        {
            NSError *creationError = nil;
            NSPersistentStore *createdStore = [self.persistentStoreCoordinator
                                               persistentStoreForURL:mainURL];
            if (nil == createdStore)
            {
                createdStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:mainURL options:iCloudOptions error:&creationError];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (nil != createdStore)
                {
                    if (nil != completionBlock)
                    {
                        completionBlock(NO, creationError);
                    }
                }
                else
                {
                    if (nil != completionBlock)
                    {
                        completionBlock(YES, nil);
                    }
                    NSNotification *notification = [NSNotification
                                                    notificationWithName:kLoadedStoreNotificationKey
                                                    object:self];
                    [[NSNotificationCenter defaultCenter] postNotification:notification];
                
                }
            });
        }
    });
}


- (void)setUpStoreWithError:(iStayHealthyErrorBlock)error
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *storeLoadedNumber = [defaults objectForKey:kStoreLoadingKey];
	__block int storeLoaded = (nil != storeLoadedNumber) ? [storeLoadedNumber intValue] : -1;
	__block BOOL isUsingiCloud = NO;

	dispatch_async(storeQueue, ^{
	    NSFileManager *defaultManager = [NSFileManager defaultManager];

	    NSURL *mainURL = [[self applicationDocumentsDirectory]
	                      URLByAppendingPathComponent:kPersistentMainStore];
	    NSURL *fallbackURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kPersistentFallbackStore];


	    BOOL hasFallbackStore = [defaultManager
	                             fileExistsAtPath:[fallbackURL absoluteString]];


	    NSDictionary *iCloudOptions = [CoreDataUtils iCloudStoreOptions];
	    NSDictionary *noniCloudOptions = [CoreDataUtils noiCloudStoreOptions];
	    NSDictionary *defaultStoreOptions = [CoreDataUtils localStoreOptions];

	    NSURL *whichStoreURL = nil;
	    NSDictionary *whichOptions = nil;


	    if (self.iCloudEnabled)
	    {
	        if (self.iCloudIsAvailable)
	        {
	            whichOptions = iCloudOptions;
	            whichStoreURL = mainURL;
	            storeLoaded = MainStoreWithiCloud;
	            isUsingiCloud = YES;
			}
	        else
	        {
	            whichOptions = defaultStoreOptions;
	            whichStoreURL = fallbackURL;
	            storeLoaded = FallbackStore;
			}
		}
	    else
	    {
	        whichOptions = defaultStoreOptions;
	        storeLoaded = FallbackStore;
	        if (hasFallbackStore)
	        {
	            whichStoreURL = fallbackURL;
			}
	        else
	        {
	            whichOptions = noniCloudOptions;
	            storeLoaded = MainStoreWithoutiCloud;
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
	    NSPersistentStore *createdStore = [self.persistentStoreCoordinator
	                                       persistentStoreForURL:whichStoreURL];
	    if (nil == createdStore)
	    {
	        createdStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:whichStoreURL options:whichOptions error:&creationError];
		}

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
//	            NSDictionary *metadata = [createdStore metadata];
	            self.storeIsReady = YES;
	            NSURL *storeURL = [createdStore URL];
	            if (isUsingiCloud)
	            {
	                [[AppSettings sharedInstance] saveUbiquityURL:storeURL];
				}
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

- (BOOL)currentStoreIsLocal:(NSPersistentStore *)store
{
	NSURL *fallbackURL = [[self applicationDocumentsDirectory]
	                      URLByAppendingPathComponent:kPersistentFallbackStore];

	BOOL isSame = NO;
	if ([store.URL isEqual:fallbackURL])
	{
		isSame = YES;
	}
	else if ([[store.URL path] compare:[fallbackURL path]] == NSOrderedSame)
	{
		isSame = YES;
	}
	return isSame;
}

- (NSPersistentStore *)currentPersistentStore
{
	if (nil == self.persistentStoreCoordinator)
	{
		return nil;
	}
	NSArray *stores = [self.persistentStoreCoordinator persistentStores];
	if (nil != stores && 0 < stores.count)
	{
		return [stores firstObject];
	}
	return nil;
}

- (void)storesWillChange:(NSNotification *)notification
{
	if (nil == notification)
	{
		return;
	}
	NSDictionary *userInfo = notification.userInfo;
	if (nil == userInfo)
	{
		return;
	}
	NSPersistentStoreUbiquitousTransitionType transitionType = [[userInfo objectForKey:NSPersistentStoreUbiquitousTransitionTypeKey] integerValue];
#ifdef APPDEBUG
	NSLog(@"transition type %ld", (long)transitionType);
#endif
	NSError *error = nil;
	[self saveContextAndWait:&error];
	if (nil == error)
	{
		[self.defaultContext reset];
	}
}

- (void)storesDidChange:(NSNotification *)notification
{
	if (nil == notification)
	{
		return;
	}
	NSDictionary *userInfo = notification.userInfo;
	if (nil == userInfo)
	{
		return;
	}

	NSPersistentStoreUbiquitousTransitionType transitionType = [[userInfo objectForKey:NSPersistentStoreUbiquitousTransitionTypeKey] integerValue];
#ifdef APPDEBUG
	NSLog(@"transition type %ld", (long)transitionType);
#endif
	if (NSPersistentStoreUbiquitousTransitionTypeInitialImportCompleted == transitionType)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
#ifdef APPDEBUG
		    NSLog(@"import finished is getting fired");
#endif
		    NSNotification *notification = [NSNotification
		                                    notificationWithName:kLoadedStoreNotificationKey
		                                                  object:self];
		    [[NSNotificationCenter defaultCenter] postNotification:notification];
		});
	}
}

#pragma mark iCloud management

- (BOOL)iCloudIsAvailable
{
	_iCloudIsAvailable = (nil != [[NSFileManager defaultManager] ubiquityIdentityToken]);
	return _iCloudIsAvailable;
}

- (BOOL)iCloudEnabled
{
	_iCloudEnabled = (nil != [CoreDataUtils iCloudStoreOptions]);
	return _iCloudEnabled;
}

- (BOOL)hasNewiCloudStore
{
	NSURL *url = [[self applicationDocumentsDirectory]
	              URLByAppendingPathComponent:kPersistentiCloudMainStore];

	return [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
}

- (void)migrateToNewiCloudStore:(iStayHealthySuccessBlock)completionBlock
{
	if (!self.iCloudIsAvailable || !self.iCloudEnabled)
	{
		if (nil != completionBlock)
		{
			completionBlock(YES, nil);
		}
		return;
	}
	NSURL *oldUrl = [[self applicationDocumentsDirectory]
	                 URLByAppendingPathComponent:kPersistentMainStore];
	if ([[NSFileManager defaultManager] fileExistsAtPath:[oldUrl path]])
	{
		dispatch_async(storeQueue, ^{
		    NSDictionary *iCloudOptions = [CoreDataUtils iCloudStoreOptions];
		    NSDictionary *newiCloudOption = [CoreDataUtils newiCloudStoreOptions];

		    BOOL success = YES;
		    NSError *overallError = nil;

		    NSError *creationError = nil;
		    NSPersistentStore *oldiCloudStore = [self.persistentStoreCoordinator
		                                         addPersistentStoreWithType:NSSQLiteStoreType
		                                                      configuration:nil
		                                                                URL:oldUrl
		                                                            options:iCloudOptions
		                                                              error:&creationError];

		    if (nil != oldiCloudStore)
		    {
		        NSURL *newUrl = [[self applicationDocumentsDirectory]
		                         URLByAppendingPathComponent:kPersistentiCloudMainStore];
		        NSPersistentStore *newStore = [self.persistentStoreCoordinator
		                                       migratePersistentStore:oldiCloudStore
		                                                        toURL:newUrl
		                                                      options:newiCloudOption
		                                                     withType:NSSQLiteStoreType
		                                                        error:&creationError];

		        if (nil != newStore)
		        {
		            NSError *removeError = nil;
		            [[NSFileManager defaultManager] removeItemAtURL:oldUrl error:&removeError];
		            success = (nil == removeError);
		            overallError = removeError;
				}
		        else
		        {
		            overallError = creationError;
		            success = NO;
				}
			}
		    else
		    {
		        success = NO;
		        overallError = creationError;
			}
		    dispatch_async(dispatch_get_main_queue(), ^{
		        if (completionBlock)
		        {
		            completionBlock(success, overallError);
				}
			});
		});
	}
	else
	{
		if (nil != completionBlock)
		{
			completionBlock(YES, nil);
		}
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
#ifdef APPDEBUG
	NSLog(@"CoreDataManager::iCloudStoreChanged %@", notification.userInfo);
#endif

	if (![formerToken isEqual:currentToken])
	{
		[CoreDataUtils dropUbiquityToken];
		[CoreDataUtils archiveUbiquityToken:currentToken];
	}
}

- (void)mergeFromiCloud:(NSNotification *)notification
{
	NSManagedObjectContext *context = self.defaultContext;

	if (nil == context || nil == notification)
	{
		return;
	}
#ifdef APPDEBUG
	NSLog(@"CoreDataManager::mergeFromiCloud %@", notification.userInfo);
#endif
	[context performBlockAndWait: ^{
	    [context mergeChangesFromContextDidSaveNotification:notification];
	    [context processPendingChanges];
	    NSError *saveError;
	    [self saveContextAndWait:&saveError];
	}];
//	[context performBlock: ^{
//	    [privateContext performBlockAndWait: ^{
//	        [privateContext mergeChangesFromContextDidSaveNotification:notification];
//	        [privateContext processPendingChanges];
//		}];
//	}];
}

#pragma mark Observers
- (void)registerObservers
{
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	    selector:@selector(storesWillChange:)
	        name:NSPersistentStoreCoordinatorStoresWillChangeNotification
	      object:nil];

	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	    selector:@selector(storesDidChange:)
	        name:NSPersistentStoreCoordinatorStoresDidChangeNotification
	      object:nil];


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
	           name:NSPersistentStoreCoordinatorStoresWillChangeNotification
	         object:nil];

	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	           name:NSPersistentStoreCoordinatorStoresDidChangeNotification
	         object:nil];

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

#pragma mark save and fetch
- (BOOL)saveAndBackup:(NSError **)error
{
	__block BOOL saveSuccess = [self saveContextAndWait:error];
	if (saveSuccess)
	{
        CoreXMLWriter *writer = [CoreXMLWriter new];
		[writer writeWithCompletionBlock: ^(NSString *xmlString, NSError *error) {
		    if (nil != xmlString)
		    {
                
                NSLog(@"RESULTS from WRITING XML ****\r\n");
                NSLog(@"%@",xmlString);
                
		        NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
		        NSURL *path = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kXMLBackupFile];
		        NSFileManager *manager = [NSFileManager defaultManager];
		        if ([manager fileExistsAtPath:[path path]])
		        {
		            NSError *removeError = nil;
		            [manager removeItemAtURL:path error:&removeError];
		            saveSuccess = (removeError == nil);
				}
		        [xmlData writeToURL:path atomically:YES];
			}
		}];
	}
	return saveSuccess;
}

- (void)restoreLocallyWithCompletionBlock:(iStayHealthySuccessBlock)completionBlock
{
	NSURL *path = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kXMLBackupFile];
	if ([[NSFileManager defaultManager] fileExistsAtPath:[path path]])
	{
		CoreXMLReader *reader = [CoreXMLReader new];
		NSData *data = [[NSData alloc] initWithContentsOfFile:[path path]];
		if (nil != data)
		{
			[reader parseXMLData:data completionBlock:completionBlock];
		}
		else
		{
			NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"Error reading backup file", nil) };
			NSError *error = [NSError errorWithDomain:@"com.iStayHealthy" code:201 userInfo:userInfo];
			completionBlock(NO, error);
		}
	}
	else
	{
		if (nil != completionBlock)
		{
			NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"Local backup file not found", nil) };
			NSError *error = [NSError errorWithDomain:@"com.iStayHealthy" code:200 userInfo:userInfo];
			completionBlock(NO, error);
		}
	}
}

- (void)resetContextsAndWait
{
	NSManagedObjectContext *context = self.defaultContext;
	[context performBlockAndWait: ^{
	    [context reset];
	}];

	[privateContext performBlockAndWait: ^{
	    [privateContext reset];
	}];
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

    __strong CoreXMLWriter *writer = [CoreXMLWriter new];
	void (^savePrivateContext) (void) = ^{
		[privateContext save:error];
//		dispatch_async(dispatch_get_main_queue(), ^{
//		    [[CoreXMLWriter sharedInstance] writeWithCompletionBlock: ^(NSString *xmlString, NSError *error) {
//		        if (nil != xmlString)
//		        {
//		            NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
//		            NSURL *path = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kXMLBackupFile];
//		            NSFileManager *manager = [NSFileManager defaultManager];
//		            if ([manager fileExistsAtPath:[path path]])
//		            {
//		                NSError *removeError = nil;
//		                [manager removeItemAtURL:path error:&removeError];
//					}
//		            [xmlData writeToURL:path atomically:YES];
//				}
//			}];
//		});
	};

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
	        iStayHealthyRecord *lastRecord = (iStayHealthyRecord *)[array lastObject];
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
	    NSUInteger count = [context countForFetchRequest:request error:&error];
	    if (0 == count || NSNotFound == count)
	    {
	        fetchedObjects = [NSArray array];
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
		}
	    else
	    {
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
		}
	}];
}

#pragma mark getting ManagedObjects and importing
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
	NSData *xmlData = [NSData dataWithContentsOfURL:sourceURL];
	if (nil == xmlData)
	{
		return NO;
	}
	self.importedXMLData = xmlData;
	self.hasDataForImport = YES;
	NSNotification *notification = [NSNotification
	                                notificationWithName:kImportedDataAvailableKey
	                                              object:self
	                                            userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	return YES;
}

- (void)importWhenReady:(NSNotification *)notification
{
	if (self.storeIsReady)
	{
		[self importWithData];
	}
	else
	{
		if (nil != self.importedXMLData)
		{
			NSString *tmpFileName = [NSString stringWithFormat:@"%@.isth", [[NSUUID UUID] UUIDString]];
			NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingString:tmpFileName];
			NSURL *tmpURL = [[NSURL alloc] initFileURLWithPath:tmpPath];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			if ([fileManager fileExistsAtPath:tmpPath])
			{
				NSError *error = nil;
				[fileManager removeItemAtPath:tmpPath error:&error];
			}
			NSData *tmpXML = self.importedXMLData;
			[tmpXML writeToURL:tmpURL atomically:YES];
			self.importedFilePath = tmpPath;
			dispatch_async(dispatch_get_main_queue(), ^{
			    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import Delayed", nil) message:NSLocalizedString(@"ImportDelayMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
			    [alert show];
			});
			self.importedXMLData = nil;
		}
	}
}

- (void)importWithData
{
	if (nil == self.importedXMLData)
	{
		return;
	}
    CoreXMLReader *reader = [CoreXMLReader new];
	[reader parseXMLData:self.importedXMLData completionBlock: ^(BOOL success, NSError *error) {
	    self.hasDataForImport = NO;
	    self.importedXMLData = nil;
	    self.importedFilePath = nil;
	    dispatch_async(dispatch_get_main_queue(), ^{
	        if (success)
	        {
	            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import Succeeded", nil) message:NSLocalizedString(@"Your Data were successfully imported. Only unique entries were saved", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
	            [alert show];
			}
	        else
	        {
	            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import Error", nil) message:NSLocalizedString(@"Your data could not be imported due to an error.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
	            [alert show];
			}
		});
	}];
}

- (void)importFromTmpFileURL
{
	if (nil == self.importedFilePath)
	{
		return;
	}
	CoreXMLReader *reader = [CoreXMLReader new];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:self.importedFilePath])
	{
		NSData *data = [NSData dataWithContentsOfFile:self.importedFilePath];
		if (nil != data)
		{
			[reader parseXMLData:data completionBlock: ^(BOOL success, NSError *error) {
			    self.hasDataForImport = NO;
			    self.importedXMLData = nil;
			    self.importedFilePath = nil;
			    dispatch_async(dispatch_get_main_queue(), ^{
			        if (success)
			        {
			            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import Succeeded", nil) message:NSLocalizedString(@"Your Data were successfully imported. Only unique entries were saved", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
			            [alert show];
					}
			        else
			        {
			            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import Error", nil) message:NSLocalizedString(@"Your data could not be imported due to an error.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
			            [alert show];
					}
				});
			}];
		}
	}
}

#pragma mark possibly for later
/**************************************
**************************************/
//- (void)replaceStoreWithLocalFallbackStoreWithCompletion:(iStayHealthySuccessBlock)completionBlock
//{
//	NSError *saveError = nil;
//	[self saveContextAndWait:&saveError];
//	if (nil != saveError)
//	{
//		if (completionBlock)
//		{
//			completionBlock(NO, saveError);
//		}
//	}
//	NSPersistentStore *currentStore = [self currentPersistentStore];
//	if (nil == currentStore)
//	{
//		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"No data storage available", nil) };
//		NSError *error = [NSError errorWithDomain:@"com.pweschmidt.istayhealthy" code:100 userInfo:userInfo];
//		if (completionBlock)
//		{
//			completionBlock(NO, error);
//		}
//		return;
//	}
//	BOOL isAlreadyLocal = [self currentStoreIsLocal:currentStore];
//	if (isAlreadyLocal)
//	{
//		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"Store is already local", nil) };
//		NSError *error = [NSError errorWithDomain:@"com.pweschmidt.istayhealthy" code:101 userInfo:userInfo];
//		if (completionBlock)
//		{
//			completionBlock(NO, error);
//		}
//		return;
//	}
//}

- (void)migrateToLocalWithCompletion:(iStayHealthySuccessBlock)completionBlock
{
//	NSError *saveError = nil;
//	[self saveContextAndWait:&saveError];
//	if (nil != saveError)
//	{
//		if (completionBlock)
//		{
//			completionBlock(NO, saveError);
//		}
//	}
//    NSError *storeError = nil;
//    if (nil == self.persistentStoreCoordinator)
//    {
//        [self setUpCoreDataManager];
//        [self setUpStoreAsLocalStoreWithError:&storeError];
//        BOOL success = (nil == storeError);
//        if (nil != completionBlock)
//        {
//            completionBlock(success, storeError);
//        }
//        return;
//    }
//    
//    [self.defaultContext lock];
//    [self.defaultContext reset];
//    
//    [privateContext performBlockAndWait:^{
//        [privateContext lock];
//        [privateContext reset];
//        NSArray *stores = [self.persistentStoreCoordinator persistentStores];
//        for (NSPersistentStore *store in stores)
//        {
//            [self.persistentStoreCoordinator removePersistentStore:store error:nil];
//        }
//        
//        [privateContext unlock];
//    }];
//    [self.defaultContext unlock];
//    
//    self.defaultContext = nil;
//    privateContext = nil;
//    
//    [self setUpCoreDataManager];
//    [self setUpStoreAsLocalStoreWithError:&storeError];
//    BOOL success = (nil == storeError);
//    if (nil != completionBlock)
//    {
//        completionBlock(success, storeError);
//    }
}

//- (void)migrateLocalStoreToiCloudStoreWithCompletion:(iStayHealthySuccessBlock)completionBlock
//{
//	NSError *saveError = nil;
//	[self saveContextAndWait:&saveError];
//	if (nil != saveError)
//	{
//		if (completionBlock)
//		{
//			completionBlock(NO, saveError);
//		}
//	}
//}
//

@end
