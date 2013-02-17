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
#import "GeneralSettings.h"
#import "UINavigationBar-Button.h"

@interface NewAlertViewController ()
@property (nonatomic, strong) NSTimer *timeLeftUpdater;
- (void)updateTimeLeftLabel:(UILabel *)timeLeftLabel;
@end

@implementation NewAlertViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)reloadData:(NSNotification *)note
{
    ///empty implementation
}

- (void)start
{
    ///empty implementation
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
#ifdef APPDEBUG
    NSLog(@"NewAlertViewController viewDidLoad");
#endif
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadMedAlertDetailViewController)];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"Alerts" target:self selector:@selector(gotoPOZ)];
    }
    self.tableView.rowHeight = 57.0;
	self.notificationsArray = (NSArray *)[[UIApplication sharedApplication]scheduledLocalNotifications];
}

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.notificationsArray = nil;
    [super viewDidUnload];
}
#endif

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
- (void)loadMedAlertDetailViewController
{
	NewAlertDetailViewController *newAlertView = [[NewAlertDetailViewController alloc] initWithNibName:@"NewAlertDetailViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newAlertView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}
/*
loads the NewAlertEditDetailViewController to edit an existing alert
 */
- (void)loadMedAlertChangeViewController:(int)row
{
    UILocalNotification *notification = (UILocalNotification *)[self.notificationsArray objectAtIndex:row];
	NewAlertEditDetailViewController *medEditController = [[NewAlertEditDetailViewController alloc] initWithNotification:notification];    
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medEditController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];	
    
}


/**
 @tableView
 @return 1 = only 1 section
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 @tableView
 @section
 @return NSInteger the number of rows == the number of saved alerts
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 70.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == [self.notificationsArray count])
    {
        return NSLocalizedString(@"No Alerts Set",nil);
    }
    else
        return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"AlertListCell";
    AlertListCell *cell = (AlertListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"AlertListCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[AlertListCell class]])
            {
                cell = (AlertListCell *)currentObject;
                break;
            }
        }
    }
	UILocalNotification *notifcation = [self.notificationsArray objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *now = [NSDate date];
    NSTimeInterval elapsedTime = [now timeIntervalSinceDate:notifcation.fireDate];
    NSTimeInterval dayInSeconds = 24 * 60 * 60;
    NSTimeInterval hourInSeconds = 3600;
    int days = elapsedTime / dayInSeconds;
    NSTimeInterval lasttime = days * dayInSeconds;
    NSTimeInterval nexttime = lasttime + dayInSeconds;
    NSTimeInterval difference = nexttime - elapsedTime;
    if (dayInSeconds < difference)
    {
        difference = difference - dayInSeconds;
    }
    NSString *timeLeft = [NSString stringWithFormat:@"%02li:%02li",
                          lround(floor(difference / 3600.)) % 100,
                          lround(floor(difference / 60.)) % 60];
    NSString *fullTimeLeftText = [NSString stringWithFormat:@"%@ %@",timeLeft, NSLocalizedString(@"remaining", @"remaining")];
    if (difference <= hourInSeconds)
    {
        cell.timeLeftLabel.textColor = DARK_RED;
    }
    cell.timeLeftLabel.text = fullTimeLeftText;
    
    
    cell.title.text = [dateFormatter stringFromDate:notifcation.fireDate];
    cell.text.text = notifcation.alertBody;
    return cell;
}

- (void)updateTimeLeftLabel:(UILabel *)timeLeftLabel
{
}


#pragma mark -
#pragma mark Table view delegate
/**
 when selecting a row - go to the MedAlertEditViewController to change the settings of the selected alert
 @tableView
 @indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self loadMedAlertChangeViewController:indexPath.row];
}

@end
