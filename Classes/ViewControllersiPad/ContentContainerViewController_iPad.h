//
//  ContentContainerViewController_iPad.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import <UIKit/UIKit.h>
#import "PWESNavigationDelegate.h"

@interface ContentContainerViewController_iPad : UIViewController <UIViewControllerTransitioningDelegate, PWESNavigationDelegate, UIAlertViewDelegate>
@property (nonatomic, assign) TransitionType transitionType;
- (void)showMenu;
- (void)hideMenu;
@end
