//
//  ContentNavigationController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/08/2013.
//
//

#import "ContentNavigationController.h"
#import "ContentContainerViewController.h"
#import "Utilities.h"

@interface ContentNavigationController ()

@end

@implementation ContentNavigationController


- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)transitionToNavigationControllerWithName:(NSString *)name
{
	[(ContentContainerViewController *)self.parentViewController transitionToNavigationControllerWithName : name completion : nil];
}

- (void)showMenu
{
	if ([self.parentViewController isKindOfClass:[ContentContainerViewController class]])
	{
		ContentContainerViewController *container = (ContentContainerViewController *)self.parentViewController;
		[container showMenu];
	}
}

- (void)hideMenu
{
	if ([self.parentViewController isKindOfClass:[ContentContainerViewController class]])
	{
		ContentContainerViewController *container = (ContentContainerViewController *)self.parentViewController;
		[container hideMenu];
	}
}

- (void)showMailController:(MFMailComposeViewController *)mailController
{
	if ([self.parentViewController isKindOfClass:[ContentContainerViewController class]])
	{
		ContentContainerViewController *container = (ContentContainerViewController *)self.parentViewController;
		[container showMailController:mailController];
	}
}

- (void)hideMailController:(MFMailComposeViewController *)mailController
{
	if ([self.parentViewController isKindOfClass:[ContentContainerViewController class]])
	{
		ContentContainerViewController *container = (ContentContainerViewController *)self.parentViewController;
		[container hideMailController:mailController];
	}
}

@end
