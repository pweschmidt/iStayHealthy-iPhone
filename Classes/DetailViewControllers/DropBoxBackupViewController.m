//
//  DropBoxBackupViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DropBoxBackupViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "iStayHealthyAppDelegate.h"
#import "DataLoader.h"
#import "XMLLoader.h"
#import "GeneralSettings.h"

@interface DropBoxBackupViewController ()<DBRestClientDelegate>
- (void)unlinkDropBox;
- (void)showDBError;
- (void)backup;
- (void)restore;
- (void)createIStayHealthyFolder;
- (void)copyOldFileToNew;
@property (nonatomic, strong, readonly) DBRestClient* restClient;
@end

@implementation DropBoxBackupViewController
@synthesize iStayHealthyPath, activityIndicator, dropBoxFileExists, newDropboxFileExists;

/**
 initWithStyle
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
#ifdef APPDEBUG
        NSLog(@"DropBoxBackupViewController initWithStyle - do we reach this point?");
#endif
    }
    return self;
}

/**
 didReceiveMemoryWarning
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/** 
 dealloc
 */

/**
 viewDidUnload
 */

- (void)viewDidUnload
{
    self.iStayHealthyPath = nil;
    self.activityIndicator = nil;
    [super viewDidUnload];
}

/**
 viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
#ifdef APPDEBUG
    NSLog(@"DropboxController viewDidLoad");
#endif
	// Set these variables before launching the app
    [self restClient];
    self.iStayHealthyPath = nil;
    self.dropBoxFileExists = NO;
    self.newDropboxFileExists = NO;
    isBackup = NO;
    if(nil != restClient)
        [[self restClient] loadMetadata:@"/"];

}


/**
 viewWillAppear
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self restClient] loadMetadata:@"/iStayHealthy"];
    
}


#pragma mark - Table view data source
/**
 (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

/**
 (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 2;
    }
    return 1;
}

/**
 (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+4.0, 118.0, 40.0);
    UIImageView *view = [[UIImageView alloc]initWithFrame:frame];
    [view setImage:[UIImage imageNamed:@"dropbox-small.png"]];
    [cell.contentView addSubview:view];
    
    if (0 == indexPath.section)
    {
        CGRect textFrame = CGRectMake(CGRectGetMinX(cell.bounds)+150.0, CGRectGetMinY(cell.bounds)+17.0, 100, 14);
        UILabel *textLabel = [[UILabel alloc]initWithFrame:textFrame];
        textLabel.textColor = TEXTCOLOUR;
        textLabel.font = [UIFont systemFontOfSize:12.0];
        textLabel.textAlignment = UITextAlignmentLeft;
        switch (indexPath.row)
        {
            case 0:
                textLabel.text = NSLocalizedString(@"Save to Dropbox",@"Save to Dropbox");
                break;            
            case 1:
                textLabel.text = NSLocalizedString(@"Get from Dropbox",@"Get from Dropbox");
                break;
        }
        [cell.contentView addSubview:textLabel];
    }
    else
    {
        CGRect textFrame = CGRectMake(CGRectGetMinX(cell.bounds)+150.0, CGRectGetMinY(cell.bounds)+19.0, 100, 12);
        UILabel *textLabel = [[UILabel alloc]initWithFrame:textFrame];
        textLabel.textColor = TEXTCOLOUR;
        textLabel.font = [UIFont systemFontOfSize:12.0];
        textLabel.textAlignment = UITextAlignmentLeft;
        textLabel.text = NSLocalizedString(@"Unlink DropBox",@"Unlink DropBox");
        [cell.contentView addSubview:textLabel];        
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

#pragma mark - Table view delegate

/**
 sets the timing of the deselect
 @id
 */
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

