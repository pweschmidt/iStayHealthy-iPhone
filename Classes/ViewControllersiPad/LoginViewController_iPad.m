//
//  LoginViewController_iPad.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import "LoginViewController_iPad.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "UILabel+Standard.h"
#import "KeychainHandler.h"
#import "ContainerViewController_iPad.h"

@interface LoginViewController_iPad ()
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UILabel *wrongPasswordLabel;
- (void)login:(id)sender;
- (void)requestNewPassword:(id)sender;
@end

@implementation LoginViewController_iPad

- (void)viewDidLoad
{
	[super viewDidLoad];
	if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
	{
		if (self.view.frame.size.width < self.view.frame.size.height)
		{
			self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width);
		}
	}
	CGRect frame = self.view.bounds;

	CGFloat xOffset = frame.size.width / 2 - 110;
	CGFloat yOffset = 200;
	UIImageView *logoView = [[UIImageView alloc]
	                         initWithImage:[UIImage imageNamed:@"icon_50_flat.png"]];
	logoView.layer.cornerRadius = 10;
	logoView.layer.masksToBounds = YES;
	logoView.frame = CGRectMake(xOffset - 60, yOffset, 50, 50);

	[self.view addSubview:logoView];

	UILabel *titleLabel = [UILabel standardLabel];
	titleLabel.frame = CGRectMake(xOffset, yOffset, 300, 50);
	titleLabel.text = @"iStayHealthy";
	titleLabel.textAlignment = NSTextAlignmentLeft;
	titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:45];
	[self.view addSubview:titleLabel];

	UILabel *versionLabel = [UILabel standardLabel];
	versionLabel.frame = CGRectMake(xOffset, yOffset + 60, 220, 20);
	versionLabel.text = [[[NSBundle mainBundle] infoDictionary]
	                     objectForKey:@"CFBundleShortVersionString"];
	versionLabel.textAlignment = NSTextAlignmentCenter;
	versionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
	[self.view addSubview:versionLabel];


	UILabel *copyrightLabel = [UILabel standardLabel];
	copyrightLabel.frame = CGRectMake(xOffset, yOffset + 85, 220, 20);
	copyrightLabel.backgroundColor = [UIColor clearColor];
	copyrightLabel.text = @"Peter Schmidt, 2014";
	copyrightLabel.textAlignment = NSTextAlignmentCenter;
	copyrightLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
	[self.view addSubview:copyrightLabel];

	UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset + 145, 280, 40)];
	passwordField.backgroundColor = [UIColor whiteColor];
	passwordField.delegate = self;
	passwordField.text = NSLocalizedString(@"Enter password", nil);
	passwordField.clearsOnBeginEditing = YES;
	passwordField.textColor = [UIColor darkGrayColor];
	passwordField.secureTextEntry = NO;
	[self.view addSubview:passwordField];

	UIButton *forgottonButton = [UIButton buttonWithType:UIButtonTypeCustom];
	forgottonButton.backgroundColor = [UIColor clearColor];
	forgottonButton.frame = CGRectMake(xOffset, yOffset + 175, 300, 44);
	UILabel *forgottenLabel = [UILabel standardLabel];
	forgottenLabel.frame = CGRectMake(0, 0, 300, 44);
	forgottenLabel.text = NSLocalizedString(@"Forgot Password", nil);
	forgottenLabel.backgroundColor = [UIColor clearColor];
	forgottenLabel.textColor = DARK_RED;
	[forgottonButton addTarget:self action:@selector(requestNewPassword:) forControlEvents:UIControlEventTouchUpInside];
	[forgottonButton addSubview:forgottenLabel];
	[self.view addSubview:forgottonButton];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)login:(id)sender
{
	if (nil == sender || ![sender isKindOfClass:[UITextField class]])
	{
		return;
	}
	UITextField *passwordField = (UITextField *)sender;
	NSString *suggestedPassword = passwordField.text;
	NSUInteger hash = [suggestedPassword hash];
	BOOL isValidated = NO;
	if ([KeychainHandler compareKeychainValueForMatchingPIN:hash])
	{
		isValidated = YES;
	}
	else if ([suggestedPassword caseInsensitiveCompare:kSecretKey] == NSOrderedSame)
	{
		isValidated = YES;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:NO forKey:kIsPasswordEnabled];
		[defaults synchronize];
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Reset", nil)
		                            message:NSLocalizedString(@"Please reset password", nil)
		                           delegate:self
		                  cancelButtonTitle:@"Ok"
		                  otherButtonTitles:nil] show];
	}
	if (isValidated)
	{
		if ([self.parentViewController isKindOfClass:[ContainerViewController_iPad class]])
		{
			ContainerViewController_iPad *container = (ContainerViewController_iPad *)self.parentViewController;
			if ([container respondsToSelector:@selector(transitionToContentController:)])
			{
				[container transitionToContentController:self];
			}
		}
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong Password", nil) message:NSLocalizedString(@"Wrong Password! Try again", @"Wrong Password! Try again") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
	passwordField.text = NSLocalizedString(@"Enter password", nil);
	passwordField.textColor = [UIColor darkGrayColor];
	passwordField.secureTextEntry = NO;
}

- (void)requestNewPassword:(id)sender
{
	if (![MFMailComposeViewController canSendMail])
	{
		return;
	}

	MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
	mail.navigationController.navigationBar.tintColor = [UIColor blackColor];
	NSArray *toRecipient = [NSArray arrayWithObjects:@"istayhealthy.app@gmail.com", nil];
	mail.mailComposeDelegate = self;
	[mail setToRecipients:toRecipient];
	[mail setSubject:@"I forgot my iStayHealthy password (iPhone)"];
	[self presentViewController:mail animated:YES completion: ^{
	}];
}

#pragma mark TextField Delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	textField.textColor = [UIColor blackColor];
	textField.secureTextEntry = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self login:textField];
	[textField resignFirstResponder];
}

#pragma mark Mail delegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion: ^{
	}];
}

@end
