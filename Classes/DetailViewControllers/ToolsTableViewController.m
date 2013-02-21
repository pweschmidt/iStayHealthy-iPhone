//
//  ToolsTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 09/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ToolsTableViewController.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "NSArray-Set.h"
#import "Utilities.h"
#import "iStayHealthyAppDelegate.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "KeychainHandler.h"

@interface ToolsTableViewController ()
@property (nonatomic, strong) NSString *password;
@property BOOL isPasswordEnabled;
@property BOOL firstIsSet;
@property BOOL secondIsSet;
@property BOOL isConsistent;
@property (nonatomic, strong) NSString *firstPassword;
@property (nonatomic, strong) NSString *secondPassword;
@property (nonatomic, strong) UISwitch *passwordSwitch;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *passConfirmField;
@property (nonatomic, strong) UIImageView *firstRightView;
@property (nonatomic, strong) UIImageView *firstWrongView;
@property (nonatomic, strong) UIImageView *secondRightView;
@property (nonatomic, strong) UIImageView *secondWrongView;
//- (NSString *)passwordFromMasterRecord;
@end

@implementation ToolsTableViewController
/**
 dealloc
 */


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.title = NSLocalizedString(@"Password", @"Password");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];
    /*
    if (self.isPasswordEnabled)
    {
        self.password = [self passwordFromMasterRecord];
        if (!self.password)
        {
            self.isPasswordEnabled = NO;
            [defaults setBool:self.isPasswordEnabled forKey:kIsPasswordEnabled];
            [defaults synchronize];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Not Found"
                                                            message:@"Please reset your password"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }    
     */
}

/*
- (NSString *)passwordFromMasterRecord
{
    self.masterRecord = nil;
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
    {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"Error Loading Data",nil)
							  message:[NSString stringWithFormat:NSLocalizedString(@"Error was %@, quitting.", @"Error was %@, quitting"), [error localizedDescription]]
							  delegate:self
							  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
							  otherButtonTitles:nil];
		[alert show];
	}
	NSArray *records = [self.fetchedResultsController fetchedObjects];
    for (iStayHealthyRecord *record in records)
    {
        NSString *password = record.Password;
        if (nil != password)
        {
            if (![password isEqualToString:@""] && password.length != 0)
            {
                self.masterRecord = record;
                return record.Password;
            }
        }
    }
    return nil;
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.firstIsSet = NO;
    self.secondIsSet = NO;
    self.isConsistent = NO;
}

/**
 dismiss view without saving
 @id
 */
- (IBAction) done: (id) sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.firstIsSet && self.secondIsSet && self.isConsistent && self.isPasswordEnabled)
    {
        NSUInteger hash = [self.password hash];
        NSString *encodedHash = [KeychainHandler securedSHA256DigestHashForPIN:hash];
        if ([KeychainHandler createKeychainValue:encodedHash forIdentifier:kIsPasswordEnabled])
        {
            [defaults setBool:YES forKey:kIsPasswordEnabled];
            UIAlertView *isDone = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password", @"Password") message:NSLocalizedString(@"PasswordSet", @"PasswordSet") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [isDone show];
            
        }
        else
        {
            [defaults setBool:NO forKey:kIsPasswordEnabled];
        }
    }
    else
    {
        [defaults setBool:NO forKey:kIsPasswordEnabled];
    }
//    [defaults setBool:YES forKey:kPasswordTransferred];
    [defaults synchronize];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) switchPasswordEnabling:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.passwordSwitch.on)
    {
        [defaults setBool:YES forKey:kIsPasswordEnabled];
        self.isPasswordEnabled = YES;
    }
    else
    {
        [defaults setBool:NO forKey:kIsPasswordEnabled];
        self.isPasswordEnabled = NO;
    }
    [defaults synchronize];
    [self.tableView reloadData];    
}


