//
//  CEZoomAnimationController.m
//  TransitionsDemo
//
//  Created by Colin Eberhardt on 22/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CECardsAnimationController.h"

@interface UIView (InsertSubviewIfPossible)
/// Inserts the subview at index if possible. Else, adds subview to the end
- (void)insertSubview:(UIView *)subview atIndexIfPossible:(NSInteger)index;
@end

@implementation CECardsAnimationController

- (id)init
{
	self = [super init];
	if (self)
	{
		_animationStyle = CECardsAnimateBySlidingUp;
		_opacityOfPresentingViewAfterPresentation = 0.6f;
		_scaleOfPresentingViewAfterPresentation = 0.6f;
		
		_xInsetsOfPresentedFrame = 0;
		_yInsetsOfPresentedFrame = 0;
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
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromVC];

	// where we'd like to- view to end up
	CGRect toFrame =
	CGRectInset(fromFrame,
				self.xInsetsOfPresentedFrame,
				self.yInsetsOfPresentedFrame);
	
	// positions the to- view off screen, depending on the animation style
    CGRect offScreenFrame;
	
	// to simulate springiness, we'll overshoot the final frame first before
	// we come to a complete rest
	CGRect intermediateFrame;
	
	switch (self.animationStyle)
	{
		case CECardsAnimateBySlidingUp:
		{
			offScreenFrame =
			CGRectOffset(toFrame, 0, fromFrame.size.height);
			
			intermediateFrame =
			CGRectOffset(toFrame, 0, -10);
			
			break;
		}
			
		case CECardsAnimateBySlidingDown:
		{
			offScreenFrame =
			CGRectOffset(toFrame, 0, -fromFrame.size.height);
			
			intermediateFrame =
			CGRectOffset(toFrame, 0, 10);
			
			break;
		}
			
		case CECardsAnimateBySlidingLeft:
		{
			offScreenFrame =
			CGRectOffset(toFrame, fromFrame.size.width, 0);
			
			intermediateFrame =
			CGRectOffset(toFrame, -10, 0);
			
			break;
		}
			
		case CECardsAnimateBySlidingRight:
		{
			offScreenFrame =
			CGRectOffset(toFrame, -fromFrame.size.width, 0);
			
			intermediateFrame =
			CGRectOffset(toFrame, 10, 0);
			
			break;
		}
			
		default:
		{
			NSAssert(0, @"Invalid animationStyle %ld", (long)self.animationStyle);
			break;
		}
	}

    toView.frame = offScreenFrame;
	
	UIView *originalSuperViewOfFromView = fromView.superview;
	NSUInteger indexOfFromViewInOriginalSuperView =
	[originalSuperViewOfFromView.subviews indexOfObject:fromView];
	
	// iOS 8 doesn't add fromView to the containerView by default.
	// In fact, adding it seems to be problematic because it expects
	// the fromView to remain where it is when we finally dismiss the toView.
	// We're still going to add it for the animation here to work, but
	// we'll have to put it back where it was.
	if (containerView != originalSuperViewOfFromView)
	{
		[containerView addSubview:fromView];
	}
	
	[containerView insertSubview:toView aboveSubview:fromView];
	
    [UIView animateKeyframesWithDuration:self.duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        // push the from- view to the back
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.3f animations:^{
            fromView.layer.transform =
			[self fallBackwardsAndScaleDownSlightly];
			
			fromView.layer.zPosition = toView.layer.zPosition - 1000;
			
            fromView.alpha = self.opacityOfPresentingViewAfterPresentation;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.3f relativeDuration:0.4f animations:^{
            fromView.layer.transform =
			[self sendFurtherBackwardsAndALittleUpward:fromView];
        }];

        // slide the to- view in position depending on the animation style.
		// this is simulated with an intermediate frame since the original
		// implementation by Tope used a 'spring' animation, which does not
		// work with keyframes
        [UIView addKeyframeWithRelativeStartTime:0.6f relativeDuration:0.3f animations:^{
            toView.frame = intermediateFrame;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.9f relativeDuration:0.1f animations:^{
            toView.frame = toFrame;
        }];

    } completion:^(BOOL finished) {
		
		BOOL cancelled = [transitionContext transitionWasCancelled];
		
		if (cancelled)
		{
			[containerView insertSubview:fromView aboveSubview:toView];
		}
		else
		{
			// iOS 8 doesn't like fromView being added to the transition view
			// Move it back so we don't get into trouble
			if (originalSuperViewOfFromView != fromView.superview)
			{
				[originalSuperViewOfFromView insertSubview:fromView atIndexIfPossible:indexOfFromViewInOriginalSuperView];
			}
		}
		
		fromView.layer.zPosition = 0;
        [transitionContext completeTransition:!cancelled];
    }];
    
    
}

