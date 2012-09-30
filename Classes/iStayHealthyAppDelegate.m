//
//  iStayHealthyAppDelegate.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iStayHealthyAppDelegate.h"
#import "iStayHealthyRecord.h"
#import "iStayHealthyTabBarController.h"
#import "iStayHealthyPasswordController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Utilities.h"
#import "XMLLoader.h"
#import "SQLiteHelper.h"

@interface iStayHealthyAppDelegate() <DBSessionDelegate>
@property (nonatomic, strong, readwrite) SQLiteHelper *sqlHelper;
- (void)postNotificationWithNote:(NSNotification *)note;
@end

@implementation iStayHealthyAppDelegate
@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize passController = _passController;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize relinkUserId = _relinkUserId;
@synthesize cloudURL = _cloudURL;
@synthesize iCloudIsAvailable = _iCloudIsAvailable;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize sqlHelper = _sqlHelper;
NSString *MEDICATIONALERTKEY = @"MedicationAlertKey";

#pragma mark -
#pragma mark Application lifecycle
/**
 apart from launching the UI, it sets up the notification and a DropBox session
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifdef APPDEBUG
	NSLog(@"If you can see this we are in DEBUG mode");
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        NSLog(@"We are running on 6.0");
    }
#endif
    
	self.sqlHelper = [[SQLiteHelper alloc] init];
    _managedObjectContext = self.sqlHelper.mainObjectContext;

	Class cls = NSClassFromString(@"UILocalNotification");
	if (cls)
    {
		UILocalNotification *notification = [launchOptions objectForKey:
											 UIApplicationLaunchOptionsLocalNotificationKey];
		
		if (notification)
        {
			NSString *reminderText = [notification.userInfo 
									  objectForKey:MEDICATIONALERTKEY];
			[self showReminder:reminderText];
		}
	}	
    
    
	application.applicationIconBadgeNumber = 0;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPasswordEnabled = [defaults boolForKey:@"isPasswordEnabled"];

    NSString* consumerKey = @"sekt4gbt7526j0y";
	NSString* consumerSecret = @"drg5hompcf9vbd2";
    NSString* root = kDBRootDropbox;
	DBSession* session = [[DBSession alloc]initWithAppKey:consumerKey
                                                appSecret:consumerSecret
                                                     root:root];
	[DBSession setSharedSession:session];
	NSString* errorMsg = nil;    
	if (errorMsg != nil)
    {
		[[[UIAlertView alloc]
		   initWithTitle:@"Error Configuring DropBox Session" message:errorMsg 
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		 show];
	}    
    
    if (isPasswordEnabled)
    {
        iStayHealthyPasswordController *tmpPassController =
        [[iStayHealthyPasswordController alloc]initWithNibName:@"iStayHealthyPasswordController" bundle:nil];
        self.passController = tmpPassController;
        self.window.rootViewController = self.passController;
//        [self.window addSubview:tmpPassController.view];
    }
    else
    
    {
        iStayHealthyTabBarController *tmpBarController = [[iStayHealthyTabBarController alloc]initWithNibName:nil bundle:nil];
        self.tabBarController = tmpBarController;
        self.window.rootViewController = self.tabBarController;
//        [self.window addSubview:tmpBarController.view];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(postNotificationWithNote:)
                                                 name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                                               object:self.sqlHelper.persistentStoreCoordinator];
    [self.sqlHelper loadSQLitePersistentStore];
    [self.window makeKeyAndVisible];
    return YES;
}


/**
 */
- (BOOL)handleFileImport:(NSURL *)url
{
#ifdef APPDEBUG
    NSLog(@"in handleFileImport");
#endif
    if (nil == url || ![url isFileURL])
    {
        return NO;
    }
    NSData *importedData = [NSData dataWithContentsOfURL:url];
    if (![XMLLoader isXML:importedData])
    {
        return NO;
    }
    XMLLoader *xmlLoader = [[XMLLoader alloc]initWithData:importedData];
    NSError* error = nil;
    [xmlLoader startParsing:&error];        
    [xmlLoader synchronise];
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefetchAllDatabaseData" object:self];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    
        
    return YES;
}