/**
 responder to textfield input
 @textField
 @return BOOL
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

/**
 changes the text colour to black once we start editing
 @textField
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setSecureTextEntry:YES];
	textField.textColor = [UIColor blackColor];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField setSecureTextEntry:TRUE];
    if (20 == textField.tag && self.secondIsSet && !self.isConsistent)
    {
        self.secondRightView.hidden = YES;
        self.secondWrongView.hidden = YES;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    int tag = textField.tag;
    switch (tag)
    {
        case 10:
            if (4 > [textField.text length])
            {
                self.passwordField.text = NSLocalizedString(@"Password too short", @"Password too short");
                self.passwordField.textColor = DARK_RED;
                self.passwordField.secureTextEntry = NO;
                self.firstWrongView.hidden = NO;
            }
            else
            {
                self.firstPassword = textField.text;
                self.firstIsSet = YES;
                self.firstRightView.hidden = NO;
            }
            break;
        case 20:
            self.secondPassword = textField.text;
            self.secondIsSet = YES;
            break;
    }
    //check that passwords are consistent
    if (self.firstIsSet && self.secondIsSet)
    {
        if ([self.firstPassword isEqualToString:self.secondPassword])
        {
            self.isConsistent = YES;
            self.secondRightView.hidden = NO;
            self.password = self.firstPassword;
        }
        else
        {
            self.isConsistent = NO;
            self.passConfirmField.text = NSLocalizedString(@"Try Again", @"Try Again");
            self.passConfirmField.textColor = DARK_RED;
            self.passConfirmField.secureTextEntry = NO;
            self.secondWrongView.hidden = NO;
        }
    }
}

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.passwordSwitch = nil;
    self.passwordField = nil;
    self.passConfirmField = nil;
    self.firstPassword = nil;
    self.secondPassword = nil;
    self.firstRightView = nil;
    self.firstWrongView = nil;
    self.secondRightView = nil;
    self.secondWrongView = nil;
    [super viewDidUnload];
}
#endif

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    if (1 == section && self.isPasswordEnabled)
    {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    if (0 == indexPath.section)
    {
        NSString *identifier = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:identifier];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+12.0, 112.0, 22.0);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = TEXTCOLOUR;
        label.textAlignment = UITextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:15.0];

        CGRect frameSwitch = CGRectMake(215.0, 10.0, 94.0, 27.0);
        UISwitch *switchEnabled = [[UISwitch alloc] initWithFrame:frameSwitch];
        [switchEnabled addTarget:self action:@selector(switchPasswordEnabling:) forControlEvents:UIControlEventValueChanged];
        
        switchEnabled.onTintColor = TINTCOLOUR;
        
        cell.accessoryView = switchEnabled;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.passwordSwitch = switchEnabled;
        [self.passwordSwitch setOn:self.isPasswordEnabled];
        label.text = NSLocalizedString(@"Enable?", @"Enable?");
        [cell addSubview:label];
        return cell;
    }
    if (1 == indexPath.section)
    {
        if (self.isPasswordEnabled)
        {
            if (0 == indexPath.row)
            {
                NSString *identifier = @"firstPasswordCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:identifier];
                }
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+12.0, 112.0, 22.0);
                UILabel *label = [[UILabel alloc] initWithFrame:frame];
                label.textColor = TEXTCOLOUR;
                label.textAlignment = UITextAlignmentLeft;
                label.font = [UIFont systemFontOfSize:15.0];
                label.text = NSLocalizedString(@"Password", @"Password");
                [cell addSubview:label];
                
                CGRect textframe = CGRectMake(CGRectGetMinX(cell.bounds)+150.0, CGRectGetMinY(cell.bounds)+14.0, 120.0, 22.0);
                UITextField *field = [[UITextField alloc] initWithFrame:textframe];
                field.borderStyle = UITextBorderStyleNone;
                field.textColor = [UIColor lightGrayColor];
                field.textAlignment = UITextAlignmentLeft;
                field.font = [UIFont systemFontOfSize:15.0];
                field.backgroundColor = [UIColor whiteColor];
                field.autocorrectionType = UITextAutocorrectionTypeNo;
                field.keyboardType = UIKeyboardTypeDefault;
                field.returnKeyType = UIReturnKeyDone;
                field.clearsOnBeginEditing = YES;
                field.delegate = self;
                field.enabled = YES;
                [field setSecureTextEntry:NO];
                field.textColor = [UIColor darkGrayColor];
                field.text = NSLocalizedString(@"Enter Password", @"Enter Password");
                [cell addSubview:field];
                self.passwordField = field;
                self.passwordField.tag = 10;
                
                
                CGRect rightFrame = CGRectMake(CGRectGetMinX(cell.bounds) + 270.0, CGRectGetMinY(cell.bounds) + 14.0, 17.0, 17.0);
                UIImageView *firstView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.png"]];
                [firstView setFrame:rightFrame];
                [firstView setBackgroundColor:[UIColor clearColor]];
                self.firstRightView = firstView;
                self.firstRightView.hidden = YES;
                [cell addSubview:firstView];

                UIImageView *secondView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wrong.png"]];
                [secondView setFrame:rightFrame];
                [secondView setBackgroundColor:[UIColor clearColor]];
                self.firstWrongView = secondView;
                self.firstWrongView.hidden = YES;
                [cell addSubview:secondView];
                
                
                return cell;
            }
            else if(1 == indexPath.row)
            {
                NSString *identifier = @"secondPasswordCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:identifier];
                }
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+12.0, 112.0, 22.0);
                UILabel *label = [[UILabel alloc] initWithFrame:frame];
                label.textColor = TEXTCOLOUR;
                label.textAlignment = UITextAlignmentLeft;
                label.font = [UIFont systemFontOfSize:15.0];
                label.text = NSLocalizedString(@"Password", @"Password");
                [cell addSubview:label];
                label.text = NSLocalizedString(@"Confirm", @"Confirm");
                [cell addSubview:label];
                
                CGRect textframe = CGRectMake(CGRectGetMinX(cell.bounds)+150.0, CGRectGetMinY(cell.bounds)+14.0, 120.0, 22.0);
                UITextField *field = [[UITextField alloc] initWithFrame:textframe];
                field.borderStyle = UITextBorderStyleNone;
                field.textColor = [UIColor lightGrayColor];
                field.textAlignment = UITextAlignmentLeft;
                field.font = [UIFont systemFontOfSize:15.0];
                field.backgroundColor = [UIColor whiteColor];
                field.autocorrectionType = UITextAutocorrectionTypeNo;
                field.keyboardType = UIKeyboardTypeDefault;
                field.returnKeyType = UIReturnKeyDone;
                field.clearsOnBeginEditing = YES;
                field.delegate = self;
                field.enabled = YES;
                [field setSecureTextEntry:NO];
                field.textColor = [UIColor darkGrayColor];
                field.text = NSLocalizedString(@"Confirm Password", @"Confirm Password");
                [cell addSubview:field];
                self.passConfirmField = field;     
                self.passConfirmField.tag = 20;

                CGRect rightFrame = CGRectMake(CGRectGetMinX(cell.bounds) + 270.0, CGRectGetMinY(cell.bounds) + 14.0, 17.0, 17.0);
                UIImageView *firstView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.png"]];
                [firstView setFrame:rightFrame];
                [firstView setBackgroundColor:[UIColor clearColor]];
                self.secondRightView = firstView;
                self.secondRightView.hidden = YES;
                [cell addSubview:firstView];
                
                UIImageView *secondView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wrong.png"]];
                [secondView setFrame:rightFrame];
                [secondView setBackgroundColor:[UIColor clearColor]];
                self.secondWrongView = secondView;
                self.secondWrongView.hidden = YES;
                [cell addSubview:secondView];
                
                
                return cell;
            }
        }
    }
    
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


@end
