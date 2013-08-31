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
#import "MyHIVMedicationViewController.h"
#import "Constants.h"
#import "ContentNavigationController.h"
#import "DropboxViewController.h"
#import "Utilities.h"

@interface ContentContainerViewController_iPad ()
@property (nonatomic, strong) NSDictionary * controllers;
@property (nonatomic, strong) id currentController;
@property (nonatomic, strong) id previousController;
@end

@implementation ContentContainerViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.controllers = [self rootControllers_iPad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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


#pragma iPad handling
- (NSDictionary *)rootControllers_iPad
{
    ResultsListTableViewController *resultsController = [[ResultsListTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    DropboxViewController *dropBoxController = [[DropboxViewController alloc] init];
    MyHIVMedicationViewController *hivController = [[MyHIVMedicationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    //    resultsController.view.frame = self.view.frame;
    //    dropBoxController.view.frame = self.view.frame;
    //    hivController.view.frame = self.view.frame;
    
    ContentNavigationController *resultsNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:resultsController];
    ContentNavigationController *dropNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:dropBoxController];
    ContentNavigationController *hivNavCtrl = [[ContentNavigationController alloc] initWithRootViewController:hivController];
    
    [self addChildViewController:resultsNavCtrl];
    [self addChildViewController:dropNavCtrl];
    [self addChildViewController:hivNavCtrl];
    
    [self.view addSubview:resultsNavCtrl.view];
    
    self.currentController = resultsNavCtrl;
    self.previousController = nil;
    
    NSDictionary *controllers = @{kResultsController : resultsNavCtrl,
                                  kDropboxController : dropNavCtrl,
                                  kHIVMedsController : hivNavCtrl
                                  };
    
    return controllers;
}

@end
