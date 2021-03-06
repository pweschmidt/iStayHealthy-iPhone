//
//  ContentContainerViewController_iPad.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import "ContentContainerViewController_iPad.h"
#import "HamburgerMenuTableViewController.h"
#import "ResultsCollectionViewController.h"
#import "OtherMedsCollectionViewController.h"
#import "MyHIVCollectionViewController.h"
#import "ProceduresCollectionViewController.h"
#import "SideEffectsCollectionViewController.h"
#import "NotificationsAlertsCollectionViewController.h"
#import "ClinicAddressCollectionViewController.h"
#import "MissedMedicationCollectionViewController.h"
#import "PWESSeinfeldCollectionViewController.h"
#import "Constants.h"
#import "ContentNavigationController_iPad.h"
#import "DropboxViewController.h"
#import "Utilities.h"
#import "PWESDashboardViewController.h"
#import "PWESSlideTransition.h"
#import "CoreDataConstants.h"
#import "AppSettings.h"

@interface ContentContainerViewController_iPad ()
@property (nonatomic, strong) NSDictionary *controllers;
@property (nonatomic, strong) id currentController;
@property (nonatomic, strong) id previousController;
@property (nonatomic, strong) HamburgerMenuTableViewController *shownMenuController;
@end

@implementation ContentContainerViewController_iPad

- (void)viewDidLoad
{
	[super viewDidLoad];
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
	{
		if (self.view.frame.size.width < self.view.frame.size.height)
		{
			self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width);
		}
	}
	self.shownMenuController = nil;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	ContentNavigationController_iPad *navigationController = [self navigationControllerForName_iPad:kDashboardController];
	[self addChildViewController:navigationController];
	[self moveToChildNavigationController:navigationController];
//	if (![[AppSettings sharedInstance] hasUpdated])
//	{
//		[self createWarning];
//	}
}

- (void)createWarning
{
	NSString *message = [[AppSettings sharedInstance] updateMessage];
	if (nil != message)
	{
		UIAlertView *warning = [[UIAlertView alloc]
		                        initWithTitle:NSLocalizedString(@"Upgraded", nil)
		                                     message:message
		                                    delegate:nil
		                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
		                           otherButtonTitles:nil];
		[warning show];
	}
	[[AppSettings sharedInstance] resetUpdateSettings];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if ([title isEqualToString:NSLocalizedString(@"Disable Warning!", nil)])
	{
		[defaults setBool:YES forKey:kDontShowWarning];
	}
	else
	{
		[defaults setBool:NO forKey:kDontShowWarning];
	}
	BOOL updatedVersion = [defaults boolForKey:kIsVersionUpdate400];
	if (!updatedVersion)
	{
		[defaults setBool:YES forKey:kIsVersionUpdate400];
	}
	[defaults synchronize];
}

- (ContentNavigationController_iPad *)startController
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL medDiaryActivated = [defaults boolForKey:kDiaryActivatedKey];
	if (medDiaryActivated)
	{
		return [self navigationControllerForName_iPad:kMedicationDiaryController];
	}
	else
	{
		return [self navigationControllerForName_iPad:kDashboardController];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)showMenu
{
	self.transitionType = kMenuTransition;
	HamburgerMenuTableViewController *menuController = [[HamburgerMenuTableViewController alloc] init];
        //	menuController.modalPresentationStyle = UIModalPresentationCustom;
    menuController.modalPresentationStyle = [Utilities modalPresentationStyle];
	menuController.transitioningDelegate = self;
	menuController.transitionDelegate = self;
	self.shownMenuController = menuController;
	[self presentViewController:menuController animated:YES completion:nil];
}

- (void)hideMenu
{
	if (nil != self.shownMenuController)
	{
		[self.shownMenuController dismissViewControllerAnimated:YES completion:nil];
		self.shownMenuController = nil;
	}
}

#pragma mark PWESNavigationDelegate methods
- (void)changeTransitionType:(TransitionType)transitionType
{
	self.transitionType = transitionType;
}

