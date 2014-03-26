//
//  ContentContainerViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import <UIKit/UIKit.h>
#import "PWESNavigationDelegate.h"

@interface ContentContainerViewController : UIViewController <UIViewControllerTransitioningDelegate, PWESNavigationDelegate>
@property (nonatomic, assign) TransitionType transitionType;
- (void)showMenu;
@end
