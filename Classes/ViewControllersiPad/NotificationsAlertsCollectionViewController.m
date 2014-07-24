//
//  NotificationsAlertsCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/04/2014.
//
//

#import "NotificationsAlertsCollectionViewController.h"
#import "BaseCollectionViewCell.h"
#import "Constants.h"
#import "EditAlertsTableViewController.h"
#import "TimeView_iPad.h"
#import "TimeCounter.h"

#define kAlertsCollectionCellIdentifier @"AlertsCollectionCellIdentifier"

@interface NotificationsAlertsCollectionViewController ()
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) UILocalNotification *markedNotification;
@property (nonatomic, strong) NSMutableArray *counterArray;
@end

@implementation NotificationsAlertsCollectionViewController
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.counterArray = [NSMutableArray array];
	[self retrieveLocalNotifications];
	[self setTitleViewWithTitle:NSLocalizedString(@"Alerts", nil)];
	self.markedNotification = nil;
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kAlertsCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	EditAlertsTableViewController *editController = [[EditAlertsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
	editController.notificationsDelegate = self;
	editController.preferredContentSize = CGSizeMake(320, 568);
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.notifications.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UILocalNotification *notification = [self.notifications objectAtIndex:indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAlertsCollectionCellIdentifier
	                                                                         forIndexPath:indexPath];

	[cell setManagedObject:nil];
	if (nil != notification)
	{
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.timeStyle = NSDateFormatterShortStyle;
		[cell addTitle:[formatter stringFromDate:notification.fireDate]];

		TimeView_iPad *view = [TimeView_iPad viewWithNotification:notification frame:CGRectMake(0, 2, 150, 130)];
		[view startTimer];
		NSInteger tag = indexPath.row * 100;
		if (![self.counterArray containsObject:view])
		{
			view.tag = tag;
			[self.counterArray addObject:view];
		}
		[cell addView:view];
	}
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	UILocalNotification *notification = (UILocalNotification *)[self.notifications
	                                                            objectAtIndex:indexPath.row];
	EditAlertsTableViewController *controller = [[EditAlertsTableViewController alloc] initWithStyle:UITableViewStyleGrouped
	                                                                               localNotification:notification];
	controller.notificationsDelegate = self;
	controller.preferredContentSize = CGSizeMake(320, 568);
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:controller];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
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
}

- (void)reloadSQLData:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
}

- (void)retrieveLocalNotifications
{
	self.notifications = (NSArray *)[[UIApplication sharedApplication]scheduledLocalNotifications];
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

#pragma mark NotificationsDelegate methods
- (void)updateLocalNotifications
{
	[self retrieveLocalNotifications];
	[self.collectionView reloadData];
}

- (void)restartTimer
{
//	[self restartCounters];
}

@end
