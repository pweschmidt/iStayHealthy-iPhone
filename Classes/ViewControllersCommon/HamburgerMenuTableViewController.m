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
#import "Menus.h"
#import "UILabel+Standard.h"
#import "UIFont+Standard.h"

@interface HamburgerMenuTableViewController ()
@property (nonatomic, strong) NSArray *menus;
@property (nonatomic, strong) NSArray *controllers;
@end

@implementation HamburgerMenuTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = kDarkBackgroundColor;
	self.tableView.backgroundColor = kDarkBackgroundColor;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self setTitleViewWithTitle:NSLocalizedString(@"Menu", nil)];
	[self disableRightBarButtons];
//    self.navigationItem.title = NSLocalizedString(@"Menu", nil);
	UIImage *menuImage = [UIImage imageNamed:@"cancel.png"];
	UIImageView *menuView = [[UIImageView alloc] initWithImage:menuImage];
	menuView.backgroundColor = [UIColor clearColor];
	menuView.frame = CGRectMake(0, 0, 20, 20);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 20, 20);
	button.backgroundColor = [UIColor clearColor];
	[button addSubview:menuView];
	[button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                             target:self action:@selector(cancel)];

	self.menus = [Menus hamburgerMenus];
	self.controllers = [Menus controllerMenu];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
	[self dismissViewControllerAnimated:YES completion:nil];
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
	NSString *CellIdentifier = [NSString stringWithFormat:@"SettingsCell%ld", (long)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
//	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.backgroundColor = [UIColor clearColor];
	CGFloat offset = (self.tableView.rowHeight - 25) / 2;

	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(60, 0, 200, self.tableView.rowHeight);
	label.textAlignment = NSTextAlignmentLeft;
	label.text = [self.menus objectAtIndex:indexPath.row];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont fontWithType:Bold size:standard];
	[cell.contentView addSubview:label];
	NSString *controllerName = [Menus
	                            controllerNameForRowIndexPath:indexPath
	                                              ignoreFirst:NO];
	if (nil != controllerName)
	{
		NSDictionary *images = [Menus menuImages];
		UIImage *image = [images objectForKey:controllerName];
		if (nil != image)
		{
			UIImageView *medImageView = [[UIImageView alloc] init];
			medImageView.frame = CGRectMake(20, offset, 25, 25);
			medImageView.backgroundColor = [UIColor clearColor];
			medImageView.image = image;
			[cell.contentView addSubview:medImageView];
		}
	}



	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *toControllerName = [self.controllers objectAtIndex:indexPath.row];
	__strong id <PWESNavigationDelegate> strongDelegate = self.transitionDelegate;
	if (nil != strongDelegate && [strongDelegate respondsToSelector:@selector(changeTransitionType:)]
	    && [strongDelegate respondsToSelector:@selector(transitionToNavigationControllerWithName:completion:)])
	{
		[strongDelegate changeTransitionType:kControllerTransition];
		[strongDelegate transitionToNavigationControllerWithName:toControllerName completion:nil];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startMailController
{
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.navigationController.navigationBar.tintColor = [UIColor blackColor];
	mailController.mailComposeDelegate = self;
	[mailController setSubject:@"iStayHealthy Data (attached)"];
//    [mailController setMessageBody:msgBody isHTML:NO];
//    [mailController addAttachmentData:xmlData mimeType:@"text/xml" fileName:tmpXMLFile];
	[self.navigationController presentViewController:mailController animated:YES completion: ^{
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
	[self.navigationController presentViewController:mailController animated:YES completion: ^{
	}];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)disableRightBarButtons
{
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)setTitleViewWithTitle:(NSString *)titleString
{
	if (nil == titleString)
	{
		return;
	}
	CGFloat width = 180;
	CGFloat height = 44;
	CGFloat logoWidth = 29;
	CGFloat pozWidth = 45;
	CGFloat labelWidth = 180 - 29 - 45;
	CGFloat topOffset = (44 - 29) / 2;
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, width, height);

	UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_29.png"]];
	logo.frame = CGRectMake(0, topOffset, logoWidth, logoWidth);
	logo.layer.cornerRadius = 6;
	logo.layer.masksToBounds = YES;
	UIImageView *poz = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pozicon.png"]];
	poz.frame = CGRectMake(width - pozWidth, topOffset, pozWidth, logoWidth);
	poz.layer.cornerRadius = 6;
	poz.layer.masksToBounds = YES;

	[button addSubview:logo];
	[button addSubview:poz];

	UILabel *titleLabel = [UILabel standardLabel];
	titleLabel.text = titleString;
	titleLabel.frame = CGRectMake(logoWidth, 0, labelWidth, height);
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.font = [UIFont fontWithType:Standard size:17];
	titleLabel.numberOfLines = 0;
	titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

	[button addSubview:titleLabel];
	[button    addTarget:self
	              action:@selector(goToPOZSite)
	    forControlEvents:UIControlEventTouchUpInside];
	[titleView addSubview:button];

	self.navigationItem.titleView = titleView;
}

@end
