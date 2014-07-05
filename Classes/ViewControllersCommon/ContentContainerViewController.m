//
//  ContentContainerViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "ContentContainerViewController.h"
#import "HamburgerMenuTableViewController.h"
#import "ClinicalAddressTableViewController.h"
#import "NotificationAlertsTableViewController.h"
#import "OtherMedicationsListTableViewController.h"
#import "ProceduresListTableViewController.h"
#import "ResultsListTableViewController.h"
#import "MyHIVMedicationViewController.h"
#import "MissedMedicationsTableViewController.h"
#import "SideEffectsTableViewController.h"
#import "PWESSeinfeldViewController.h"
#import "SettingsTableViewController.h"
#import "InformationTableViewController.h"
#import "Constants.h"
#import "CoreDataConstants.h"
#import "ContentNavigationController.h"
#import "DropboxViewController.h"
#import "PWESDashboardViewController.h"
#import "Utilities.h"
#import "EmailViewController.h"
#import "PWESZoomTransition.h"

@interface ContentContainerViewController ()
@property (nonatomic, strong) NSDictionary *controllers;
@property (nonatomic, strong) id currentController;
@property (nonatomic, strong) id previousController;
@end

@implementation ContentContainerViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	ContentNavigationController *navigationController = [self startController];
	[self addChildViewController:navigationController];
	[self moveToChildNavigationController:navigationController];
}

- (ContentNavigationController *)startController
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL medDiaryActivated = [defaults boolForKey:kDiaryActivatedKey];
	if (medDiaryActivated)
	{
		return [self navigationControllerForName_iPhone:kMedicationDiaryController];
	}
	else
	{
		return [self navigationControllerForName_iPhone:kDashboardController];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)showMenu
{
	self.transitionType = kMenuTransition;
	HamburgerMenuTableViewController *menuController = [[HamburgerMenuTableViewController alloc] init];
	menuController.modalPresentationStyle = UIModalPresentationCustom;
	menuController.transitioningDelegate = self;
	menuController.transitionDelegate = self;
	[self presentViewController:menuController animated:YES completion:nil];
}

- (void)showMailController:(MFMailComposeViewController *)mailController
{
	if (nil == mailController)
	{
		return;
	}
	mailController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
	[self presentViewController:mailController animated:YES completion:nil];
}

- (void)hideMailController:(MFMailComposeViewController *)mailController
{
	if (nil == mailController)
	{
		return;
	}
	[mailController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PWESNavigationDelegate methods
- (void)changeTransitionType:(TransitionType)transitionType
{
	self.transitionType = transitionType;
}

- (void)transitionToNavigationControllerWithName:(NSString *)name
                                      completion:(finishBlock)completion
{
	ContentNavigationController *navigationController = [self navigationControllerForName_iPhone:name];
	if (nil == navigationController)
	{
		return;
	}
	[self addChildViewController:navigationController];
	ContentNavigationController *currentNavigationController = self.currentController;
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
	        NSLog(@"transition isn't finished yet");
		}
	}];
}

#pragma mark private methods
- (void)moveToChildNavigationController:(ContentNavigationController *)childNavigationController
{
	[childNavigationController didMoveToParentViewController:self];
	[self.view addSubview:childNavigationController.view];
	self.currentController = nil;
	self.currentController = childNavigationController;
}

- (void)removeChildNavigationController:(ContentNavigationController *)childNavigationController
{
	[childNavigationController removeFromParentViewController];
	[childNavigationController willMoveToParentViewController:nil];
}

- (void)addChildNavigationController:(ContentNavigationController *)childNavigationController
{
	if (nil != childNavigationController)
	{
		[self addChildViewController:childNavigationController];
		[self.view addSubview:childNavigationController.view];
	}
}

- (ContentNavigationController *)navigationControllerForName_iPhone:(NSString *)controllerName
{
	if (nil == controllerName)
	{
		return nil;
	}

	ContentNavigationController *navigationController = nil;
	if ([kDashboardController isEqualToString:controllerName])
	{
		PWESDashboardViewController *dashboardController = [[PWESDashboardViewController alloc] init];
		navigationController  = [[ContentNavigationController alloc] initWithRootViewController:dashboardController];
	}
	else if ([kResultsController isEqualToString:controllerName])
	{
		ResultsListTableViewController *resultsController = [[ResultsListTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:resultsController];
	}
	else if ([kDropboxController isEqualToString:controllerName])
	{
		DropboxViewController *dropBoxController = [[DropboxViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:dropBoxController];
	}
	else if ([kHIVMedsController isEqualToString:controllerName])
	{
		MyHIVMedicationViewController *hivController = [[MyHIVMedicationViewController alloc]
		                                                init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:hivController];
	}
	else if ([kAlertsController isEqualToString:controllerName])
	{
		NotificationAlertsTableViewController *alertsController = [[NotificationAlertsTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:alertsController];
	}
	else if ([kOtherMedsController isEqualToString:controllerName])
	{
		OtherMedicationsListTableViewController *otherController = [[OtherMedicationsListTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:otherController];
	}
	else if ([kProceduresController isEqualToString:controllerName])
	{
		ProceduresListTableViewController *procController = [[ProceduresListTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:procController];
	}
	else if ([kClinicsController isEqualToString:controllerName])
	{
		ClinicalAddressTableViewController *clinicController = [[ClinicalAddressTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:clinicController];
	}
	else if ([kMissedController isEqualToString:controllerName])
	{
		MissedMedicationsTableViewController *missedController = [[MissedMedicationsTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:missedController];
	}
	else if ([kSideEffectsController isEqualToString:controllerName])
	{
		SideEffectsTableViewController *effectsController = [[SideEffectsTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:effectsController];
	}
	else if ([kInfoController isEqualToString:controllerName])
	{
		InformationTableViewController *infoController = [[InformationTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:infoController];
	}
	else if ([kMedicationDiaryController isEqualToString:controllerName])
	{
		PWESSeinfeldViewController *calendarController = [[PWESSeinfeldViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:calendarController];
	}
	else if ([kSettingsController isEqualToString:controllerName])
	{
		SettingsTableViewController *settingsController = [[SettingsTableViewController alloc] init];
		navigationController = [[ContentNavigationController alloc]
		                        initWithRootViewController:settingsController];
	}
	else if ([kEmailController isEqualToString:controllerName])
	{
		EmailViewController *emailController = [[EmailViewController alloc]initWithStyle:UITableViewStyleGrouped];
		navigationController = [[ContentNavigationController alloc] initWithRootViewController:emailController];
	}
	return navigationController;
}

#pragma mark UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning> )animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
	PWESZoomTransition *zoomTransition = [[PWESZoomTransition alloc] init];
	zoomTransition.transitionType = kMenuTransition;
	return zoomTransition;
}

- (id <UIViewControllerAnimatedTransitioning> )animationControllerForDismissedController:(UIViewController *)dismissed
{
	PWESZoomTransition *zoomTransition = [[PWESZoomTransition alloc] init];
	zoomTransition.transitionType = kControllerTransition;
	return zoomTransition;
}

@end
