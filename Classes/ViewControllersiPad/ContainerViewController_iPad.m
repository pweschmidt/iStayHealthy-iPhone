//
//  ContainerViewController_iPad.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import "ContainerViewController_iPad.h"
#import "LoginViewController_iPad.h"
#import "ContentContainerViewController_iPad.h"
#import "Constants.h"
#import "Utilities.h"
#import "KeychainHandler.h"
#import "AppSettings.h"

@interface ContainerViewController_iPad ()
@property (nonatomic, strong) LoginViewController_iPad *loginController;
@property (nonatomic, strong) ContentContainerViewController_iPad *contentController;
@property (nonatomic, strong) id currentController;
@end

@implementation ContainerViewController_iPad

- (void)viewDidLoad
{
	[super viewDidLoad];
	[[AppSettings sharedInstance] disablePasswordForUpdate];
#ifdef APPDEBUG
	NSLog(@"We got to the ContainerViewController for iPad - hurrah");
#endif
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
	{
		if (self.view.frame.size.width < self.view.frame.size.height)
		{
			self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width);
		}
	}
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
	// Dispose of any resources that can be recreated.
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
