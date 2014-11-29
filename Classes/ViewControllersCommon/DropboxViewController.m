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
#import "ContentNavigationController_iPad.h"
#import "Constants.h"
#import "Utilities.h"
#import "Menus.h"
#import "UILabel+Standard.h"
#import "UIFont+Standard.h"
#import "CoreXMLReader.h"
#import "CoreXMLWriter.h"
#import "CoreDataManager.h"
#import <DropboxSDK/DropboxSDK.h>

#define kiStayHealthyPath @"/iStayHealthy"
#define kiStayHealthyUploadFile @"iStayHealthy_upload.isth"
#define kiStayHealthyFile @"iStayHealthy.isth"
#define kiStayHealthyFilePath @"/iStayHealthy/iStayHealthy.isth"
#define kiStayHealthyNewFilePath @"/iStayHealthy/iStayHealthy_upload.isth"
#define kBackupDateFormat @"ddMMMyyyy'_'HHmmss"


@interface DropboxViewController () <DBRestClientDelegate>
@property (nonatomic, strong) MFMailComposeViewController *mailController;
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, assign) BOOL dropBoxFileExists;
@property (nonatomic, assign) BOOL newDropboxFileExists;
@property (nonatomic, assign) BOOL isConnectAlert;
@property (nonatomic, assign) BOOL isBackup;
@property (nonatomic, strong) NSString *iStayHealthyPath;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, assign) BOOL backupStarted;
@property (nonatomic, strong) NSMutableArray *backupFiles;
@end

