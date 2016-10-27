//
//  ProceduresListTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/09/2013.
//
//

#import "ProceduresListTableViewController.h"
#import "Constants.h"
#import "DateView.h"
#import "EditProceduresTableViewController.h"
#import "Procedures+Handling.h"
#import "UILabel+Standard.h"
#import "iStayHealthy-Swift.h"

@interface ProceduresListTableViewController ()
@property (nonatomic, strong) NSArray *procedures;
@end

@implementation ProceduresListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.procedures = [NSArray array];     // init with empty array
    [self setTitleViewWithTitle:NSLocalizedString(@"Illness", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
    EditProceduresTableViewController *controller = [[EditProceduresTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];

    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.procedures.count;
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

    [subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger index, BOOL *stop) {
         [view removeFromSuperview];
     }];
    Procedures *procedures = (Procedures *) [self.procedures objectAtIndex:indexPath.row];
    CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath] - 2;
    UILabel *name = [UILabel standardLabel];
    name.text = procedures.Illness;
    name.frame = CGRectMake(20 + rowHeight + 10, 1, 170, rowHeight / 2);

    UILabel *proc = [UILabel standardLabel];
    proc.text = procedures.Name;
    proc.frame = CGRectMake(20 + rowHeight + 10, 1 + rowHeight / 2, 170, rowHeight / 2);


    DateView *dateView = [DateView viewWithDate:procedures.Date frame:CGRectMake(20, 1, rowHeight, rowHeight)];

    [cell.contentView addSubview:name];
    [cell.contentView addSubview:proc];
    [cell.contentView addSubview:dateView];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle)
    {
        self.markedIndexPath = indexPath;
        self.markedObject = [self.procedures objectAtIndex:indexPath.row];
        [self showDeleteAlertView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Procedures *proc = (Procedures *) [self.procedures objectAtIndex:indexPath.row];
    EditProceduresTableViewController *controller = [[EditProceduresTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:proc hasNumericalInput:NO];

    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];

    [manager fetchData:kProcedures
             predicate:nil
              sortTerm:kDate
             ascending:NO completion: ^(NSArray *array, NSError *error) {
         if (nil == array)
         {
             [PWESAlertHandler.alertHandler
              showAlertViewWithCancelButton:NSLocalizedString(@"Error", nil)
              message:NSLocalizedString(@"Error loading data", nil)
              presentingController:self];
         }
         else
         {
             self.procedures = nil;
             self.procedures = [NSArray arrayWithArray:array];
             [self.tableView reloadData];
         }
     }];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    [self reloadSQLData:notification];
}

@end
