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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)transitionToNavigationControllerWithName:(NSString *)name
{
	[(ContentContainerViewController_iPad *)self.parentViewController transitionToNavigationControllerWithName : name];
}

- (void)rewindToPreviousController
{
	[(ContentContainerViewController_iPad *)self.parentViewController rewindToPreviousController];
}

- (BOOL)shouldAutorotate
{
	return [self.topViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
