//
//  ResultsListTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/08/2013.
//
//

#import "ResultsListTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "DateView.h"
#import "ResultsView_iPhone.h"
#import "Results.h"
#import "EditResultsTableViewController.h"

@interface ResultsListTableViewController ()
@property (nonatomic, strong) NSArray *results;
@end

@implementation ResultsListTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.results = [NSArray array]; //init with empty array
	[self setTitleViewWithTitle:NSLocalizedString(@"Results", nil)];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.results.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (0 == self.results.count)
	{
		return NSLocalizedString(@"No Results Entered", nil);
	}
	else
		return @"";
}

- (void)addButtonPressed:(id)sender
{
	EditResultsTableViewController *editController = [[EditResultsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:YES];
	[self.navigationController pushViewController:editController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = [NSString stringWithFormat:@"ResultsCell%ld", (long)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	[self configureResultsCell:cell indexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)configureResultsCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
	NSArray *subviews = cell.contentView.subviews;
	[subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger index, BOOL *stop) {
	    [view removeFromSuperview];
	}];
	Results *results = [self.results objectAtIndex:indexPath.row];
	CGFloat rowHeight = self.tableView.rowHeight - 2;
	DateView *dateView = [DateView viewWithDate:results.ResultsDate frame:CGRectMake(20, 1, rowHeight, rowHeight)];

	ResultsView_iPhone *hivView = [ResultsView_iPhone viewForResults:results resultsType:HIVResultsType frame:CGRectMake(70, 1, 70, rowHeight)];

	ResultsView_iPhone *bloodView = [ResultsView_iPhone viewForResults:results resultsType:BloodResultsType frame:CGRectMake(145, 1, 60, rowHeight)];

	ResultsView_iPhone *otherView = [ResultsView_iPhone viewForResults:results resultsType:OtherResultsType frame:CGRectMake(210, 1, 60, rowHeight)];

	[cell.contentView addSubview:dateView];
	[cell.contentView addSubview:hivView];
	[cell.contentView addSubview:bloodView];
	[cell.contentView addSubview:otherView];
	[cell.contentView setNeedsDisplay];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UITableViewCellEditingStyleDelete == editingStyle)
	{
		self.markedIndexPath = indexPath;
		self.markedObject = [self.results objectAtIndex:indexPath.row];
		[self showDeleteAlertView];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Results *results = [self.results objectAtIndex:indexPath.row];
	EditResultsTableViewController *editController = [[EditResultsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:results hasNumericalInput:YES];
	editController.menuDelegate = nil;
	[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	[self.navigationController pushViewController:editController animated:YES];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
#ifdef APPDEBUG
	NSLog(@"ResultsListTableViewController:reloadSQLData with name %@", notification.name);
#endif
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kResults predicate:nil sortTerm:kResultsDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	    if (nil == array)
	    {
	        UIAlertView *errorAlert = [[UIAlertView alloc]
	                                   initWithTitle:NSLocalizedString(@"Error", nil)
	                                                message:NSLocalizedString(@"Error loading data", nil)
	                                               delegate:nil
	                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
	                                      otherButtonTitles:nil];
	        [errorAlert show];
		}
	    else
	    {
	        self.results = nil;
	        self.results = array;
#ifdef APPDEBUG
	        NSLog(@"we have %lu results returned", (unsigned long)self.results.count);
#endif
	        [self.tableView reloadData];
		}
	}];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
#ifdef APPDEBUG
	NSLog(@"ResultsListTableViewController:handleStoreChanged with name %@", notification.name);
#endif
}

#pragma mark - private methods


@end
