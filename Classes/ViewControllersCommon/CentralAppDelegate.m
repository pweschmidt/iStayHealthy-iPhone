//
//  CentralAppDelegate.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "CentralAppDelegate.h"
#import "Utilities.h"
// #import "CoreDataManager.h"
#import "UIFont+Standard.h"
#import <DropboxSDK/DropboxSDK.h>
#import "ContentContainerViewController.h"
#import "KeychainHandler.h"
#import "iStayHealthy-Swift.h"

@interface CentralAppDelegate ()
@property (nonatomic, strong) id containerController;
@property (nonatomic, strong) NSString *reminderText;
@end


@implementation CentralAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"**** didFinishLaunchingWithOptions");
    [self registerUserNotifications:application];
    self.window.tintColor = TEXTCOLOUR;

    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: TEXTCOLOUR, NSFontAttributeName : [UIFont fontWithType:Standard size:17] }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    self.window.tintColor = TINTCOLOUR;
    self.containerController = self.window.rootViewController;


//    [[CoreDataManager sharedInstance] setUpCoreDataManager];
//
//    [[CoreDataManager sharedInstance] setUpStoreWithError: ^(NSError *error) {
//         if (error)
//         {
// #ifdef APPDEBUG
//             NSLog(@"Error occurred with code %ld and message %@", (long) [error code], [error localizedDescription]);
// #endif
//         }
//     }];

    UILocalNotification *notification = [launchOptions objectForKey:
                                         UIApplicationLaunchOptionsLocalNotificationKey];

    if (notification)
    {
        NSString *reminderText = [notification.userInfo
                                  objectForKey:kAppNotificationKey];
        self.reminderText = reminderText;
        [self showReminder:reminderText];
    }
    application.applicationIconBadgeNumber = 0;

    NSString *root = kDBRootDropbox;
    DBSession *session = [[DBSession alloc]initWithAppKey:kDropboxConsumerKey
                                                appSecret:kDropboxSecretKey
                                                     root:root];
    [DBSession setSharedSession:session];

    PWESPersistentStoreManager *storeManager = [PWESPersistentStoreManager defaultManager];
    BOOL successfullySetUp = [storeManager setUpCoreDataStack];
    if (!successfullySetUp)
    {

    }
//    PWESPersistentStoreManager *defaultManager = [PWESPersistentStoreManager defaultManager];
//    StorageType storageType = [defaultManager findStorageType];
//    switch (storageType)
//    {
//        case hasNewDataBaseFile:
//            NSLog(@"It appears we have a new database file. No need to migrate then.\r\n");
//            break;
//        case hasOldDataBaseAndBackupFile:
//            NSLog(@"We have old database file AND backup file.\r\n");
//            break;
//        case hasOldDataBaseFileNoBackupFile:
//            NSLog(@"We have old database file but NO backup file. \r\n");
//            break;
//        case isNewUser:
//            NSLog(@"Looks like this is a new user");
//            break;
//    }
    return YES;
}

- (void)registerUserNotifications:(UIApplication *)application
{
    UIUserNotificationType notificationTypes = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];

    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIAlertView *receivedAlert = [[UIAlertView alloc] initWithTitle:@"Received notification" message:@"Hurrah we received a notification" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

    [receivedAlert show];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    TokenCertificate *certificate = [TokenCertificate sharedToken];

    certificate.deviceToken = deviceToken;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSError *error = nil;
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];

    [manager saveContext:&error];
//    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
//    if (nil != error)
//    {
//    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"**** applicationWillEnterForeground");
    if (0 < application.applicationIconBadgeNumber)
    {
        application.applicationIconBadgeNumber = 0;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];

    if (isPasswordEnabled)
    {
        //        [self.containerController transitionToLoginController:self];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];

    NSError *error = nil;

    [manager saveContext:&error];
//    NSError *error = nil;
//
//    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
}

- (BOOL)  application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation
{
    if ([[DBSession sharedSession] handleOpenURL:url])
    {
        if ([[DBSession sharedSession] isLinked])
        {
#ifdef APPDEBUG
            NSLog(@"App is linked");
#endif
        }
        return YES;
    }
    else if ([url isFileURL])
    {
        return [self handleFileImport:url];
    }
    else
    {
        return [self handleImportFromLinkURL:url];
    }
}

#pragma mark - private
- (BOOL)handleFileImport:(NSURL *)url
{
    if (nil == url || ![url isFileURL])
    {
        return NO;
    }
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];

//    [manager save];
//    NSError *error = nil;
//    [[CoreDataManager sharedInstance] addFileToImportList:url error:&error];
//    if (nil != error)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:NSLocalizedString(@"Import Error", nil)
//                                            message:NSLocalizedString(@"Error importing file", nil)
//                                           delegate:nil
//                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                  otherButtonTitles:nil];
//        [alertView show];
//        return NO;
//    }
    return YES;
}

- (BOOL)handleImportFromLinkURL:(NSURL *)url
{

    if (nil == url || nil == url.query)
    {
        return NO;
    }
    NSLog(@"We handle the following URL: %@", url);
    NSString *queryString = url.query;
    PWESCoreURLImporter *urlImporter = [PWESCoreURLImporter new];
    NSDictionary *results = [urlImporter resultsFromURLQueryString:queryString];
    if (nil != results && 0 < results.allKeys.count)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kImportNotificationKey object:nil userInfo:results];
    }
    return YES;
}

- (void)showReminder:(NSString *)text
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"iStayHealthy Alert", nil)
                                        message:text
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];

    [alertView show];
}

@end
