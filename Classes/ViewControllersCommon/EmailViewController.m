//
//  EmailViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/03/2014.
//
//

#import "EmailViewController.h"
#import "Constants.h"
#import "GeneralSettings.h"
#import "ContentNavigationController.h"
@interface EmailViewController ()
@property (nonatomic, strong) MFMailComposeViewController *mailController;
@end

@implementation EmailViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = DEFAULT_BACKGROUND;
	UIImage *menuImage = [UIImage imageNamed:@"menu.png"];
	UIImageView *menuView = [[UIImageView alloc] initWithImage:menuImage];
	menuView.backgroundColor = [UIColor clearColor];
	menuView.frame = CGRectMake(0, 0, 20, 20);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 20, 20);
	button.backgroundColor = [UIColor clearColor];
	[button addSubview:menuView];
	[button addTarget:self action:@selector(hamburgerMenu) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)hamburgerMenu
{
	if ([self.parentViewController isKindOfClass:[ContentNavigationController class]])
	{
		ContentNavigationController *navController = (ContentNavigationController *)self.parentViewController;
		[navController showMenu];
	}
}

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
	NSString *cellIdentifier = @"MailCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	if (0 == indexPath.section)
	{
		cell.textLabel.text = NSLocalizedString(@"Feedback", nil);
	}
	else
	{
		cell.textLabel.text = NSLocalizedString(@"Email results", nil);
	}
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
		[self startFeedbackController];
	}
	else
	{
		[self startMailController];
	}
}

- (void)startMailController
{
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
	mailController.mailComposeDelegate = self;
	self.mailController = mailController;
	[mailController setSubject:@"iStayHealthy Data (attached)"];
	self.mailController = mailController;
	//    [mailController setMessageBody:msgBody isHTML:NO];
	//    [mailController addAttachmentData:xmlData mimeType:@"text/xml" fileName:tmpXMLFile];
	ContentNavigationController *navController = (ContentNavigationController *)self.parentViewController;
	[navController showMailController:mailController];
//	[self.navigationController presentViewController:mailController animated:YES completion:nil];
}

- (void)startFeedbackController
{
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];

	NSArray *toRecipient = [NSArray arrayWithObjects:@"istayhealthy.app@gmail.com", nil];
	mailController.mailComposeDelegate = self;
	[mailController setToRecipients:toRecipient];
	[mailController setSubject:@"Feedback for iStayHealthy iPhone app"];
	ContentNavigationController *navController = (ContentNavigationController *)self.parentViewController;
	[navController showMailController:mailController];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
	if (nil != self.mailController)
	{
		ContentNavigationController *navController = (ContentNavigationController *)self.parentViewController;
		[navController hideMailController:self.mailController];
	}
//	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
