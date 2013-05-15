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
#import "Constants.h"
#import "SQLDatabaseManager.h"

@interface iStayHealthyAppDelegate() <DBSessionDelegate>
@property (nonatomic, strong, readwrite) SQLDatabaseManager *sqlHelper;
- (void)postNotificationWithNote:(NSNotification *)note;
@end

@implementation iStayHealthyAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
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
    
	self.sqlHelper = [[SQLDatabaseManager alloc] init];
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
    BOOL isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];
    BOOL passwordIsTransferred = [defaults boolForKey:kPasswordTransferred];

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
    
    if (isPasswordEnabled && passwordIsTransferred)
    {
        iStayHealthyPasswordController *tmpPassController =
        [[iStayHealthyPasswordController alloc]initWithNibName:@"iStayHealthyPasswordController" bundle:nil];
        self.passController = tmpPassController;
        self.window.rootViewController = self.passController;
//        [self.window addSubview:tmpPassController.view];
    }
    else
    
    {
        if (isPasswordEnabled && !passwordIsTransferred)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Reset", nil)
                                        message:NSLocalizedString(@"Empty Password", nil)
                                       delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            [defaults setBool:NO forKey:kIsPasswordEnabled];
            [defaults synchronize];
        }
        iStayHealthyTabBarController *tmpBarController = [[iStayHealthyTabBarController alloc]initWithNibName:nil bundle:nil];
        self.tabBarController = tmpBarController;
        self.window.rootViewController = self.tabBarController;
//        [self.window addSubview:tmpBarController.view];
    }
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(postNotificationWithNote:)
     name:NSPersistentStoreCoordinatorStoresDidChangeNotification
     object:self.sqlHelper.persistentStoreCoordinator];
    
    [self.sqlHelper loadSQLitePersistentStore];
    
    NSURL *appURL = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (nil != appURL)
    {
        if ([appURL isFileURL])
        {
            [self handleFileImport:appURL];
        }
    }
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
    if (![XMLLoader isXML:importedData] || nil == self.sqlHelper)
    {
        UIAlertView *cancelImport = [[UIAlertView alloc] initWithTitle:@"Import Error" message:@"The file has not the correct format" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil];
        [cancelImport show];
        return NO;
    }
    self.sqlHelper.importData = importedData;
    UIAlertView *importAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import", nil) message:NSLocalizedString(@"Import File", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Import", nil), nil];
    [importAlert show];
    
    return YES;
}

- (BOOL)handleParametersFromURL:(NSURL *)url
{
    BOOL success = YES;
    NSString *parameters = [url parameterString];
    if (nil == parameters)
    {
        return NO;
    }
    NSArray *parameterArray = [parameters componentsSeparatedByString:@"&"];
    __block NSMutableArray *kvc = [NSMutableArray array];
    [parameterArray enumerateObjectsUsingBlock:^(NSString *parameter, NSUInteger index, BOOL *stop){
        NSArray *parameterValues = [parameter componentsSeparatedByString:@"="];
        if (2 == parameterValues.count)
        {
            NSString *key = [parameterValues objectAtIndex:0];
            NSString *value = [parameterValues objectAtIndex:1];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:value forKey:key];
            [kvc addObject:dictionary];
        }
    }];
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:kvc];
    NSUserDefaults *standardDefault = [NSUserDefaults standardUserDefaults];
    [standardDefault removeObjectForKey:@"ResultParameters"];
    [standardDefault setObject:archivedData forKey:@"ResultParameters"];
    [standardDefault synchronize];
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"ParseResultsFromURL" object:self];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    
    return success;
}


/**
 acc to Apple Doc - this should replace handleOpenURL method below
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
#ifdef APPDEBUG
    NSLog(@"in openURL");
#endif
    if (nil == url)
    {
        return NO;
    }
    BOOL success = YES;
    
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"com.pweschmidt.iStayHealthy"])
    {
        [self handleParametersFromURL:url];
    }
    else if ([[DBSession sharedSession] handleOpenURL:url])
    {
        if ([[DBSession sharedSession] isLinked])
        {
            //any app calls?
        }
        return YES;
    }
    else if ([url isFileURL])
    {
        success = [self handleFileImport:url];
    }
    return success;
}


/**
 this is a deprecated method, but we'll retain it here just in case
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (nil == url)
    {
        return NO;
    }
    BOOL success = YES;
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"com.pweschmidt.iStayHealthy"])
    {
        [self handleParametersFromURL:url];
    }
    else if ([[DBSession sharedSession] handleOpenURL:url])
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
    else if ([url isFileURL])
    {
        success = [self handleFileImport:url];
    }
    return success;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
#ifdef APPDEBUG
    NSLog(@"in applicationWillResignActive");
#endif
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
    BOOL isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];
    
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
    BOOL isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];
    
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
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
                                            message:NSLocalizedString(@"Save error message", nil)
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles: nil]
                 show];
            }
        }
    }];
}    


#pragma mark post notification and other utility methods

- (void)postNotificationWithNote:(NSNotification *)note
{
#ifdef APPDEBUG
    NSLog(@"iStayHealthyAppDelegate::postNotificationWithNote");
#endif
    NSNotification* refreshNotification = [NSNotification
                                           notificationWithName:@"RefetchAllDatabaseData"
                                           object:self
                                           userInfo:[note userInfo]];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];    
}

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
    NSString *buttonTitle = [alertView buttonTitleAtIndex:index];
    NSString *importTitle = NSLocalizedString(@"Import", @"Import");
    NSLog(@"The buttonTitle is %@ and the expected title is %@", buttonTitle, importTitle);
    if ([importTitle isEqualToString:buttonTitle])
    {
        NSLog(@"we get to importing the data");
        if (nil != self.sqlHelper)
        {
            NSLog(@"we get to importing the data. SQLHelper is NOT nil");
            [self.sqlHelper loadImportedData];
        }
        return;
    }
    
	if (index != alertView.cancelButtonIndex)
    {
		[[DBSession sharedSession] linkUserId:self.relinkUserId fromController:self.tabBarController];
	}
	self.relinkUserId = nil;
}


@end

