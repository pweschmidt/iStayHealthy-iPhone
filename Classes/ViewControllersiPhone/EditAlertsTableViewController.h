//
//  EditAlertsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "BaseEditTableViewController.h"

@interface EditAlertsTableViewController : BaseEditTableViewController
- (id)initWithStyle:(UITableViewStyle)style
  localNotification:(UILocalNotification *)localNotification;
@end
