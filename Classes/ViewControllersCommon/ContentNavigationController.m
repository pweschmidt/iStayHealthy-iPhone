//
//  ContentNavigationController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/08/2013.
//
//

#import "ContentNavigationController.h"
#import "ContentContainerViewController.h"


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
    [(ContentContainerViewController *)self.parentViewController transitionToNavigationControllerWithName:name];
}

- (void)rewindToPreviousController
{
    [(ContentContainerViewController *)self.parentViewController rewindToPreviousController];
}

@end
