//
//  LoginViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
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
@end
