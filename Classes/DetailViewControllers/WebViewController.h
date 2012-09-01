//
//  WebViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 12/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, strong) NSString *webNavtitle;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
- (IBAction) goBack:(id) sender;
- (IBAction) goForward:(id) sender;
- (IBAction) gotoAddress:(id)sender forURL:(NSURL *)url;
- (IBAction) done:				(id) sender;
- (id)initWithURLString:(NSString *)urlString withTitle:(NSString *)navTitle;
@end
