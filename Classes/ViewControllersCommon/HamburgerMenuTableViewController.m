//
//  HamburgerMenuTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "HamburgerMenuTableViewController.h"
#import "ContentContainerViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "GeneralSettings.h"
#import "Constants.h"
#import "Menus.h"
#import "UILabel+Standard.h"
#import "UIFont+Standard.h"

@interface HamburgerMenuTableViewController ()
@property (nonatomic, strong) NSArray *menus;
@end

@implementation HamburgerMenuTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = DEFAULT_BACKGROUND;
    [self setTitleViewWithTitle:NSLocalizedString(@"Menu", nil)];
    [self disableRightBarButtons];
//    self.navigationItem.title = NSLocalizedString(@"Menu", nil);
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel)];
    
    self.menus = [Menus hamburgerMenus];
}

- (void)goToPOZSite
{
    NSLog(@"navigation button clicked");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.menus objectAtIndex:indexPath.row];
    cell.textLabel.textColor = TEXTCOLOUR;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *controllerName = [Menus
                                controllerNameForRowIndexPath:indexPath
                                ignoreFirst:NO];
    if (nil == controllerName)
    {
        return;
    }
    if ([controllerName isEqualToString:kDropboxController])
    {
        if (![[DBSession sharedSession] isLinked])
        {
            [[DBSession sharedSession] linkFromController:self];
        }
        else
        {
            [(ContentContainerViewController *)self.parentViewController transitionToNavigationControllerWithName:controllerName];            
        }
    }
    else if ([controllerName isEqualToString:kFeedbackController])
    {
        [self startFeedbackController];
    }
    else if ([controllerName isEqualToString:kEmailController])
    {
        [self startMailController];
    }
    else
    {
        [(ContentContainerViewController *)self.parentViewController transitionToNavigationControllerWithName:controllerName];
    }
}

- (void)cancel
{
    [(ContentNavigationController *)self.parentViewController rewindToPreviousController];
}

- (void)startMailController
{
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@"iStayHealthy Data (attached)"];
//    [mailController setMessageBody:msgBody isHTML:NO];
//    [mailController addAttachmentData:xmlData mimeType:@"text/xml" fileName:tmpXMLFile];
    [self.navigationController presentViewController:mailController animated:YES completion:^{
    }];
}

- (void)startFeedbackController
{
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    NSArray *toRecipient = [NSArray arrayWithObjects:@"istayhealthy.app@gmail.com", nil];
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:toRecipient];
    [mailController setSubject:@"Feedback for iStayHealthy iPhone app"];
    [self.navigationController presentViewController:mailController animated:YES completion:^{
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
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
