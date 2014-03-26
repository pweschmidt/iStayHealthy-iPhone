//
//  PWESZoomTransition.m
//  PWESCustomTransitions
//
//  Created by Peter Schmidt on 01/03/2014.
//  Copyright (c) 2014 Peter Schmidt. All rights reserved.
//

#import "PWESZoomTransition.h"
#import "Constants.h"
#import "PWESUtils.h"

@interface PWESZoomTransition ()
{
	CGAffineTransform originalTransform;
	CGRect originalFrame;
	CGRect originalBounds;
}
@property (nonatomic, strong) NSString *toControllerName;
@end

@implementation PWESZoomTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning> )transitionContext
{
	return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning> )transitionContext
{
	UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

	NSTimeInterval duration = [self transitionDuration:transitionContext];
	UIView *containerView = [transitionContext containerView];

	containerView.backgroundColor = [UIColor lightGrayColor];
	if (kMenuTransition == self.transitionType)
	{
		fromController.view.layer.transform = CATransform3DIdentity;
		fromController.view.layer.position = CGPointMake(containerView.bounds.size.width / 2, containerView.bounds.size.height / 2);
		toController.view.alpha = 0;
		toController.view.frame = containerView.bounds;
		toController.view.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1);
		[containerView insertSubview:toController.view belowSubview:fromController.view];
		[UIView animateWithDuration:duration animations: ^{
		    toController.view.alpha = 1.0;
		    toController.view.layer.transform = CATransform3DIdentity;
		    fromController.view.layer.transform = CATransform3DMakeScale(kZoomFactor, kZoomFactor, 1.0);
		    fromController.view.layer.position = CGPointMake(containerView.bounds.size.width / 2 + fromController.view.layer.bounds.size.width * kZoomFactor / 2, fromController.view.layer.position.y);
		    [transitionContext finalFrameForViewController:fromController];
		} completion: ^(BOOL finished) {
		    [transitionContext completeTransition:finished];
		}];
	}
	else if (kControllerTransition == self.transitionType)
	{
		toController.view.layer.transform = CATransform3DMakeScale(kZoomFactor, kZoomFactor, 1.0);
		toController.view.layer.position = CGPointMake(containerView.bounds.size.width / 2 + fromController.view.layer.bounds.size.width * kZoomFactor / 2, fromController.view.layer.position.y);

		fromController.view.alpha = 1.0;
		fromController.view.layer.transform = CATransform3DIdentity;
		[UIView animateWithDuration:duration animations: ^{
		    fromController.view.alpha = 0.0;
		    fromController.view.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1);
		    fromController.view.frame = containerView.bounds;
		    toController.view.layer.transform = CATransform3DIdentity;
		    toController.view.layer.position = CGPointMake(containerView.bounds.size.width / 2, containerView.bounds.size.height / 2);
		} completion: ^(BOOL finished) {
		    fromController.view.alpha = 1.0;
		    fromController.view.layer.transform = CATransform3DIdentity;
		    [fromController.view removeFromSuperview];
		    [transitionContext completeTransition:finished];
		}];
	}
}

@end
