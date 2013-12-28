//
//  CEZoomAnimationController.m
//  TransitionsDemo
//
//  Created by Colin Eberhardt on 22/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CECardsAnimationController.h"

@implementation CECardsAnimationController

- (id)init
{
	self = [super init];
	if (self)
	{
		_animationStyle = CECardsAnimateBySlidingUp;
	}
	return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    if(self.reverse){
        [self executeReverseAnimation:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
    } else {
        [self executeForwardsAnimation:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
    }
    
}

-(void)executeForwardsAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];

    // the current from- view frame, which is also where the to- view will be
    CGRect frame = [transitionContext initialFrameForViewController:fromVC];
	
	// positions the to- view off screen, depending on the animation style
    CGRect offScreenFrame = frame;
	
	// to simulate springiness, we'll overshoot the final frame first before
	// we come to a complete rest
	CGRect intermediateFrame = frame;
	
	switch (self.animationStyle)
	{
		case CECardsAnimateBySlidingUp:
		{
			offScreenFrame =
			CGRectOffset(offScreenFrame, 0, offScreenFrame.size.height);
			
			intermediateFrame = CGRectOffset(frame, 0, -10);
			break;
		}
			
		case CECardsAnimateBySlidingDown:
		{
			offScreenFrame =
			CGRectOffset(offScreenFrame, 0, -offScreenFrame.size.height);
			
			intermediateFrame = CGRectOffset(frame, 0, 10);
			break;
		}

		case CECardsAnimateBySlidingLeft:
		{
			offScreenFrame =
			CGRectOffset(offScreenFrame, offScreenFrame.size.width, 0);
			
			intermediateFrame = CGRectOffset(frame, -10, 0);
			break;
		}
			
		case CECardsAnimateBySlidingRight:
		{
			offScreenFrame =
			CGRectOffset(offScreenFrame, -offScreenFrame.size.width, 0);
			
			intermediateFrame = CGRectOffset(frame, 10, 0);
			break;
		}
			
		default:
		{
			NSAssert(0, @"Invalid animationStyle %d", self.animationStyle);
			break;
		}
	}

    toView.frame = offScreenFrame;
    
    [containerView insertSubview:toView aboveSubview:fromView];
    
    CATransform3D t1 = [self firstTransform];
    CATransform3D t2 = [self secondTransformWithView:fromView];
    
    [UIView animateKeyframesWithDuration:self.duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        // push the from- view to the back
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.4f animations:^{
            fromView.layer.transform = t1;
            fromView.alpha = 0.6;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.2f relativeDuration:0.4f animations:^{
            fromView.layer.transform = t2;
        }];

        // slide the to- view in position depending on the animation style.
		// this is simulated with an intermediate frame since the original
		// implementation by Tope used a 'spring' animation, which does not
		// work with keyframes
        [UIView addKeyframeWithRelativeStartTime:0.6f relativeDuration:0.3f animations:^{
            toView.frame = intermediateFrame;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.9f relativeDuration:0.1f animations:^{
            toView.frame = frame;
        }];

    } completion:^(BOOL finished) {
		
		BOOL cancelled = [transitionContext transitionWasCancelled];
		
		if (cancelled)
		{
			[containerView insertSubview:fromView aboveSubview:toView];
		}
		
        [transitionContext completeTransition:!cancelled];
    }];
    
    
}

-(void)executeReverseAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];
    
    // positions the to- view behind the from- view
    CGRect frame = [transitionContext initialFrameForViewController:fromVC];
    toView.frame = frame;
    CATransform3D scale = CATransform3DIdentity;
    toView.layer.transform = CATransform3DScale(scale, 0.6, 0.6, 1);
    toView.alpha = 0.6;
    
    [containerView insertSubview:toView belowSubview:fromView];

	// determine where the from- view will exit
    CGRect frameOffScreen = frame;

	switch (self.animationStyle)
	{
		// We need to slide back down
		case CECardsAnimateBySlidingUp:
		{
			frameOffScreen =
			CGRectOffset(frameOffScreen, 0, frameOffScreen.size.height);
			break;
		}

		// We need to slide back up
		case CECardsAnimateBySlidingDown:
		{
			frameOffScreen =
			CGRectOffset(frameOffScreen, 0, -frameOffScreen.size.height);
			break;
		}

		// We need to slide rightwards
		case CECardsAnimateBySlidingLeft:
		{
			frameOffScreen =
			CGRectOffset(frameOffScreen, frameOffScreen.size.width, 0);
			break;
		}
			
		// We need to slide leftwards
		case CECardsAnimateBySlidingRight:
		{
			frameOffScreen =
			CGRectOffset(frameOffScreen, -frameOffScreen.size.width, 0);
			break;
		}
			
		default:
		{
			NSAssert(0, @"Invalid animationStyle %d", self.animationStyle);
			break;
		}
	}
    
    CATransform3D t1 = [self firstTransform];
    
    [UIView animateKeyframesWithDuration:self.duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{

        // push the from- view off the bottom of the screen
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
            fromView.frame = frameOffScreen;
        }];
        
        // animate the to- view into place
        [UIView addKeyframeWithRelativeStartTime:0.25f relativeDuration:0.5f animations:^{
            toView.layer.transform = t1;
            toView.alpha = 1.0;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75f relativeDuration:0.25f animations:^{
            toView.layer.transform = CATransform3DIdentity;
        }];
    } completion:^(BOOL finished) {
		
		BOOL cancelled = [transitionContext transitionWasCancelled];
		
		if (cancelled)
		{
			toView.layer.transform = CATransform3DIdentity;
            toView.alpha = 0.6;
			[containerView insertSubview:fromView aboveSubview:toView];
		}
		
        [transitionContext completeTransition:!cancelled];
    }];
}

-(CATransform3D)firstTransform{
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f * M_PI/180.0f, 1, 0, 0);
    return t1;
    
}

-(CATransform3D)secondTransformWithView:(UIView*)view{
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = [self firstTransform].m34;
    t2 = CATransform3DTranslate(t2, 0, view.frame.size.height*-0.08, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    return t2;
}

@end
