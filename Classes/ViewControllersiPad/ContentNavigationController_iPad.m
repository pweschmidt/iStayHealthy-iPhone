//
//  ContentNavigationController_iPad.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/02/2014.
//
//

#import "ContentNavigationController_iPad.h"
#import "ContentContainerViewController_iPad.h"

@interface ContentNavigationController_iPad ()

@end

@implementation ContentNavigationController_iPad
- (void)viewDidLoad
{
	[super viewDidLoad];
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
	// Dispose of any resources that can be recreated.
}

- (void)transitionToNavigationControllerWithName:(NSString *)name
{
	[(ContentContainerViewController_iPad *)self.parentViewController transitionToNavigationControllerWithName : name completion : nil];
}

- (void)showMenu
{
	if ([self.parentViewController isKindOfClass:[ContentContainerViewController_iPad class]])
	{
		ContentContainerViewController_iPad *container = (ContentContainerViewController_iPad *)self.parentViewController;
		[container showMenu];
	}
}

@end
