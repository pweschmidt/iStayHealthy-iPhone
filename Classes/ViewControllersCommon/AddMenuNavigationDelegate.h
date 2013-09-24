//
//  AddMenuNavigationDelegate.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 24/09/2013.
//
//

#import <Foundation/Foundation.h>

@protocol AddMenuNavigationDelegate <NSObject>
- (void)moveToNavigationControllerWithName:(NSString *)name;
@end
