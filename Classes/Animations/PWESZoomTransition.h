//
//  PWESZoomTransition.h
//  PWESCustomTransitions
//
//  Created by Peter Schmidt on 01/03/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface PWESZoomTransition : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) TransitionType transitionType;
@end
