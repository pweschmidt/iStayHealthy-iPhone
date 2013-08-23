//
//  ContainerViewControllerDelegate.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/08/2013.
//
//

#import <Foundation/Foundation.h>

@protocol ContainerViewControllerDelegate <NSObject>
/**
 hide the menu view
 */
- (void)slideInHamburger;
/**
 show the menu view
 */
- (void)slideOutHamburger;

- (void)slideInAdder;
- (void)slideOutAdder;
@end