- (void)transitionToNavigationControllerWithName:(NSString *)name
                                      completion:(finishBlock)completion
{
	ContentNavigationController_iPad *navigationController = [self navigationControllerForName_iPad:name];
	if (nil == navigationController)
	{
		return;
	}
	[self addChildViewController:navigationController];
	ContentNavigationController_iPad *currentNavigationController = self.currentController;
	[self transitionFromViewController:currentNavigationController toViewController:navigationController duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion: ^(BOOL finished) {
	    NSNotification *notification = [NSNotification
	                                    notificationWithName:kLoadedStoreNotificationKey
	                                                  object:self];
	    [[NSNotificationCenter defaultCenter] postNotification:notification];
	    [self moveToChildNavigationController:navigationController];
	    [self removeChildNavigationController:currentNavigationController];
	    self.currentController = navigationController;
	    if (nil != completion)
	    {
	        completion();
		}
	    if (!finished)
	    {
#ifdef APPDEBUG
	        NSLog(@"transition isn't finished yet");
#endif
		}
	}];
}

#pragma mark UIViewControllerTransitioningDelegate methods
- (id <UIViewControllerAnimatedTransitioning> )animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
	PWESSlideTransition *slideTransition = [[PWESSlideTransition alloc] init];
	slideTransition.transitionType = kMenuTransition;
	return slideTransition;
}

- (id <UIViewControllerAnimatedTransitioning> )animationControllerForDismissedController:(UIViewController *)dismissed
{
	PWESSlideTransition *slideTransition = [[PWESSlideTransition alloc] init];
	slideTransition.transitionType = kControllerTransition;
	return slideTransition;
}

#pragma mark private methods
- (void)moveToChildNavigationController:(ContentNavigationController_iPad *)childNavigationController
{
	[childNavigationController didMoveToParentViewController:self];
	[self.view addSubview:childNavigationController.view];
	self.currentController = nil;
	self.currentController = childNavigationController;
}

- (void)removeChildNavigationController:(ContentNavigationController_iPad *)childNavigationController
{
	[childNavigationController removeFromParentViewController];
	[childNavigationController willMoveToParentViewController:nil];
}

- (void)addChildNavigationController:(ContentNavigationController_iPad *)childNavigationController
{
	if (nil != childNavigationController)
	{
		[self addChildViewController:childNavigationController];
		[self.view addSubview:childNavigationController.view];
	}
}

- (ContentNavigationController_iPad *)navigationControllerForName_iPad:(NSString *)controllerName
{
	if (nil == controllerName)
	{
		return nil;
	}

	ContentNavigationController_iPad *navigationController = nil;
	if ([kResultsController isEqualToString:controllerName])
	{
		ResultsCollectionViewController *resultsController = [[ResultsCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:resultsController];
	}
	else if ([kDashboardController isEqualToString:controllerName])
	{
		PWESDashboardViewController *dashboardController = [[PWESDashboardViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:dashboardController];
	}
	else if ([kDropboxController isEqualToString:controllerName])
	{
		DropboxViewController *dropBoxController = [[DropboxViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:dropBoxController];
	}
	else if ([kHIVMedsController isEqualToString:controllerName])
	{
		MyHIVCollectionViewController *hivController = [[MyHIVCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:hivController];
	}
	else if ([kOtherMedsController isEqualToString:controllerName])
	{
		OtherMedsCollectionViewController *controller = [[OtherMedsCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:controller];
	}
	else if ([kSideEffectsController isEqualToString:controllerName])
	{
		SideEffectsCollectionViewController *controller = [[SideEffectsCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:controller];
	}
	else if ([kMissedController isEqualToString:controllerName])
	{
		MissedMedicationCollectionViewController *controller = [[MissedMedicationCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:controller];
	}
	else if ([kMedicationDiaryController isEqualToString:controllerName])
	{
		PWESSeinfeldCollectionViewController *calendarController = [[PWESSeinfeldCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc]
		                        initWithRootViewController:calendarController];
	}
	else if ([kProceduresController isEqualToString:controllerName])
	{
		ProceduresCollectionViewController *controller = [[ProceduresCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:controller];
	}
	else if ([kClinicsController isEqualToString:controllerName])
	{
		ClinicAddressCollectionViewController *controller = [[ClinicAddressCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:controller];
	}
	else if ([kAlertsController isEqualToString:controllerName])
	{
		NotificationsAlertsCollectionViewController *controller = [[NotificationsAlertsCollectionViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:controller];
	}
	return navigationController;
}

@end
