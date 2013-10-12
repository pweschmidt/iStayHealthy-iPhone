//
//  WebViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 12/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (id)initWithURLString:(NSString *)urlString withTitle:(NSString *)navTitle
{
    self = [super initWithNibName:@"WebViewController" bundle:nil];
    if (self)
    {
        _url = [NSURL URLWithString:urlString];
        _webNavtitle = navTitle;
    }
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = self.webNavtitle;

    CGRect titleFrame = CGRectMake(CGRectGetMinX(self.toolBar.bounds)+290.0, CGRectGetMinY(self.toolBar.bounds)+12.0, 20.0, 20.0);
    UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc]initWithFrame:titleFrame];
    actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    actView.hidesWhenStopped = YES;
    [self.toolBar addSubview:actView];
    self.webView.scalesPageToFit = YES;
    self.activityIndicatorView = actView;
	
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
	[self.webView loadRequest:requestObj];
}

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.url = nil;
    self.webView = nil;
    self.activityIndicatorView = nil;
    self.toolBar = nil;
    [super viewDidUnload];
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
#ifdef APPDEBUG
    NSLog(@"Start Loading page");
#endif
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
		NSURL *URL = [request URL];	
		if ([[URL scheme] isEqualToString:@"http"])
        {
			[self gotoAddress:nil forURL:URL];
		}	 
		return NO;
	}	
	return YES;   
}

-(IBAction) goBack:(id)sender
{
	[self.webView goBack];
}

-(IBAction) goForward:(id)sender
{
	[self.webView goForward];
}
-(IBAction)gotoAddress:(id) sender  forURL:(NSURL *)urlString
{
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlString];
	
	[self.webView loadRequest:requestObj];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
#ifdef APPDEBUG
    NSLog(@"Start Loading page");
#endif
	[self.activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
#ifdef APPDEBUG
    NSLog(@"Stop Loading page");
#endif
	[self.activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
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
