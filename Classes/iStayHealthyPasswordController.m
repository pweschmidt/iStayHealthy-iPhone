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
#import <QuartzCore/QuartzCore.h>

@interface iStayHealthyPasswordController ()
- (void)start;
@end

@implementation iStayHealthyPasswordController
@synthesize passwordField = _passwordField;
@synthesize label = _label;
@synthesize versionLabel = _versionLabel;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize tabBarController = _tabBarController;
@synthesize passwordString = _passwordString;
@synthesize activityIndicator = _activityIndicator;

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
    [self.activityIndicator stopAnimating];
	int count = [records count];
    if (0 < count)
    {
        iStayHealthyRecord *masterRecord = (iStayHealthyRecord *)[records objectAtIndex:0];
        self.passwordString = masterRecord.Password;
    }
    else
    {//shouldn't really happen
        [self loadTabController];
    }
    
}

- (void)start
{
    [self.activityIndicator startAnimating];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"RefetchAllDatabaseData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(start) name:@"startLoading" object:nil];
    
    CGRect frame = CGRectMake(self.view.bounds.size.width/2 - 50, self.view.bounds.size.height/2-50, 100, 100);
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator.frame = frame;
    self.activityIndicator.layer.cornerRadius = 10;
    [self.view addSubview:self.activityIndicator];
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
    if (0 < records.count)
    {
        iStayHealthyRecord *masterRecord = (iStayHealthyRecord *)[records objectAtIndex:0];
        self.passwordString = masterRecord.Password;
    }
    else
    {//shouldn't really happen
        [self loadTabController];
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



@end
