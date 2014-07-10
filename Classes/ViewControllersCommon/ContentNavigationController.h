//
//  ContentNavigationController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/08/2013.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ContentNavigationController : UINavigationController
- (void)transitionToNavigationControllerWithName:(NSString *)name;
- (void)showMenu;
- (void)hideMenu;
- (void)showMailController:(MFMailComposeViewController *)mailController;
- (void)hideMailController:(MFMailComposeViewController *)mailController;
@end
