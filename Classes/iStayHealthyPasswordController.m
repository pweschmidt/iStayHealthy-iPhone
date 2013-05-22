//
//  iStayHealthyPasswordController.m
//  iStayHealthy
//
//  Created by peterschmidt on 06/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "iStayHealthyPasswordController.h"
#import "iStayHealthyTabBarController.h"
#import "iStayHealthyRecord.h"
#import "iStayHealthyAppDelegate.h"
#import "WebViewController.h"
#import "GeneralSettings.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "KeychainHandler.h"

@interface iStayHealthyPasswordController ()
//@property (nonatomic, strong) NSString * passwordString;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) iStayHealthyTabBarController *tabBarController;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property BOOL hasReloadedData;
@end

@implementation iStayHealthyPasswordController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData:)
                                                     name:@"RefetchAllDatabaseData"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(start)
                                                     name:@"startAnimation"
                                                   object:nil];
    }
    return self;
}

- (void)reloadData:(NSNotification *)note
{
#ifdef APPDEBUG
    NSLog(@"NewStatusViewController:reloadData");
#endif
    self.hasReloadedData = YES;
    [self.activityIndicator stopAnimating];
}

- (void)start
{
    if (![self.activityIndicator isAnimating] && !self.hasReloadedData)
    {
        [self.activityIndicator startAnimating];
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - Text Editing and Processing

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
    NSString *suggestedPassword = self.passwordField.text;
#ifdef APPDEBUG
    NSLog(@"stored password is %@",suggestedPassword);
#endif
    NSUInteger hash = [suggestedPassword hash];
    BOOL isValidated = NO;
    if ([KeychainHandler compareKeychainValueForMatchingPIN:hash])
    {
        isValidated = YES;
    }
    else if([suggestedPassword caseInsensitiveCompare:kSecretKey] == NSOrderedSame)
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
        [self loadTabController];
    }
    else
    {
        self.label.text = NSLocalizedString(@"Wrong Password! Try again", @"Wrong Password! Try again");
        self.label.textColor = DARK_RED;
        self.passwordField.text = @"";
    }
    self.passwordField.text = @"";
}


#ifdef __IPHONE_6_0
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}
#endif

/**
 changes the text colour to black once we start editing
 @textField
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
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





#pragma mark - View lifecycle
- (IBAction)testLoad:(id)sender
{
    [self loadTabController];
}


- (void)loadTabController
{
    iStayHealthyTabBarController *tmpBarController = 
    [[iStayHealthyTabBarController alloc]initWithNibName:nil bundle:nil];
    self.tabBarController = tmpBarController;
    tmpBarController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:tmpBarController animated:YES];
}

- (void)dismissTabBarController
{
    if (0 != self.tabBarController.view && 0 < [self.tabBarController.viewControllers count])
    {
        [self.tabBarController dismissModalViewControllerAnimated:NO];
    }
}

- (IBAction)sendMail:(id)sender
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
    [self presentModalViewController:mail animated:YES];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hasReloadedData = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPasswordEnabled = [defaults boolForKey:kIsPasswordEnabled];
    BOOL passwordIsTransferred = [defaults boolForKey:kPasswordTransferred];
    if (isPasswordEnabled && !passwordIsTransferred)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Reset", nil)
                                    message:NSLocalizedString(@"Empty Password", nil)
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        [defaults setBool:NO forKey:kIsPasswordEnabled];
        [defaults synchronize];
        [self loadTabController];
    }

    CGRect frame = CGRectMake(self.view.bounds.size.width/2 - 70, self.view.bounds.size.height/2-70, 140, 140);
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator.frame = frame;
    self.activityIndicator.layer.cornerRadius = 10;
    CGRect labelFrame = CGRectMake(15, 90, 100, 30);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = NSLocalizedString(@"Loading", "Loading");
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:12];
    [self.activityIndicator addSubview:label];
    [self.view addSubview:self.activityIndicator];
    
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *passwordFromSettings = (NSString *)[defaults objectForKey:kPassword];
    if (!passwordFromSettings)
    {
        self.passwordString = [self passwordFromMasterRecord];
    }
    else
    {
        self.passwordString = passwordFromSettings;
    }
    
    if (!self.passwordString)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:@"Your stored password appears to be empty. Please go into the app and recreate it." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self loadTabController];
    }
    else
    {
        if ([self.passwordString isEqualToString:@""] || 0 == self.passwordString.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:@"Your stored password appears to be empty. Please go into the app and recreate it." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [self loadTabController];
        }
    }
    
    */
    
    self.label.text = NSLocalizedString(@"Enter Password", @"Enter Password");
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"version %@",version];
    
    
    UILabel *forgotLabel = [[UILabel alloc] init];
    forgotLabel.frame = CGRectMake(self.forgotButton.bounds.origin.x, self.forgotButton.bounds.origin.y, self.forgotButton.bounds.size.width, self.forgotButton.bounds.size.height);
    forgotLabel.text = NSLocalizedString(@"Forgot Password", nil);
    forgotLabel.textColor = DARK_RED;
    forgotLabel.font = [UIFont boldSystemFontOfSize:12];
    forgotLabel.backgroundColor = [UIColor clearColor];
    [self.forgotButton addSubview:forgotLabel];
    
}

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.label = nil;
    self.passwordField = nil;
    self.versionLabel = nil;
}
#endif

#pragma mark -
#pragma mark Mail delegate
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
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"iStayHealthy E-mail"
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



@end
