//
//  EditAlertsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "BaseEditTableViewController.h"
#import "NotificationsDelegate.h"

@interface EditAlertsTableViewController : BaseEditTableViewController
@property (nonatomic, weak) id <NotificationsDelegate> notificationsDelegate;
- (id)  initWithStyle:(UITableViewStyle)style
    localNotification:(UILocalNotification *)localNotification;
@end