@implementation DropboxViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = NSLocalizedString(@"Dropbox", nil);
	[self disableRightBarButtons];
	self.iStayHealthyPath = nil;
	self.dropBoxFileExists = NO;
	self.newDropboxFileExists = NO;
	self.isBackup = NO;
	self.backupStarted = NO;
	self.backupFiles = [NSMutableArray array];
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
		return 2;
	}
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([[DBSession sharedSession]isLinked])
	{
		NSInteger rows = 1;
		switch (section)
		{
			case 0:
				rows = 2;
				break;

			case 1:
				rows = 1;
				break;
		}
		return rows;
	}
	else
	{
		return 1;
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
	cell.contentView.backgroundColor = [UIColor whiteColor];


	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(20, 0, 200, self.tableView.rowHeight);
	if (0 == indexPath.section)
	{
		if ([[DBSession sharedSession] isLinked])
		{
			switch (indexPath.row)
			{
				case 0:
					label.text = NSLocalizedString(@"Save to Dropbox", nil);
					break;

				case 1:
					label.text = NSLocalizedString(@"Get from Dropbox", nil);
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
		label.text = NSLocalizedString(@"Unlink Dropbox", @"Unlink DropBox");
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
						[self.restClient loadFile:kiStayHealthyFilePath
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
	label.frame = CGRectMake(20, 2, self.view.bounds.size.width - 100, 20);
	if (0 == section)
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
	if (1 == section)
	{
		return 36;
	}
	else
	{
		return 10;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 36)];

	if ([[DBSession sharedSession] isLinked] && 1 == section)
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
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingString:kiStayHealthyFile];
	NSFileManager *defaultManager = [NSFileManager defaultManager];
	NSError *error = nil;
	if ([defaultManager fileExistsAtPath:tmpPath])
	{
		[defaultManager removeItemAtPath:tmpPath error:&error];
	}
	return tmpPath;
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
	  initWithTitle:NSLocalizedString(@"Error Loading Dropbox data", nil) message:NSLocalizedString(@"There was an error loading data from Dropbox.", nil)
	       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	 show];
}

- (void)createIStayHealthyFolder
{
	[self.restClient createFolder:kiStayHealthyPath];
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
#ifdef APPDEBUG
	        NSLog(@"XML DATA STRING TO SEND TO DROPBOX \r\n\r\n%@", xmlString);
#endif
	        NSData * xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	        NSError *writeError = nil;
	        [xmlData writeToFile:dataPath options:NSDataWritingAtomic error:&writeError];
	        if (writeError)
	        {
	            [[[UIAlertView alloc]
	              initWithTitle:NSLocalizedString(@"Error writing data to tmp directory", nil) message:[error localizedDescription]
	                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	             show];
	            [self stopAnimation:nil];
			}
	        else
	        {
	            self.backupStarted = YES;
	            [self.restClient uploadFile:kiStayHealthyUploadFile
	                                 toPath:kiStayHealthyPath
	                          withParentRev:nil
	                               fromPath:dataPath];
			}
		}
	    else
	    {
	        [self stopAnimation:nil];
	        [[[UIAlertView alloc]
	          initWithTitle:NSLocalizedString(@"Error writing data", nil) message:[error localizedDescription]
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
	                       message:NSLocalizedString(@"Data were retrieved from Dropbox.", nil)
	                      delegate:nil
	             cancelButtonTitle:@"OK" otherButtonTitles:nil]
	         show];
		}
	    else
	    {
	        [self stopAnimation:nil];
	        [[[UIAlertView alloc]
	          initWithTitle:NSLocalizedString(@"Error retrieving data", nil) message:[error localizedDescription]
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
			if ([child isDirectory] && [pathName isEqualToString:kiStayHealthyPath])
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
			[self.restClient loadMetadata:kiStayHealthyPath];
		}
	}
	if ([path isEqualToString:kiStayHealthyPath])
	{
		DBMetadata *backupFile = nil;
		for (DBMetadata *child in metadata.contents)
		{
			NSString *pathName = [child path];
			if ([pathName hasSuffix:kiStayHealthyFile])
			{
				backupFile = child;
				self.dropBoxFileExists = YES;
			}
			if ([pathName hasSuffix:@".isth"])
			{
				NSLog(@"**** backup file found %@ ****", pathName);
				[self.backupFiles addObject:pathName];
			}
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
	  initWithTitle:NSLocalizedString(@"Save Finished", nil) message:NSLocalizedString(@"Data were sent to DropBox iStayHealthy.isth.", nil)
	       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	 show];

	NSString *olderBackupFilePath = [self backedUpFileName];
#ifdef APPDEBUG
	NSLog(@"uploaded file to %@ . the existing file will be renamed to %@", destPath, olderBackupFilePath);
#endif
	if (self.dropBoxFileExists)
	{
		[self.restClient moveFrom:kiStayHealthyFilePath toPath:olderBackupFilePath];
	}
	else
	{
		[self.restClient moveFrom:destPath toPath:kiStayHealthyFilePath];
	}
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
	[self stopAnimation:nil];
	[[[UIAlertView alloc]
	  initWithTitle:@"Error Uploading to Dropbox" message:@"There was an error uploading data to Dropbox."
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
	  initWithTitle:@"Error Loading file from Dropbox" message:@"There was an error loading a file from Dropbox."
	       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	 show];
}

- (void)restClient:(DBRestClient *)client movedPath:(NSString *)from_path to:(DBMetadata *)result
{
#ifdef APPDEBUG
#endif
	if (self.backupStarted)
	{
#ifdef APPDEBUG
		NSLog(@"we completed the moved from path %@ to %@", from_path, result.path);
#endif

		if ([from_path isEqualToString:kiStayHealthyFilePath])
		{
#ifdef APPDEBUG
			NSLog(@"we completed first part of the move, i.e the move of the existing backup file to its new name/path");
#endif
			[self.restClient moveFrom:kiStayHealthyNewFilePath toPath:kiStayHealthyFilePath];
		}
		else if ([from_path isEqualToString:kiStayHealthyNewFilePath])
		{
#ifdef APPDEBUG
			NSLog(@"we are done with the backup as we moved the new upload file to its proper location");
#endif
			self.backupStarted = NO;
		}
	}
}

- (void)restClient:(DBRestClient *)client movePathFailedWithError:(NSError *)error
{
#ifdef APPDEBUG
	NSLog(@"The move to the filepath failed due to %@ with error code %lu", error.localizedDescription, (long)error.code);
#endif
	if (self.backupStarted)
	{
#ifdef APPDEBUG
		NSLog(@"move to path failed, but we started a backup. so we are trying to move the new file to the proper path");
#endif
		[self.restClient moveFrom:kiStayHealthyNewFilePath toPath:kiStayHealthyFilePath];
	}
	self.backupStarted = NO;
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

- (void)handleStoreChanged:(NSNotification *)notification
{
}

#pragma mark mail stuff
- (void)startMailController
{
	CoreXMLWriter *writer = [CoreXMLWriter sharedInstance];
	NSString *dataPath = [self uploadFileTmpPath];

	[writer writeWithCompletionBlock: ^(NSString *xmlString, NSError *error) {
	    if (nil != xmlString)
	    {
	        NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	        NSError *writeError = nil;
	        [xmlData writeToFile:dataPath options:NSDataWritingAtomic error:&writeError];
	        if (writeError)
	        {
	            [[[UIAlertView alloc]
	              initWithTitle:NSLocalizedString(@"Error writing data to tmp directory", nil) message:[error localizedDescription]
	                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	             show];
			}
	        else
	        {
	            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];

	            mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
	            mailController.mailComposeDelegate = self;
	            [mailController addAttachmentData:xmlData mimeType:@"application/xml" fileName:dataPath];
	            self.mailController = mailController;
	            [mailController setSubject:@"iStayHealthy Data (attached)"];
	            self.mailController = mailController;
	            if ([Utilities isIPad])
	            {
	                ContentNavigationController_iPad *navController = (ContentNavigationController_iPad *)self.parentViewController;
//                     [navController showMailController:mailController];
				}
	            else
	            {
	                ContentNavigationController *navController = (ContentNavigationController *)self.parentViewController;
	                [navController showMailController:mailController];
				}
			}
		}
	}];
}

- (NSString *)backedUpFileName
{
	NSDateFormatter *formatter = [NSDateFormatter new];
	formatter.dateFormat = kBackupDateFormat;
	NSLocale *enforcedPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	formatter.locale = enforcedPOSIXLocale;
	NSDate *date = [NSDate date];
	NSString *formattedDate = [formatter stringFromDate:date];
	NSString *filePath = [NSString stringWithFormat:@"%@/iStayHealthy_%@.isth", kiStayHealthyPath, formattedDate];
#ifdef APPDEBUG
	NSLog(@"The backup file will be called %@", filePath);
#endif
	if ([self.backupFiles containsObject:filePath])
	{
		NSString *uuid = [[NSUUID UUID] UUIDString];
		filePath = [NSString stringWithFormat:@"%@/iStayHealthy_%@_%@.isth", kiStayHealthyPath, formattedDate, uuid];
	}
	return filePath;
}

@end
