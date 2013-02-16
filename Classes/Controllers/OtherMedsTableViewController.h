//
//  OtherMedsTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "SQLDataTableController.h"
#import "StatusViewControllerLandscape.h"
#import "BasicViewController.h"

@interface OtherMedsTableViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
- (void)loadDetailOtherMedsController;
- (void)loadEditMedsControllerForId:(NSUInteger)rowId;
- (IBAction)done:(id)sender;
- (void)reloadData:(NSNotification*)note;
- (void)start;
@end
