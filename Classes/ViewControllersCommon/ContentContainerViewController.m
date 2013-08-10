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
#import "Constants.h"
#import "ContentNavigationController.h"

@interface ContentContainerViewController ()
@property (nonatomic, strong) NSDictionary * controllers;
@property (nonatomic, strong) id currentController;
@property (nonatomic, strong) id previousController;
@end

@implementation ContentContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.controllers = [self rootControllers];
    
    
    
    
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


- (NSDictionary *)rootControllers
{
    HamburgerMenuTableViewController *menuController = [[HamburgerMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
    AddMenuTableViewController *addController = [[AddMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
    ResultsListTableViewController *resultsController = [[ResultsListTableViewController alloc]init];
    
    menuController.view.frame = self.view.frame;
    addController.view.frame = self.view.frame;
    resultsController.view.frame = self.view.frame;
    
    ContentNavigationController *menuNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:menuController];
    ContentNavigationController *addNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:addController];
    ContentNavigationController *resultsNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:resultsController];
    
    

    [self addChildViewController:menuNavCtrl];
    [self addChildViewController:addNavCtrl];
    [self addChildViewController:resultsNavCtrl];

    [self.view addSubview:resultsNavCtrl.view];
    self.currentController = resultsNavCtrl;
    self.previousController = nil;
    
    NSDictionary *controllers = @{kMenuController : menuNavCtrl,
                                  kAddController : addNavCtrl,
                                  kResultsController : resultsNavCtrl};
    return controllers;
}


@end
