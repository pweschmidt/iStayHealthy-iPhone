//
//  DropboxViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "DropboxViewController.h"
#import "Constants.h"
#import "Utilities.h"
#import "Menus.h"
#import "UILabel+Standard.h"
#import "UIFont+Standard.h"
#import "CoreXMLReader.h"
#import "CoreXMLWriter.h"
#import <DropboxSDK/DropboxSDK.h>
#import "iStayHealthy-Swift.h"

#define kiStayHealthyPath        @"/iStayHealthy"
#define kiStayHealthyUploadFile  @"iStayHealthy_upload.isth"
#define kiStayHealthyFile        @"iStayHealthy.isth"
#define kiStayHealthyFilePath    @"/iStayHealthy/iStayHealthy.isth"
#define kiStayHealthyNewFilePath @"/iStayHealthy/iStayHealthy_upload.isth"
#define kBackupDateFormat        @"ddMMMyyyy'_'HHmmss"

@interface DropboxViewController () <DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, assign) BOOL dropBoxFileExists;
@property (nonatomic, assign) BOOL newDropboxFileExists;
@property (nonatomic, assign) BOOL isConnectAlert;
@property (nonatomic, assign) BOOL isBackup;
@property (nonatomic, strong) NSString *iStayHealthyPath;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityIndicatorLabel;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
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
    label.frame = CGRectMake(20, 0, 200, [self tableView:self.tableView estimatedHeightForRowAtIndexPath:indexPath]);
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
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Backup?", nil)
                                                                    message:NSLocalizedString(@"You are about to store your data externally. Click Backup if you want to continue.", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                          otherButtonTitles:NSLocalizedString(@"Backup", nil), nil];
                    [alert show];
                }
                break;

                case 1:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore?", nil)
                                                                    message:NSLocalizedString(@"You are about to download  data from an external storage. Click Restore if you want to continue.", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                          otherButtonTitles:NSLocalizedString(@"Restore", nil), nil];
                    [alert show];
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
        self.activityIndicatorLabel = label;
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
            UINavigationController *navController = (UINavigationController *) self.parentViewController;
            PWESContentContainerController *contentController = (PWESContentContainerController *) navController.parentViewController;
            [[DBSession sharedSession] linkFromController:contentController];
        }
    }
    else if ([title isEqualToString:NSLocalizedString(@"Backup", nil)])
    {
        [self backup];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Restore", nil)])
    {
        [self restoreFromDropbox];
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
    [PWESAlertHandler.alertHandler
     showAlertViewWithCancelButton:NSLocalizedString(@"Error Loading Dropbox data", nil)
     message:NSLocalizedString(@"There was an error loading data from Dropbox.", nil)
     presentingController:self];
}

- (void)createIStayHealthyFolder
{
    [self.restClient createFolder:kiStayHealthyPath];
}

- (void)backup
{
    if (![[DBSession sharedSession]isLinked])
    {
        return;
    }
    NSString *dataPath = [self uploadFileTmpPath];
    [self startAnimation:nil];
    CoreXMLWriter *writer = [CoreXMLWriter new];
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
                 [PWESAlertHandler.alertHandler
                  showAlertViewWithCancelButton:NSLocalizedString(@"Error writing data to tmp directory", nil)
                  message:error.description
                  presentingController:self];
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
             [PWESAlertHandler.alertHandler
              showAlertViewWithCancelButton:NSLocalizedString(@"Error writing data", nil)
              message:error.description
              presentingController:self];
         }
     }];
}

- (void)restoreFromDropbox
{
    if ([[DBSession sharedSession] isLinked])
    {
        [self startAnimation:nil];
        NSString *dataPath = [self dropBoxFileTmpPath];
        [self.restClient loadFile:kiStayHealthyFilePath
                         intoPath:dataPath];
    }
}


- (void)restore
{
    NSString *dataPath = [self dropBoxFileTmpPath];
    NSData *xmlData = [[NSData alloc]initWithContentsOfFile:dataPath];
    CoreXMLReader *reader = [CoreXMLReader new];

    [reader parseXMLData:xmlData completionBlock: ^(BOOL success, NSError *error) {
         if (success)
         {
             [self stopAnimation:nil];
             [PWESAlertHandler.alertHandler
              showAlertViewWithOKButton:NSLocalizedString(@"Restore Finished", nil)
              message:NSLocalizedString(@"Data were retrieved from Dropbox.", nil)
              presentingController:self];
         }
         else
         {
             [self stopAnimation:nil];
             [PWESAlertHandler.alertHandler
              showAlertViewWithCancelButton:NSLocalizedString(@"Error retrieving data", nil)
              message:error.localizedDescription
              presentingController:self];
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
#ifdef APPDEBUG
                NSLog(@"**** backup file found %@ ****", pathName);
#endif
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
    [PWESAlertHandler.alertHandler
     showAlertViewWithCancelButton:@"Dropbox Error"
     message:[NSString stringWithFormat:@"Error creating iStayHealthy folder %@", [error localizedDescription]]
     presentingController:self];
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
    [PWESAlertHandler.alertHandler
     showAlertViewWithOKButton:NSLocalizedString(@"Save Finished", nil)
     message:NSLocalizedString(@"Data were sent to DropBox iStayHealthy.isth.", nil)
     presentingController:self];

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
    [PWESAlertHandler.alertHandler
     showAlertViewWithCancelButton:@"Error Uploading to Dropbox"
     message:@"There was an error uploading data to Dropbox."
     presentingController:self];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
{
    [self restore];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    [self stopAnimation:nil];
    [PWESAlertHandler.alertHandler
     showAlertViewWithCancelButton:@"Error Loading file from Dropbox"
     message:@"There was an error loading a file from Dropbox."
     presentingController:self];
}

- (void)restClient:(DBRestClient *)client movedPath:(NSString *)from_path to:(DBMetadata *)result
{
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
    NSLog(@"The move to the filepath failed due to %@ with error code %lu", error.localizedDescription, (long) error.code);
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
        self.activityIndicatorLabel.text = NSLocalizedString(@"Syncing data...", nil);
    }
}

- (void)stopAnimation:(NSNotification *)notification
{
    if ([self.activityIndicator isAnimating])
    {
        [self.activityIndicator stopAnimating];
        self.activityIndicatorLabel.text = @"";
    }
}

- (void)handleStoreChanged:(NSNotification *)notification
{
}

- (NSString *)backedUpFileName
{
    NSDateFormatter *formatter = [NSDateFormatter new];

    formatter.dateFormat = kBackupDateFormat;
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
