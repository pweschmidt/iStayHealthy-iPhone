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
        //	UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

	NSTimeInterval duration = [self transitionDuration:transitionContext];
	UIView *containerView = [transitionContext containerView];
    
    UIView *fromControllerView = [self viewForTransitioningContext:transitionContext isToController:NO];
    UIView *toControllerView = [self viewForTransitioningContext:transitionContext isToController:YES];

	containerView.backgroundColor = [UIColor lightGrayColor];
	if (kMenuTransition == self.transitionType)
	{
		fromControllerView.layer.transform = CATransform3DIdentity;
		fromControllerView.layer.position = CGPointMake(containerView.bounds.size.width / 2, containerView.bounds.size.height / 2);
		toControllerView.alpha = 0;
		toControllerView.frame = containerView.bounds;
		toControllerView.layer.transform = CATransform3DMakeScale(kEnlargeFactor, kEnlargeFactor, 1);
            //        [containerView addSubview:fromControllerView];
        [containerView addSubview:toControllerView];
            //        [containerView bringSubviewToFront:fromControllerView];
            //		[containerView insertSubview:toControllerView belowSubview:fromControllerView];
		[UIView animateWithDuration:duration animations: ^{
		    toControllerView.alpha = 1.0;
		    toControllerView.layer.transform = CATransform3DIdentity;
		    fromControllerView.layer.transform = CATransform3DMakeScale(kZoomFactor, kZoomFactor, 1.0);
		    CGFloat zoomedXOffset = containerView.bounds.size.width * 0.75 + fromControllerView.layer.bounds.size.width * kZoomFactor / 2;
		    fromControllerView.layer.position = CGPointMake(zoomedXOffset, fromControllerView.layer.position.y);
		    fromControllerView.alpha = 0.6;
                //		    [transitionContext finalFrameForViewController:fromController];
		} completion: ^(BOOL finished) {
		    [transitionContext completeTransition:finished];
		}];
	}
	else if (kControllerTransition == self.transitionType)
	{
		toControllerView.layer.transform = CATransform3DMakeScale(kZoomFactor, kZoomFactor, 1.0);
		CGFloat zoomedXOffset = containerView.bounds.size.width * 0.75 + fromControllerView.layer.bounds.size.width * kZoomFactor / 2;
		toControllerView.layer.position = CGPointMake(zoomedXOffset, fromControllerView.layer.position.y);
		toControllerView.alpha = 0.6;

		fromControllerView.alpha = 1.0;
		fromControllerView.layer.transform = CATransform3DIdentity;
        [containerView addSubview:fromControllerView];
//        [containerView addSubview:toControllerView];
//        [containerView bringSubviewToFront:toControllerView];
		[UIView animateWithDuration:duration animations: ^{
		    fromControllerView.alpha = 0.0;
		    fromControllerView.layer.transform = CATransform3DMakeScale(kEnlargeFactor, kEnlargeFactor, 1);
		    fromControllerView.frame = containerView.bounds;
		    toControllerView.layer.transform = CATransform3DIdentity;
		    toControllerView.layer.position = CGPointMake(containerView.bounds.size.width / 2, containerView.bounds.size.height / 2);
		    toControllerView.alpha = 1.0;
		} completion: ^(BOOL finished) {
		    fromControllerView.alpha = 1.0;
		    fromControllerView.layer.transform = CATransform3DIdentity;
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

@end
