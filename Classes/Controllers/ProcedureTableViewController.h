//
//  ProcedureTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "SQLDataTableController.h"
#import "StatusViewControllerLandscape.h"
#import "BasicViewController.h"

@interface ProcedureTableViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
- (void)loadDetailProcedureViewController;
- (void)loadEditProcedureViewControllerForId:(NSUInteger)rowId;
- (IBAction)done:(id)sender;
- (void)reloadData:(NSNotification*)note;
- (void)start;
@end
