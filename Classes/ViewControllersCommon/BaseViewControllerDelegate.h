//
//  BaseViewControllerDelegate.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import <Foundation/Foundation.h>

@protocol BaseViewControllerDelegate <NSObject>
- (void)registerObservers;
- (void)unregisterObservers;
- (void)reloadSQLData:(NSNotification *)notification;
- (void)startAnimation:(NSNotification *)notification;
- (void)stopAnimation:(NSNotification *)notification;
- (void)handleError:(NSNotification *)notification;
- (void)handleStoreChanged:(NSNotification *)notification;
@end
