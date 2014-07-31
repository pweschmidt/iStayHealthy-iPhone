//
//  HelpTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/07/2014.
//
//

#import "HelpTableViewController.h"
#import "UIFont+Standard.h"
#import "CoreDataManager.h"
#import "Utilities.h"
#import "IconsTableViewController.h"

@interface HelpTableViewController ()
@end

@implementation HelpTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.backgroundColor = DEFAULT_BACKGROUND;
	[self setTitleViewWithTitle:NSLocalizedString(@"Help", nil)];
	[self disableRightBarButtons];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"Cells";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	cell.contentView.backgroundColor = [UIColor whiteColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.textColor = TEXTCOLOUR;
	cell.textLabel.font = [UIFont fontWithType:Standard size:standard];

	if (0 == indexPath.section)
	{
		cell.textLabel.text = NSLocalizedString(@"Data Storage Explained", nil);
	}
	else
	{
		cell.textLabel.text = NSLocalizedString(@"Show Icons", nil);
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (0 == section)
	{
		return NSLocalizedString(@"Where are my data?", nil);
	}
	else
	{
		return NSLocalizedString(@"Icons Explained", nil);
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		[self showDataExplainer];
//		switch (indexPath.row)
//		{
//			case 0:
//				[self showDataExplainer];
//				break;
//
//			case 1:
//				[self loadLocalStore];
//				break;
//
//			case 2:
//				[self loadMainStoreWithoutiCloud];
//				break;
//
//			case 3:
//				[self loadMainStoreWithiCloud];
//				break;
//		}
	}
	else
	{
		[self showIconExplainer];
	}
}

- (void)showDataExplainer
{
}

- (void)showIconExplainer
{
	IconsTableViewController *controller = [[IconsTableViewController alloc] initAsPopoverController];
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
}

//- (void)loadLocalStore
//{
//#ifdef APPDEBUG
//	if ([Utilities isSimulator])
//	{
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You cannot change the store on the simulator.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//		[alert show];
//		return;
//	}
//
//#endif
//
//	[[CoreDataManager sharedInstance] replaceStoreWithLocalFallbackStoreWithCompletion: ^(BOOL success, NSError *error) {
//	    if (success)
//	    {
//	        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"The data were reloaded successfully. Please, check if you can see your data now.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//	        [alert show];
//		}
//	    else
//	    {
//	        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There was an error while reloading.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//	        [alert show];
//		}
//	}];
//}
//
//- (void)loadMainStoreWithoutiCloud
//{
//#ifdef APPDEBUG
//	if ([Utilities isSimulator])
//	{
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You cannot change the iCloud store on the simulator.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//		[alert show];
//		return;
//	}
//
//#endif
//	[[CoreDataManager sharedInstance] migrateiCloudStoreToLocalWithCompletion: ^(BOOL success, NSError *error) {
//	    if (success)
//	    {
//	        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"The data were reloaded successfully. Please, check if you can see your data now.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//	        [alert show];
//		}
//	    else
//	    {
//	        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There was an error while reloading.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//	        [alert show];
//		}
//	}];
//}
//
//- (void)loadMainStoreWithiCloud
//{
//#ifdef APPDEBUG
//	if ([Utilities isSimulator])
//	{
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You cannot change the iCloud store on the simulator.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//		[alert show];
//		return;
//	}
//
//#endif
//	[[CoreDataManager sharedInstance] migrateLocalStoreToiCloudStoreWithCompletion: ^(BOOL success, NSError *error) {
//	    if (success)
//	    {
//	        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"The data were reloaded successfully. Please, check if you can see your data now.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//	        [alert show];
//		}
//	    else
//	    {
//	        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There was an error while reloading.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//	        [alert show];
//		}
//	}];
//}



@end
