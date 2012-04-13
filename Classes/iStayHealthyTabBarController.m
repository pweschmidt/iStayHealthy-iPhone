//
//  iStayHealthyTabBarController.m
//  iStayHealthy
//
//  Created by peterschmidt on 06/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "iStayHealthyTabBarController.h"
#import "NewStatusViewController.h"
#import "NewResultsViewController.h"
#import "HIVMedicationViewController.h"
#import "NewAlertViewController.h"
#import "GeneralMedicalTableViewController.h"

@implementation iStayHealthyTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/**
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableArray *viewControllersArray = 
    [[[NSMutableArray alloc]initWithCapacity:5]autorelease];
    
    NewStatusViewController *statusView = [[[NewStatusViewController alloc]initWithNibName:@"NewStatusViewController" bundle:nil]autorelease];
//    statusView.title = NSLocalizedString(@"Charts", @"Charts");
    statusView.tabBarItem = [[[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Charts", @"Charts") image:[UIImage imageNamed:@"status-small.png"] tag:0]autorelease];
    UINavigationController *statusNavController = [[[UINavigationController alloc]initWithRootViewController:statusView]autorelease];
    statusNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:statusNavController];
    
    NewResultsViewController *resultsView = [[[NewResultsViewController alloc]initWithNibName:@"NewResultsViewController" bundle:nil]autorelease];
//    resultsView.title = NSLocalizedString(@"Results", @"Results");
    resultsView.tabBarItem = [[[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Results", @"Results") image:[UIImage imageNamed:@"list-small.png"] tag:1]autorelease];
    UINavigationController *resultsNavController = [[[UINavigationController alloc]initWithRootViewController:resultsView]autorelease];
    resultsNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:resultsNavController];
    
    HIVMedicationViewController *hivMedsView = [[[HIVMedicationViewController alloc]initWithNibName:@"HIVMedicationViewController" bundle:nil]autorelease];
//    hivMedsView.title = NSLocalizedString(@"HIV Drugs", @"HIV Drugs");
    hivMedsView.tabBarItem = [[[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"HIV Drugs", @"HIV Drugs") image:[UIImage imageNamed:@"combi-small.png"] tag:2]autorelease];
    UINavigationController *hivMedsNavController = [[[UINavigationController alloc]initWithRootViewController:hivMedsView]autorelease];
    hivMedsNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:hivMedsNavController];
    
    NewAlertViewController *alertsView = [[[NewAlertViewController alloc]initWithNibName:@"NewAlertViewController" bundle:nil]autorelease];
//    alertsView.title = NSLocalizedString(@"Alerts", @"Alerts");
    alertsView.tabBarItem = [[[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Alerts", @"Alerts") image:[UIImage imageNamed:@"Alarm-Clock-32.png"] tag:3]autorelease];
    UINavigationController *alertsNavController = [[[UINavigationController alloc]initWithRootViewController:alertsView]autorelease];
    alertsNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:alertsNavController];


    GeneralMedicalTableViewController *generalView = [[[GeneralMedicalTableViewController alloc]
                                                       initWithNibName:@"GeneralMedicalTableViewController" bundle:nil]autorelease];
//    generalView.title = NSLocalizedString(@"General", "General");
    generalView.tabBarItem = [[[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"General", @"General") image:[UIImage imageNamed:@"cross-small.png"] tag:4]autorelease];
    UINavigationController *generalNavController = [[[UINavigationController alloc]initWithRootViewController:generalView]autorelease];
    generalNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:generalNavController];
    
    self.viewControllers = viewControllersArray;
    
    
    
}

- (void)viewDidUnload
{
#ifdef APPDEBUG
    NSLog(@"in iStayHealthyTabBarController::viewDidUnload");
#endif
    [super viewDidUnload];
}
- (void)viewWillDisappear:(BOOL)animated {
#ifdef APPDEBUG
    NSLog(@"in iStayHealthyTabBarController::viewWillDisappear");
#endif
    [super viewWillDisappear:animated];
}


@end
