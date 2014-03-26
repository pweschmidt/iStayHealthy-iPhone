//
//  PWESSlideTransition.m
//  PWESCustomTransitions
//
//  Created by Peter Schmidt on 22/03/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import "PWESSlideTransition.h"
#import "Constants.h"

#define kSlideLength 100

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
	UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	NSTimeInterval duration = [self transitionDuration:transitionContext];

	CGRect endContentFrame = CGRectZero;
	CGRect transformedEndFrame = CGRectZero;
	CGRect transformedMenuFrame = CGRectZero;

	if (kMenuTransition == self.transitionType)
	{
		toController.view.alpha = 0.0;
		transformedMenuFrame = [[transitionContext containerView]
		                        convertRect:CGRectMake(0, 0, CGRectGetWidth(fromController.view.bounds), CGRectGetHeight(fromController.view.bounds)) fromView:fromController.view];
		toController.view.frame = transformedMenuFrame;
		endContentFrame = CGRectMake(kSlideLength, 0, CGRectGetWidth(fromController.view.bounds), CGRectGetHeight(fromController.view.bounds));
		transformedEndFrame = [[transitionContext containerView] convertRect:endContentFrame fromView:fromController.view];

		[containerView insertSubview:toController.view belowSubview:fromController.view];

		[UIView animateWithDuration:duration animations: ^{
		    toController.view.alpha = 1.0;
		    fromController.view.frame = transformedEndFrame;
		} completion: ^(BOOL finished) {
		    [transitionContext completeTransition:finished];
		}];
	}
	else
	{
		fromController.view.alpha = 1.0;
		transformedMenuFrame = [[transitionContext containerView] convertRect:CGRectMake(0, 0, CGRectGetWidth(fromController.view.bounds), CGRectGetHeight(fromController.view.bounds)) fromView:fromController.view];

		endContentFrame = CGRectMake(0, 0, CGRectGetWidth(toController.view.bounds), CGRectGetHeight(toController.view.bounds));
		transformedEndFrame = [[transitionContext containerView] convertRect:endContentFrame fromView:toController.view];

		[UIView animateWithDuration:duration animations: ^{
		    toController.view.frame = transformedEndFrame;
		    fromController.view.alpha = 0.0;
		} completion: ^(BOOL finished) {
		    [fromController.view removeFromSuperview];
		    [toController.view removeFromSuperview];
		    [transitionContext completeTransition:finished];
		}];
	}
}

- (void)logFramesAndOrientationForTransition:(id <UIViewControllerContextTransitioning> )transitionContext
{
	UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

	UIView *containerView = [transitionContext containerView];

	CGRect containerFrame = containerView.frame;
	CGRect containerBounds = containerView.bounds;

	CGRect fromFrame = fromController.view.frame;
	CGRect fromBounds = fromController.view.bounds;

	CGRect toFrame = toController.view.frame;
	CGRect toBounds = toController.view.bounds;

	NSLog(@"Container Frame = %@ ", NSStringFromCGRect(containerFrame));
	NSLog(@"Container Bounds = %@ ", NSStringFromCGRect(containerBounds));
	NSLog(@"From Frame = %@ ", NSStringFromCGRect(fromFrame));
	NSLog(@"From Bounds = %@ ", NSStringFromCGRect(fromBounds));
	NSLog(@"To Frame = %@ ", NSStringFromCGRect(toFrame));
	NSLog(@"To Bounds = %@ ", NSStringFromCGRect(toBounds));
}

@end
