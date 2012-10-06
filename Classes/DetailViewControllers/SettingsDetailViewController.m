//
//  SettingsDetailViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 05/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsDetailViewController.h"
#import "DropBoxBackupViewController.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import "DataLoader.h"
#import "ToolsTableViewController.h"
#import "SettingsCell.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Utilities.h"
#import "WebViewController.h"
#import "UINavigationBar-Button.h"


@implementation SettingsDetailViewController

/**
 memory management
 */
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/**
 viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"Extras" target:self selector:@selector(gotoPOZ)];
    }

}



/**
 */
- (void)gotoPOZ
{
    NSString *url = @"http://www.poz.com";
    NSString *title = @"POZ Magazine";
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:url withTitle:title];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
    
}



#pragma mark - Actions
/**
 return to parent root controller
 */
- (IBAction) done:	(id) sender
{
	[self dismissModalViewControllerAnimated:YES];    
}


/**
 backup/syn from DropBox
 */
- (void)startDropBox
{
    if (![[DBSession sharedSession] isLinked])
    {
		[[DBSession sharedSession] linkFromController:self];
    }
    DropBoxBackupViewController *dropBoxController = [[DropBoxBackupViewController alloc]
                                                      initWithNibName:@"DropBoxBackupViewController" bundle:nil];
    [self.navigationController pushViewController:dropBoxController animated:YES];
}

/**
 */
- (void)startEmailResultsMessageView
{
    if (![MFMailComposeViewController canSendMail])
    {
#ifdef APPDEBUG
        NSLog(@"MFMailComposeViewController not configured to send mails");
#endif
        return;
    }
    if (DEVICE_IS_SIMULATOR)
    {
#ifdef APPDEBUG
        NSLog(@"SettingsDetailViewController::startEmailMessageView called from iPhone Simulator");
#endif
    }
    NSString *tmpXMLFile = [NSTemporaryDirectory() stringByAppendingFormat:@"iStayHealthy.isth"];
    DataLoader *loader = [[DataLoader alloc]init];
    [loader getSQLData];
    NSString *msgBody = [loader csvString];
    NSData *xmlData = [loader xmlData];
	NSError *error = nil;
    [xmlData writeToFile:tmpXMLFile options:NSDataWritingAtomic error:&error];
	if (error != nil)
    {
		[[[UIAlertView alloc]
		   initWithTitle:@"Error writing XML data to tmp directory" message:[error localizedDescription] 
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		 show];
	}
 
    else
    {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];        
        mailController.mailComposeDelegate = self;
        [mailController setSubject:@"iStayHealthy Data (attached)"];
        [mailController setMessageBody:msgBody isHTML:NO];
        [mailController addAttachmentData:xmlData mimeType:@"text/xml" fileName:tmpXMLFile];
        [self presentModalViewController:mailController animated:YES];
    }
    
}


/**
 start the E-mail Message Viewer
 */
- (void)startEmailMessageView
{
    if (![MFMailComposeViewController canSendMail])
    {
#ifdef APPDEBUG
        NSLog(@"MFMailComposeViewController not configured to send mails");
#endif
        return;
    }
    if (DEVICE_IS_SIMULATOR)
    {
#ifdef APPDEBUG
        NSLog(@"SettingsDetailViewController::startEmailMessageView called from iPhone Simulator");
#endif
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    NSArray *toRecipient = [NSArray arrayWithObjects:@"istayhealthy.app@gmail.com", nil];
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:toRecipient];
    [mailController setSubject:@"Feedback for iStayHealthy iPhone app"];
    [self presentModalViewController:mailController animated:YES];
}

/**
 called when e-mail message is sent
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    NSString *resultText = @"";
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
//            resultText = @"Result: canceled";
#ifdef APPDEBUG
            NSLog(@"Result: canceled");
#endif
            break;
        }
        case MFMailComposeResultSent:
        {
//            resultText = @"Result: sent";
#ifdef APPDEBUG
            NSLog(@"Result: sent");
#endif
            break;
        }
        case MFMailComposeResultFailed:
        {
            resultText = @"Result: failed";
#ifdef APPDEBUG
            NSLog(@"Result: failed");
#endif
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iStayHealthy E-mail" 
                                                                message:resultText delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            break;
        }
        case MFMailComposeResultSaved:
        {
//            resultText = @"Result: saved";
#ifdef APPDEBUG
            NSLog(@"Result: saved");
#endif
            break;
        }
    }
    [self dismissModalViewControllerAnimated:YES];
}





/**
 */
- (void)startPasswordController
{
    ToolsTableViewController *toolsController =
    [[ToolsTableViewController alloc] initWithNibName:@"ToolsTableViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                     initWithRootViewController:toolsController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];    
}



#pragma mark - Table view data source

/**
 numberOfSectionsInTableView
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
        return 3;
//        return 4;
    }
    return 1;
}



/**
 @tableView
 @indexPath
 @return height as CGFloat
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

/**
 (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        NSString *identifier = @"SettingsCell";
        SettingsCell *cell = (SettingsCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SettingsCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[SettingsCell class]])
                {
                    cell = (SettingsCell *)currentObject;
                    break;
                }
            }  
        }
        int row = indexPath.row;
        switch (row)
        {
            case 0:
                [[cell settingsImageView]setImage:[UIImage imageNamed:@"dropbox-small.png"]];
                [[cell label]setText:NSLocalizedString(@"Backup", @"Backup")];
                break;
            case 1:
                [[cell settingsImageView]setImage:[UIImage imageNamed:@"feedback-small.png"]];
                [[cell label]setText:NSLocalizedString(@"Feedback?", @"Feedback?")];
                break;
            case 2:
                [[cell settingsImageView]setImage:[UIImage imageNamed:@"e-mail-small.png"]];
                [[cell label]setText:NSLocalizedString(@"Email Results", @"Email Results")];
                break;
                /*
            case 3:
                [[cell label]setText:@"Tintabee Server"];
                break;
                 */
        }
        return cell;
        
    }
    if (1 == indexPath.section)
    {
        NSString *identifier = @"PasswordCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"PasswordCell"
                                                                owner:self
                                                              options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[UITableViewCell class]])
                {
                    cell = (UITableViewCell *)currentObject;
                    break;
                }
            }  
        }
        return cell;
    }
    return nil;
    
}


#pragma mark - Table view delegate
/**
 phase out when deselecting
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
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    if (0 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case 0:
                [self startDropBox];
                break;
                
            case 1:
                [self startEmailMessageView];        
                break;
            case 2:
                [self startEmailResultsMessageView];
                break;
                /*
            case 3:
                [self testTintabee];
                break;
                 */
        }
    }
    else
    {
        [self startPasswordController];
    }
}




@end
