//
//  LoginViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "LoginViewController.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "GeneralSettings.h"
#import "UILabel+Standard.h"

@interface LoginViewController ()
@property (nonatomic, strong) NSString *password;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logoView.image = [UIImage imageNamed:@"icon_50_flat.png"];
    self.logoView.layer.cornerRadius = 5;

    self.titleLabel.text = @"iStayHealthy";
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = TEXTCOLOUR;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:24];

    self.copyrightLabel.backgroundColor = [UIColor clearColor];
    self.copyrightLabel.text = @"Peter Schmidt, 2013";
    self.copyrightLabel.textColor = TEXTCOLOUR;
    self.copyrightLabel.textAlignment = NSTextAlignmentCenter;
    self.copyrightLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12];

    self.versionLabel.text = [[[NSBundle mainBundle] infoDictionary]
                              objectForKey:@"CFBundleVersion"];
    self.versionLabel.textColor = TEXTCOLOUR;
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12];
    self.versionLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *forgottenLabel = [UILabel standardLabel];
    forgottenLabel.frame = self.forgottenButton.frame;
    forgottenLabel.text = NSLocalizedString(@"Forgot Password", nil);;
    forgottenLabel.backgroundColor = [UIColor clearColor];
    forgottenLabel.textColor = DARK_RED;
    [self.forgottenButton addSubview:forgottenLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)login:(id)sender
{
    
}


- (IBAction)requestNewPassword:(id)sender
{
    
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

#pragma mark - handle rotations (iPad only)
- (BOOL)shouldAutorotate
{
    if ([Utilities isIPad])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([Utilities isIPad])
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}


#pragma mark TextField Delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.password = textField.text;
}

@end
