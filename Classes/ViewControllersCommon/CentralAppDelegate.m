//
//  CentralAppDelegate.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "CentralAppDelegate.h"
#import "ContainerViewController.h"
#import "ContainerViewController_iPad.h"
#import "Utilities.h"
#import "CoreDataManager.h"
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
#ifdef APPDEBUG
    NSLog(@"We got to the new CentralAppDelegate");
#endif
    [self registerUserNotifications:application];
    self.window.tintColor = TEXTCOLOUR;

    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: TEXTCOLOUR, NSFontAttributeName : [UIFont fontWithType:Standard size:17] }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    self.window.tintColor = TINTCOLOUR;
    self.containerController = self.window.rootViewController;
    [[CoreDataManager sharedInstance] setUpCoreDataManager];
    [[CoreDataManager sharedInstance] setUpStoreWithError: ^(NSError *error) {
         if (error)
         {
#ifdef APPDEBUG
             NSLog(@"Error occurred with code %ld and message %@", (long) [error code], [error localizedDescription]);
#endif
         }
     }];
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
    NSLog(@"Device token is %@", deviceToken);
    TokenCertificate *certificate = [TokenCertificate sharedToken];
    certificate.deviceToken = deviceToken;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"did register notification");

}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSError *error = nil;

    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
    if (nil != error)
    {
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (0 < application.applicationIconBadgeNumber)
    {
        application.applicationIconBadgeNumber = 0;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];

    if (isPasswordEnabled)
    {
        [self.containerController transitionToLoginController:self];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSError *error = nil;

    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
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
    return YES;
}

#pragma mark - private
- (BOOL)handleFileImport:(NSURL *)url
{
    if (nil == url || ![url isFileURL])
    {
        return NO;
    }
    NSError *error = nil;
    [[CoreDataManager sharedInstance] addFileToImportList:url error:&error];
    if (nil != error)
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Import Error", nil)
                                            message:NSLocalizedString(@"Error importing file", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
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
