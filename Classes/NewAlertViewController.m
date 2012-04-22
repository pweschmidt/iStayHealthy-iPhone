//
//  NewAlertViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewAlertViewController.h"
#import "NewAlertDetailViewController.h"
#import "NewAlertEditDetailViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "iStayHealthyRecord.h"
#import "AlertListCell.h"
#import "UINavigationBar-Button.h"

@implementation NewAlertViewController
@synthesize notificationsArray;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/**
 dealloc
 */
- (void)dealloc {
	[notificationsArray release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
#ifdef APPDEBUG
    NSLog(@"NewAlertViewController viewDidLoad");
#endif
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadMedAlertDetailViewController)]autorelease];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        [navBar addButtonWithImageName:@"alertsnavbar.png" withTarget:self withSelector:@selector(gotoPOZ)];
    }
    self.tableView.rowHeight = 57.0;
	self.notificationsArray = (NSArray *)[[UIApplication sharedApplication]scheduledLocalNotifications];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef APPDEBUG
    NSLog(@"NewAlertViewController viewWillAppear");
#endif
    [super viewWillAppear:animated];
    self.notificationsArray = (NSArray *)[[UIApplication sharedApplication] scheduledLocalNotifications];
    [self.tableView reloadData];
}

/**
 loads the MedAlertDetailViewController to create a new alert
 */
- (void)loadMedAlertDetailViewController{
	NewAlertDetailViewController *newAlertView = [[NewAlertDetailViewController alloc] initWithNibName:@"NewAlertDetailViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newAlertView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [newAlertView release];
}
/*
loads the NewAlertEditDetailViewController to edit an existing alert
 */
- (void)loadMedAlertChangeViewController:(int)row{
    UILocalNotification *notification = (UILocalNotification *)[self.notificationsArray objectAtIndex:row];
	NewAlertEditDetailViewController *medEditController = [[NewAlertEditDetailViewController alloc] initWithNotification:notification];    
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medEditController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];	
    [navigationController release];
    [medEditController release];
    
}


/**
 @tableView
 @return 1 = only 1 section
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/**
 @tableView
 @section
 @return NSInteger the number of rows == the number of saved alerts
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#ifdef APPDEBUG
	NSLog(@"numberOfRowsInSection:: number of notifications is %d",[self.notificationsArray count]);
#endif
    return [self.notificationsArray count];
}

/**
 returns cell height == 60.0
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 70.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == [self.notificationsArray count]) {
        return NSLocalizedString(@"No Alerts Set",nil);
    }
    else
        return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"AlertListCell";
    AlertListCell *cell = (AlertListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"AlertListCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[AlertListCell class]]) {
                cell = (AlertListCell *)currentObject;
                break;
            }
        }
    }
	UILocalNotification *notifcation = [self.notificationsArray objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
    [dateFormatter setDateFormat:@"HH:mm"];
    [[cell title]setText:[dateFormatter stringFromDate:notifcation.fireDate]];
    [[cell text]setText:notifcation.alertBody];
    return cell;
}


#pragma mark -
#pragma mark Table view delegate
/**
 when selecting a row - go to the MedAlertEditViewController to change the settings of the selected alert
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self loadMedAlertChangeViewController:indexPath.row];
}

@end
