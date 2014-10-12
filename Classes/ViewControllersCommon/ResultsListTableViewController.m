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
@property (nonatomic, strong) UISegmentedControl *resultsSegmentControl;
@end

@implementation ResultsListTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.results = [NSArray array]; //init with empty array
	[self setTitleViewWithTitle:NSLocalizedString(@"Results", nil)];
    NSArray *menuTitles = @[NSLocalizedString(@"All", nil),
                            NSLocalizedString(@"HIV", nil),
                            NSLocalizedString(@"Bloods", nil),
                            NSLocalizedString(@"Cells", nil),
                            NSLocalizedString(@"Other", nil),
                            NSLocalizedString(@"Liver", nil)];
    self.resultsSegmentControl = [[UISegmentedControl alloc] initWithItems:menuTitles];
    CGFloat width = self.tableView.bounds.size.width;
    if (320 < width)
    {
        width = 320;
    }
    CGFloat segmentWidth = width - 2 * 10;
    self.resultsSegmentControl.frame = CGRectMake(10, 3, segmentWidth, 30);
    self.resultsSegmentControl.selectedSegmentIndex = 0;
    [self.resultsSegmentControl addTarget:self action:@selector(indexDidChangeForSegment) forControlEvents:UIControlEventValueChanged];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    
    headerView = [[UIView alloc]
                  initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
    [headerView addSubview:self.resultsSegmentControl];
    return headerView;
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
	CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath] - 2;
	DateView *dateView = [DateView viewWithDate:results.ResultsDate frame:CGRectMake(20, 1, rowHeight, rowHeight)];

	ResultsView_iPhone *hivView = [ResultsView_iPhone viewForResults:results resultsType:HIVResultsType frame:CGRectMake(70, 1, 70, rowHeight)];

	ResultsView_iPhone *bloodView = [ResultsView_iPhone viewForResults:results resultsType:BloodResultsType frame:CGRectMake(140, 1, 50, rowHeight)];

	ResultsView_iPhone *otherView = [ResultsView_iPhone viewForResults:results resultsType:OtherResultsType frame:CGRectMake(195, 1, 40, rowHeight)];

	ResultsView_iPhone *liverView = [ResultsView_iPhone viewForResults:results resultsType:LiverResultsType frame:CGRectMake(240, 1, 40, rowHeight)];

	[cell.contentView addSubview:dateView];
	[cell.contentView addSubview:hivView];
	[cell.contentView addSubview:bloodView];
	[cell.contentView addSubview:otherView];
	[cell.contentView addSubview:liverView];
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
- (void)indexDidChangeForSegment
{
}

@end
