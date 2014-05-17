//
//  SettingsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "SettingsTableViewController.h"
#import "UILabel+Standard.h"
#import "KeychainHandler.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"

@interface SettingsTableViewController ()
@property (nonatomic, strong) UISwitch *passwordSwitch;
@property (nonatomic, strong) NSMutableDictionary *contentViewsDictionary;
@property (nonatomic, strong) NSMutableDictionary *textViews;
@property (nonatomic, strong) NSMutableDictionary *passwordDictionary;
@property (nonatomic, strong) NSMutableArray *passwordSetArray;
@end

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.backgroundColor = DEFAULT_BACKGROUND;
	[self setTitleViewWithTitle:NSLocalizedString(@"Password", nil)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
	                                          initWithBarButtonSystemItem:UIBarButtonSystemItemDone
	                                                               target:self action:@selector(done:)];
	[self resetDictionaries];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL hasPassword = [[defaults objectForKey:kIsPasswordEnabled] boolValue];

	UISwitch *passwordSwitch = [[UISwitch alloc] init];
	[passwordSwitch setOn:hasPassword];
	[passwordSwitch addTarget:self action:@selector(changePasswordSettings:) forControlEvents:UIControlEventValueChanged];
	self.passwordSwitch = passwordSwitch;
}

- (void)changePasswordSettings:(id)sender
{
	[self resetDictionaries];
	[self.tableView reloadData];
}

- (void)resetDictionaries
{
	self.contentViewsDictionary = nil;
	self.textViews = nil;
	self.passwordDictionary = nil;
	self.contentViewsDictionary = [NSMutableDictionary dictionary];
	self.textViews = [NSMutableDictionary dictionary];
	self.passwordDictionary = [NSMutableDictionary dictionary];
}

- (void)done:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (!self.passwordSwitch.isOn)
	{
		[KeychainHandler deleteItemFromKeychainWithIdentifier:kIsPasswordEnabled];
		[defaults setBool:NO forKey:kIsPasswordEnabled];
		[defaults synchronize];
		UIAlertView *isDone = [[UIAlertView alloc]
		                       initWithTitle:NSLocalizedString(@"Password Disabled", @"Password Disabled")
		                                    message:NSLocalizedString(@"No Password", @"No Password")
		                                   delegate:self
		                          cancelButtonTitle:@"Ok"
		                          otherButtonTitles:nil];
		[isDone show];
		return;
	}
	if (2 != self.textViews.allKeys.count)
	{
		[KeychainHandler deleteItemFromKeychainWithIdentifier:kIsPasswordEnabled];
		[defaults setBool:NO forKey:kIsPasswordEnabled];
		[defaults synchronize];
		return;
	}
	UITextField *field = [self.textViews objectForKey:@(0)];
	if (![self checkPassword:field])
	{
		[KeychainHandler deleteItemFromKeychainWithIdentifier:kIsPasswordEnabled];
		[defaults setBool:NO forKey:kIsPasswordEnabled];
		[defaults synchronize];
		return;
	}
	NSString *password = field.text;
	NSUInteger hash = [password hash];
	NSString *encodedHash = [KeychainHandler securedSHA256DigestHashForPIN:hash];
	BOOL hasPassword = [[defaults objectForKey:kIsPasswordEnabled] boolValue];
	BOOL success = NO;
	if (hasPassword)
	{
		success = [KeychainHandler updateKeychainValue:encodedHash
		                                 forIdentifier:kIsPasswordEnabled];
	}
	else
	{
		[defaults setBool:YES forKey:kIsPasswordEnabled];
		success = [KeychainHandler createKeychainValue:encodedHash
		                                 forIdentifier:kIsPasswordEnabled];
	}

	if (success)
	{
		UIAlertView *isDone = [[UIAlertView alloc]
		                       initWithTitle:NSLocalizedString(@"Password", @"Password")
		                                    message:NSLocalizedString(@"PasswordSet", @"PasswordSet")
		                                   delegate:nil
		                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
		                          otherButtonTitles:nil];
		[isDone show];
	}
	else
	{
		UIAlertView *isDone = [[UIAlertView alloc]
		                       initWithTitle:NSLocalizedString(@"Password Error", nil)
		                                    message:NSLocalizedString(@"Password Problem", nil)
		                                   delegate:self
		                          cancelButtonTitle:@"Ok"
		                          otherButtonTitles:nil];
		[isDone show];
		[defaults setBool:NO forKey:kIsPasswordEnabled];
	}

	[defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.passwordSwitch.isOn)
	{
		return 2;
	}
	else
	{
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] init];
	headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
	UILabel *label = [[UILabel alloc]
	                  initWithFrame:CGRectMake(20, 10, 150, 20)];
	label.backgroundColor = [UIColor clearColor];
	label.text = NSLocalizedString(@"Enable?", @"Enable?");
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:15];
	self.passwordSwitch.frame = CGRectMake(180, 2, 80, 36);
	[headerView addSubview:label];
	[headerView addSubview:self.passwordSwitch];
	return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"PasswordCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
		                              reuseIdentifier:CellIdentifier];
	}
	[self configureCell:cell indexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
	NSInteger tag = indexPath.row;
	NSNumber *taggedViewNumber = [NSNumber numberWithInteger:tag];
	cell.contentView.backgroundColor = [UIColor clearColor];
	UIView *mainContentView = [self.contentViewsDictionary objectForKey:taggedViewNumber];
	if (nil == mainContentView)
	{
		mainContentView = [[UIView alloc] initWithFrame:cell.contentView.frame];
		mainContentView.backgroundColor = [UIColor whiteColor];
		[self.contentViewsDictionary setObject:mainContentView forKey:taggedViewNumber];
	}

	UILabel *label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	label.frame = CGRectMake(20, 0, 80, cell.contentView.frame.size.height);
	label.text = NSLocalizedString(@"Password", @"Password");
	label.textColor = TEXTCOLOUR;
	label.font = [UIFont systemFontOfSize:12];
	label.textAlignment = NSTextAlignmentLeft;
	label.numberOfLines = 0;
	label.lineBreakMode = NSLineBreakByWordWrapping;
	[mainContentView addSubview:label];
	[cell.contentView addSubview:mainContentView];

	UITextField *textField = [self.textViews objectForKey:taggedViewNumber];
	if (nil == textField)
	{
		textField = [[UITextField alloc] init];
		textField.backgroundColor = [UIColor whiteColor];
		textField.tag = [taggedViewNumber integerValue];
		textField.frame = CGRectMake(100, 0, cell.contentView.frame.size.width - 120, cell.contentView.frame.size.height);
		textField.delegate = self;
		textField.font = [UIFont systemFontOfSize:15];
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.returnKeyType = UIReturnKeyDone;
		textField.clearsOnBeginEditing = YES;
		textField.placeholder = (0 == tag) ? NSLocalizedString(@"Enter Password", nil) : NSLocalizedString(@"Confirm Password", nil);
		[self.textViews setObject:textField forKey:taggedViewNumber];
	}

	[cell.contentView addSubview:textField];
	[cell.contentView bringSubviewToFront:textField];
}

