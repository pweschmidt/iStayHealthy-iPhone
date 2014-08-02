//
//  ContainerViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/06/2013.
//
//

#import "ContainerViewController.h"
#import "LoginViewController.h"
#import "ContentContainerViewController.h"
#import "Constants.h"
#import "Utilities.h"
#import "KeychainHandler.h"
#import "AppSettings.h"

@interface ContainerViewController ()
@property (nonatomic, strong) LoginViewController *loginController;
@property (nonatomic, strong) ContentContainerViewController *contentController;
@property (nonatomic, strong) id currentController;
@end

@implementation ContainerViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
#ifdef APPDEBUG
	NSLog(@"We got to the ContainerViewController - hurrah");
#endif
	self.loginController = [self.storyboard
	                        instantiateViewControllerWithIdentifier:@"loginController"];
	if (nil != self.loginController)
	{
		self.loginController.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
		[self addChildViewController:self.loginController];
	}
	self.contentController = [self.storyboard
	                          instantiateViewControllerWithIdentifier:@"contentController"];
	if (nil != self.contentController)
	{
		self.contentController.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
		[self addChildViewController:self.contentController];
	}

	[[AppSettings sharedInstance] disablePasswordForUpdate];
	BOOL isPasswordEnabled = [[AppSettings sharedInstance] hasPasswordEnabled];
	if (isPasswordEnabled)
	{
#ifdef APPDEBUG
		NSLog(@"calling the login view controller");
#endif
		[self.view addSubview:self.loginController.view];
		self.currentController = self.loginController;
	}
	else
	{
#ifdef APPDEBUG
		NSLog(@"Calling the content container view controller");
#endif
		[self.view addSubview:self.contentController.view];
		self.currentController = self.contentController;
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (IBAction)transitionToContentController:(id)sender
{
	[self transitionFromViewController:self.currentController toViewController:self.contentController duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion: ^(BOOL finished) {
	    [self.contentController didMoveToParentViewController:self];
	    self.currentController = self.contentController;
	}];
}

- (IBAction)transitionToLoginController:(id)sender
{
	[self transitionFromViewController:self.currentController toViewController:self.loginController duration:0 options:UIViewAnimationTransitionNone animations:nil completion: ^(BOOL finished) {
	    [self.loginController didMoveToParentViewController:self];
	    self.currentController = self.loginController;
	}];
}

@end