-(void)executeReverseAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];
    
    // positions the to- view behind the from- view
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromVC];
    
	// get the final size of the to-view, adjusted for the size we inseted
	// earlier during presentation
	CGRect toFrame =
	CGRectInset(fromFrame,
				-self.xInsetsOfPresentedFrame,
				-self.yInsetsOfPresentedFrame);
	
	toView.frame = toFrame;
	
	CATransform3D toViewOriginalTransformation =
	[self sendFurtherBackwardsAndALittleUpward:toView];
	
	toView.layer.transform = toViewOriginalTransformation;
    toView.alpha = self.opacityOfPresentingViewAfterPresentation;

	// Fix for iOS 8 where we need to put back toView to its original
	// after we put it in our containerView for animation
	UIView *originalSuperViewOfToView = toView.superview;
	NSUInteger indexOfToViewInOriginalSuperView =
	[originalSuperViewOfToView.subviews indexOfObject:toView];
	
    [containerView insertSubview:toView belowSubview:fromView];

	// determine where the from- view will exit to
    CGRect frameOffScreen;

	switch (self.animationStyle)
	{
		// We need to slide back down
		case CECardsAnimateBySlidingUp:
		{
			frameOffScreen =
			CGRectOffset(fromFrame, 0, toFrame.size.height);
			break;
		}

		// We need to slide back up
		case CECardsAnimateBySlidingDown:
		{
			frameOffScreen =
			CGRectOffset(fromFrame, 0, -toFrame.size.height);
			break;
		}

		// We need to slide rightwards
		case CECardsAnimateBySlidingLeft:
		{
			frameOffScreen =
			CGRectOffset(fromFrame, toFrame.size.width, 0);
			break;
		}
			
		// We need to slide leftwards
		case CECardsAnimateBySlidingRight:
		{
			frameOffScreen =
			CGRectOffset(fromFrame, -toFrame.size.width, 0);
			break;
		}
			
		default:
		{
			NSAssert(0, @"Invalid animationStyle %ld", (long)self.animationStyle);
			break;
		}
	}
    
    [UIView animateKeyframesWithDuration:self.duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{

        // push the from- view off the bottom of the screen
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
            fromView.frame = frameOffScreen;
        }];
        
        // animate the to- view into place
        [UIView addKeyframeWithRelativeStartTime:0.1f relativeDuration:0.6f animations:^{
            toView.layer.transform = [self fallBackwardsAndScaleDownSlightly];
            toView.alpha = 1.0;
			
			toView.layer.zPosition = fromView.layer.zPosition - 1000;
        }];
		
        [UIView addKeyframeWithRelativeStartTime:0.7f relativeDuration:0.3f animations:^{
            toView.layer.transform = CATransform3DIdentity;
        }];
    } completion:^(BOOL finished) {
		
		BOOL cancelled = [transitionContext transitionWasCancelled];
		
		if (cancelled)
		{
			toView.layer.transform = toViewOriginalTransformation;
            toView.alpha = self.opacityOfPresentingViewAfterPresentation;
			
			// iOS 8 doesn't like fromView being added to the transition view
			// Move it back so we don't get into trouble
			if (originalSuperViewOfToView != toView.superview)
			{
				[originalSuperViewOfToView insertSubview:toView atIndexIfPossible:indexOfToViewInOriginalSuperView];
			}
			else
			{
				[containerView insertSubview:fromView aboveSubview:toView];
			}
		}
		// iOS 8 doesn't like fromView being added to the transition view
		// Move it back so we don't get into trouble
		else if (originalSuperViewOfToView != toView.superview)
		{
			[originalSuperViewOfToView insertSubview:toView atIndexIfPossible:indexOfToViewInOriginalSuperView];
		}
		
		toView.layer.zPosition = 0;
        [transitionContext completeTransition:!cancelled];
    }];
}

#define INITIAL_TRANSFORMATION_SCALE 0.95
#define M34_TRANSFORMATION 1.0/-900

-(CATransform3D)fallBackwardsAndScaleDownSlightly
{
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = M34_TRANSFORMATION;
    t1 = CATransform3DScale(t1,
							INITIAL_TRANSFORMATION_SCALE,
							INITIAL_TRANSFORMATION_SCALE,
							1);
	
    t1 = CATransform3DRotate(t1, 15.0f * M_PI/180.0f, 1, 0, 0);
    return t1;
    
}

-(CATransform3D)sendFurtherBackwardsAndALittleUpward:(UIView*)view
{
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = M34_TRANSFORMATION;
    t2 = CATransform3DTranslate(t2, 0, view.frame.size.height*-0.08, 0);
    t2 = CATransform3DScale(t2,
							self.scaleOfPresentingViewAfterPresentation * INITIAL_TRANSFORMATION_SCALE,
							self.scaleOfPresentingViewAfterPresentation * INITIAL_TRANSFORMATION_SCALE,
							1);
    
    return t2;
}

@end


@implementation UIView (InsertSubviewIfPossible)

- (void)insertSubview:(UIView *)subview atIndexIfPossible:(NSInteger)index
{
	if (index <= [self.subviews count])
	{
		[self insertSubview:subview atIndex:index];
	}
	else
	{
		[self addSubview:subview];
	}
}

@end
