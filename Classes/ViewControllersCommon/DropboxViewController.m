//
//  DropboxViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "DropboxViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreXMLReader.h"
#import "Utilities.h"
#import "Menus.h"
#import "UILabel+Standard.h"
#import "UIFont+Standard.h"
#import "CoreXMLReader.h"
#import "CoreXMLWriter.h"
#import "CoreDataManager.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxViewController () <DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, assign) BOOL dropBoxFileExists;
@property (nonatomic, assign) BOOL newDropboxFileExists;
@property (nonatomic, assign) BOOL isConnectAlert;
@property (nonatomic, assign) BOOL isBackup;
@property (nonatomic, strong) NSString *iStayHealthyPath;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) NSString *parentRevision;
@end

@implementation DropboxViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = NSLocalizedString(@"Backup/Restore", nil);
	[self disableRightBarButtons];
	self.iStayHealthyPath = nil;
	self.dropBoxFileExists = NO;
	self.newDropboxFileExists = NO;
	self.isBackup = NO;
	self.parentRevision = nil;
	[self createRestClient];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([[DBSession sharedSession]isLinked])
	{
		return 3;
	}
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([[DBSession sharedSession]isLinked])
	{
		if (2 > section)
		{
			return 2;
		}
		return 1;
	}
	else
	{
		if (0 == section)
		{
			return 2;
		}
		else
		{
			return 1;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = [NSString stringWithFormat:@"DropboxCell"];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}


	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(20, 0, 200, self.tableView.rowHeight);
	if (0 == indexPath.section)
	{
		switch (indexPath.row)
		{
			case 0:
				label.text = NSLocalizedString(@"Save locally", nil);
				break;

			case 1:
				label.text = NSLocalizedString(@"Restore locally", nil);
				break;
		}
	}
	else if (1 == indexPath.section)
	{
		if ([[DBSession sharedSession] isLinked])
		{
			switch (indexPath.row)
			{
				case 0:
					label.text = NSLocalizedString(@"Save to Dropbox", @"Save to Dropbox");
					break;

				case 1:
					label.text = NSLocalizedString(@"Get from Dropbox", @"Get from Dropbox");
					break;
			}
		}
		else
		{
			label.text = NSLocalizedString(@"Link with Dropbox", nil);
		}
	}
	else
	{
		label.text = NSLocalizedString(@"Unlink DropBox", @"Unlink DropBox");
	}

	[cell.contentView addSubview:label];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)deselect:(id)sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		if (0 == indexPath.row)
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
	else if (1 == indexPath.section)
	{
		if ([[DBSession sharedSession] isLinked])
		{
			switch (indexPath.row)
			{
				case 0:
					[self backup];
					break;

				case 1:
				{
					if ([[DBSession sharedSession] isLinked])
					{
						[self startAnimation:nil];
						NSString *dataPath = [self dropBoxFileTmpPath];
						[self.restClient loadFile:@"/iStayHealthy/iStayHealthy.isth"
						                    atRev:self.parentRevision
						                 intoPath:dataPath];
					}
				}
				break;
			}
		}
		else
		{
			self.isConnectAlert = YES;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Link?", @"Link?")
			                                                message:NSLocalizedString(@"You are not linked to Dropbox account. Do you want to link it up now?", nil)
			                                               delegate:self
			                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
			                                      otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];

			[alert show];
		}
	}
	else
	{
		self.isConnectAlert = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unlink?", @"Unlink?")
		                                                message:NSLocalizedString(@"Do you want to unlink your Dropbox account?", nil)
		                                               delegate:self
		                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
		                                      otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];

		[alert show];
	}
	[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	UILabel *label = [UILabel standardLabel];
	label.font = [UIFont fontWithType:Bold size:standard];
	label.frame = CGRectMake(20, 0, self.view.bounds.size.width - 100, 20);
	if (0 == section)
	{
		label.text = NSLocalizedString(@"Local Backup/Restore", nil);
	}
	else if (1 == section)
	{
		label.text = NSLocalizedString(@"Dropbox", nil);
	}
	else
	{
		label.text = NSLocalizedString(@"Connection to Dropbox", nil);
	}
	[view addSubview:label];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (2 == section)
	{
		return 36;
	}
	else
		return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 36)];
	if (2 == section)
	{
		UILabel *label = [UILabel standardLabel];
		label.text = @"";
		label.frame = CGRectMake(80, 0, self.view.bounds.size.width - 100, 36);
		[view addSubview:label];
		self.activityLabel = label;
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		indicator.hidesWhenStopped = YES;
		indicator.frame = CGRectMake(20, 0, 36, 36);
		[view addSubview:indicator];
		self.activityIndicator = indicator;
		if ([[DBSession sharedSession] isLinked])
		{
			[self startAnimation:nil];
		}
	}
	else
	{
		view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);
	}
	return view;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if ([title isEqualToString:NSLocalizedString(@"Yes", @"Yes")])
	{
		if (!self.isConnectAlert)
		{
			[self unlinkDropBox];
		}
		else
		{
			ContentNavigationController *navController = (ContentNavigationController *)self.parentViewController;
			ContentContainerViewController *contentController = (ContentContainerViewController *)navController.parentViewController;
			[[DBSession sharedSession] linkFromController:contentController];
		}
	}
}

