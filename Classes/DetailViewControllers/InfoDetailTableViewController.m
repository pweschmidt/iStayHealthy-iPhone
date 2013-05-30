//
//  InfoDetailTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoDetailTableViewController.h"
#import "WebViewController.h"
#import "UINavigationBar-Button.h"
#import "GeneralSettings.h"
#import "Utilities.h"
@implementation InfoDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.headerLabel.text = [NSString stringWithFormat:@"iStayHealthy version %@",version];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"Glossary" target:self selector:@selector(gotoPOZ)];
    }

}
/**
 */
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


/**
 loads the Webview
 */
- (IBAction)loadWebView:(id)sender
{
	NSString *urlAddress = NSLocalizedString(@"BannerURL", @"BannerURL");
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:urlAddress withTitle:NSLocalizedString(@"POZ Magazine", @"POZ Magazine")];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}

- (IBAction)loadAd:(id)sender
{
	NSString *urlAddress = NSLocalizedString(@"AdURL", @"AdURL");
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:urlAddress withTitle:NSLocalizedString(@"Gaydar.Net", @"Gaydar.net")];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}


/**
 return to parent root controller
 */
- (IBAction) done:	(id) sender
{
	[self dismissModalViewControllerAnimated:YES];    
}


#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.headerLabel = nil;
    self.headerLabel = nil;
    self.adButton = nil;
    self.bannerButton = nil;
    [super viewDidUnload];
}
#endif

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds)+20.0, CGRectGetMinY(cell.bounds)+12.0, 180.0, 22.0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = TEXTCOLOUR;
    label.textAlignment = UITextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15.0];
    switch (indexPath.row)
    {
        case 0:
            label.text = NSLocalizedString(@"General Info", nil);
            break;
        case 1:
            label.text = NSLocalizedString(@"Testing", nil);
            break;
        case 2:
            label.text = NSLocalizedString(@"Prevention", nil);
            break;
        case 3:
            label.text = NSLocalizedString(@"HIV Drugs", nil);
            break;
    }
    [cell addSubview:label];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = nil;
    NSString *title = nil;
    switch (indexPath.row)
    {
        case 0:
            urlString = [Utilities generalInfoURLFromLocale];
            title = NSLocalizedString(@"General Info", nil);
            break;
        case 1:
            urlString = [Utilities testingInfoURLFromLocale];
            title = NSLocalizedString(@"Testing", nil);
            break;
        case 2:
            urlString = [Utilities preventionURLFromLocale];
            title = NSLocalizedString(@"Prevention", nil);
            break;
        case 3:
            urlString = [Utilities medListURLFromLocale];
            title = NSLocalizedString(@"HIV Drugs", nil);
            break;
    }
    
    if (nil != urlString && nil != title)
    {
        WebViewController *webViewController = [[WebViewController alloc]initWithURLString:urlString withTitle:title];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
        UINavigationBar *navigationBar = [navigationController navigationBar];
        navigationBar.tintColor = [UIColor blackColor];
        [self presentModalViewController:navigationController animated:YES];
    }
}

@end
