//
//  MissedMedicationsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "MissedMedicationsTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "EditMissedMedsTableViewController.h"
#import "MissedMedication+Handling.h"
#import "DateView.h"
#import "UILabel+Standard.h"

@interface MissedMedicationsTableViewController ()
@property (nonatomic, strong) NSArray *missed;
@property (nonatomic, strong) NSArray *currentMeds;
@end

@implementation MissedMedicationsTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.missed = [NSArray array];
	self.currentMeds = [NSArray array];
	[self setTitleViewWithTitle:NSLocalizedString(@"Missed Medication", nil)];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (void)addButtonPressed:(id)sender
{
	EditMissedMedsTableViewController *controller = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped currentMeds:self.currentMeds managedObject:nil];
	[self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.missed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	[self configureCell:cell indexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
	NSArray *subviews = cell.contentView.subviews;
	[subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger index, BOOL *stop) {
	    [view removeFromSuperview];
	}];
	MissedMedication *missed = (MissedMedication *)[self.missed objectAtIndex:indexPath.row];
	CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath] - 2;
	DateView *dateView = [DateView viewWithDate:missed.MissedDate frame:CGRectMake(20, 1, rowHeight, rowHeight)];

	UILabel *nameLabel = [UILabel standardLabel];
	nameLabel.frame = CGRectMake(70, 1, 100, rowHeight);
	nameLabel.text = missed.Name;

	UILabel *reasonLabel = [UILabel standardLabel];
	reasonLabel.frame = CGRectMake(175, 1, 100, rowHeight);
	if (nil != missed.missedReason && ![missed.missedReason isEqualToString:@""])
	{
		reasonLabel.text = missed.missedReason;
		reasonLabel.textColor = DARK_RED;
	}

	[cell.contentView addSubview:dateView];
	[cell.contentView addSubview:nameLabel];
	[cell.contentView addSubview:reasonLabel];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UITableViewCellEditingStyleDelete == editingStyle)
	{
		self.markedIndexPath = indexPath;
		self.markedObject = [self.missed objectAtIndex:indexPath.row];
		[self showDeleteAlertView];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MissedMedication *missed = (MissedMedication *)[self.missed objectAtIndex:indexPath.row];
	EditMissedMedsTableViewController *controller = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped currentMeds:self.currentMeds managedObject:missed];
	[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kMissedMedication predicate:nil sortTerm:kMissedDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	    if (nil == array)
	    {
	        UIAlertView *errorAlert = [[UIAlertView alloc]
	                                   initWithTitle:@"Error"
	                                                message:@"Error loading data"
	                                               delegate:nil
	                                      cancelButtonTitle:@"Cancel"
	                                      otherButtonTitles:nil];
	        [errorAlert show];
		}
	    else
	    {
	        self.missed = nil;
	        self.missed = [NSArray arrayWithArray:array];
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *medsarray, NSError *innererror) {
	            if (nil == medsarray)
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
	                self.currentMeds = nil;
	                self.currentMeds = [NSArray arrayWithArray:medsarray];
	                [self.tableView reloadData];
				}
			}];
		}
	}];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
}

@end
