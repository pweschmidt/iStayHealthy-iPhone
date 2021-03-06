//
//  EditAlertsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "BaseEditTableViewController.h"
#import "NotificationsDelegate.h"
#import "SoundSelector.h"

@interface EditAlertsTableViewController : BaseEditTableViewController <SoundSelector>
@property (nonatomic, weak) id <NotificationsDelegate> notificationsDelegate;
- (id)  initWithStyle:(UITableViewStyle)style
    localNotification:(UILocalNotification *)localNotification;
@end
