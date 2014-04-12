//
//  PWESNavigationDelegate.h
//  PWESCustomTransitions
//
//  Created by Peter Schmidt on 22/03/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol PWESNavigationDelegate <NSObject>
- (void)changeTransitionType:(TransitionType)transitionType;
- (void)transitionToNavigationControllerWithName:(NSString *)name
                                      completion:(finishBlock)completion;

@end
