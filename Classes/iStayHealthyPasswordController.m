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

@interface iStayHealthyPasswordController ()
@property (nonatomic, strong) NSString * passwordString;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) iStayHealthyTabBarController *tabBarController;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property BOOL hasReloadedData;
- (NSString *)passwordFromMasterRecord;
@end

@implementation iStayHealthyPasswordController
@synthesize fetchedResultsController = fetchedResultsController_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)reloadData:(NSNotification*)note
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *passwordFromSettings = (NSString *)[defaults objectForKey:kPassword];
    if (!passwordFromSettings)
    {
        self.passwordString = [self passwordFromMasterRecord];
        if (!self.passwordString)
        {
            [self loadTabController];
        }
    }
    [self.activityIndicator stopAnimating];
}

- (void)start
{
    if (![self.activityIndicator isAnimating] && !self.hasReloadedData)
    {
        [self.activityIndicator startAnimating];
    }
}


#pragma mark - Text Editing and Processing

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
    NSString *suggestedPassword = self.passwordField.text;
#ifdef APPDEBUG
    NSLog(@"stored password is %@",self.passwordString);
#endif
    if ([self.passwordString isEqualToString:suggestedPassword] )
    {
        [self loadTabController];
    }
    else if (0 == self.passwordString.length || [self.passwordString isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Reset", nil)
                                                        message:NSLocalizedString(@"Empty Password", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
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

- (NSString *)passwordFromMasterRecord
{
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
        NSString *testPassword = record.Password;
        if (testPassword)
        {
            if (![testPassword isEqualToString:@""] && 0 < testPassword.length)
            {
                return testPassword;
            }
        }
    }
    return nil;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hasReloadedData = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"RefetchAllDatabaseData" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(start)
                                                 name:@"startAnimation" object:nil];

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
    
    
    
    self.label.text = NSLocalizedString(@"Enter Password", @"Enter Password");
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"version %@",version];
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
#pragma mark Table view delegate

/**
 this handles the fetching of the objects
 @return NSFetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController_ != nil) {
		return fetchedResultsController_;
	}
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = appDelegate.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"iStayHealthyRecord" inManagedObjectContext:context];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"Name" ascending:YES];
	NSArray *allDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:allDescriptors];
	
	[request setEntity:entity];
	
	NSFetchedResultsController *tmpFetchController = [[NSFetchedResultsController alloc]
													  initWithFetchRequest:request 
													  managedObjectContext:context 
													  sectionNameKeyPath:nil 
													  cacheName:nil];
	tmpFetchController.delegate = self;
	fetchedResultsController_ = tmpFetchController;
	
	return fetchedResultsController_;
	
}	

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	NSArray *objects = [self.fetchedResultsController fetchedObjects];
    if (nil == objects)
    {
        return;
    }
    if (0 == objects.count)
    {
        return;
    }
    iStayHealthyRecord *masterRecord = (iStayHealthyRecord *)[objects lastObject];
    self.passwordString = masterRecord.Password;
}


@end