/**
 acc to Apple Doc - this should replace handleOpenURL method below
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
#ifdef APPDEBUG
    NSLog(@"in openURL");
#endif
    if ([[DBSession sharedSession] handleOpenURL:url])
    {
        if ([[DBSession sharedSession] isLinked])
        {
            //any app calls?
        }
        return YES;
    }
    return [self handleFileImport:url];
}


/**
 this is a deprecated method, but we'll retain it here just in case
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[DBSession sharedSession] handleOpenURL:url])
    {
#ifdef APPDEBUG
        NSLog(@"in deprecated handleOpenURL method");
#endif
        if ([[DBSession sharedSession] isLinked])
        {
            //any app calls?
        }
        return YES;
    }
    return [self handleFileImport:url];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
#ifdef APPDEBUG
    NSLog(@"in applicationWillResignActive");
#endif
    [self saveContext];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
#ifdef APPDEBUG
    NSLog(@"in iStayHealthyAppDelegate::applicationDidEnterBackground");
#endif
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPasswordEnabled = [defaults boolForKey:@"isPasswordEnabled"];
    
    if (isPasswordEnabled)
    {
        [self.passController dismissModalViewControllerAnimated:NO];
        self.passController = nil;
        for (UIView *view in [self.window subviews])
        {
            [view removeFromSuperview];
        }
        iStayHealthyPasswordController *tmpPassController =
        [[iStayHealthyPasswordController alloc]initWithNibName:@"iStayHealthyPasswordController" bundle:nil];
        self.passController = tmpPassController;
        [self.window addSubview:tmpPassController.view];
    }    
    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
#ifdef APPDEBUG
    NSLog(@"in applicationWillEnterForeground");
#endif
	application.applicationIconBadgeNumber = 0;
    [self saveContext];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
#ifdef APPDEBUG
    NSLog(@"in applicationDidBecomeActive");
#endif
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
#ifdef APPDEBUG
    NSLog(@"in iStayHealthyAppDelegate::applicationWillTerminate");
#endif
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPasswordEnabled = [defaults boolForKey:@"isPasswordEnabled"];
    
    if (isPasswordEnabled)
    {
        [self.passController dismissModalViewControllerAnimated:NO];
        self.passController = nil;
        for (UIView *view in [self.window subviews])
        {
            [view removeFromSuperview];
        }
        iStayHealthyPasswordController *tmpPassController =
        [[iStayHealthyPasswordController alloc]initWithNibName:@"iStayHealthyPasswordController" bundle:nil];
        self.passController = tmpPassController;
        [self.window addSubview:tmpPassController.view];
    }    
    [self saveContext];
}

/**
 */
- (void)application:(UIApplication *)application 
didReceiveLocalNotification:(UILocalNotification *)notification
{
	
#ifdef APPDEBUG
    NSLog(@"in didReceiveLocalNotification");
#endif
	UIApplicationState state = [application applicationState];
	application.applicationIconBadgeNumber = 0;
	if (state == UIApplicationStateInactive)
    {
        NSString *reminderText = [notification.userInfo
                                  objectForKey:MEDICATIONALERTKEY];
        [self showReminder:reminderText];	
	}
	
}


/**
 */
- (void)saveContext
{
    NSManagedObjectContext *currentObjectContext = self.sqlHelper.mainObjectContext;
    [currentObjectContext performBlock:^{
        if ([currentObjectContext hasChanges])
        {
            NSError *error = nil;
            BOOL success = [currentObjectContext save:&error];
            if (!success)
            {
                abort();
            }
        }
    }];
    /*
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            abort();
        } 
    }
     */
}    


#pragma mark -
#pragma mark Core Data stack

- (void)postNotificationWithNote:(NSNotification *)note
{
#ifdef APPDEBUG
    NSLog(@"in postNotificationWithNote");
#endif
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                                                        object:self
                                                                      userInfo:[note userInfo]];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];    
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
#ifdef APPDEBUG
    NSLog(@"iStayHealthyAppDelegate: in managedObjectContext");
#endif
    
    if (_managedObjectContext != nil)
    {
#ifdef APPDEBUG
        NSLog(@"iStayHealthyAppDelegate: in managedObjectContext. We already have a managedObjectContext available");
#endif
        return _managedObjectContext;
    }
   
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (nil == coordinator)
    {
        return _managedObjectContext;
    }
    if (!self.iCloudIsAvailable)
    {
#ifdef APPDEBUG
        NSLog(@"in managedObjectContext if iCloud is not available");
#endif
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    else
    {
#ifdef APPDEBUG
        NSLog(@"in managedObjectContext if iCloud IS available");
#endif
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        _managedObjectContext = moc;
    }
    
    return _managedObjectContext;
}
 */


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
#ifdef APPDEBUG
    NSLog(@"iStayHealthyAppDelegate:in managedObjectModel ");
#endif
    
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
 */

