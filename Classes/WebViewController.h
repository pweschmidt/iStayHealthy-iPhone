//
//  WebViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 12/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>{
    UIActivityIndicatorView *activityIndicatorView;
    IBOutlet UIWebView *webView;
    IBOutlet UIToolbar *toolBar;
    NSURL *url;
    NSString *webNavtitle;
}
@property (nonatomic, assign) NSString *webNavtitle;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
- (IBAction) goBack:(id) sender;
- (IBAction) goForward:(id) sender;
- (IBAction) gotoAddress:(id)sender forURL:(NSURL *)url;
- (IBAction) done:				(id) sender;
- (id)initWithURLString:(NSString *)urlString withTitle:(NSString *)navTitle;
@end
