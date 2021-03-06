//
//  BaseTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import "BaseViewController.h"
#import "ContainerViewControllerDelegate.h"
#import "UIFont+Standard.h"
#import "UINavigationBar-Button.h"

@interface BaseTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSManagedObject *markedObject;
@property (nonatomic, strong) NSIndexPath *markedIndexPath;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *tableIndicatorView;
@property (nonatomic, strong) UILabel *tableActivityLabel;
- (void)showDeleteAlertView;
- (void)removeSQLEntry;
- (void)deselect:(id)sender;
- (void)animateTableViewWithText:(NSString *)text;
- (void)stopAnimateTableViewWithText:(NSString *)text;
@end
