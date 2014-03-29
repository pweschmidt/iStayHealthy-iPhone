//
//  ContentContainerViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import <UIKit/UIKit.h>
#import "PWESNavigationDelegate.h"
#import <MessageUI/MessageUI.h>

@interface ContentContainerViewController : UIViewController <UIViewControllerTransitioningDelegate, PWESNavigationDelegate>
@property (nonatomic, assign) TransitionType transitionType;
- (void)showMenu;
- (void)showMailController:(MFMailComposeViewController *)mailController;
- (void)hideMailController:(MFMailComposeViewController *)mailController;
@end