#pragma mark - DropBox actions

- (void)createRestClient
{
	if (![[DBSession sharedSession] isLinked])
	{
		return;
	}
	else
	{
		self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		self.restClient.delegate = self;
		[self.restClient loadMetadata:@"/"];
	}
}

- (NSString *)dropBoxFileTmpPath
{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:@"fromDropBox.xml"];
}

- (NSString *)uploadFileTmpPath
{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:@"iStayHealthy.isth"];
}

/**
   (void)unlinkDropBox
 */
- (void)unlinkDropBox
{
	[[DBSession sharedSession] unlinkAll];
}

/**
   (void)showDBError
 */
- (void)showDBError
{
	if (![[DBSession sharedSession]isLinked])
	{
		return;
	}
	[[[UIAlertView alloc]
	  initWithTitle:@"Error Loading DropBox data" message:@"There was an error loading data from DropBox."
	       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	 show];
}

- (void)createIStayHealthyFolder
{
	[self.restClient createFolder:@"/iStayHealthy"];
}

- (void)copyOldFileToNew
{
	[self.restClient copyFrom:@"/iStayHealthy/iStayHealthy.xml" toPath:@"/iStayHealthy/iStayHealthy.isth"];
}

- (void)backup
{
	if (![[DBSession sharedSession]isLinked])
	{
		return;
	}
	NSString *dataPath = [self uploadFileTmpPath];
	[self startAnimation:nil];
	CoreXMLWriter *writer = [CoreXMLWriter sharedInstance];
	[writer writeWithCompletionBlock: ^(NSString *xmlString, NSError *error) {
	    if (nil != xmlString)
	    {
	        NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	        NSError *writeError = nil;
	        [xmlData writeToFile:dataPath options:NSDataWritingAtomic error:&writeError];
	        if (writeError)
	        {
	            [[[UIAlertView alloc]
	              initWithTitle:@"Error writing data to tmp directory" message:[error localizedDescription]
	                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	             show];
			}
	        else
	        {
	            [self.restClient uploadFile:@"iStayHealthy.isth"
	                                 toPath:@"/iStayHealthy"
	                          withParentRev:self.parentRevision
	                               fromPath:dataPath];
			}
		}
	    else
	    {
	        [[[UIAlertView alloc]
	          initWithTitle:@"Error retrieving data" message:[error localizedDescription]
	               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	         show];
		}
	}];
}

- (void)restore
{
	NSString *dataPath = [self dropBoxFileTmpPath];
	NSData *xmlData = [[NSData alloc]initWithContentsOfFile:dataPath];
	[[CoreXMLReader sharedInstance] parseXMLData:xmlData completionBlock: ^(BOOL success, NSError *error) {
	    if (success)
	    {
	        [self stopAnimation:nil];
	        [[[UIAlertView alloc]
	          initWithTitle:NSLocalizedString(@"Restore Finished", nil)
	                       message:NSLocalizedString(@"Data were retrieved from DropBox.", nil)
	                      delegate:nil
	             cancelButtonTitle:@"OK" otherButtonTitles:nil]
	         show];
		}
	    else
	    {
	        [[[UIAlertView alloc]
	          initWithTitle:@"Error retrieving data" message:[error localizedDescription]
	               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	         show];
		}
	}];
}

#pragma mark - DropBox DBRestClient methods
- (DBRestClient *)restClient
{
	if (!_restClient)
	{
		_restClient =
		    [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
	NSString *path = [metadata path];
	[self startAnimation:nil];
	if ([path isEqualToString:@"/"])
	{
		for (DBMetadata *child in metadata.contents)
		{
			NSString *pathName = [child path];
			if ([child isDirectory] && [pathName isEqualToString:@"/iStayHealthy"])
			{
				self.iStayHealthyPath = pathName;
			}
		}
		if (nil == self.iStayHealthyPath)
		{
			[self createIStayHealthyFolder];
		}
		else
		{
			[self.restClient loadMetadata:@"/iStayHealthy"];
		}
	}
	if ([path isEqualToString:@"/iStayHealthy"])
	{
		DBMetadata *backupFile = nil;
		for (DBMetadata *child in metadata.contents)
		{
			NSString *pathName = [child path];
			if ([pathName hasSuffix:@"iStayHealthy.isth"])
			{
				backupFile = child;
			}
		}
		if (nil != backupFile)
		{
			self.parentRevision = backupFile.rev;
		}
		else
		{
			self.parentRevision = nil;
		}
		[self stopAnimation:nil];
	}
}

- (void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder
{
	[self stopAnimation:nil];
}

- (void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error
{
	[self stopAnimation:nil];
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Dropbox Error" message:[NSString stringWithFormat:@"Error creating iStayHealthy folder %@", [error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)restClient:(DBRestClient *)client
        copiedPath:(NSString *)fromPath
                to:(DBMetadata *)to
{
	if ([fromPath isEqualToString:@"/iStayHealthy/iStayHealthy.xml"] && [[to path] isEqualToString:@"/iStayHealthy/iStayHealthy.isth"])
	{
		self.newDropboxFileExists = YES;
	}
}

- (void)restClient:(DBRestClient *)client copyPathFailedWithError:(NSError *)error
{
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Dropbox Copy error" message:[NSString stringWithFormat:@"Error copying file %@", [error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)restClient:(DBRestClient *)client metadataUnchangedAtPath:(NSString *)path
{
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
	[self showDBError];
}

- (void)restClient:(DBRestClient *)client
      uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath
          metadata:(DBMetadata *)metadata
{
	[self stopAnimation:nil];
	[[[UIAlertView alloc]
	  initWithTitle:NSLocalizedString(@"Backup Finished", @"Backup Finished") message:NSLocalizedString(@"Data were sent to DropBox iStayHealthy.xml.", nil)
	       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	 show];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
	[self stopAnimation:nil];
	[[[UIAlertView alloc]
	  initWithTitle:@"Error Uploading to DropBox" message:@"There was an error uploading data to DropBox."
	       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	 show];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
{
	[self restore];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
	[self stopAnimation:nil];
	[[[UIAlertView alloc]
	  initWithTitle:@"Error Loading file from DropBox" message:@"There was an error loading a file from DropBox."
	       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	 show];
}

#pragma mark BaseTableViewController methods
- (void)reloadSQLData:(NSNotification *)notification
{
}

- (void)startAnimation:(NSNotification *)notification
{
	if (![self.activityIndicator isAnimating])
	{
		[self.activityIndicator startAnimating];
		self.activityLabel.text = NSLocalizedString(@"Syncing data...", nil);
	}
}

- (void)stopAnimation:(NSNotification *)notification
{
	if ([self.activityIndicator isAnimating])
	{
		[self.activityIndicator stopAnimating];
		self.activityLabel.text = @"";
	}
}

- (void)handleError:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
}

@end
