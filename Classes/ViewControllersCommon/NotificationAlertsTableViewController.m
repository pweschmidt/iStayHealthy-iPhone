//
//  NotificationAlertsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/09/2013.
//
//

#import "NotificationAlertsTableViewController.h"
//#import "ContentContainerViewController.h"
//#import "ContentNavigationController.h"
#import "Constants.h"
#import "EditAlertsTableViewController.h"
#import "TimeView.h"
#import "TimeCounter.h"

@interface NotificationAlertsTableViewController ()
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) UILocalNotification *markedNotification;
@property (nonatomic, strong) NSMutableArray *counterArray;
@end

@implementation NotificationAlertsTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.counterArray = [NSMutableArray array];
	[self retrieveLocalNotifications];
	[self setTitleViewWithTitle:NSLocalizedString(@"Alerts", nil)];
	self.markedNotification = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self restartCounters];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self stopCounters];
	[super viewWillDisappear:animated];
}

- (void)stopCounters
{
	[self.counterArray enumerateObjectsUsingBlock: ^(TimeCounter *counter, NSUInteger idx, BOOL *stop) {
	    [counter stopTimer];
	}];
}

- (void)retrieveLocalNotifications
{
	self.notifications = (NSArray *)[[UIApplication sharedApplication]scheduledLocalNotifications];
}

- (void)didReceiveMemoryWarning
{
	[self stopCounters];
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	EditAlertsTableViewController *controller = [[EditAlertsTableViewController alloc]
	                                             initWithStyle:UITableViewStyleGrouped
                                                 localNotification:nil];
	controller.notificationsDelegate = self;
	[self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[self configureCell:cell indexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
	NSArray *subviews = cell.contentView.subviews;
	[subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger index, BOOL *stop) {
	    [view removeFromSuperview];
	}];
	UILocalNotification *notification = [self.notifications objectAtIndex:indexPath.row];
	CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
	CGFloat scale = 1.6;
	TimeView *timeView = [TimeView viewWithTime:notification.fireDate frame:CGRectMake(20, 0, rowHeight * scale, rowHeight)];
	timeView.tag = indexPath.row;

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25 + rowHeight * scale, 0, 180, rowHeight / 2)];

	label.text = notification.alertBody;
	label.textAlignment = NSTextAlignmentLeft;
	label.textColor = TEXTCOLOUR;
	label.font = [UIFont fontWithType:Standard size:standard];
	label.tag = indexPath.row * 10;

	TimeCounter *counter = [TimeCounter viewWithTime:notification.fireDate notification:notification frame:CGRectMake(25 + rowHeight * scale, rowHeight / 2, 180, rowHeight / 2)];
//	[counter startTimer];
	counter.tag = indexPath.row * 100;
	[self.counterArray addObject:counter];

	[cell.contentView addSubview:timeView];
	[cell.contentView addSubview:label];
	[cell.contentView addSubview:counter];
}

- (void)restartCounters
{
	if (nil == self.counterArray || 0 == self.counterArray.count)
	{
		return;
	}
	[self.counterArray enumerateObjectsUsingBlock: ^(TimeCounter *counter, NSUInteger idx, BOOL *stop) {
	    [counter startTimer];
	}];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UITableViewCellEditingStyleDelete == editingStyle)
	{
		self.markedIndexPath = indexPath;
		self.markedNotification = (UILocalNotification *)[self.notifications
		                                                  objectAtIndex:indexPath.row];
		[self showDeleteAlertView];
	}
}

- (void)removeSQLEntry
{
	if (nil == self.markedNotification)
	{
		return;
	}
	[[UIApplication sharedApplication] cancelLocalNotification:self.markedNotification];
	self.notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	self.markedNotification = nil;
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UILocalNotification *notification = (UILocalNotification *)[self.notifications
	                                                            objectAtIndex:indexPath.row];
	EditAlertsTableViewController *controller = [[EditAlertsTableViewController alloc]
	                                             initWithStyle:UITableViewStyleGrouped
                                                 localNotification:notification];
	controller.notificationsDelegate = self;
	[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)reloadSQLData:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
}

#pragma mark NotificationsDelegate methods
- (void)updateLocalNotifications
{
	[self retrieveLocalNotifications];
    [self.tableView reloadData];
}

- (void)restartTimer
{
	[self restartCounters];
}

@end
