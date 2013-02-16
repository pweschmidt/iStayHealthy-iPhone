//
//  SideEffectsViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLDataTableController.h"
#import "StatusViewControllerLandscape.h"
#import "BasicViewController.h"
@interface SideEffectsViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
- (IBAction) done:					(id) sender;
- (id)initWithContext:(NSManagedObjectContext *)context medications:(NSArray *)medications;
- (void)reloadData:(NSNotification*)note;
- (void)start;
@end
