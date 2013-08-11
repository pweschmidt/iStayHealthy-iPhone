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
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxViewController ()<DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient* restClient;
@property (nonatomic, assign) BOOL dropBoxFileExists;
@property (nonatomic, assign) BOOL newDropboxFileExists;
@property (nonatomic, assign) BOOL isBackup;
@property (nonatomic, strong) NSString *iStayHealthyPath;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *parentRevision;
@end

@implementation DropboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Dropbox", nil);
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(settingsMenu)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMenu)];
    self.iStayHealthyPath = nil;
    self.dropBoxFileExists = NO;
    self.newDropboxFileExists = NO;
    self.isBackup = NO;
    self.parentRevision = nil;
    [self setRestClient];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods
- (void)settingsMenu
{
    [(ContentNavigationController *)self.parentViewController transitionToNavigationControllerWithName:kMenuController];
}

- (void)addMenu
{
    [(ContentNavigationController *)self.parentViewController transitionToNavigationControllerWithName:kAddController];
}

#pragma mark - DropBox actions

- (void)setRestClient
{
    if (![[DBSession sharedSession] isLinked])
    {
		return;
    }
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
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
    [self.activityIndicator startAnimating];
    /*
    DataLoader *dataLoader = [[DataLoader alloc] init];
    NSData *xmlData = [dataLoader xmlData];
	NSError *error = nil;
    [xmlData writeToFile:dataPath options:NSDataWritingAtomic error:&error];
	if (error != nil)
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
    */
}

- (void)restore
{
    NSString *dataPath = [self dropBoxFileTmpPath];
    NSData *xmlData = [[NSData alloc]initWithContentsOfFile:dataPath];
    [[CoreXMLReader sharedInstance] parseXMLData:xmlData];
    /*
    XMLLoader *xmlLoader = [[XMLLoader alloc]initWithData:xmlData];
    NSError *error = nil;
    [xmlLoader startParsing:&error];
    BOOL success = [xmlLoader synchronise];
    [self.activityIndicator stopAnimating];
    if (success)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:kDataTablesCleaned];
        [defaults synchronize];
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Restore Data",nil) message:NSLocalizedString(@"Data were copied from DropBox iStayHealthy.isth.",nil)
          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
    }
    else
    {
        [self showDBError];
    }
    */
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
        DBMetadata *backupFile = nil;
        for (DBMetadata *child in metadata.contents)
        {
            NSString *pathName = [child path];
            if([pathName hasSuffix:@"iStayHealthy.isth"])
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
    }
}

- (void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder
{
    
}

- (void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Dropbox Error" message:[NSString stringWithFormat:@"Error creating iStayHealthy folder %@",[error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
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
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Dropbox Copy error" message:[NSString stringWithFormat:@"Error copying file %@",[error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [errorAlert show];
}


- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    [self showDBError];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc]
      initWithTitle:NSLocalizedString(@"Backup Finished",@"Backup Finished") message:NSLocalizedString(@"Data were sent to DropBox iStayHealthy.xml.",nil)
      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}


- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc]
      initWithTitle:@"Error Uploading to DropBox" message:@"There was an error uploading data to DropBox."
      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
    
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath
{
    [self restore];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error{
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc]
      initWithTitle:@"Error Loading file from DropBox" message:@"There was an error loading a file from DropBox."
      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}
@end
