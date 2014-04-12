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
#import "TimeView.h"

#define kAlertsCollectionCellIdentifier @"AlertsCollectionCellIdentifier"

@interface NotificationsAlertsCollectionViewController ()
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) UILocalNotification *markedNotification;
@end

@implementation NotificationsAlertsCollectionViewController
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.notifications = (NSArray *)[[UIApplication sharedApplication]scheduledLocalNotifications];
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
	if (nil == self.customPopoverController)
	{
		EditAlertsTableViewController *editController = [[EditAlertsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
		editController.preferredContentSize = CGSizeMake(320, 568);
		editController.customPopOverDelegate = self;
		UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
		[self presentPopoverWithController:editNavCtrl fromBarButton:(UIBarButtonItem *)sender];
	}
	else
	{
		[self hidePopover];
	}
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
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self hidePopover];
	UILocalNotification *notification = (UILocalNotification *)[self.notifications
	                                                            objectAtIndex:indexPath.row];
	EditAlertsTableViewController *controller = [[EditAlertsTableViewController alloc] initWithStyle:UITableViewStyleGrouped
	                                                                               localNotification:notification];
	controller.preferredContentSize = CGSizeMake(320, 568);
	controller.customPopOverDelegate = self;
	//	UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentPopoverWithController:editNavCtrl
	                          fromRect:CGRectMake(self.view.frame.size.width / 2 - 160, 10, 320, 50)];
}

- (void)removeSQLEntry
{
	if (nil == self.markedNotification)
	{
		return;
	}
//    [self.tableView beginUpdates];
	[[UIApplication sharedApplication] cancelLocalNotification:self.markedNotification];
	self.notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	self.markedNotification = nil;
//    [self.tableView endUpdates];
}

- (void)reloadSQLData:(NSNotification *)notification
{
}

- (void)startAnimation:(NSNotification *)notification
{
}

- (void)stopAnimation:(NSNotification *)notification
{
}

- (void)handleError:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
}

@end