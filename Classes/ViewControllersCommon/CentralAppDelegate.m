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

@interface CentralAppDelegate ()
@property (nonatomic, strong) ContainerViewController * containerController;
@end


@implementation CentralAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"We got to the new CentralAppDelegate");
    self.containerController = (ContainerViewController *)self.window.rootViewController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
