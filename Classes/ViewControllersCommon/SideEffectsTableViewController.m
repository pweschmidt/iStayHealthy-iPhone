//
//  SideEffectsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "SideEffectsTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "EditSideEffectsTableViewController.h"
#import "SideEffects+Handling.h"
#import "DateView.h"
#import "UILabel+Standard.h"

@interface SideEffectsTableViewController ()
@property (nonatomic, strong) NSArray *effects;
@property (nonatomic, strong) NSArray *currentMeds;
@end

@implementation SideEffectsTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitleViewWithTitle:NSLocalizedString(@"Side Effects", nil)];
	self.effects = [NSArray array];
	self.currentMeds = [NSArray array];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	EditSideEffectsTableViewController *controller = [[EditSideEffectsTableViewController alloc] initWithStyle:UITableViewStyleGrouped currentMeds:self.currentMeds managedObject:nil];
	[self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.effects.count;
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
	SideEffects *effects = [self.effects objectAtIndex:indexPath.row];
	CGFloat rowHeight = self.tableView.rowHeight - 2;
	DateView *dateView = [DateView viewWithDate:effects.SideEffectDate frame:CGRectMake(20, 1, rowHeight, rowHeight)];

	UILabel *nameLabel = [UILabel standardLabel];
	nameLabel.frame = CGRectMake(70, 1, 100, rowHeight);
	nameLabel.text = effects.Name;

	UILabel *reasonLabel = [UILabel standardLabel];
	reasonLabel.frame = CGRectMake(175, 1, 100, rowHeight);
	if (nil != effects.SideEffect && ![effects.SideEffect isEqualToString:@""])
	{
		reasonLabel.text = effects.SideEffect;
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
		self.markedObject = [self.effects objectAtIndex:indexPath.row];
		[self showDeleteAlertView];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SideEffects *effects = (SideEffects *)[self.effects objectAtIndex:indexPath.row];
	EditSideEffectsTableViewController *controller = [[EditSideEffectsTableViewController alloc] initWithStyle:UITableViewStyleGrouped currentMeds:self.currentMeds managedObject:effects];
	[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kSideEffects predicate:nil sortTerm:kSideEffectDate ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        self.effects = nil;
	        self.effects = [NSArray arrayWithArray:array];
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *medsarray, NSError *innererror) {
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
	                self.currentMeds = nil;
	                self.currentMeds = [NSArray arrayWithArray:medsarray];
	                [self.tableView reloadData];
				}
			}];
		}
	}];
}

- (void)startAnimation:(NSNotification *)notification
{
}

- (void)stopAnimation:(NSNotification *)notification
{
}

- (void)handleError:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
}

@end
