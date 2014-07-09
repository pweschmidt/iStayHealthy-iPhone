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

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		storeQueue = dispatch_queue_create(kBackgroundQueueName, NULL);
	}
	return self;
}

- (void)dealloc
{
	self.storeIsReady = NO;
	self.hasDataForImport = NO;
	[self unregisterObservers];
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
//	BOOL hasNewStore = [self hasNewiCloudStore];
//	if (!hasNewStore)
//	{
//		[self migrateToNewiCloudStore: ^(BOOL success, NSError *error) {
//		    [self setUpContextsForCoordinator];
//		}];
//	}
//	else
//	{
//	}
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

	[mainContext setParentContext:privateContext];
	[self setDefaultContext:mainContext];
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

	    NSURL *whichStoreURL = nil;
	    NSDictionary *whichOptions = nil;

	    if (self.iCloudEnabled)
	    {
	        if (self.iCloudIsAvailable)
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

- (void)storesWillChange:(NSNotification *)notification
{
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

	NSPersistentStoreUbiquitousTransitionType transitionType = [userInfo objectForKey:NSPersistentStoreUbiquitousTransitionTypeKey];

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

	void (^savePrivateContext) (void) = ^{ [privateContext save:error]; };

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
	[[CoreXMLReader sharedInstance] parseXMLData:self.xmlImportData completionBlock: ^(BOOL success, NSError *error) {
	    if ([[NSFileManager defaultManager] fileExistsAtPath:self.xmlTmpPath])
	    {
	        NSError *error = nil;
	        [[NSFileManager defaultManager] removeItemAtPath:self.xmlTmpPath error:&error];
		}
	    self.hasDataForImport = NO;
	    self.xmlTmpPath = nil;
	    self.xmlImportData = nil;
	}];
}

@end