/**
 (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case 0:
                isBackup = YES;
                [self backup];
                break;
            case 1:
                isBackup = NO;
                if (!self.dropBoxFileExists && !self.newDropboxFileExists)
                {
                    UIAlertView *noFile = [[UIAlertView alloc]initWithTitle:@"No data" message:@"No saved data on Dropbox" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [noFile show];
                }
                else
                {
                    [self.activityIndicator startAnimating];   
//                    NSString *dataPath = [self dropBoxFileTmpPath];
                    [[self restClient] loadRevisionsForFile:@"/iStayHealthy/iStayHealthy.isth" limit:1000];
//                    [[self restClient] loadFile:@"/iStayHealthy/iStayHealthy.isth" intoPath:dataPath];
                }
                break;    
        }
    }
    else
    {
        [self unlinkDropBox];        
    }
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
}

#pragma mark - DropBox actions
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
#ifdef APPDEBUG
    [[[UIAlertView alloc] 
       initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked" 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
#endif   
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

/**
 called to create the iStayHealthy folder if it doesn't exist
 */
- (void)createIStayHealthyFolder
{
#ifdef APPDEBUG
    NSLog(@"creating the iStayHealthy folder");
#endif
    [[self restClient] createFolder:@"/iStayHealthy"];    
}

/**
 called to copy the file ending with .xml to the file ending with .isth. The isth extension is recognised by the system.
 */
- (void)copyOldFileToNew
{
#ifdef APPDEBUG
    NSLog(@"copying iStayHealthy.xml to iStayHealthy.isth");
#endif
    [[self restClient] copyFrom:@"/iStayHealthy/iStayHealthy.xml" toPath:@"/iStayHealthy/iStayHealthy.isth"];
}


/**
 (void)backup 
 */
- (void)backup
{
    NSString *dataPath = [self uploadFileTmpPath];
    [self.activityIndicator startAnimating];
#ifdef APPDEBUG
    NSLog(@"DropBoxBackupViewController::backup temporary directory is in %@",dataPath);
#endif    
    DataLoader *loader = [[DataLoader alloc]init];
    [loader getSQLData];
    NSData *xmlData = [loader xmlData];
	NSError *error = nil;
    [xmlData writeToFile:dataPath options:NSDataWritingAtomic error:&error];
	if (error != nil)
    {
		[[[UIAlertView alloc]
		   initWithTitle:@"Error writing XML data to tmp directory" message:[error localizedDescription] 
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		 show];
	}
    else
    {
        [[self restClient]uploadFile:@"iStayHealthy.isth" toPath:@"/iStayHealthy" withParentRev:nil fromPath:dataPath];
    }        

}

- (void)restClient:(DBRestClient *)client loadedRevisions:(NSArray *)revisions forFile:(NSString *)path
{
#ifdef APPDEBUG
    NSLog(@"loaded Revisions with %d entries for path %@",revisions.count, path);
    for (DBMetadata *metadata in revisions)
    {
        NSLog(@"revision is %@, and modified at %@", metadata.rev, metadata.lastModifiedDate);
    }
#endif
    
    if (0 < revisions.count)
    {
        DBMetadata *latestFileMetadata = (DBMetadata *)[revisions objectAtIndex:0];
        NSString *dataPath = [self dropBoxFileTmpPath];
        [[self restClient] loadFile:path atRev:latestFileMetadata.rev intoPath:dataPath];
    }
}

- (void)restClient:(DBRestClient *)client loadRevisionsFailedWithError:(NSError *)error
{
    NSLog(@"loadRevisionsFailedWithError error message is %@ with code %d", [error localizedDescription], [error code]);
    [self.activityIndicator stopAnimating];
}

/**
 (void)restore 
 */
- (void)restore
{
    NSString *dataPath = [self dropBoxFileTmpPath];
    NSData *xmlData = [[NSData alloc]initWithContentsOfFile:dataPath];
    XMLLoader *xmlLoader = [[XMLLoader alloc]initWithData:xmlData];
    NSError *error = nil;
    [xmlLoader startParsing:&error];
    [xmlLoader synchronise];
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc] 
       initWithTitle:NSLocalizedString(@"Restore Data",nil) message:NSLocalizedString(@"Data were copied from DropBox iStayHealthy.isth.",nil)
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];        
    
}



#pragma mark -
#pragma mark DropBox DBRestClient methods
/**
 (DBRestClient*)restClient
 */
