//
//  MissedMedViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLDataTableController.h"
#import "StatusViewControllerLandscape.h"

@class iStayHealthyRecord;
@interface MissedMedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
- (IBAction) done:					(id) sender;
- (NSString *)getStringFromName:(NSString *)name;
- (void)reloadData:(NSNotification*)note;
- (id)initWithContext:(NSManagedObjectContext  *)context medications:(NSArray *)medications;
@end
