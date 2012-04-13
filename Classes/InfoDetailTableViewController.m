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

@implementation InfoDetailTableViewController
@synthesize faqList, headerLabel, adButton, bannerButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
//    [faqList release];
//    headerLabel = nil;
    self.headerLabel = nil;
    self.adButton = nil;
    self.bannerButton = nil;
    self.faqList = nil;
    [super dealloc];
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
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)] autorelease];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"FAQ" ofType:@"plist"];
	NSMutableArray *tmpMedList = [[NSMutableArray alloc]initWithContentsOfFile:path];
    self.faqList = tmpMedList;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.headerLabel.text = [NSString stringWithFormat:@"iStayHealthy version %@",version];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        CGRect pozFrame = CGRectMake(CGRectGetMinX(navBar.bounds) + 70.0, CGRectGetMinY(navBar.bounds)+7, 180, 29);
        UIButton *pozButton = [[[UIButton alloc]initWithFrame:pozFrame]autorelease];
        [pozButton setBackgroundColor:[UIColor clearColor]];
        [pozButton setImage:[UIImage imageNamed:@"gloassarynavbar.png"] forState:UIControlStateNormal];
        [pozButton addTarget:self action:@selector(gotoPOZ) forControlEvents:UIControlEventTouchUpInside];
        [navBar addSubview:pozButton];
    }

    [tmpMedList release];
}
/**
 */
- (void)gotoPOZ{
    NSString *url = @"http://www.poz.com";
    NSString *title = @"POZ Magazine";
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:url withTitle:title];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
    [webViewController release];
    [navigationController release];    
    
}


/**
 loads the Webview
 */
- (IBAction)loadWebView:(id)sender{
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
    [webViewController release];
    [navigationController release];
}

- (IBAction)loadAd:(id)sender{
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
    [webViewController release];
    [navigationController release];
}


/**
 return to parent root controller
 */
- (IBAction) done:	(id) sender{
	[self dismissModalViewControllerAnimated:YES];    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

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
    if (cell == nil) {
        cell = [[[FAQDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSArray *faqItem = (NSArray *)[self.faqList objectAtIndex:indexPath.section];
    cell.explanationView.text = (NSString *)[faqItem objectAtIndex:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return (UITableViewCell *)cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
