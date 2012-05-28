//
//  WebViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 12/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController
@synthesize webView, activityIndicatorView, toolBar, url, webNavtitle;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURLString:(NSString *)urlString withTitle:(NSString *)navTitle{
    self = [super initWithNibName:@"WebViewController" bundle:nil];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
        self.webNavtitle = navTitle;
    }
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/**
 dismisses the view without saving
 @id 
 */
- (IBAction) done:(id)sender{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = self.webNavtitle;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)];

    CGRect titleFrame = CGRectMake(CGRectGetMinX(toolBar.bounds)+290.0, CGRectGetMinY(toolBar.bounds)+12.0, 20.0, 20.0);
    UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc]initWithFrame:titleFrame];
    actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    actView.hidesWhenStopped = YES;
    [self.toolBar addSubview:actView];
    self.webView.scalesPageToFit = YES;
    self.activityIndicatorView = actView;
	
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
	[self.webView loadRequest:requestObj];
}

- (void)viewDidUnload
{
    self.url = nil;
    self.webView = nil;
    self.activityIndicatorView = nil;
    self.toolBar = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
#ifdef APPDEBUG
    NSLog(@"Start Loading page");
#endif
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *URL = [request URL];	
		if ([[URL scheme] isEqualToString:@"http"]) {
			[self gotoAddress:nil forURL:URL];
		}	 
		return NO;
	}	
	return YES;   
}

-(IBAction) goBack:(id)sender {
	[self.webView goBack];
}

-(IBAction) goForward:(id)sender {
	[self.webView goForward];
}
-(IBAction)gotoAddress:(id) sender  forURL:(NSURL *)urlString{
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlString];
	
	[self.webView loadRequest:requestObj];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
#ifdef APPDEBUG
    NSLog(@"Start Loading page");
#endif
	[activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
#ifdef APPDEBUG
    NSLog(@"Stop Loading page");
#endif
	[activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
#ifdef APPDEBUG
    NSLog(@"Stop Loading page");
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Error Loading Data",@"Error Loading Data") 
                          message:[NSString stringWithFormat:NSLocalizedString(@"Error was %@, quitting.", @"Error was %@, quitting"), [error localizedDescription]] 
                          delegate:self 
                          cancelButtonTitle:NSLocalizedString(@"Ouch, Pooh",@"Ouch, Pooh") 
                          otherButtonTitles:nil];
    [alert show];
#endif
}


@end
