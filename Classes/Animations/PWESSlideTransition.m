//
//  PWESSlideTransition.m
//  PWESCustomTransitions
//
//  Created by Peter Schmidt on 22/03/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import "PWESSlideTransition.h"
#import "Constants.h"

#define kSlideLength 200

@interface PWESSlideTransition ()
@end

@implementation PWESSlideTransition

- (id)init
{
	self = [super init];
	if (nil != self)
	{
	}
	return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning> )transitionContext
{
	return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning> )transitionContext
{
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	NSTimeInterval duration = [self transitionDuration:transitionContext];

	CGRect endContentFrame = CGRectZero;
	CGRect transformedEndFrame = CGRectZero;
	CGRect transformedMenuFrame = CGRectZero;

    UIView *fromControllerView = [self viewForTransitioningContext:transitionContext isToController:NO];
    UIView *toControllerView = [self viewForTransitioningContext:transitionContext isToController:YES];

	if (kMenuTransition == self.transitionType)
	{
		toControllerView.alpha = 0.0;
		transformedMenuFrame = [[transitionContext containerView]
		                        convertRect:CGRectMake(0, 0, CGRectGetWidth(fromControllerView.bounds), CGRectGetHeight(fromControllerView.bounds)) fromView:fromControllerView];
		toControllerView.frame = transformedMenuFrame;
		endContentFrame = CGRectMake(kSlideLength, 0, CGRectGetWidth(fromControllerView.bounds), CGRectGetHeight(fromControllerView.bounds));
		transformedEndFrame = [[transitionContext containerView] convertRect:endContentFrame fromView:fromControllerView];

        [containerView addSubview:fromControllerView];
		[containerView insertSubview:toControllerView belowSubview:fromControllerView];

		[UIView animateWithDuration:duration animations: ^{
		    toControllerView.alpha = 1.0;
		    fromControllerView.frame = endContentFrame;
            CGRect finalFrame = [transitionContext finalFrameForViewController:fromController];
            finalFrame = endContentFrame;
		} completion: ^(BOOL finished) {
		    [transitionContext completeTransition:finished];
		}];
	}
	else
	{
		fromControllerView.alpha = 1.0;
            //		transformedMenuFrame = [[transitionContext containerView] convertRect:CGRectMake(0, 0, CGRectGetWidth(fromControllerView.bounds), CGRectGetHeight(fromControllerView.bounds)) fromView:fromControllerView];

            //		endContentFrame = CGRectMake(0, 0, CGRectGetWidth(toControllerView.bounds), CGRectGetHeight(toControllerView.bounds));
            //		transformedEndFrame = [[transitionContext containerView] convertRect:endContentFrame fromView:toControllerView];
        
        [containerView addSubview:fromControllerView];
        [containerView insertSubview:toControllerView belowSubview:fromControllerView];

		[UIView animateWithDuration:duration animations: ^{
		    toControllerView.frame = containerView.bounds;
		    fromControllerView.alpha = 0.0;
		} completion: ^(BOOL finished) {
		    [transitionContext completeTransition:finished];
		}];
	}
}

- (UIView *)viewForTransitioningContext:(id<UIViewControllerContextTransitioning>)transitionContext
                         isToController:(BOOL)isToController
{
    UIView *controllerView = nil;
    UIViewController *controller = nil;
    if (isToController)
    {
        controller = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        if ([transitionContext respondsToSelector:@selector(viewForKey:)])
        {
            controllerView = [transitionContext viewForKey:UITransitionContextToViewKey];
        }
        else
        {
            controllerView = controller.view;
        }
    }
    else
    {
        controller = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        if ([transitionContext respondsToSelector:@selector(viewForKey:)])
        {
            controllerView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        }
        else
        {
            controllerView = controller.view;
        }
    }
    
    return controllerView;
}

- (void)logFramesAndOrientationForTransition:(id <UIViewControllerContextTransitioning> )transitionContext
{
//	UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//	UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//
//	UIView *containerView = [transitionContext containerView];

#ifdef APPDEBUG
//	CGRect containerFrame = containerView.frame;
//	CGRect containerBounds = containerView.bounds;
//
//	CGRect fromFrame = fromControllerView.frame;
//	CGRect fromBounds = fromControllerView.bounds;
//
//	CGRect toFrame = toControllerView.frame;
//	CGRect toBounds = toControllerView.bounds;
//	NSLog(@"Container Frame = %@ ", NSStringFromCGRect(containerFrame));
//	NSLog(@"Container Bounds = %@ ", NSStringFromCGRect(containerBounds));
//	NSLog(@"From Frame = %@ ", NSStringFromCGRect(fromFrame));
//	NSLog(@"From Bounds = %@ ", NSStringFromCGRect(fromBounds));
//	NSLog(@"To Frame = %@ ", NSStringFromCGRect(toFrame));
//	NSLog(@"To Bounds = %@ ", NSStringFromCGRect(toBounds));
#endif
}

@end
