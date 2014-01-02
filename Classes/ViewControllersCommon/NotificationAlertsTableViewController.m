//
//  NotificationAlertsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/09/2013.
//
//

#import "NotificationAlertsTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "EditAlertsTableViewController.h"
#import "TimeView.h"

@interface NotificationAlertsTableViewController ()
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) UILocalNotification *markedNotification;
@end

@implementation NotificationAlertsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.notifications = (NSArray *)[[UIApplication sharedApplication]scheduledLocalNotifications];;
    [self setTitleViewWithTitle:NSLocalizedString(@"Alerts", nil)];
    self.markedNotification = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
    EditAlertsTableViewController *controller = [[EditAlertsTableViewController alloc]
                                                 initWithStyle:UITableViewStyleGrouped
                                                 localNotification:nil];
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
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        [view removeFromSuperview];
    }];
    UILocalNotification *notification = [self.notifications objectAtIndex:indexPath.row];
    CGFloat rowHeight = self.tableView.rowHeight - 2;
    TimeView *timeView = [TimeView viewWithTime:notification.fireDate frame:CGRectMake(20, 1, rowHeight, rowHeight)];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = notification.alertBody;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = TEXTCOLOUR;
    label.font = [UIFont fontWithType:Standard size:Standard];
    [cell.contentView addSubview:timeView];
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
    [self.tableView beginUpdates];
    [[UIApplication sharedApplication] cancelLocalNotification:self.markedNotification];
    self.notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    self.markedNotification = nil;
    [self.tableView endUpdates];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILocalNotification *notification = (UILocalNotification *)[self.notifications
                                                                objectAtIndex:indexPath.row];
    EditAlertsTableViewController *controller = [[EditAlertsTableViewController alloc]
                                                 initWithStyle:UITableViewStyleGrouped
                                                 localNotification:notification];
    [self.navigationController pushViewController:controller animated:YES];
    
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
