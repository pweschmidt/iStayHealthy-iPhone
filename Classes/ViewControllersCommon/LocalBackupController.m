//
//  LocalBackupController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/07/2014.
//
//

#import "LocalBackupController.h"
#import "CoreXMLReader.h"
#import "CoreXMLWriter.h"
#import "CoreDataManager.h"
#import "UIFont+Standard.h"

@interface LocalBackupController ()

@end

@implementation LocalBackupController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.backgroundColor = DEFAULT_BACKGROUND;
	[self setTitleViewWithTitle:NSLocalizedString(@"Local Backup/Restore", nil)];
	[self disableRightBarButtons];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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
	NSString *identifier = @"CellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}

	cell.contentView.backgroundColor = [UIColor whiteColor];
	cell.textLabel.textColor = TEXTCOLOUR;
	cell.textLabel.font = [UIFont fontWithType:Standard size:standard];
	if (0 == indexPath.section)
	{
		cell.textLabel.text = NSLocalizedString(@"Save locally", nil);
	}
	else
	{
		cell.textLabel.text = NSLocalizedString(@"Restore locally", nil);
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		NSError *error = nil;
		BOOL success = [[CoreDataManager sharedInstance] saveAndBackup:&error];
		if (success)
		{
			[[[UIAlertView alloc]
			  initWithTitle:NSLocalizedString(@"Save Finished", nil)
			               message:NSLocalizedString(@"Data were saved locally.", nil)
			              delegate:nil
			     cancelButtonTitle:@"OK" otherButtonTitles:nil]
			 show];
		}
		else
		{
			[[[UIAlertView alloc]
			  initWithTitle:NSLocalizedString(@"Save Error", nil)
			               message:NSLocalizedString(@"Data could not be saved locally.", nil)
			              delegate:nil
			     cancelButtonTitle:@"OK" otherButtonTitles:nil]
			 show];
		}
	}
	else
	{
		[[CoreDataManager sharedInstance] restoreLocallyWithCompletionBlock: ^(BOOL success, NSError *error) {
		    if (success)
		    {
		        [[[UIAlertView alloc]
		          initWithTitle:NSLocalizedString(@"Restore Finished", nil)
		                       message:NSLocalizedString(@"Data were retrieved locally.", nil)
		                      delegate:nil
		             cancelButtonTitle:@"OK" otherButtonTitles:nil]
		         show];
			}
		    else
		    {
		        [[[UIAlertView alloc]
		          initWithTitle:NSLocalizedString(@"Error restoring", nil)
		                       message:NSLocalizedString(@"There was an error when retrieving data locally.", nil)
		                      delegate:nil
		             cancelButtonTitle:@"OK" otherButtonTitles:nil]
		         show];
			}
		}];
	}
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
}

@end
