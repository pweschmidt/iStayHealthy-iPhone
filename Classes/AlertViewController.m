//
//  AlertViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlertViewController.h"
#import "MedAlertDetailViewController.h"
#import "MedAlertEditViewController.h"
#import "iStayHealthyRecord.h"
#import "AlertCell.h"

@implementation AlertViewController
@synthesize notificationsArray/*, headerView*/;

#pragma mark -
#pragma mark View lifecycle

/**
 loads/sets up the views
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadMedAlertDetailViewController)];
	self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.tableView.rowHeight = 57.0;
	self.notificationsArray = (NSMutableArray *)[[UIApplication sharedApplication]scheduledLocalNotifications];
    CGRect pozFrame = CGRectMake(CGRectGetMinX(headerView.bounds)+20, CGRectGetMinY(headerView.bounds)+2, 47.0, 30.0);
    UIButton *pozButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pozButton setFrame:pozFrame];
    [pozButton setBackgroundImage:[UIImage imageNamed:@"poz75.jpg"] forState:UIControlStateNormal];
    [pozButton addTarget:self action:@selector(loadWebView:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:pozButton];
/*
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        CGRect titleFrame = CGRectMake(CGRectGetMinX(navBar.bounds)+223.0, CGRectGetMinY(navBar.bounds)+5.0, 47.0, 30.0);
        UILabel *pozLabel = [[[UILabel alloc]initWithFrame:titleFrame]autorelease];
        [pozLabel setBackgroundColor:[UIColor clearColor]];
        UIImageView *pillView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"poz75.jpg"]]autorelease];
        [pozLabel addSubview:pillView];
        [navBar addSubview:pozLabel];
    }
 */
}

/**
 loads the MedAlertDetailViewController to create a new alert
 */
- (void)loadMedAlertDetailViewController{
	MedAlertDetailViewController *newAlertView = [[MedAlertDetailViewController alloc] initWithNibName:@"MedAlertDetailViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newAlertView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
}

/**
 done just before the view will appears. 
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.notificationsArray = (NSMutableArray *)[[UIApplication sharedApplication] scheduledLocalNotifications];
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view data source

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
	NSLog(@"number of notifications is %d",[self.notificationsArray count]);
#endif
    return [self.notificationsArray count];
}

/**
 returns cell height == 60.0
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == [self.notificationsArray count]) {
        return NSLocalizedString(@"No Alerts Set",nil);
    }
    else
        return @"";
}

/**
 load/setup the alert cells
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AlertCell *cell = (AlertCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[AlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
	NSString *pillPath = [[NSBundle mainBundle] pathForResource:@"Alarm-Clock-55" ofType:@"png"];
    
	UILocalNotification *notifcation = [self.notificationsArray objectAtIndex:indexPath.row];
	
	
	cell.imageView.image = [UIImage imageWithContentsOfFile:pillPath];
	cell.alarmLabel.text = notifcation.alertBody;
	cell.timeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"At", nil),[dateFormatter stringFromDate:notifcation.fireDate]];
	
    [dateFormatter release];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return (UITableViewCell *)cell;
}


/**
 only deletion of rows is permitted. The order in which this happens matter. first cancel the notification
 then remove it from the array. swapping will end up in a crash
 @tableView
 @editingStyle
 @indexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		UILocalNotification *notification = (UILocalNotification *)[self.notificationsArray objectAtIndex:indexPath.row];
		[[UIApplication sharedApplication] cancelLocalNotification:notification];
		[self.notificationsArray removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}



#pragma mark -
#pragma mark Table view delegate
/**
 when selecting a row - go to the MedAlertEditViewController to change the settings of the selected alert
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MedAlertEditViewController *medEditController = [[MedAlertEditViewController alloc] initWithNibName:@"MedAlertEditViewController" bundle:nil];
	medEditController.previousNotification = (UILocalNotification *)[self.notificationsArray objectAtIndex:indexPath.row];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medEditController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[medEditController release];
	[navigationController release];
	
}


#pragma mark -
#pragma mark Memory management
/**
 handle memory warnings
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 unload view
 */
- (void)viewDidUnload {
	[super viewDidUnload];
}

/**
 dealloc
 */
- (void)dealloc {
	[notificationsArray release];
//    [headerView release];
    [super dealloc];
}


@end

