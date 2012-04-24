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
- (void)loadDefaultPath;
- (void)backup;
- (void)restore;
@property (nonatomic, readonly) DBRestClient* restClient;
@end

@implementation DropBoxBackupViewController
@synthesize iStayHealthyPath, activityIndicator;

/**
 initWithStyle
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
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
- (void) dealloc{    
    [restClient release];
    self.iStayHealthyPath = nil;
    self.activityIndicator = nil;
    [super dealloc];
}

#pragma mark - View lifecycle
/**
 viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Set these variables before launching the app
    self.iStayHealthyPath = nil;
    dropBoxFileExists = NO;
    isBackup = NO;

}

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
 viewWillAppear
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![[DBSession sharedSession] isLinked]) {
    }
    else{
#ifdef APPDEBUG
        [[[[UIAlertView alloc] 
           initWithTitle:@"Account Linked!" message:@"Your dropbox account is already linked" 
           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
          autorelease]
         show];        
#endif
    }
    if (nil == restClient) {
#ifdef APPDEBUG
        NSLog(@"DropBoxBackupViewController viewWillAppear - restClient is null");
#endif
    }    
    else{
        [self loadDefaultPath];
    }
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
    if (0 == section) {
        return 2;
    }
    return 1;
}

/**
 (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+4.0, 118.0, 40.0);
    UIImageView *view = [[[UIImageView alloc]initWithFrame:frame]autorelease];
    [view setImage:[UIImage imageNamed:@"dropbox-small.png"]];
    [cell.contentView addSubview:view];
    
    if (0 == indexPath.section) {
        CGRect textFrame = CGRectMake(CGRectGetMinX(cell.bounds)+150.0, CGRectGetMinY(cell.bounds)+17.0, 100, 14);
        UILabel *textLabel = [[[UILabel alloc]initWithFrame:textFrame]autorelease];
        textLabel.textColor = TEXTCOLOUR;
        textLabel.font = [UIFont systemFontOfSize:12.0];
        textLabel.textAlignment = UITextAlignmentLeft;
        switch (indexPath.row) {
            case 0:
                textLabel.text = NSLocalizedString(@"Save to Dropbox",@"Save to Dropbox");
                break;            
            case 1:
                textLabel.text = NSLocalizedString(@"Get from Dropbox",@"Get from Dropbox");
                break;
        }
        [cell.contentView addSubview:textLabel];
    }
    else{
        CGRect textFrame = CGRectMake(CGRectGetMinX(cell.bounds)+150.0, CGRectGetMinY(cell.bounds)+19.0, 100, 12);
        UILabel *textLabel = [[[UILabel alloc]initWithFrame:textFrame]autorelease];
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
    if (0 == indexPath.section) {
        switch (indexPath.row) {
            case 0:
                isBackup = YES;
                [self backup];
                break;
            case 1:
                isBackup = NO;
                [self restore];
                break;    
        }
    }
    else{
        [self unlinkDropBox];        
    }
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
}

#pragma mark - DropBox actions
- (NSString *)dropBoxFileTmpPath{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"fromDropBox.xml"];
}

- (NSString *)uploadFileTmpPath{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"iStayHealthy.xml"];    
}

/**
 (void)unlinkDropBox 
 */
