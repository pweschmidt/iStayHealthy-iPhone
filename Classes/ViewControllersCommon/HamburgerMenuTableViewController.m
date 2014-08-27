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
#import "Utilities.h"
#import "AppSettings.h"

@interface HamburgerMenuTableViewController ()
@property (nonatomic, strong) NSArray *menus;
@property (nonatomic, strong) NSArray *controllers;
@end

#define kIconLabelViewTag 100
#define kIconImageViewTag 101

@implementation HamburgerMenuTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = kDarkBackgroundColor;
	self.tableView.backgroundColor = kDarkBackgroundColor;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	self.menus = [Menus hamburgerMenus];
	self.controllers = [Menus controllerMenu];
}

- (void)goToPOZSite
{
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 84;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 84)];
	view.backgroundColor = kDarkBackgroundColor;

	NSString *version = [[AppSettings sharedInstance] versionString];
	NSString *name = [NSString stringWithFormat:@"iStayHealthy %@", version];
	UILabel *versionLabel = [UILabel standardLabel];
	versionLabel.frame = CGRectMake(20, 64, self.view.bounds.size.width, 20);
	versionLabel.text = name;
	versionLabel.font = [UIFont fontWithType:BoldItalic size:standard];
	versionLabel.textAlignment = NSTextAlignmentLeft;
	versionLabel.textColor = [UIColor whiteColor];
	[view addSubview:versionLabel];

	return view;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([Utilities isIPad])
	{
		return 55;
	}
	return self.tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = [NSString stringWithFormat:@"SettingsCell%ld", (long)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.contentView.backgroundColor = [UIColor clearColor];
	cell.backgroundColor = [UIColor clearColor];
	CGFloat offset = (self.tableView.rowHeight - 42) / 2;
	if ([Utilities isIPad])
	{
		offset = 5.5f;
	}


	id labelObj = [cell.contentView viewWithTag:kIconLabelViewTag];
	NSString *menuName = [self.menus objectAtIndex:indexPath.row];
	if (nil == labelObj)
	{
		UILabel *label = [UILabel standardLabel];
		label.frame = CGRectMake(65, 0, 200, self.tableView.rowHeight);
		label.textAlignment = NSTextAlignmentLeft;
		label.text = menuName;
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont fontWithType:Bold size:standard];
		label.tag = kIconLabelViewTag;
		[cell.contentView addSubview:label];
	}
	id imageObj = [cell.contentView viewWithTag:kIconImageViewTag];


	NSString *controllerName = [Menus
	                            controllerNameForRowIndexPath:indexPath
	                                              ignoreFirst:NO];
	if (nil == imageObj)
	{
		UIImageView *medImageView = [[UIImageView alloc] init];
		medImageView.backgroundColor = [UIColor clearColor];
		if (nil != controllerName)
		{
			NSDictionary *images = [Menus menuImages];
			medImageView.frame = CGRectMake(20, offset, 42, 42);
			medImageView.image = [images objectForKey:controllerName];
		}
		else
		{
			medImageView.frame = CGRectMake(20, 3, 42, 29);
			medImageView.image = [UIImage imageNamed:@"pozicon.png"];
		}
		medImageView.tag = kIconImageViewTag;
		[cell.contentView addSubview:medImageView];
	}



	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *menuName = [self.menus objectAtIndex:indexPath.row];
	NSString *toControllerName = [self.controllers objectAtIndex:indexPath.row];
	__strong id <PWESNavigationDelegate> strongDelegate = self.transitionDelegate;
	BOOL doTransition = NO;
	if ([menuName isEqualToString:NSLocalizedString(@"POZ Magazine", nil)])
	{
		NSString *urlString = NSLocalizedString(@"BannerURL", nil);

		if ([urlString hasPrefix:@"http"])
		{
			NSURL *url = [NSURL URLWithString:urlString];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
	else
	{
		doTransition = YES;
		if (nil != strongDelegate && [strongDelegate respondsToSelector:@selector(changeTransitionType:)]
		    && [strongDelegate respondsToSelector:@selector(transitionToNavigationControllerWithName:completion:)])
		{
			[strongDelegate changeTransitionType:kControllerTransition];
		}
	}
	[self dismissViewControllerAnimated:YES completion: ^{
	    if (nil != toControllerName && doTransition && nil != strongDelegate && [strongDelegate respondsToSelector:@selector(transitionToNavigationControllerWithName:completion:)])
	    {
	        [strongDelegate transitionToNavigationControllerWithName:toControllerName completion:nil];
		}
	}];
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
