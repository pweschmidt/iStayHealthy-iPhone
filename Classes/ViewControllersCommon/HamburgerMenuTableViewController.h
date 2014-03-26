//
//  HamburgerMenuTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseTableViewController.h"
#import "ContentNavigationController.h"
#import "PWESNavigationDelegate.h"

@interface HamburgerMenuTableViewController : BaseTableViewController
	<MFMailComposeViewControllerDelegate>
@property (nonatomic, weak) id <PWESNavigationDelegate> transitionDelegate;
@property (nonatomic, strong) NSString *currentController;
@end