#pragma mark UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	textField.secureTextEntry = YES;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	textField.secureTextEntry = YES;
	textField.textColor = [UIColor blackColor];
	UIColor *backgroundColour = [UIColor colorWithRed:235.0f / 255.0f green:235.0f / 255.0f blue:235.0f / 255.0f alpha:0.8];

	[UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
	    for (NSNumber * tagFieldNumber in self.textViews.allKeys)
	    {
	        UIView *view = [self.contentViewsDictionary objectForKey:tagFieldNumber];
	        if (nil != view)
	        {
	            view.backgroundColor = backgroundColour;
			}
	        if (textField.tag != [tagFieldNumber integerValue])
	        {
	            UITextField *field = [self.textViews objectForKey:tagFieldNumber];
	            if (nil != field)
	            {
	                field.backgroundColor = backgroundColour;
				}
			}
		}
	} completion: ^(BOOL finished) {
	}];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
	NSNumber *taggedViewNumber = [NSNumber numberWithInteger:textField.tag];
	[self.passwordDictionary setObject:textField.text forKey:taggedViewNumber];
	[UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
	    for (NSNumber * tagFieldNumber in self.textViews.allKeys)
	    {
	        UIView *view = [self.contentViewsDictionary objectForKey:tagFieldNumber];
	        if (nil != view)
	        {
	            view.backgroundColor = [UIColor whiteColor];
	            view.alpha = 1.0;
			}
	        if (textField.tag != [tagFieldNumber integerValue])
	        {
	            UITextField *field = [self.textViews objectForKey:tagFieldNumber];
	            if (nil != field)
	            {
	                field.backgroundColor = [UIColor whiteColor];
	                field.alpha = 1.0;
				}
			}
		}
	} completion: ^(BOOL finished) {
	}];
}

- (BOOL)checkPassword:(UITextField *)textField
{
	if (4 > textField.text.length)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password too short", @"Password too short") message:NSLocalizedString(@"Try Again", @"Try Again") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		return NO;
	}

	NSInteger tag = (0 == textField.tag) ? 1 : 0;
	NSNumber *taggedViewNumber = [NSNumber numberWithInteger:tag];
	NSString *otherPassword = [self.passwordDictionary objectForKey:taggedViewNumber];

	if (nil == otherPassword || ![otherPassword isEqualToString:textField.text])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Passwords don't match", nil) message:NSLocalizedString(@"Try again", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
		[alert show];
		textField.text = @"";
		return NO;
	}
	return YES;
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
