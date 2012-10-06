//
//  InfoDetailTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoDetailTableViewController.h"
#import "FAQDetailCell.h"
#import "WebViewController.h"
#import "UINavigationBar-Button.h"

@implementation InfoDetailTableViewController
@synthesize faqList = _faqList;
@synthesize headerLabel = _headerLabel;
@synthesize adButton = _adButton;
@synthesize bannerButton = _bannerButton;

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
//    self.navigationItem.title = NSLocalizedString(@"Glossary", @"Glossary");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"FAQ" ofType:@"plist"];
	NSMutableArray *tmpMedList = [[NSMutableArray alloc]initWithContentsOfFile:path];
    self.faqList = tmpMedList;
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
    //    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSString *urlAddress = NSLocalizedString(@"BannerURL", @"BannerURL");
    /*
     if ([language isEqualToString:@"de"]) {
     urlAddress = @"http://www.aidshilfe.de";
     }
     */
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:urlAddress withTitle:NSLocalizedString(@"POZ Magazine", @"POZ Magazine")];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}

- (IBAction)loadAd:(id)sender
{
	NSString *urlAddress = NSLocalizedString(@"AdURL", @"AdURL");
    /*
     if ([language isEqualToString:@"de"]) {
     urlAddress = @"http://www.aidshilfe.de";
     }
     */
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
    self.faqList = nil;
    [super viewDidUnload];
}
#endif

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.faqList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSArray *currentFAQList = (NSArray *)[self.faqList objectAtIndex:section];
    return (NSString *)[currentFAQList objectAtIndex:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    FAQDetailCell *cell = (FAQDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[FAQDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSArray *faqItem = (NSArray *)[self.faqList objectAtIndex:indexPath.section];
    cell.explanationView.text = (NSString *)[faqItem objectAtIndex:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return (UITableViewCell *)cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
