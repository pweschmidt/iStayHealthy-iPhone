//
//  ContentNavigationController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/08/2013.
//
//

#import <UIKit/UIKit.h>

@interface ContentNavigationController : UINavigationController
- (void)transitionToNavigationControllerWithName:(NSString *)name;
- (void)showMenu;
@end
