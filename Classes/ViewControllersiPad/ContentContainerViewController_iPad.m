//
//  ContentContainerViewController_iPad.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import "ContentContainerViewController_iPad.h"
#import "HamburgerMenuTableViewController.h"
#import "AddMenuTableViewController.h"
#import "ResultsListTableViewController.h"
#import "ResultsCollectionViewController.h"
#import "MyHIVMedicationViewController.h"
#import "Constants.h"
#import "ContentNavigationController_iPad.h"
#import "DropboxViewController.h"
#import "Utilities.h"
#import "PWESSlideTransition.h"

@interface ContentContainerViewController_iPad ()
@property (nonatomic, strong) NSDictionary *controllers;
@property (nonatomic, strong) id currentController;
@property (nonatomic, strong) id previousController;
@end

@implementation ContentContainerViewController_iPad

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	ContentNavigationController_iPad *navigationController = [self navigationControllerForName_iPad:kResultsController];
	[self addChildViewController:navigationController];
	[self moveToChildNavigationController:navigationController];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
	{
		if (self.view.frame.size.width < self.view.frame.size.height)
		{
			self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width);
		}
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)showMenu
{
	self.transitionType = kMenuTransition;
	HamburgerMenuTableViewController *menuController = [[HamburgerMenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	menuController.modalPresentationStyle = UIModalPresentationCustom;
	menuController.transitioningDelegate = self;
	menuController.transitionDelegate = self;
	[self presentViewController:menuController animated:YES completion:nil];
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
	else if ([kDropboxController isEqualToString:controllerName])
	{
		DropboxViewController *dropBoxController = [[DropboxViewController alloc] init];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:dropBoxController];
	}
	else if ([kHIVMedsController isEqualToString:controllerName])
	{
		MyHIVMedicationViewController *hivController = [[MyHIVMedicationViewController alloc] initWithStyle:UITableViewStyleGrouped];
		navigationController = [[ContentNavigationController_iPad alloc] initWithRootViewController:hivController];
	}
	return navigationController;
}

@end
