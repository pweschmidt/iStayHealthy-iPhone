//
//  BasicViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 15/02/2013.
//
//

#import "BasicViewController.h"
#import "iStayHealthyAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "WebViewController.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    [self setUpLandscapeController];
    
    if (self.headerView)
    {
        CGRect adFrame = CGRectMake(20.0, 1.0, 280, 29);
        UIButton *addButton = [[UIButton alloc]initWithFrame:adFrame];
        [addButton setBackgroundColor:[UIColor clearColor]];
        [addButton addTarget:self action:@selector(loadURL) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[Utilities bannerImageFromLocale]];
        
        if (nil != imageView)
        {
            [addButton addSubview:imageView];
        }
        
        [self.headerView addSubview:addButton];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"RefetchAllDatabaseData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseAndReload:) name:@"ParseResultsFromURL"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(start)
                                                 name:@"startAnimation"
                                               object:nil];
    
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)setUpLandscapeController
{
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    StatusViewControllerLandscape *landscape = nil;
    if (height < 568)
    {
        landscape = [[StatusViewControllerLandscape alloc]initWithNibName:@"StatusViewControllerLandscape"
                                                                   bundle:nil];
    }
    else
    {
        landscape = [[StatusViewControllerLandscape alloc]initWithNibName:@"StatusViewControllerLandscape_iPhone5"
                                                                   bundle:nil];
    }
    
	self.landscapeController = landscape;
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self performSelector:@selector(updateLandscapeView)
               withObject:nil
               afterDelay:0];
}

- (void)updateLandscapeView
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft && !self.isShowingLandscape)
	{
        [self presentModalViewController:self.landscapeController animated:YES];
        self.isShowingLandscape = YES;
    }
    else if(deviceOrientation == UIDeviceOrientationLandscapeRight && !self.isShowingLandscape){
        [self presentModalViewController:self.landscapeController animated:YES];
        self.isShowingLandscape = YES;
        
    }
	else if (deviceOrientation == UIDeviceOrientationPortrait && self.isShowingLandscape)
	{
        [self dismissModalViewControllerAnimated:YES];
        self.isShowingLandscape = NO;
    }
    else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown && self.isShowingLandscape){
        [self dismissModalViewControllerAnimated:YES];
        self.isShowingLandscape = NO;
    }
}

#ifdef __IPHONE_6_0
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
#endif



#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}
#endif


- (void)loadURL
{
    NSString *url = [Utilities urlStringFromLocale];
    NSString *title = [Utilities titleFromLocale];
    
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:url withTitle:title];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)gotoPOZ
{
    NSString *url = @"http://www.poz.com";
    NSString *title = @"POZ Magazine";
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:url withTitle:title];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
    
}


@end
