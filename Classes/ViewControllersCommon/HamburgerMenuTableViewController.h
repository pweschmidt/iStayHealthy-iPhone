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

@protocol PWESContentMenuHandler;

@interface HamburgerMenuTableViewController : UITableViewController
    <MFMailComposeViewControllerDelegate>
@property (nonatomic, weak) id <PWESNavigationDelegate> transitionDelegate;
@property (nonatomic, strong) NSString *currentController;
@property (nonatomic, weak) id<PWESContentMenuHandler>menuHandler;
@end
