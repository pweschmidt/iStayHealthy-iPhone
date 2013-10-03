//
//  CentralAppDelegate.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "CentralAppDelegate.h"
#import "ContainerViewController.h"
#import "Constants.h"
#import "GeneralSettings.h"
#import "Utilities.h"
#import "CoreDataManager.h"
#import <DropboxSDK/DropboxSDK.h>
#import "ContentContainerViewController.h"

#import "TestFlight.h"

@interface CentralAppDelegate ()
@property (nonatomic, strong) ContainerViewController * containerController;
@end


@implementation CentralAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"We got to the new CentralAppDelegate");
    self.window.tintColor = TEXTCOLOUR;
    self.containerController = (ContainerViewController *)self.window.rootViewController;
    [[CoreDataManager sharedInstance] setUpCoreDataManager];
    [[CoreDataManager sharedInstance] setUpStoreWithError:^(NSError *error) {
        if (error)
        {
            NSLog(@"Error occurred with code %d and message %@", [error code], [error localizedDescription]);
        }
    }];
    [TestFlight takeOff:@"f9640006-475c-47e9-ad01-b9ff23f67d1b"];
    
    
    UILocalNotification *notification = [launchOptions objectForKey:
                                         UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (notification)
    {
        NSString *reminderText = [notification.userInfo
                                  objectForKey:kAppNotificationKey];
        [self showReminder:reminderText];
    }
    
    NSInteger badges = application.applicationIconBadgeNumber - 1;
    if (0 > badges)
    {
        badges = 0;
    }
    application.applicationIconBadgeNumber = badges;
    
    NSString* root = kDBRootDropbox;
	DBSession* session = [[DBSession alloc]initWithAppKey:kDropboxConsumerKey
                                                appSecret:kDropboxSecretKey
                                                     root:root];
	[DBSession setSharedSession:session];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];
    BOOL passwordIsTransferred = [defaults boolForKey:kPasswordTransferred];
    if (isPasswordEnabled && passwordIsTransferred)
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([[DBSession sharedSession] handleOpenURL:url])
    {
        if ([[DBSession sharedSession] isLinked])
        {
            //any app calls?
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
                                  initWithTitle:NSLocalizedString(@"Import Error",nil)
                                  message:NSLocalizedString(@"Error importing file", nil)
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)showReminder:(NSString *)text
{
	UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"iStayHealthy Alert",nil)
                              message:text
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil)
                              otherButtonTitles:nil];
	[alertView show];
}

@end