- (void)unlinkDropBox{
    [[DBSession sharedSession] unlinkAll];
#ifdef APPDEBUG
    [[[[UIAlertView alloc] 
       initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked" 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
      autorelease]
     show];
#endif   
}

/**
 (void)showDBError 
 */
- (void)showDBError{
    if (![[DBSession sharedSession]isLinked]) {
        return;
    }
    [[[[UIAlertView alloc] 
       initWithTitle:@"Error Loading DropBox data" message:@"There was an error loading data from DropBox." 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
      autorelease]
     show];
    
}


/**
 (void)loadDefaultPath 
 */
- (void)loadDefaultPath{
    [[self restClient] loadMetadata:@"/"];
    if (nil == self.iStayHealthyPath) {
        [[self restClient] createFolder:@"iStayHealthy"];
    }    
}


/**
 (void)backup 
 */
- (void)backup{
    NSString *dataPath = [self uploadFileTmpPath];
    [self.activityIndicator startAnimating];
#ifdef APPDEBUG
    NSLog(@"DropBoxBackupViewController::backup temporary directory is in %@",dataPath);
#endif    
    DataLoader *loader = [[[DataLoader alloc]init] autorelease];
    [loader getSQLData];
    NSData *xmlData = [loader xmlData];
	NSError *error = nil;
    [xmlData writeToFile:dataPath options:NSDataWritingAtomic error:&error];
	if (error != nil) {
		[[[[UIAlertView alloc]
		   initWithTitle:@"Error writing XML data to tmp directory" message:[error localizedDescription] 
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		  autorelease]
		 show];
	}
    else{
        [[self restClient]uploadFile:@"iStayHealthy.xml" toPath:@"/iStayHealthy" withParentRev:nil fromPath:dataPath];
    }        

}

/**
 (void)restore 
 */
- (void)restore{
    NSString *dataPath = [self dropBoxFileTmpPath];
    [self.activityIndicator startAnimating];    
    [[self restClient] loadFile:@"/iStayHealthy/iStayHealthy.xml" intoPath:dataPath];
    NSData *xmlData = [[[NSData alloc]initWithContentsOfFile:dataPath]autorelease];
    XMLLoader *xmlLoader = [[[XMLLoader alloc]initWithData:xmlData]autorelease];
    NSError *error = nil;
    if([xmlLoader startParsing:&error]){
        [xmlLoader synchronise];
    }
    
}



#pragma mark -
#pragma mark DropBox DBRestClient methods
/**
 (DBRestClient*)restClient
 */
- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}


- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
#ifdef APPDEBUG
    NSLog(@"calling DBRestClient::loadedMetadata");
#endif
    for (DBMetadata *child in metadata.contents) {
        NSString *pathName = [child path];
        if ([child isDirectory] && [pathName isEqualToString:@"iStayHealthy"]) {
            self.iStayHealthyPath = pathName;
        }
        else if([pathName isEqualToString:@"iStayHealthy.xml"]){
            dropBoxFileExists = YES;            
        }
    }
    
}

/**
 (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
 */
- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
#ifdef APPDEBUG
    NSLog(@"Metadata unchanged!");
#endif
}

/**
 (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
 */
- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
#ifdef APPDEBUG
    NSLog(@"Error loading metadata: %@", error);
#endif
    [self showDBError];
}

/**
 */
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    if (![[DBSession sharedSession]isLinked]) {
        return;
    }
#ifdef APPDEBUG
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
#endif
    [self.activityIndicator stopAnimating];
    [[[[UIAlertView alloc] 
       initWithTitle:NSLocalizedString(@"Backup Finished",@"Backup Finished") message:NSLocalizedString(@"Data were sent to DropBox iStayHealthy.xml.",nil)
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
      autorelease]
     show];
}


/**
 */
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error{
#ifdef APPDEBUG
    NSLog(@"Error uploading file: %@", error);
#endif
    if (![[DBSession sharedSession]isLinked]) {
        return;
    }
    [self.activityIndicator stopAnimating];
    [[[[UIAlertView alloc] 
       initWithTitle:@"Error Uploading to DropBox" message:@"There was an error uploading data to DropBox." 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
      autorelease]
     show];
    
}

/**
 */
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    if (![[DBSession sharedSession]isLinked]) {
        return;
    }
#ifdef APPDEBUG
    NSLog(@"File downloaded successfully to path: %@", localPath);
#endif
    [self.activityIndicator stopAnimating];
    [[[[UIAlertView alloc] 
       initWithTitle:NSLocalizedString(@"Restore Data",nil) message:NSLocalizedString(@"Data were copied from DropBox iStayHealthy.xml.",nil)
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
      autorelease]
     show];        
}

/**
 */
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error{
    if (![[DBSession sharedSession]isLinked]) {
        return;
    }
    [self.activityIndicator stopAnimating];
    [[[[UIAlertView alloc] 
       initWithTitle:@"Error Loading file from DropBox" message:@"There was an error loading a file from DropBox." 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
      autorelease]
     show];
    
}


@end
