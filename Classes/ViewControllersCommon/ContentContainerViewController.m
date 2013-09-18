//
//  ContentContainerViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "ContentContainerViewController.h"
#import "HamburgerMenuTableViewController.h"
#import "AddMenuTableViewController.h"
#import "ResultsListTableViewController.h"
#import "MyHIVMedicationViewController.h"
#import "Constants.h"
#import "ContentNavigationController.h"
#import "DropboxViewController.h"
#import "DashboardViewController.h"
#import "Utilities.h"

@interface ContentContainerViewController ()
@property (nonatomic, strong) NSDictionary * controllers;
@property (nonatomic, strong) id currentController;
@property (nonatomic, strong) id previousController;
@end

@implementation ContentContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.controllers = [self rootControllers_iPhone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rewindToPreviousController
{
    if (nil == self.previousController)
    {
        return;
    }
    if (self.currentController == self.previousController)
    {
        return;
    }
    [self transitionFromViewController:self.currentController toViewController:self.previousController duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        self.currentController = self.previousController;
        self.previousController = nil;
    }];
}

- (void)transitionToNavigationControllerWithName:(NSString *)name
{
    id controller = [self.controllers objectForKey:name];
    [self transitionFromViewController:self.currentController toViewController:controller duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished){
        [controller didMoveToParentViewController:self];
        self.previousController = self.currentController;
        self.currentController = controller;
    }];
}

#pragma iPhone handling

- (NSDictionary *)rootControllers_iPhone
{
    HamburgerMenuTableViewController *menuController = [[HamburgerMenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    AddMenuTableViewController *addController = [[AddMenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ResultsListTableViewController *resultsController = [[ResultsListTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    DropboxViewController *dropBoxController = [[DropboxViewController alloc] init];
    MyHIVMedicationViewController *hivController = [[MyHIVMedicationViewController alloc] initWithStyle:UITableViewStyleGrouped];

    DashboardViewController *dashboardController = [[DashboardViewController alloc] init];

    menuController.view.frame       = self.view.frame;
    addController.view.frame        = self.view.frame;
    resultsController.view.frame    = self.view.frame;
    dropBoxController.view.frame    = self.view.frame;
    hivController.view.frame        = self.view.frame;
    dashboardController.view.frame  = self.view.frame;
    
    ContentNavigationController *menuNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:menuController];
    ContentNavigationController *addNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:addController];
    ContentNavigationController *resultsNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:resultsController];
    ContentNavigationController *dropNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:dropBoxController];
    ContentNavigationController *hivNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:hivController];
    
    ContentNavigationController *dashNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:dashboardController];
    
    [self addChildViewController:menuNavCtrl];
    [self addChildViewController:addNavCtrl];
    [self addChildViewController:resultsNavCtrl];
    [self addChildViewController:dropNavCtrl];
    [self addChildViewController:hivNavCtrl];
    [self addChildViewController:dashNavCtrl];

    [self.view addSubview:dashNavCtrl.view];
    self.currentController = dashNavCtrl;
    self.previousController = nil;
    
    NSDictionary *controllers = @{kMenuController : menuNavCtrl,
                                  kAddController : addNavCtrl,
                                  kResultsController : resultsNavCtrl,
                                  kDropboxController : dropNavCtrl,
                                  kHIVMedsController : hivNavCtrl,
                                  kDashboardController : dashNavCtrl
                                  };
    return controllers;
}

@end
