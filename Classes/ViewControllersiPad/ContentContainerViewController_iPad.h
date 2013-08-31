//
//  ContentContainerViewController_iPad.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import <UIKit/UIKit.h>

@interface ContentContainerViewController_iPad : UIViewController
- (void)transitionToNavigationControllerWithName:(NSString *)name;
- (void)rewindToPreviousController;
@end
