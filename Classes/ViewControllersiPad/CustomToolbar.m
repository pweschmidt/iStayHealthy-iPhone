//
//  CustomToolbar.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/02/2014.
//
//

#import "CustomToolbar.h"
#import "UIBarButtonItem+iStayHealthy.h"
#import "SettingsTableViewController.h"
#import "InformationTableViewController.h"
#import "DropboxViewController.h"
#import "Menus.h"
#import <DropboxSDK/DropboxSDK.h>
#import "GeneralSettings.h"
#import "Constants.h"

@interface CustomToolbar ()
{
	CGRect popUpFrame;
}

@end

@implementation CustomToolbar

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self addCustomBarbuttons];
	}
	return self;
}

- (void)addCustomBarbuttons
{
	NSArray *buttonTypes = [Menus toolbarButtonItems];
	__block NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:buttonTypes.count];
	[buttonTypes enumerateObjectsUsingBlock: ^(NSString *title, NSUInteger index, BOOL *stop) {
	    UIBarButtonItem *barbutton = nil;
	    if ([title isEqualToString:NSLocalizedString(@"Settings", nil)])
	    {
	        barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openSettings)];
		}
	    else if ([title isEqualToString:NSLocalizedString(@"Backups", nil)])
	    {
	        barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openBackup)];
		}
	    else if ([title isEqualToString:NSLocalizedString(@"Feedback", nil)])
	    {
	        barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openFeedback)];
		}
	    else if ([title isEqualToString:NSLocalizedString(@"Email Data", nil)])
	    {
	        barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openMailWithAttachment)];
		}
	    else if ([title isEqualToString:NSLocalizedString(@"Info", nil)])
	    {
	        barbutton = [UIBarButtonItem barButtonItemForTitle:title target:self action:@selector(openInfo)];
		}
	    if (nil != barbutton)
	    {
	        [buttons addObject:barbutton];
		}
	}];
	[self setItems:buttons];
}

- (void)openFeedback
{
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];

	NSArray *toRecipient = [NSArray arrayWithObjects:@"istayhealthy.app@gmail.com", nil];
	mailController.mailComposeDelegate = self;
	[mailController setToRecipients:toRecipient];
	[mailController setSubject:@"Feedback for iStayHealthy iPhone app"];
}

- (void)openMailWithAttachment
{
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
	mailController.mailComposeDelegate = self;
	[mailController setSubject:@"iStayHealthy Data (attached)"];
}

- (void)openSettings
{
	SettingsTableViewController *settingsController = [[SettingsTableViewController alloc] init];
}

- (void)openInfo
{
	InformationTableViewController *infoController = [[InformationTableViewController alloc] init];
}

- (void)openBackup
{
	DropboxViewController *backupController = [[DropboxViewController alloc] init];
	if (![[DBSession sharedSession] isLinked])
	{
		[[DBSession sharedSession] linkFromController:backupController];
	}
	else
	{
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
}

@end
