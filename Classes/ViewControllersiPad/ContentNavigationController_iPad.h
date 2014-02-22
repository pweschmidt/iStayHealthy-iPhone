//
//  ContentNavigationController_iPad.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/02/2014.
//
//

#import <UIKit/UIKit.h>

@interface ContentNavigationController_iPad : UINavigationController
- (void)transitionToNavigationControllerWithName:(NSString *)name;
- (void)rewindToPreviousController;
@end
