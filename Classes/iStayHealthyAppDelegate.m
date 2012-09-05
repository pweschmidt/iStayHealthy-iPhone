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

@interface iStayHealthyAppDelegate() <DBSessionDelegate>
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
#endif
	
    
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
        [self.window addSubview:tmpPassController.view];
        [self.window makeKeyAndVisible];
    }    
    else
    
    {
        iStayHealthyTabBarController *tmpBarController = [[iStayHealthyTabBarController alloc]initWithNibName:nil bundle:nil];
        self.tabBarController = tmpBarController;
        [self.window addSubview:tmpBarController.view];
        [self.window makeKeyAndVisible];
    }
    //finally see if iCloud is available or not
    [self checkForiCloud];  
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


/**
 check for the right version and device. If we are a Simulator - iCloud won't work.
 Same holds for devices below version iOS 5.0
 */
- (void)checkForiCloud
{
    self.iCloudIsAvailable = FALSE;
    if (DEVICE_IS_SIMULATOR)
    {
        return;
    }    
    
    self.cloudURL = [[NSFileManager defaultManager]URLForUbiquityContainerIdentifier:@"5Y4HL833A4.com.pweschmidt.iStayHealthy"];
    if (self.cloudURL)
    {
#ifdef APPDEBUG
        NSLog(@"iCloud is available with the URL being %@",self.cloudURL);
#endif
        self.iCloudIsAvailable = TRUE;
    }
    else
    {
#ifdef APPDEBUG
        NSLog(@"iCloud is NOT available");
#endif
        self.iCloudIsAvailable = FALSE;
    }    
}



- (void)applicationWillResignActive:(UIApplication *)application
{
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
	application.applicationIconBadgeNumber = 0;
    [self saveContext];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
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
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
#ifdef APPDEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
   
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (nil == coordinator)
    {
        return _managedObjectContext;
    }
    if (!self.iCloudIsAvailable)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    else
    {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        _managedObjectContext = moc;
    }
    
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iStayHealthy" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 iOS5.x method for merging changes from iCloud
 */
- (void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc
{
    [moc mergeChangesFromContextDidSaveNotification:note]; 
    
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefetchAllDatabaseData" object:self  userInfo:[note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

/**
 iOS5.x method for merging changes from iCloud
 */
// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    [moc performBlock:^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iStayHealthy.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSPersistentStoreCoordinator* psc = _persistentStoreCoordinator;

    
    if (!self.iCloudIsAvailable)
    {
//        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSString* coreDataCloudContent = [[self.cloudURL path] stringByAppendingPathComponent:@"data"];
        NSURL *amendedCloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
         [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
         @"5Y4HL833A4.com.pweschmidt.iStayHealthy.store", NSPersistentStoreUbiquitousContentNameKey,
         amendedCloudURL, NSPersistentStoreUbiquitousContentURLKey,
         nil];
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            
            abort();
        }    
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
            // this needs to match the entitlements and provisioning profile
 //           NSURL *cloudURL = [[NSFileManager defaultManager]URLForUbiquityContainerIdentifier:@"5Y4HL833A4.com.pweschmidt.iStayHealthy"];
            NSDictionary *cloudOptions = nil;
            if (self.cloudURL)
            {//this is just a precaution. We should have iCloud enabled already
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
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            [psc unlock];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"asynchronously added persistent store!");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
            });
            
        });            
        
    }
    
    return _persistentStoreCoordinator;
}

/**
 creates the Master record the very first time we run this application
 */
- (void)setUpMasterRecord
{
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
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
 




#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
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