- (void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc
{
    /*
    [moc mergeChangesFromContextDidSaveNotification:note];
    
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefetchAllDatabaseData" object:self  userInfo:[note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
     */
}

/*
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
#ifdef APPDEBUG
    NSLog(@"in mergeChangesFrom_iCloud");
#endif
    [self.sqlHelper.mainObjectContext performBlock:^{
        [self.sqlHelper.mainObjectContext mergeChangesFromContextDidSaveNotification:notification];
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                                                            object:self
                                                                          userInfo:[notification userInfo]];
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
        
    }];
--    NSManagedObjectContext* moc = [self managedObjectContext];
--    [moc performBlock:^{
--        [self mergeiCloudChanges:notification forContext:moc];
--    }];
}
 */


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    
#ifdef APPDEBUG
    NSLog(@"iStayHealthyAppDelegate:in persistentStoreCoordinator ");
#endif
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iStayHealthy.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSPersistentStoreCoordinator* psc = _persistentStoreCoordinator;

    
    if (!self.iCloudIsAvailable)
    {
#ifdef APPDEBUG
        NSLog(@"iStayHealthyAppDelegate:in persistentStoreCoordinator : iCloud is NOT available");
#endif
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            
            abort();
        }    
    }
    else
    {
#ifdef APPDEBUG
        NSLog(@"iStayHealthyAppDelegate:in persistentStoreCoordinator : iCloud IS available");
#endif
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
            NSDictionary *cloudOptions = nil;
            if (self.cloudURL)
            {
                NSString* coreDataCloudContent = [[self.cloudURL path] stringByAppendingPathComponent:@"data"];
                
                NSURL *amendedCloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
                
                cloudOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store", NSPersistentStoreUbiquitousContentNameKey,
                                amendedCloudURL, NSPersistentStoreUbiquitousContentURLKey,
                                nil];
            }
            else
            {
                cloudOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            }
            
            NSError *error = nil;
            [psc lock];
            if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:cloudOptions error:&error])
            {
                NSLog(@"iStayHealthyAppDelegate:Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            [psc unlock];
            
            dispatch_async(dispatch_get_main_queue(), ^{
#ifdef APPDEBUG
                NSLog(@"iStayHealthyAppDelegate:asynchronously added persistent store!");
#endif
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
            });
            
        });            
        
    }
    
    return _persistentStoreCoordinator;
}
 */

/**
 creates the Master record the very first time we run this application
 */
- (void)setUpMasterRecord
{
#ifdef APPDEBUG
    NSLog(@"in setUpMasterRecord ");
#endif
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
    {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"Error Loading Data",nil) 
							  message:[NSString stringWithFormat:NSLocalizedString(@"Error was %@, quitting.", @"Error was %@, quitting"), [error localizedDescription]] 
							  delegate:self 
							  cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
							  otherButtonTitles:nil];
		[alert show];
	}
	NSArray *records = [self.fetchedResultsController fetchedObjects];
	if (nil != records)
    {
		if (0 < [records count])
        {
			return;
		}
	}
#ifdef APPDEBUG
	else
    {
		NSLog(@"Record is nil???? should this really happen");
	}
	NSLog(@"AppDelegate::setUpMasterRecord create/save a new master record to the data base");	
#endif
	NSManagedObject *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"iStayHealthyRecord" inManagedObjectContext:[self.fetchedResultsController managedObjectContext]];
	[newRecord setValue:@"YourName" forKey:@"Name"];
	error = nil;
	if (![newRecord.managedObjectContext save:&error])
    {
#ifdef APPDEBUG
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		abort();
	}
}

/**
 */
- (NSFetchedResultsController *)fetchedResultsController
{
#ifdef APPDEBUG
    NSLog(@"iStayHealthyAppDelegate:in fetchedResultsController ");
#endif
	if (fetchedResultsController_ != nil)
    {
		return fetchedResultsController_;
	}
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"iStayHealthyRecord" inManagedObjectContext:context];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"Name" ascending:YES];
	NSArray *allDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:allDescriptors];
	
	[request setEntity:entity];
	
	NSFetchedResultsController *tmpFetchController = [[NSFetchedResultsController alloc]
													  initWithFetchRequest:request 
													  managedObjectContext:context 
													  sectionNameKeyPath:nil 
													  cacheName:nil];
	tmpFetchController.delegate = self;
	fetchedResultsController_ = tmpFetchController;
	
	return fetchedResultsController_;
	
}	


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
#ifdef APPDEBUG
    NSLog(@"iStayHealthyAppDelegate:in applicationDocumentsDirectory ");
#endif
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
 




#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
#ifdef APPDEBUG
    NSLog(@"iStayHealthyAppDelegate:in applicationDidReceiveMemoryWarning ");
#endif
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



/*
 Notification alert
 */
- (void)showReminder:(NSString *)text
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iStayHealthy Alert" 
														message:text delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId
{
#ifdef APPDEBUG
    NSLog(@"in sessionDidReceiveAuthorizationFailure ");
#endif
	self.relinkUserId = userId;
	[[[UIAlertView alloc] 
	   initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self 
	   cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]
	 show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index
{
	if (index != alertView.cancelButtonIndex)
    {
		[[DBSession sharedSession] linkUserId:self.relinkUserId fromController:self.tabBarController];
	}
	self.relinkUserId = nil;
}


@end