- (DBRestClient *)restClient
{
#ifdef APPDEBUG
    NSLog(@"DropboxController restClient");
#endif
    if (!restClient)
    {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}


- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    NSString *path = [metadata path];
    if ([path isEqualToString:@"/"])
    {
        for (DBMetadata *child in metadata.contents)
        {
            NSString *pathName = [child path];
            if ([child isDirectory] && [pathName isEqualToString:@"/iStayHealthy"])
            {
#ifdef APPDEBUG
                NSLog(@"DBRestClient::loadedMetadata - we found the iStayHealthy folder");
#endif
                self.iStayHealthyPath = pathName;
            }
        }
        if (nil == self.iStayHealthyPath)
        {
            [self createIStayHealthyFolder];
        }          
    }
    if ([path isEqualToString:@"/iStayHealthy"])
    {
        for (DBMetadata *child in metadata.contents)
        {
            NSString *pathName = [child path];
            if([pathName hasSuffix:@"iStayHealthy.xml"])
            {
#ifdef APPDEBUG
                NSLog(@"DBRestClient::loadedMetadata - we found the iStayHealthy.xml file");
#endif
                self.dropBoxFileExists = YES;            
            }
            if([pathName hasSuffix:@"iStayHealthy.isth"])
            {
#ifdef APPDEBUG
                NSLog(@"DBRestClient::loadedMetadata - we found the iStayHealthy.isth file");
#endif
                self.newDropboxFileExists = YES;            
            }
        }
        if(self.dropBoxFileExists && !self.newDropboxFileExists)
        {
#ifdef APPDEBUG
            NSLog(@"DBRestClient::loadedMetadata - we found the iStayHealthy.xml but not the isth file");
#endif
            [self copyOldFileToNew];
        }
    }
    
}

/**
 */
- (void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder
{
    
}

- (void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Dropbox Error" message:[NSString stringWithFormat:@"Error creating iStayHealthy folder %@",[error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [errorAlert show];    
}

- (void)restClient:(DBRestClient *)client copiedPath:(NSString *)fromPath to:(DBMetadata *)to
{
    if ([fromPath isEqualToString:@"/iStayHealthy/iStayHealthy.xml"] && [[to path] isEqualToString:@"/iStayHealthy/iStayHealthy.isth"])
    {
        newDropboxFileExists = YES;
    }
}

- (void)restClient:(DBRestClient *)client copyPathFailedWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Dropbox Copy error" message:[NSString stringWithFormat:@"Error copying file %@",[error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [errorAlert show];
}


/**
 (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
 */
- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
#ifdef APPDEBUG
    NSLog(@"Metadata unchanged!");
#endif
}

/**
 (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
 */
- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
#ifdef APPDEBUG
    NSLog(@"Error loading metadata: %@ (%@)", error, [error localizedDescription]);
#endif
    [self showDBError];
}

/**
 */
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    
    if (![[DBSession sharedSession]isLinked])
    {
        return;
    }
#ifdef APPDEBUG
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
#endif
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc] 
       initWithTitle:NSLocalizedString(@"Backup Finished",@"Backup Finished") message:NSLocalizedString(@"Data were sent to DropBox iStayHealthy.xml.",nil)
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}


/**
 */
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
#ifdef APPDEBUG
    NSLog(@"Error uploading file: %@", error);
#endif
    if (![[DBSession sharedSession]isLinked])
    {
        return;
    }
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc] 
       initWithTitle:@"Error Uploading to DropBox" message:@"There was an error uploading data to DropBox." 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
    
}

/**
 */
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath
{
    if (![[DBSession sharedSession]isLinked])
    {
        return;
    }
#ifdef APPDEBUG
    NSLog(@"File downloaded successfully to path: %@", localPath);
#endif
    [self restore];
}

/**
 */
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error{
    if (![[DBSession sharedSession]isLinked])
    {
        return;
    }
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc] 
       initWithTitle:@"Error Loading file from DropBox" message:@"There was an error loading a file from DropBox." 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
    
}


@end
