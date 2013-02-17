//
//  NewAlertViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 29/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

@interface NewAlertViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *notificationsArray;
- (void)loadMedAlertDetailViewController;
- (void)loadMedAlertChangeViewController:(int)row;
@end
