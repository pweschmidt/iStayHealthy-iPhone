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
    if (self)
    {
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
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
#ifdef APPDEBUG
    NSLog(@"The screensize/height is %f ",height);
#endif
    NSMutableArray *viewControllersArray =
    [[NSMutableArray alloc]initWithCapacity:5];
    NewStatusViewController *statusView = nil;
    if (height < 568)
    {
        statusView = [[NewStatusViewController alloc]initWithNibName:@"NewStatusViewController" bundle:nil];
    }
    else
    {
        statusView = [[NewStatusViewController alloc]initWithNibName:@"NewStatusViewController_iPhone5" bundle:nil];
    }
//    DashboardViewController *statusView = [[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:nil];
//    statusView.title = NSLocalizedString(@"Charts", @"Charts");
    statusView.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Charts", @"Charts") image:[UIImage imageNamed:@"status-small.png"] tag:0];
    UINavigationController *statusNavController = [[UINavigationController alloc]initWithRootViewController:statusView];
    statusNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:statusNavController];
    
    NewResultsViewController *resultsView = [[NewResultsViewController alloc]initWithNibName:@"NewResultsViewController" bundle:nil];
//    resultsView.title = NSLocalizedString(@"Results", @"Results");
    resultsView.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Results", @"Results") image:[UIImage imageNamed:@"list-small.png"] tag:1];
    UINavigationController *resultsNavController = [[UINavigationController alloc]initWithRootViewController:resultsView];
    resultsNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:resultsNavController];
    
    HIVMedicationViewController *hivMedsView = [[HIVMedicationViewController alloc]initWithNibName:@"HIVMedicationViewController" bundle:nil];
//    hivMedsView.title = NSLocalizedString(@"HIV Drugs", @"HIV Drugs");
    hivMedsView.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"HIV Drugs", @"HIV Drugs") image:[UIImage imageNamed:@"combi-small.png"] tag:2];
    UINavigationController *hivMedsNavController = [[UINavigationController alloc]initWithRootViewController:hivMedsView];
    hivMedsNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:hivMedsNavController];
    
    NewAlertViewController *alertsView = [[NewAlertViewController alloc]initWithNibName:@"NewAlertViewController" bundle:nil];
//    alertsView.title = NSLocalizedString(@"Alerts", @"Alerts");
    alertsView.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Alerts", @"Alerts") image:[UIImage imageNamed:@"Alarm-Clock-32.png"] tag:3];
    UINavigationController *alertsNavController = [[UINavigationController alloc]initWithRootViewController:alertsView];
    alertsNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:alertsNavController];


    GeneralMedicalTableViewController *generalView = [[GeneralMedicalTableViewController alloc]
                                                       initWithNibName:@"GeneralMedicalTableViewController" bundle:nil];
//    generalView.title = NSLocalizedString(@"General", "General");
    generalView.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"General", @"General") image:[UIImage imageNamed:@"cross-small.png"] tag:4];
    UINavigationController *generalNavController = [[UINavigationController alloc]initWithRootViewController:generalView];
    generalNavController.navigationBar.tintColor = [UIColor blackColor];
    [viewControllersArray addObject:generalNavController];
    
    self.viewControllers = viewControllersArray;
    
    
    
}

#ifdef __IPHONE_6_0
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}
#endif
@end
